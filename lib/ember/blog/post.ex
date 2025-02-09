defmodule Ember.Blog.Post do
  defstruct [:title, :description, :date, :slug, :content, :raw_content, tags: []]

  @posts_path "priv/posts/**/*.md"

  def all_posts do
    @posts_path
    |> Path.wildcard()
    |> Enum.map(&parse_file/1)
    |> Enum.sort_by(& &1.date, {:desc, Date})
  end

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
    IO.puts("Content starts with: #{String.slice(content, 0..10)}")
    content = String.replace(content, "\r\n", "\n")
    parts = String.split(content, ~r/^---\s*$/m, parts: 3)
    IO.inspect(parts, label: "Split parts")

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

  defp parse_tags(nil), do: []
  defp parse_tags(tags) when is_list(tags), do: tags
  defp parse_tags(_), do: []
end
