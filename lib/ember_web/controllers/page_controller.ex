defmodule EmberWeb.PageController do
  use EmberWeb, :controller
  alias Ember.Generator

  def home(conn, _params) do
    posts = Generator.list_published_posts("priv/posts")
    |> Enum.map(&String.replace(&1, ".md", ""))
    render(conn, :home, posts: posts)
  end
end
