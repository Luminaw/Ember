defmodule EmberWeb.BlogController do
  use EmberWeb, :controller
  alias Ember.Generator

  def index(conn, params) do
    case get_format(conn) do
      "json" ->
        posts_dir = Application.app_dir(:ember, "priv/posts")
        posts = list_posts(posts_dir)
        json(conn, %{posts: posts})

      _ ->
        with {:ok, html} <- Generator.render_markdown("posts/index.md") do
          render(conn, :page, html: html)
        else
          {:error, error} ->
            conn
            |> put_status(500)
            |> render(:error, message: error.message)
        end
    end
  end

  def show(conn, %{"page" => page}) do
    case get_format(conn) do
      "json" ->
        case Generator.render_markdown("posts/#{page}.md") do
          {:ok, html} ->
            json(conn, %{content: html})
          {:error, error} ->
            conn
            |> put_status(:not_found)
            |> json(%{error: error.message})
        end

      _ ->
        with {:ok, html} <- Generator.render_markdown("posts/#{page}.md") do
          render(conn, :page, html: html)
        else
          {:error, _error} ->
            conn
            |> put_status(404)
            |> render(:error, message: "Page not found")
        end
    end
  end

  defp list_posts(content_dir) do
    File.ls!(content_dir)
    |> Enum.filter(&String.ends_with?(&1, ".md"))
    |> Enum.map(fn filename ->
      %{
        id: String.replace(filename, ".md", ""),
        title: filename |> String.replace(".md", "") |> String.capitalize(),
        path: "/blog/#{String.replace(filename, ".md", "")}"
      }
    end)
  end
end
