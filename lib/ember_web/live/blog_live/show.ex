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
    <div class="container">
      <article class="blog-container">
        <h1 class="blog-title"><%= @post.title %></h1>

        <div class="blog-meta">
          <%= Calendar.strftime(@post.date, "%B %d, %Y") %>
          <%= if @post.tags != [] do %>
            •
            <%= for tag <- @post.tags do %>
              <span class="tag">
                #<%= tag %>
              </span>
            <% end %>
          <% end %>
        </div>

        <div class="blog-content">
          <%= raw Earmark.as_html!(@post.content) %>
        </div>

        <div class="mt-1">
          <button class="button" phx-click="navigate" phx-value-to="/">← Back to posts</button>
        </div>
      </article>
    </div>
    """
  end

  def handle_event("navigate", %{"to" => to}, socket) do
    {:noreply, push_navigate(socket, to: to)}
  end
end
