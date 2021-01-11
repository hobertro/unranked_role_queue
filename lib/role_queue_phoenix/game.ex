defmodule RoleQueuePhoenix.Game do

  @enforce_keys [:squares]
  defstruct squares: nil, scores: %{}, winner: nil

  # alias Bingo.{Buzzwords, Game, Square, BingoChecker}

  @doc """
  Creates a game with a `size` x `size` collection of squares
  taken randomly from the given list of `buzzwords` where
  each buzzword is of the form `%{phrase: "Upsell", points: 10}`.
  """
  def new(name) do
    # buzzwords = Buzzwords.read_buzzwords()
    Game.new(name)
  end

  @doc """
  Creates a game with a `size` x `size` collection of squares
  taken randomly from the given list of `buzzwords` where
  each buzzword is of the form `%{phrase: "Upsell", points: 10}`.
  """
  # def new(buzzwords, size) do
  #   squares =
  #     buzzwords
  #     |> Enum.shuffle()
  #     |> Enum.take(size * size)
  #     |> Enum.map(&Square.from_buzzword(&1))
  #     |> Enum.chunk_every(size)

  #   %Game{squares: squares}
  # end
end
