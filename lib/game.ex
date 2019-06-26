defmodule Blackjack.Game do
  defstruct num_decks: 1,
            money: 10000,
            current_bet: 500,
            dealer_hand: nil,
            player_hands: [],
            current_player_hand: 0,
            shoe: nil

  alias Blackjack.Game

  def run(_args \\ []) do
    game = %Game{}
  end

  def max_player_hands do
    7
  end

  def all_bets(game) do
    Enum.reduce(game.player_hands, 0, fn player_hand, total ->
      total + player_hand.bet
    end)
  end
end