defmodule GameSpec do
  use ESpec
  alias Blackjack.{Game, PlayerHand}

  describe "Game.max_player_hands/0" do
    it "returns 7" do
      expect Game.max_player_hands
             |> to(eq 7)
    end
  end

  describe "Game.all_bets/1" do
    let :player_hand_1, do: %PlayerHand{bet: 500}
    let :player_hand_2, do: %PlayerHand{bet: 1000}
    let :game, do: %Game{player_hands: [player_hand_1(), player_hand_2()]}

    it "returns 1000" do
      expect Game.all_bets(game())
             |> to(eq 1500)
    end
  end
end
