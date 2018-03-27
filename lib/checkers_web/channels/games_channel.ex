defmodule CheckersWeb.GamesChannel do
  use CheckersWeb, :channel

  alias Checkers.Game

  #def join("games:lobby", payload, socket) do
  #  if authorized?(payload) do
  #    {:ok, socket}
  #  else
  #    {:error, %{reason: "unauthorized"}}
  #  end
  #end

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      game = Checkers.GameBackup.load(name) || Game.new()
      socket = socket
      |> assign(:game, game)
      |> assign(:name, name)
      Checkers.GameBackup.save(socket.assigns[:name],game)
      {:ok, %{"join" => name, "game" => Game.client_view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("fetchTile", %{"id" => id, "color" => color}, socket) do
    update = Game.fetchTile(Checkers.GameBackup.load(socket.assigns[:name]) ||  Game.new(),id,color)
    # saving game state
    Checkers.GameBackup.save(socket.assigns[:name],update)
    socket = assign(socket, :game, update)
    # push next move on socket
    broadcast! socket, "fetchTile", %{ "game" => Game.client_view(update)}
    {:reply, {:ok, %{ "game" => Game.client_view(update)}}, socket}
  end

  def handle_in("joinTable", %{"id" => id}, socket) do
     update = Game.joinTable(Checkers.GameBackup.load(socket.assigns[:name]),id)
     # saving game state
     Checkers.GameBackup.save(socket.assigns[:name],update)
     socket = assign(socket, :game, update)
     # push next move on socket
     broadcast! socket, "joinTable", %{ "game" => Game.client_view(update)}
     {:reply, {:ok, %{ "game" => Game.client_view(update)}}, socket}
  end

  def handle_in("takeChance", %{"id" => id, "pawn_id" => pawn_id, "color" => color}, socket) do
    update = Game.takeChance(Checkers.GameBackup.load(socket.assigns[:name]),id,pawn_id,color)
    # saving game state
    Checkers.GameBackup.save(socket.assigns[:name],update)
    socket = assign(socket, :game, update)
    # push next move on socket
    broadcast! socket, "takeChance", %{ "game" => Game.client_view(update)}
    {:reply, {:ok, %{ "game" => Game.client_view(update)}}, socket}
  end

  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
