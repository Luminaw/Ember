defmodule EmberWeb.BlogLive.Index do
  use EmberWeb, :live_view
  alias Ember.Blog.Post

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :posts, Post.all_posts())}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto py-8">
      <h1 class="text-3xl font-bold mb-8">Blog Posts</h1>

      <div class="space-y-8">
        <%= for post <- @posts do %>
          <article class="border-b border-gray-200 pb-8">
            <h2 class="text-2xl font-semibold mb-2">
              <.link href={~p"/#{post.slug}"} class="hover:text-blue-600 transition-colors">
                <%= post.title %>
              </.link>
            </h2>
            <div class="text-gray-600 mb-4">
              <%= Calendar.strftime(post.date, "%B %d, %Y") %>
              <%= if post.tags != [] do %>
                •
                <%= for tag <- post.tags do %>
                  <span class="inline-block bg-gray-100 rounded-full px-3 py-1 text-sm font-semibold text-gray-700 mr-2">
                    #<%= tag %>
                  </span>
                <% end %>
              <% end %>
            </div>
            <p class="text-gray-700"><%= post.description %></p>
          </article>
        <% end %>
      </div>
    </div>
    """
  end
end
