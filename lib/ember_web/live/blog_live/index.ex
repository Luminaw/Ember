defmodule EmberWeb.BlogLive.Index do
  use EmberWeb, :live_view
  alias Ember.Blog.{Post, Tag}

  def mount(%{"tag" => tag}, _session, socket) do
    {:ok,
     socket
     |> assign(:posts, Tag.posts_with_tag(tag))
     |> assign(:tags, Tag.list_tags())
     |> assign(:selected_tag, tag)}
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:posts, Post.all_posts())
     |> assign(:tags, Tag.list_tags())
     |> assign(:selected_tag, nil)}
  end

  def handle_event("filter-tag", %{"tag" => tag}, socket) do
    {:noreply,
     socket
     |> assign(:selected_tag, tag)
     |> assign(:posts, Tag.posts_with_tag(tag))}
  end

  def handle_event("clear-filter", _, socket) do
    {:noreply,
     socket
     |> assign(:selected_tag, nil)
     |> assign(:posts, Post.all_posts())}
  end

  def render(assigns) do
    ~H"""
    <div class="blog-container">
      <h1 class="blog-title">Blog Posts</h1>

      <div class="tags-filter">
        <%= for tag <- @tags do %>
          <button
            class={"tag-button #{if @selected_tag == tag, do: "selected"}"}
            phx-click="filter-tag"
            phx-value-tag={tag}
          >
            #<%= tag %>
          </button>
        <% end %>
        <%= if @selected_tag do %>
          <button class="clear-filter" phx-click="clear-filter">
            Clear filter
          </button>
        <% end %>
      </div>

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
                <button
                  class={"tag-button #{if @selected_tag == tag, do: "selected"}"}
                  phx-click="filter-tag"
                  phx-value-tag={tag}
                >
                  #<%= tag %>
                </button>
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
