defmodule Church.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Church.Repo

  alias Church.Accounts.Church, as: ChurchStruct
  alias Church.Accounts.User
  alias Church.Utility
  alias Church.Videos

  def get_church_by_id(church_id) do
    church = Repo.get_by(ChurchStruct, id: church_id) |> Repo.preload(:latest_videos)
    return_church_with_latest_videos(church)
  end

  def get_church_by_uuid(uuid) do
    church = Repo.get_by(ChurchStruct, uuid: uuid) |> Repo.preload(:latest_videos)
    return_church_with_latest_videos(church)
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

    church
    |> ChurchStruct.changeset(attrs)
    |> Repo.update()
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
end
