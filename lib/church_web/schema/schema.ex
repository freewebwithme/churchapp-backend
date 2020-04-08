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
end
