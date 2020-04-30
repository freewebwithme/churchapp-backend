defmodule ChurchWeb.YoutubeController do
  use ChurchWeb, :controller

  def index(conn, _params) do
    IO.puts("Printing from YoutubeController")
    send_resp(conn, 200, "")
  end
end
