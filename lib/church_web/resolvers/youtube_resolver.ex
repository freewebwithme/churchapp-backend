defmodule ChurchWeb.Resolvers.YoutubeResolver do
  alias Church.Youtube
  alias Church.Response.{VideoSearchResponse, VideoSearchResult}
  alias UUID
  alias Timex.Format.DateTime.Formatter

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
        {:ok, formatted_datetime} = format_datetime(video.snippet.publishedAt)

        %VideoSearchResult{
          id: create_id(),
          etag: video.etag,
          video_id: video.id.videoId,
          channel_id: video.snippet.channelId,
          channel_title: video.snippet.channelTitle,
          description: video.snippet.description,
          live_broadcast_content: video.snippet.liveBroadcastContent,
          published_at: formatted_datetime,
          title: video.snippet.title,
          thumbnail_url: video.snippet.thumbnails.medium.url
        }
      end)

    new_video_search_response = %VideoSearchResponse{
      id: create_id(),
      etag: etag,
      next_page_token: next_page_token,
      prev_page_token: prev_page_token,
      results_per_page: results_per_page,
      total_results: total_results,
      items: search_results_items
    }

    {:ok, new_video_search_response}
  end

  def create_id() do
    UUID.uuid1()
  end

  defp format_datetime(datetime) do
    Formatter.format(datetime, "{YYYY}년 {M}월 {D}일")
  end
end
