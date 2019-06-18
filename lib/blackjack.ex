defmodule Blackjack do
  alias Blackjack.Game

  def main(args \\ []) do
    Game.run(args)
  end
end
