defmodule Blackjack.Game do
  defstruct num_decks: 1,
            money: 10000,
            current_bet: 500,
            dealer_hand: nil,
            player_hands: [],
            current_player_hand: 0,
            shoe: nil

  alias Blackjack.Game

  def run(args \\ []) do
    game = %Game{}
    IO.inspect(game)
  end
end