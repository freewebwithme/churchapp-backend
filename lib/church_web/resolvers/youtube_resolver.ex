defmodule ChurchWeb.Resolvers.YoutubeResolver do
  alias Church.{Youtube, Videos}
  alias Church.Response.{VideoSearchResponse, VideoSearchResult}
  alias Church.Utility

  @doc """
  Return 10 most recent videos from channel for HomeScreen.
  """
  def search_videos(
        _,
        %{
          query: query,
          order: order,
          max_results: max_results,
          next_page_token: next_page_token_request
        },
        _
      ) do
    part = "snippet"

    {:ok, video_search_list_response} =
      Youtube.search_videos(part, query, order, max_results, next_page_token_request)

    %{
      etag: etag,
      nextPageToken: next_page_token,
      prevPageToken: prev_page_token,
      items: search_results,
      pageInfo: %{resultsPerPage: results_per_page, totalResults: total_results}
    } = video_search_list_response

    # Build VideoSearchResult Struct
    search_results_items =
      Enum.map(search_results, fn video ->
        {:ok, formatted_datetime} = Utility.format_datetime(video.snippet.publishedAt)

        %VideoSearchResult{
          id: Utility.create_id(),
          etag: video.etag,
          video_id: video.id.videoId,
          channel_id: video.snippet.channelId,
          channel_title: video.snippet.channelTitle,
          description: video.snippet.description,
          live_broadcast_content: video.snippet.liveBroadcastContent,
          published_at: formatted_datetime,
          title: video.snippet.title,
          thumbnail_url: Utility.get_thumbnail_url(video)
        }
      end)

    new_video_search_response = %VideoSearchResponse{
      id: Utility.create_id(),
      etag: etag,
      next_page_token: next_page_token,
      prev_page_token: prev_page_token,
      results_per_page: results_per_page,
      total_results: total_results,
      items: search_results_items
    }

    {:ok, new_video_search_response}
  end

  def get_most_recent_videos(_, %{count: count}, _) do
    videos = Videos.get_most_recent_videos() |> Enum.take(count)
    {:ok, videos}
  end

  def get_all_playlists(_, _, _) do
    playlists = Videos.get_all_playlists()
    {:ok, playlists}
  end

  def get_playlist_items(_, %{next_page_token: next_page_token, playlist_id: playlist_id}, _) do
    %{items: videos, next_page_token: token, page_info: _page_info} =
      Youtube.list_playlist_items("snippet", playlist_id, 25, next_page_token)

    playlist_items =
      Enum.map(videos, fn video ->
        {:ok, formatted_datetime} = Utility.format_datetime(video.snippet.publishedAt)

        %VideoSearchResult{
          id: Utility.create_id(),
          etag: video.etag,
          video_id: video.snippet.resourceId.videoId,
          channel_id: video.snippet.channelId,
          channel_title: video.snippet.channelTitle,
          description: video.snippet.description,
          live_broadcast_content: nil,
          published_at: formatted_datetime,
          title: video.snippet.title,
          thumbnail_url: Utility.get_thumbnail_url(video)
        }
      end)

    new_playlist_items_response = %VideoSearchResponse{
      id: Utility.create_id(),
      etag: nil,
      next_page_token: token,
      prev_page_token: nil,
      results_per_page: nil,
      total_results: nil,
      items: playlist_items
    }

    {:ok, new_playlist_items_response}
  end
end
