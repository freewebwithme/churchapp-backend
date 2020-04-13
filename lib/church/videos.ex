defmodule Church.Videos do
  @moduledoc """
  Module for video.
  Creating videos and insert, get videos
  """
  import Ecto.Query, warn: false
  alias Church.Repo
  alias Church.Videos.LatestVideos
  alias Church.Youtube
  alias Church.Response.Playlist
  alias Church.Utility

  alias Timex.Format.DateTime.Formatter
  alias UUID

  def list_latest_videos() do
    Repo.all(LatestVideos)
  end

  @doc """
  Insert all 25 videos at once using insert_all
  """
  @spec insert_all_latest_videos(videos :: list) :: {integer(), nil | [term()]}
  def insert_all_latest_videos(videos) do
    Repo.insert_all(LatestVideos, videos, on_conflict: :nothing, returning: true)
  end

  def delete_all_latest_videos() do
    Repo.delete_all(from(v in LatestVideos))
  end

  @doc """
  buid list of maps for insert_all_latest_videos
  """
  def build_videos_from_response(response) do
    %{
      etag: _etag,
      nextPageToken: _next_page_token,
      prevPageToken: _prev_page_token,
      items: search_results,
      pageInfo: _page_info
    } = response

    Enum.map(search_results, fn video ->
      {:ok, formatted_datetime} = Utility.format_datetime(video.snippet.publishedAt)
      timestamp = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

      %{
        title: video.snippet.title,
        description: video.snippet.description,
        channel_title: video.snippet.channelTitle,
        video_id: video.id.videoId,
        thumbnail_url: Utility.get_thumbnail_url(video),
        published_at: formatted_datetime,
        inserted_at: timestamp,
        updated_at: timestamp
      }
    end)
  end

  @doc """
  Check for most recent videos from database.
  If it is empty(maybe app loading for the first time?),
  Request Search List api to Youtube Data Api
  And save the result.
  If has videos, return them
  """
  def get_most_recent_videos() do
    latest_videos = list_latest_videos()

    with true <- Enum.empty?(latest_videos) do
      # There is no latest videos in database
      # Call API and save them to database
      {:ok, response} = Youtube.search_videos("snippet", "", "date", 25, "")

      {_rows, videos} = build_videos_from_response(response) |> insert_all_latest_videos
      videos
    else
      false -> latest_videos
    end
  end

  def build_playlists(playlists) do
    Enum.map(playlists, fn playlist ->
      %Playlist{
        id: Utility.create_id(),
        playlist_title: playlist.snippet.title,
        description: playlist.snippet.description,
        thumbnail_url: Utility.get_thumbnail_url(playlist),
        playlist_id: playlist.id
      }
    end)
  end

  def build_playlist_items(items, next_page_token) do
  end

  def get_all_playlists() do
    %{items: playlists, next_page_token: _token, page_info: _info} =
      Youtube.list_playlists_info("snippet", 25)

    build_playlists(playlists)
  end
end
