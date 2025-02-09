defmodule EmberWeb.BlogLive.Show do
  use EmberWeb, :live_view
  alias Ember.Blog.Post

  def mount(%{"slug" => slug}, _session, socket) do
    case Post.get_post_by_slug(slug) do
      nil ->
        {:ok, socket
        |> put_flash(:error, "Post not found")
        |> redirect(to: ~p"/")}

      post ->
        {:ok, assign(socket, :post, post)}
    end
  end

  def render(assigns) do
    ~H"""
    <article class="max-w-4xl mx-auto py-8">
      <div class="mb-8">
        <.link href={~p"/"} class="text-blue-600 hover:text-blue-800">← Back to all posts</.link>
      </div>

      <h1 class="text-4xl font-bold mb-4"><%= @post.title %></h1>

      <div class="text-gray-600 mb-8">
        <%= Calendar.strftime(@post.date, "%B %d, %Y") %>
        <%= if @post.tags != [] do %>
          •
          <%= for tag <- @post.tags do %>
            <span class="inline-block bg-gray-100 rounded-full px-3 py-1 text-sm font-semibold text-gray-700 mr-2">
              #<%= tag %>
            </span>
          <% end %>
        <% end %>
      </div>

      <div class="prose prose-lg max-w-none">
        <%= raw Earmark.as_html!(@post.content) %>
      </div>
    </article>
    """
  end
end
