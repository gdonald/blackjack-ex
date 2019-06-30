defmodule GameSpec do
  use ESpec
  alias Blackjack.{Card, Game, Hand, PlayerHand}

  let :seven, do: %Card{value: 6}
  let :ace, do: %Card{value: 0}
  let :ten, do: %Card{value: 9}
  let :player_hand_7_7,
      do: %PlayerHand{
        hand: %Hand{
          cards: [seven(), seven()]
        }
      }
  let :player_hand_A_10,
      do: %PlayerHand{
        hand: %Hand{
          cards: [ace(), ten()]
        }
      }
  let :player_hand_10_10_10,
      do: %PlayerHand{
        hand: %Hand{
          cards: [ten(), ten(), ten()]
        }
      }

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

  describe "Game.more_hands_to_play?/1" do
    context "one player hand" do
      let :game,
          do: %Game{
            current_player_hand: 0,
            player_hands: [%PlayerHand{}]
          }

      it "returns false" do
        expect Game.more_hands_to_play?(game())
               |> to(be_false())
      end
    end

    context "two player hands, currently on the first hand" do
      let :game,
          do: %Game{
            current_player_hand: 0,
            player_hands: [%PlayerHand{}, %PlayerHand{}]
          }

      it "returns true" do
        expect Game.more_hands_to_play?(game())
               |> to(be_true())
      end
    end

    context "two player hands, currently on the second hand" do
      let :game,
          do: %Game{
            current_player_hand: 1,
            player_hands: [%PlayerHand{}, %PlayerHand{}]
          }

      it "returns false" do
        expect Game.more_hands_to_play?(game())
               |> to(be_false())
      end
    end
  end

  describe "Game.needs_to_play_dealer_hand?/1" do
    context "one non-busted, non-blackjack hand" do
      let :game,
          do: %Game{
            player_hands: [player_hand_7_7()]
          }

      it "returns true" do
        expect Game.needs_to_play_dealer_hand?(game())
               |> to(be_true())
      end
    end

    context "one non-busted, non-blackjack hand and a busted hand" do
      let :game,
          do: %Game{
            player_hands: [player_hand_7_7(), player_hand_10_10_10()]
          }

      it "returns true" do
        expect Game.needs_to_play_dealer_hand?(game())
               |> to(be_true())
      end
    end

    context "one non-busted, non-blackjack hand and a blackjack hand" do
      let :game,
          do: %Game{
            player_hands: [player_hand_7_7(), player_hand_A_10()]
          }

      it "returns true" do
        expect Game.needs_to_play_dealer_hand?(game())
               |> to(be_true())
      end
    end

    context "one busted hand" do
      let :game,
          do: %Game{
            player_hands: [player_hand_10_10_10()]
          }

      it "returns false" do
        expect Game.needs_to_play_dealer_hand?(game())
               |> to(be_false())
      end
    end

    context "one blackjack hand" do
      let :game,
          do: %Game{
            player_hands: [player_hand_A_10()]
          }

      it "returns false" do
        expect Game.needs_to_play_dealer_hand?(game())
               |> to(be_false())
      end
    end
  end
end
