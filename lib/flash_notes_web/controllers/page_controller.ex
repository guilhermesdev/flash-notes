defmodule FlashNotesWeb.PageController do
  use FlashNotesWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
