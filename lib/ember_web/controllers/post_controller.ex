defmodule EmberWeb.PostController do
  use EmberWeb, :controller
  alias Ember.Generator

  def show(conn, %{"id" => post_id}) do
    post_path = Path.join(["priv", "posts", "#{post_id}.md"])
    template_path = Path.join([Application.app_dir(:ember), "priv", "templates", "post.html"])

    case Generator.render_content(post_path, template_path) do
      {:ok, content} ->
        render(conn, :show, content: content)
      {:error, :not_published} ->
        conn
        |> put_status(:not_found)
        |> render(:not_found)
      {:error, _reason} ->
        conn
        |> put_status(:not_found)
        |> render(:not_found)
    end
  end
end
