defmodule EmberWeb.BlogHTML do
  use EmberWeb, :html

  embed_templates "blog_html/*"

  def page(assigns) do
    ~H"""
    <div class="blog-content">
      <%= raw(@html) %>
    </div>
    """
  end

  def error(assigns) do
    ~H"""
    <div class="error-content">
      <h1>Error</h1>
      <p><%= @message %></p>
    </div>
    """
  end
end
