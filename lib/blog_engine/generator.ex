defmodule Ember.Generator do
  alias Ember.Generator.Error
  require Logger

  # Add this function to sanitize paths
  defp ensure_safe_path(base_dir, path) do
    full_path = Path.expand(path, base_dir)
    if String.starts_with?(full_path, base_dir) do
      {:ok, full_path}
    else
      {:error, Error.new("Path traversal detected", :invalid_path, path)}
    end
  end

  def generate_blog(content_dir, output_dir, template_path \\ "../../templates/index.html") do
    with :ok <- ensure_directory(output_dir),
         {:ok, abs_content_dir} <- ensure_safe_path(File.cwd!(), content_dir),
         {:ok, _template} <- read_template(template_path) do

      current_datetime = DateTime.utc_now()

      File.ls!(abs_content_dir)
      |> Enum.filter(&String.ends_with?(&1, ".md"))
      |> Enum.filter(fn filename ->
        case get_post_datetime(Path.join(abs_content_dir, filename)) do
          {:ok, post_datetime} -> DateTime.compare(post_datetime, current_datetime) in [:lt, :eq]
          _ -> false
        end
      end)
      |> Task.async_stream(fn filename ->
        safe_filename = Path.basename(filename)
        filepath = Path.join(abs_content_dir, safe_filename)
        with {:ok, html} <- render_content(filepath, template_path),  # Pass template instead of path
             output_filename = String.replace(filename, ".md", ".html"),
             output_path = Path.join(output_dir, output_filename),
             :ok <- File.write(output_path, html) do
          {:ok, output_path}
        else
          {:error, reason} -> {:error, filename, reason}
        end
      end, max_concurrency: 4)  # Limit concurrent tasks
      |> Enum.to_list()
    end
  end

  defp get_post_datetime(filepath) do
    with {:ok, content} <- read_file(filepath),
         [frontmatter | _] <- String.split(content, "---\n", parts: 3),
         {:ok, parsed} <- YamlElixir.read_from_string(frontmatter),
         %{"date" => date_string} = parsed do

      # Handle different time formats
      time_string = Map.get(parsed, "time", "00:00:00")
      datetime_string = "#{date_string}T#{time_string}Z"
      Logger.debug("Parsed datetime: #{datetime_string}")

      case DateTime.from_iso8601(datetime_string) do
        {:ok, datetime, _offset} -> {:ok, datetime}
        _error ->
          # Fallback to midnight if only date is provided
          case Date.from_iso8601(date_string) do
            {:ok, date} -> {:ok, DateTime.new!(date, ~T[00:00:00], "Etc/UTC")}
            _error -> {:error, :invalid_datetime}
          end
      end
    else
      _ -> {:error, :invalid_datetime}
    end
  end

  def is_post_published?(filepath) do
    case get_post_datetime(filepath) do
      {:ok, post_datetime} ->
        DateTime.compare(post_datetime, DateTime.utc_now()) in [:lt, :eq]
      _ -> false
    end
  end

  def render_markdown(filepath) do
    posts_dir = Application.app_dir(:ember, "priv")
    with {:ok, safe_path} <- ensure_safe_path(posts_dir, filepath),
         true <- is_post_published?(safe_path) || {:error, :not_published},
         {:ok, content} <- read_file(safe_path),
         {:ok, processed_content} <- process_eex(content, safe_path),
         {:ok, html_content} <- markdown_to_html(processed_content, safe_path) do
      {:ok, html_content}
    end
  end

  def render_content(filepath, template_path) do  # Modified to accept template
    with {:ok, template} <- read_template(template_path),
         true <- is_post_published?(filepath) || {:error, :not_published},
         {:ok, content} <- read_file(filepath),
         {:ok, processed_content} <- process_eex(content, filepath),
         {:ok, html_content} <- markdown_to_html(processed_content, filepath) do
      {:ok, String.replace(template, "<div id=\"content\"></div>", html_content)}
    end
  end

  def list_published_posts(content_dir) do
    with {:ok, abs_content_dir} <- ensure_safe_path(File.cwd!(), content_dir) do
      File.ls!(abs_content_dir)
      |> Enum.filter(&String.ends_with?(&1, ".md"))
      |> Enum.filter(fn filename ->
        filepath = Path.join(abs_content_dir, filename)
        is_post_published?(filepath)
      end)
    end
  end

  defp read_file(path) do
    max_size = 5_000_000  # 5 MB
    case File.stat(path) do
      {:ok, %{size: size}} when size > max_size ->
        {:error, Error.new("File size too large", :file_size, path)}
      {:ok, _ } ->
        case File.read(path) do
          {:ok, content} -> {:ok, content}
          {:error, reason} ->
            {:error, Error.new("Failed to read file", reason, path)}
        end
      {:error, reason} ->
        {:error, Error.new("Failed to check file size", reason, path)}
    end
  end

  defp read_template(template_path) do
    with {:ok, safe_path} <- ensure_safe_path(__DIR__, template_path) do
      case File.read(safe_path) do
        {:ok, template} -> {:ok, template}
        {:error, reason} ->
          {:error, Error.new("Failed to read template", reason, safe_path)}
      end
    end
  end

    defp process_eex(content, filepath) do
    task = Task.async(fn ->
      try do
        {:ok, EEx.eval_string(content)}
      rescue
        e in EEx.SyntaxError ->
          {:error, Error.new("EEx syntax error: #{Exception.message(e)}", :eex_syntax, filepath)}
      end
    end)

    case Task.yield(task, 5000) || Task.shutdown(task) do
      {:ok, result} -> result
      nil -> {:error, Error.new("EEx evaluation timeout", :timeout, filepath)}
    end
  end

  defp markdown_to_html(content, filepath) do
    try do
      {
        :ok,
        content
        |> Earmark.as_html!()
        |> sanitize()
      }
    rescue
      e in Earmark.Error ->
        {:error, Error.new("Markdown parsing error: #{Exception.message(e)}", :markdown_syntax, filepath)}
    end
  end

  defp ensure_directory(dir) do
    case File.mkdir_p(dir) do
      :ok -> :ok
      {:error, reason} ->
{:error, Error.new("Failed to create directory", reason, dir)}
end
  end

  def sanitize(html) when is_binary(html) do
    HtmlSanitizeEx.basic_html(html)
  end

  def sanitize(nil), do: nil
end
