defmodule ChurchWeb.Schema.Schema do
  use Absinthe.Schema
  alias ChurchWeb.Resolvers

  query do
    @doc "Search Videos"
    field :search_videos, :video_search_response do
      arg(:order, non_null(:string))
      arg(:max_results, non_null(:integer))
      arg(:query, non_null(:string))
      arg(:next_page_token, :string)
      resolve(&Resolvers.YoutubeResolver.search_videos/3)
    end

    @doc "Get most recent videos"
    field :most_recent, list_of(:latest_videos) do
      arg(:count, non_null(:integer))
      resolve(&Resolvers.YoutubeResolver.get_most_recent_videos/3)
    end

    @doc "Get all playlists"
    field :playlists, list_of(:playlist) do
      resolve(&Resolvers.YoutubeResolver.get_all_playlists/3)
    end

    @doc "Get all playlist items"
    field :playlist_items, :video_search_response do
      arg(:next_page_token, :string)
      arg(:playlist_id, :string)
      resolve(&Resolvers.YoutubeResolver.get_playlist_items/3)
    end
  end

  object :video_search_response do
    field(:id, :string)
    field(:etag, :string)
    field(:next_page_token, :string)
    field(:prev_page_token, :string)
    field(:results_per_page, :integer)
    field(:total_results, :integer)
    field(:items, list_of(:video_search_result))
  end

  object :video_search_result do
    field(:id, :string)
    field(:etag, :string)
    field(:video_id, :string)
    field(:channel_id, :string)
    field(:channel_title, :string)
    field(:description, :string)
    field(:live_broadcast_content, :string)
    field(:published_at, :string)
    field(:title, :string)
    field(:thumbnail_url, :string)
  end

  object :latest_videos do
    field :id, :id
    field :title, :string
    field :description, :string
    field :video_id, :string
    field :thumbnail_url, :string
    field :published_at, :string
    field :channel_title, :string
  end

  object :playlist do
    field :id, :id
    field :playlist_id, :string
    field :playlist_title, :string
    field :description, :string
    field :thumbnail_url, :string
  end
end
