defmodule Ember.Blog.Tag do
  alias Ember.Blog.Post

  @doc """
  Returns a list of all unique tags from all posts.
  """
  def list_tags do
    Post.all_posts()
    |> Enum.flat_map(& &1.tags)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Returns all posts that have the given tag.
  """
  def posts_with_tag(tag) do
    Post.all_posts()
    |> Enum.filter(&(tag in &1.tags))
    |> Enum.sort_by(& &1.date, {:desc, Date})
  end
end
