defmodule ChurchWeb.Schema.Schema do
  use Absinthe.Schema
  alias ChurchWeb.Resolvers
  alias ChurchWeb.Schema.Middleware
  alias Church.Utility

  def middleware(middleware, _field, %{identifier: :mutation}) do
    middleware ++ [Middleware.ChangesetErrors]
  end

  def middleware(middleware, _field, _object) do
    middleware
  end

  query do
    @doc "Get the currently signed in user"
    field :me, :user do
      resolve(&Resolvers.Accounts.me/3)
    end

    @doc "Get church"
    field :get_church, :church do
      arg(:uuid, :string)
      resolve(&Resolvers.Accounts.get_church/3)
    end

    @doc "Search Videos"
    field :search_videos, :video_search_response do
      arg(:channel_id, non_null(:string))
      arg(:order, non_null(:string))
      arg(:max_results, non_null(:integer))
      arg(:query, non_null(:string))
      arg(:next_page_token, :string)
      resolve(&Resolvers.YoutubeResolver.search_videos/3)
    end

    @doc "Get most recent videos"
    field :most_recent, list_of(:latest_videos) do
      arg(:count, non_null(:integer))
      arg(:church_id, :id)
      arg(:channel_id, :string)
      resolve(&Resolvers.YoutubeResolver.get_most_recent_videos/3)
    end

    @doc "Get all playlists"
    field :playlists, list_of(:playlist) do
      arg(:channel_id, :string)
      resolve(&Resolvers.YoutubeResolver.get_all_playlists/3)
    end

    @doc "Get all playlist items"
    field :playlist_items, :video_search_response do
      arg(:next_page_token, :string)
      arg(:playlist_id, :string)
      resolve(&Resolvers.YoutubeResolver.get_playlist_items/3)
    end
  end

  mutation do
    @doc "user sign up"
    field :sign_up, :session do
      arg(:email, :string)
      arg(:password, :string)
      arg(:name, :string)
      resolve(&Resolvers.Accounts.sign_up/3)
    end

    @doc "User sign in"
    field :sign_in, :session do
      arg(:email, :string)
      arg(:password, :string)
      resolve(&Resolvers.Accounts.sign_in/3)
    end

    @doc "Get presigned url"
    field :get_presigned_url, :presigned_url do
      arg(:file_extension, :string)
      arg(:content_type, :string)
      arg(:user_id, :id)
      resolve(&Resolvers.AmazonResolver.get_presigned_url/3)
    end

    @doc "create church for user"
    field :create_church, :church do
      arg(:name, non_null(:string))
      arg(:channel_id, non_null(:string))
      arg(:intro, non_null(:string))
      arg(:user_id, non_null(:string))

      resolve(&Resolvers.Accounts.create_church/3)
    end

    @doc "Delete thumbnail image"
    field :delete_slide_image, :church do
      arg(:slider_number, :string)
      arg(:user_id, :string)

      resolve(&Resolvers.Accounts.delete_slide_image/3)
    end
  end

  object :session do
    field :token, :string
    field :user, :user
  end

  object :presigned_url do
    field :url, :string
  end

  object :user do
    field :id, :id
    field :name, :string
    field :email, :string
    field :church, :church
  end

  object :church do
    field :name, :string
    field :intro, :string
    field :uuid, :string
    field :channel_id, :string

    field :slide_image_one, :string do
      resolve(fn parent, _, _ ->
        image = Map.get(parent, :slide_image_one)

        case is_nil(image) do
          false ->
            image_url = Utility.build_image_url(image)
            {:ok, image_url}

          _ ->
            {:ok, nil}
        end
      end)
    end

    field :slide_image_two, :string do
      resolve(fn parent, _, _ ->
        image = Map.get(parent, :slide_image_two)

        case is_nil(image) do
          false ->
            image_url = Utility.build_image_url(image)
            {:ok, image_url}

          _ ->
            {:ok, nil}
        end
      end)
    end

    field :slide_image_three, :string do
      resolve(fn parent, _, _ ->
        image = Map.get(parent, :slide_image_three)

        case is_nil(image) do
          false ->
            image_url = Utility.build_image_url(image)
            {:ok, image_url}

          _ ->
            {:ok, nil}
        end
      end)
    end

    field :user, :user
    field :latest_videos, list_of(:latest_videos)
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
