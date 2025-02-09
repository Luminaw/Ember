defmodule EmberWeb.BlogLive.Index do
  use EmberWeb, :live_view
  alias Ember.Blog.Post

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :posts, Post.all_posts())}
  end

  def render(assigns) do
    ~H"""
    <div class="blog-container">
      <h1 class="blog-title">Blog Posts</h1>

      <ul class="blog-list">
        <%= for post <- @posts do %>
          <li class="blog-list-item">
            <h2>
              <.link navigate={~p"/#{post.slug}"}>
                <%= post.title %>
              </.link>
            </h2>
            <div class="blog-meta">
              Posted on <%= Calendar.strftime(post.date, "%B %d, %Y") %>
            </div>
            <div class="blog-preview">
              <%= post.description %>
            </div>
            <div class="blog-tags">
              <%= for tag <- post.tags do %>
                <span class="tag"><%= tag %></span>
              <% end %>
            </div>
            <.link navigate={~p"/#{post.slug}"} class="read-more">
              Read more →
            </.link>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end
end
