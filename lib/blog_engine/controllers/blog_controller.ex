defmodule EmberWeb.BlogController do
  use Phoenix.Controller

  def index(conn, _params) do
    content_dir = Application.get_env(:ember, :content_dir)
    posts = list_posts(content_dir)
    json(conn, %{posts: posts})
  end

  def show(conn, %{"path" => path}) do
    content_dir = Application.get_env(:ember, :content_dir)
    file_path = Path.join(content_dir, "#{path}.md")

    case Ember.Generator.render_markdown(file_path) do
      {:ok, html} ->
        json(conn, %{content: html})
      {:error, error} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: error.message})
    end
  end

  defp list_posts(content_dir) do
    File.ls!(content_dir)
    |> Enum.filter(&String.ends_with?(&1, ".md"))
    |> Enum.map(fn filename ->
      %{
        id: String.replace(filename, ".md", ""),
        title: filename |> String.replace(".md", "") |> String.capitalize(),
        path: "/posts/#{String.replace(filename, ".md", "")}"
      }
    end)
  end
end
