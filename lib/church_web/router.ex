defmodule ChurchWeb.Router do
  use ChurchWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/" do
    pipe_through(:api)

    forward("/api", Absinthe.Plug, schema: ChurchWeb.Schema.Schema)

    forward("/graphiql", Absinthe.Plug.GraphiQL,
      schema: ChurchWeb.Schema.Schema,
      socket: ChurchWeb.UserSocket
    )
  end
end
