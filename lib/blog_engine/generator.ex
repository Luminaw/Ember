defmodule Ember.Generator do
  alias Ember.Generator.Error

  def generate_blog(content_dir, output_dir, template_path \\ "../../templates/index.html") do
    with :ok <- ensure_directory(output_dir) do
      File.ls!(content_dir)
      |> Enum.filter(&String.ends_with?(&1, ".md"))
      |> Enum.map(fn filename ->
        filepath = Path.join(content_dir, filename)
        with {:ok, html} <- render_content(filepath, template_path),
             output_filename = String.replace(filename, ".md", ".html"),
             output_path = Path.join(output_dir, output_filename),
             :ok <- File.write(output_path, html) do
          {:ok, output_path}
        else
          {:error, reason} -> {:error, filename, reason}
        end
      end)
    end
  end

  def render_markdown(filepath) do
    posts_dir = Application.app_dir(:ember, "priv/posts")
    full_path = Path.join(posts_dir, filepath)

    with {:ok, content} <- read_file(full_path),
         {:ok, processed_content} <- process_eex(content, full_path),
         {:ok, html_content} <- markdown_to_html(processed_content, full_path) do
      {:ok, html_content}
    end
  end

  defp render_content(filepath, template_path) do
    with {:ok, content} <- read_file(filepath),
         {:ok, processed_content} <- process_eex(content, filepath),
         {:ok, html_content} <- markdown_to_html(processed_content, filepath),
         {:ok, template} <- read_template(template_path) do
      {:ok, String.replace(template, "<div id=\"content\"></div>", html_content)}
    end
  end

  defp read_file(path) do
    case File.read(path) do
      {:ok, content} -> {:ok, content}
      {:error, reason} ->
        {:error, Error.new("Failed to read file", reason, path)}
    end
  end

  defp read_template(template_path) do
    path = Path.join(__DIR__, template_path)
    case File.read(path) do
      {:ok, template} -> {:ok, template}
      {:error, reason} ->
        {:error, Error.new("Failed to read template", reason, path)}
    end
  end

  defp process_eex(content, filepath) do
    try do
      {:ok, EEx.eval_string(content)}
    rescue
      e in EEx.SyntaxError ->
        {:error, Error.new("EEx syntax error: #{Exception.message(e)}", :eex_syntax, filepath)}
    end
  end

  defp markdown_to_html(content, filepath) do
    try do
      {:ok, Earmark.as_html!(content)}
    rescue
      e in EarmarkParser.Error ->
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
end
