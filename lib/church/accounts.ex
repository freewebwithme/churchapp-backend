defmodule Church.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Church.Repo

  alias Church.Accounts.Church, as: ChurchStruct
  alias Church.Accounts.User
  alias Church.Accounts.StripeUser
  alias Church.Utility
  alias Church.Videos

  alias Church.Api.StripeApi

  def get_church_by_id(church_id) do
    church =
      Repo.get_by(ChurchStruct, id: church_id) |> Repo.preload([:latest_videos, :employees])

    return_church_with_latest_videos(church)
  end

  def get_church_by_uuid(uuid) do
    church = Repo.get_by(ChurchStruct, uuid: uuid) |> Repo.preload([:latest_videos, :employees])
    return_church_with_latest_videos(church)
  end

  @doc """
  This function used for only get church
  Used in YoutubeController.handle_upload_notification()
  """
  def get_church_by_channel_id(channel_id) do
    Repo.get_by(ChurchStruct, channel_id: channel_id)
  end

  @doc """
  Check if church has latest videos.
  if no latest videos, call youtube api to get latest videos.
  """
  def return_church_with_latest_videos(church) do
    church =
      case Enum.empty?(church.latest_videos) do
        true ->
          latest_videos = Videos.get_most_recent_videos(church)
          Map.put(church, :latest_videos, latest_videos)

        _ ->
          church
      end

    church
  end

  def create_church(attrs) do
    %{user_id: id} = attrs
    user = Repo.get_by(User, id: id)
    attrs = Map.put(attrs, :uuid, UUID.uuid1())

    %ChurchStruct{}
    |> ChurchStruct.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  def update_church(%ChurchStruct{} = church, attrs) do
    IO.puts("Calling update_church")
    IO.inspect(church)
    IO.inspect(attrs)

    changeset = ChurchStruct.changeset(church, attrs)

    case changeset.changes["channel_id"] do
      nil ->
        # channel id is updated, call latest videos from youtube
        {:ok, church} = Repo.update(changeset)
        # delete old latest videos
        Videos.delete_all_latest_videos(church.id)
        latest_videos = Videos.get_most_recent_videos_from_youtube(church)
        church = Map.put(church, :latest_videos, latest_videos)
        {:ok, church}

      _ ->
        Repo.update(changeset)
    end
  end

  def update_service_info(church_id, schedules) do
    church = get_church_by_id(church_id)
    church_changeset = Ecto.Changeset.change(church)

    {:ok, schedule_map} = Jason.decode(schedules)

    IO.puts("Printing map")
    IO.inspect(schedule_map)

    # Build Schedule struct
    final_schedules =
      Enum.map(schedule_map, fn {k, v} ->
        %Church.Accounts.Schedule{
          service_name: k,
          service_time: List.first(v),
          order: List.last(v)
        }
      end)

    IO.puts("Printing final map")
    IO.inspect(final_schedules)

    church_changeset = Ecto.Changeset.put_embed(church_changeset, :schedules, final_schedules)
    Repo.update(church_changeset)
  end

  def delete_church(%ChurchStruct{} = church) do
    Repo.delete(church)
  end

  def delete_slide_image(user_id, slider_number) do
    user = get_user(user_id)
    bucket_name = Utility.get_bucket_name()

    cond do
      slider_number == "sliderTwo" ->
        image_key_name = user.church.slide_image_two

        case is_nil(image_key_name) do
          false ->
            result = Utility.delete_file_from_s3(bucket_name, image_key_name)
            IO.puts("Printing from delete s3 image")
            IO.inspect(result)
            update_church(user.church, %{slide_image_two: nil})

          _ ->
            nil
        end

      slider_number == "sliderThree" ->
        image_key_name = user.church.slide_image_two

        case is_nil(image_key_name) do
          false ->
            Utility.delete_file_from_s3(bucket_name, image_key_name)
            update_church(user.church, %{slide_image_three: nil})

          _ ->
            nil
        end
    end
  end

  def change_church(%ChurchStruct{} = church) do
    ChurchStruct.changeset(church, %{})
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def get_user(id) do
    Repo.get(User, id) |> Repo.preload(:church)
  end

  def update_user(%User{} = user, attrs \\ %{}) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def authenticate_user(email, password) do
    user = Repo.get_by(User, email: email) |> Repo.preload(:church)
    IO.puts("Printing User")
    IO.inspect(user)

    with %{password: hashed_password} when not is_nil(hashed_password) <- user,
         true <- Comeonin.Ecto.Password.valid?(password, hashed_password) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  def create_stripe_user(email, church_id) do
    {:ok, stripe_user} = StripeApi.create_user(email)

    %StripeUser{}
    |> StripeUser.changeset(%{email: email, stripe_id: stripe_user.id, church_id: church_id})
    |> Repo.insert()
  end

  def get_stripe_user(email, church_id) do
    Repo.get_by(StripeUser, email: email, church_id: church_id)
  end
end
