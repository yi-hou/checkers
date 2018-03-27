defmodule Checkers.Game do

	def new do
    %{
       	pawns: %{"red" => generateRedTiles("red"),
       	         "black" => generateBlackTiles("black")},
       	selectedTile: 99,
       	lastturn: "none",
        fscore: 0,
        sscore: 0,
        moves: %{},
        turn: "red",
        first_player: "none",
        second_player: "none",
    }
	end

	def client_view(game) do
	 %{
        pawns: game[:pawns],
        selectedTile: game.selectedTile,
       	lastturn: game.lastturn,
        moves: game[:moves],
        turn: game.turn,
        first_player: game.first_player,
        second_player: game.second_player,
        fscore: 0,
        sscore: 0,
    }
  	end

    def capture(game,t,captured,value) do
     pos = t.location;
      cond do
        value == pos + 14 -> listTils = capturedPieces(game,captured, value - 7)
        value == pos + 18 -> listTils = capturedPieces(game,captured, value - 9)
        value == pos - 14 -> listTils = capturedPieces(game,captured, value + 7)
        value == pos - 18 -> listTils = capturedPieces(game,captured, value + 9)
        true -> listTils = []
      end
    end

  def generateBlackTiles(p) do
    blacktile = []
    locations = [{0,40},{1,42},{2,44},{3,46},{4,49},{5,51},{6,53},{7,55},{8,56},{9,58},{10,60},{11,62}];
    blacktile = Enum.map(locations, fn{k,v} -> blacktile ++
    blacktile ++ %{id: k, team: "black", location: v, killed: false,king: false} end)
  end

  def generateRedTiles(p) do
    redtile = []
    locations = [{0,1},{1,3},{2,5},{3,7},{4,8},{5,10},{6,12},{7,14},{8,17},{9,19},{10,21},{11,23}];
    redtile = Enum.map(locations, fn{k,v} -> redtile ++
    redtile ++ %{id: k, team: "red", location: v, killed: false,king: false} end)
  end

  def takeChance(game,id,p,k) do
    listoFPieces = game[:pawns]
    pieceInTurn = listoFPieces[k]
    pieceToMove = Enum.at(pieceInTurn,p)
    if(k == "red") do lost = "black"
      newPosition = 55
    else lost = "red"
      newPosition = 8
    end
    capturedPieceList = listoFPieces[lost]
    kill = capture(game,pieceToMove,lost,id)
    newpieceInTurn = []
    newpieceInTurn = Enum.map(pieceInTurn, fn(x) ->
      if(x.id == p ) do
        if((k =="red" and id > newPosition) or (k == "black" and id<newPosition)) do
          newpieceInTurn = newpieceInTurn ++
          %{killed: x.killed, id: x.id, team: x.team, king: true, location: id}
        else  newpieceInTurn = newpieceInTurn ++
        %{killed: x.killed, id: x.id, team: x.team, king: x.king, location: id}
        end
      else
        newpieceInTurn = newpieceInTurn ++ x
    end end)
    killedPiece = []
    if((length kill) != 0) do
      pawn = Enum.at(kill,0)
      killedPiece = Enum.map(capturedPieceList, fn(x) -> if(x.id == pawn.id) do
          killedPiece = killedPiece ++ %{killed: x.killed, id: x.id, team: x.team, king: x.king, location: -100}
        else   killedPiece = killedPiece ++ x
      end end)
    else  killedPiece = killedPiece ++ capturedPieceList
    end
    if(k == "red") do newPawns = %{"red" => newpieceInTurn, "black" => killedPiece}
    else newPawns = %{"black" => newpieceInTurn, "red" => killedPiece}
    end
    game = Map.put(game, :pawns, newPawns)
    game = %{game | selectedTile: 99 }
    game = %{game | lastturn: 'none' }
    game = %{game | moves: %{}}
    if(k == "red") do game = %{game | turn: "black"}
    else game = %{game | turn: "red"}
    end
  end

def capturedPieces(game,p,k) do
  Enum.filter(game[:pawns][p], fn(x) ->
    x.location == k
  end)
