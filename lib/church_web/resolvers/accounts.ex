defmodule ChurchWeb.Resolvers.Accounts do
  alias Church.Accounts

  def me(_, _, %{context: %{current_user: user}}) do
    IO.puts("Found a user")
    IO.inspect(user)
    {:ok, user}
  end

  def me(_, _, _), do: {:ok, nil}

  def sign_in(_, %{email: email, password: password}, _) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        token = ChurchWeb.AuthToken.sign(user)
        {:ok, %{user: user, token: token}}

      :error ->
        {:error, "로그인 도중에 문제가 발생했습니다."}
    end
  end

  def sign_up(_, args, _) do
    with {:ok, user} <- Accounts.create_user(args) do
      token = ChurchWeb.AuthToken.sign(user)
      {:ok, %{user: user, token: token}}
    end
  end

  def create_church(_, args, _) do
    Accounts.create_church(args)
  end

  def get_church(_, %{uuid: uuid}, _) do
    church = Accounts.get_church_by_uuid(uuid)
    {:ok, church}
  end

  def delete_slide_image(_, %{slider_number: slider_number, user_id: user_id}, _) do
    Accounts.delete_slide_image(user_id, slider_number)
  end
end
