defmodule ChurchWeb.YoutubeController do
  use ChurchWeb, :controller
  alias Church.Videos
  alias Church.Accounts

  @doc """
  This function get a request from https://pubsubhubbub.appspot.com/subscribe
  and return hub.challenge number to
  This way can confirm subscription.
  """
  def subscribe_confirm(conn, params) do
    IO.puts("Printing from YoutubeController")
    IO.inspect(params)
    %{"hub.challenge" => challenge} = params
    IO.inspect(challenge)
    send_resp(conn, 200, challenge)
  end

  @doc """
  This function handle upload notification Youtube Data API.
  If user uploads a video to channel, this function get a notification.

  Then refresh latest video database by calling YoutubeApi.search_videos()
  and save them to database

  So Up to date vidoes on the list.
  """
  def handle_upload_notification(conn, params) do
    # Catch xml body from conn
    {:ok, body, _conn} = Plug.Conn.read_body(conn)
    IO.inspect(body)

    # convert raw xml to map
    converted_body = XmlToMap.naive_map(body)

    # pattern match for channel Id
    %{
      "feed" => %{
        "entry" => %{
          "title" => _title,
          "{http://www.youtube.com/xml/schemas/2015}channelId" => channel_id
        }
      }
    } = converted_body

    # get church by channel id
    church = Accounts.get_church_by_channel_id(channel_id)
    # delete current latest videos
    Videos.delete_all_latest_videos(church.id)
    # get new latest videos
    videos = Videos.get_most_recent_videos_from_youtube(church)
    IO.inspect(videos)

    send_resp(conn, 200, "")
  end
end