end

  def fetchTile(game,id,k) do
    m = game[:pawns]
    p = m[k]
    t = Enum.at(p,id)
    m=%{};
    arr = %{};
    newarr = %{};
    cond do
      t.king == true -> arr = redValidTiles(game,t)
      newarr = blackValidTiles(game,t)
      m = Map.merge(arr,newarr)
      t.team == "red" -> m = redValidTiles(game,t)
      true ->  m = blackValidTiles(game,t)
    end
    game = Map.put(game, :moves, m)
    game = %{game | selectedTile: id }
    game = %{game | lastturn: k }
  end

  def fetchNextMoveB(r,b,a,k,p) do
      checkBlock = %{}
      cond do
        r[a]!=nil -> a = p.location + 14
        if((r[a]!=nil) or (b[a]!=nil) or (rem(a + 1, 8) == 0)) do
                a = 99
        end
        b[a]!=nil -> a = 99
        true -> a
      end
      cond do
        r[k]!=nil -> k = p.location + 18
       if((r[k]!=nil) or (b[k]!=nil) or (rem(k, 8) == 0)) do
          k = 99
       end
        b[k]!=nil -> k = 99
        true -> k
      end
      checkBlock = %{a => true, k => true}
  end

  def fetchNextMoveR(r,b,a,k,p) do
      checkBlock = %{}
      cond do
        b[a]!=nil ->  a = p.location + 14
        if((r[a]!=nil) or (b[a]!=nil) or (rem(a + 1, 8) == 0)) do
          a = 99
        end
        r[a]!=nil -> a = 99
        true ->  a
      end
      cond do
        b[k]!=nil ->  k = p.location + 18
        if((r[k]!=nil) or (b[k]!=nil) or (rem(k, 8) == 0)) do
          k = 99
        end
        r[k]!=nil -> k = 99
        true -> k
      end
      checkBlock = %{a => true, k => true}
  end

  def redValidTiles(game,p) do
    listOfmoves = %{}
    makepawns=[]
    pawns = game[:pawns]
    a = p.location + 7
    k = p.location + 9
    redPawns = pawns["red"]
    blackPawns = pawns["black"]
    r = %{}
    b = %{}

    r = Enum.reduce(redPawns, %{},fn(x,acc) ->
      Map.put(acc, x.location, x)
    end)

    b = Enum.reduce(blackPawns, %{},fn(x,acc) ->
      Map.put(acc, x.location, x)
    end)

    if(rem(p.location, 8) == 0) do
        a = 99;
    end
    if(rem(p.location+1, 8) == 0) do
        k = 99;
    end
    if(p.team == "black") do
        fetchNextMoveB(r,b,a,k,p)
    else
        fetchNextMoveR(r,b,a,k,p)
    end
  end

  def blackValidTiles(game,p) do
    listOfmoves = %{}
    makepawns=[]
    pawns = game[:pawns]
    a = p.location - 9
    k = p.location - 7
    redPawns = pawns["red"]
    blackPawns = pawns["black"]
    r = %{}
    b = %{}

    r = Enum.reduce(redPawns, %{},fn(x,acc) ->
      Map.put(acc, x.location, x)
    end)

    b = Enum.reduce(blackPawns, %{},fn(x,acc) ->
      Map.put(acc, x.location, x)
    end)

    if(rem(p.location, 8) == 0) do
        a = 99;
    end
    if(rem(p.location+1, 8) == 0) do
        k = 99;
    end
    if(p.team == "black") do
        redTileLocation(r,b,a,k,p)
    else
        blackTileLocation(r,b,a,k,p)
    end
  end

  def blackTileLocation(r,b,a,k,p) do
      checkBlock = %{}
      cond do
        b[a]!=nil -> a = p.location - 18
        if((r[a]!=nil) or (b[a]!=nil) or (rem(a + 1, 8) == 0)) do
          a = 99
        end
        r[a]!=nil -> a = 99
        true -> a
      end
      cond do
        b[k]!=nil -> k = p.location - 14
        if((r[k]!=nil) or (b[k]!=nil) or (rem(k, 8) == 0)) do
          k = 99
        end
        r[k]!=nil -> k = 99
        true -> k
      end
      checkBlock = %{a => true, k => true}
  end

  def redTileLocation(r,b,a,k,p) do
      checkBlock = %{}
      cond do
        r[a]!=nil -> a = p.location - 18
        if((r[a]!=nil) or (b[a]!=nil) or (rem(a + 1, 8) == 0)) do
          a = 100
        end
        b[a]!=nil -> a = 100
        true -> a
      end
      cond do
        r[k]!=nil -> k = p.location - 14
        if((r[k]!=nil) or (b[k]!=nil) or (rem(k, 8) == 0)) do
          k = 99
        end
        b[k]!=nil -> k = 99
        true -> k
      end
      checkBlock = %{a => true, k => true}
  end

  def joinTable(game,playername) do
      cond do
        game.first_player == "none" -> %{game | first_player: playername }
        game.second_player == "none" -> %{game | second_player: playername }
        true -> game
      end
  end

end
