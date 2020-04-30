defmodule ChurchWeb.Router do
  use ChurchWeb, :router

  pipeline :api do
    plug CORSPlug, origin: "*"
    plug(:accepts, ["json"])
    plug ChurchWeb.Plugs.SetCurrentUser
  end

  scope "/" do
    pipe_through(:api)

    forward("/api", Absinthe.Plug, schema: ChurchWeb.Schema.Schema)

    forward("/graphiql", Absinthe.Plug.GraphiQL,
      schema: ChurchWeb.Schema.Schema,
      socket: ChurchWeb.UserSocket
    )
  end

  scope "/webhook", ChurchWeb do
    pipe_through(:api)

    get "/youtube", YoutubeController, :index
  end

  scope "/slide-image", ChurchWeb do
    pipe_through(:api)

    post "/upload", SlideimageController, :upload
  end
end
