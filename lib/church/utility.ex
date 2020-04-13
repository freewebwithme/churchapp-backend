defmodule Church.Utility do
  alias UUID
  alias Timex.Format.DateTime.Formatter

  def create_id() do
    UUID.uuid1()
  end

  def format_datetime(datetime) do
    Formatter.format(datetime, "{YYYY}년 {M}월 {D}일")
  end

  @doc """
  Some of playlist has private video.
  Accessing thumbnails url like this
  video.snippet.thumbnails.medium.url will raise exception.
  If video is private video, then return default thumbnail url.
  """
  def get_thumbnail_url(video) do
    with true <- is_nil(video.snippet.thumbnails) do
      "https://churchapp-la.s3-us-west-1.amazonaws.com/no-thumbnail.png"
    else
      false -> video.snippet.thumbnails.medium.url
    end
  end
end
