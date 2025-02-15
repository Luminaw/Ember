defmodule Ember.Blog.Post do
  defstruct [:title, :description, :date, :slug, :content, :raw_content, tags: []]

  @posts_path "priv/posts/**/*.md"

  def all_posts do
    @posts_path
    |> Path.wildcard()
    |> Enum.map(&parse_file/1)
    |> Enum.filter(&is_published?/1)
    |> Enum.sort_by(& &1.date, {:desc, Date})
  end

  def get_post_by_slug(slug) do
    all_posts()
    |> Enum.find(&(&1.slug == slug))
  end

  defp is_published?(%{date: date, time: time}) do
    post_datetime = get_post_datetime(date, time)
    DateTime.compare(post_datetime, DateTime.utc_now()) in [:lt, :eq]
  end
  defp is_published?(_), do: false

  defp parse_file(file_path) do
    file_path
    |> File.read!()
    |> parse_frontmatter()
    |> Map.put(:slug, file_path |> Path.basename(".md"))
  end

  defp parse_frontmatter(raw_content) do
    case split_frontmatter(raw_content) do
      {frontmatter, content} ->
        case YamlElixir.read_from_string(frontmatter) do
          {:ok, parsed} when is_map(parsed) ->
            %{
              title: parsed["title"] || "Untitled",
              description: parsed["description"] || "",
              date: parse_date(parsed["date"]),
              time: parsed["time"] || "00:00:00",
              tags: parse_tags(parsed["tags"]),
              content: String.trim(content),
              raw_content: raw_content
            }

          _ ->
            raise "Invalid YAML in frontmatter"
        end

      _ ->
        raise "Post must start with frontmatter between ---"
    end
  end

  defp split_frontmatter(content) do
    content = String.replace(content, "\r\n", "\n")
    parts = String.split(content, ~r/^---\s*$/m, parts: 3)

    case parts do
      ["", frontmatter, content] -> {frontmatter, content}
      [frontmatter, content, _] -> {frontmatter, content}
      _ -> nil
    end
  end

  defp parse_date(nil), do: nil
  defp parse_date(date_string) when is_binary(date_string) do
    Date.from_iso8601!(date_string)
  end

  defp get_post_datetime(date, time) when is_binary(time) do
    {:ok, datetime, _} = DateTime.from_iso8601("#{Date.to_iso8601(date)}T#{time}Z")
    datetime
  end
  defp get_post_datetime(date, _) do
    DateTime.new!(date, ~T[00:00:00], "Etc/UTC")
  end

  defp parse_tags(nil), do: []
  defp parse_tags(tags) when is_list(tags), do: tags
  defp parse_tags(_), do: []
end
