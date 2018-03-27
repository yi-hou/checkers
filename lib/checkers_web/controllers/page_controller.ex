defmodule CheckersWeb.PageController do
  use CheckersWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def game(conn, params) do
  	IO.inspect(params)
    render conn, "game.html", game: params["username"], name:  params["pusername"]
  end

  def game2(conn, params) do
    IO.inspect(params)
    render conn, "game.html", game: params["username"], name:  params["pusername"]
  end

  def game3(conn, params) do
    IO.inspect(params)
    render conn, "game.html", game: params["username"], name:  params["pusername"]
  end

  def variation1(conn, _params) do
    render conn, "variation1.html"
  end

  def variation2(conn, _params) do
    render conn, "variation2.html"
  end

  def variation3(conn, _params) do
    render conn, "variation3.html"
  end
  def rules(conn, _params) do
    render conn, "rules.html"
  end

end
