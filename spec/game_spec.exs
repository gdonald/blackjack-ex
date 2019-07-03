defmodule GameSpec do
  use ESpec
  alias Blackjack.{Card, DealerHand, Game, Hand, PlayerHand, Shoe}

  let :six, do: %Card{value: 5}
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

  describe "Game.unhide_dealer_down_card!/1" do
    let :dealer_hand, do: %DealerHand{hide_down_card: true}
    let :game, do: %Game{dealer_hand: dealer_hand()}

    it "flips dealer down card" do
      expect game().dealer_hand.hide_down_card
             |> to(be_true())
      game = Game.unhide_dealer_down_card!(game())
      expect game.dealer_hand.hide_down_card
             |> to(be_false())
    end
  end

  describe "Game.deal_dealer_cards!/1" do
    let :shoe, do: %Shoe{cards: [ace()]}

    context "soft 17" do
      let :hand, do: %Hand{cards: [ace(), six()]}
      let :dealer_hand, do: %DealerHand{hand: hand(), hide_down_card: false}
      let :game, do: %Game{shoe: shoe(), dealer_hand: dealer_hand()}

      it "takes a card" do
        expect length(game().dealer_hand.hand.cards)
               |> to(eq 2)
        game = Game.deal_dealer_cards!(game())
        expect length(game.dealer_hand.hand.cards)
               |> to(eq 3)
      end
    end

    context "soft 18" do
      let :hand, do: %Hand{cards: [ace(), seven()]}
      let :dealer_hand, do: %DealerHand{hand: hand(), hide_down_card: false}
      let :game, do: %Game{shoe: shoe(), dealer_hand: dealer_hand()}

      it "takes no cards" do
        expect length(game().dealer_hand.hand.cards)
               |> to(eq 2)
        game = Game.deal_dealer_cards!(game())
        expect length(game.dealer_hand.hand.cards)
               |> to(eq 2)
      end
    end

    context "hard 16" do
      let :hand, do: %Hand{cards: [ten(), six()]}
      let :dealer_hand, do: %DealerHand{hand: hand(), hide_down_card: false}
      let :game, do: %Game{shoe: shoe(), dealer_hand: dealer_hand()}

      it "takes a card" do
        expect length(game().dealer_hand.hand.cards)
               |> to(eq 2)
        game = Game.deal_dealer_cards!(game())
        expect length(game.dealer_hand.hand.cards)
               |> to(eq 3)
      end
    end

    context "hard 17" do
      let :hand, do: %Hand{cards: [ten(), seven()]}
      let :dealer_hand, do: %DealerHand{hand: hand(), hide_down_card: false}
      let :game, do: %Game{shoe: shoe(), dealer_hand: dealer_hand()}

      it "takes no cards" do
        expect length(game().dealer_hand.hand.cards)
               |> to(eq 2)
        game = Game.deal_dealer_cards!(game())
        expect length(game.dealer_hand.hand.cards)
               |> to(eq 2)
      end
    end
  end

  describe "Game.normalize_current_bet!/1" do
    context "current bet has sufficient money and is in range" do
      let :game, do: %Game{current_bet: 500}

      it "does not alter the current bet" do
        game = Game.normalize_current_bet!(game())
        expect game.current_bet
               |> to(eq 500)
      end
    end

    context "current bet has insufficient money" do
      let :game, do: %Game{current_bet: 10500}

      it "alters the current bet" do
        game = Game.normalize_current_bet!(game())
        expect game.current_bet
               |> to(eq 10000)
      end
    end

    context "current bet is more than max bet" do
      let :game, do: %Game{money: 10000000, current_bet: 10000500}

      it "alters the current bet" do
        game = Game.normalize_current_bet!(game())
        expect game.current_bet
               |> to(eq 10000000)
      end
    end

    context "current bet is less than min bet" do
      let :game, do: %Game{current_bet: 499}

      it "alters the current bet" do
        game = Game.normalize_current_bet!(game())
        expect game.current_bet
               |> to(eq 500)
      end
    end
  end

  describe "Game.save_game!/1" do
    let :game, do: %Game{}

    it "persists a save game file to disk" do
      Game.save_game!(game())
      expect File.read!("bj.txt")
             |> to(eq "1|10000|500")
    end
  end

  describe "Game.load_game!/1" do
    let :game, do: %Game{num_decks: 0, money: 0, current_bet: 0}

    it "reads a persisted game file from disk" do
      game = Game.load_game!(game())
      expect game.num_decks
             |> to(eq 1)
      expect game.money
             |> to(eq 10000)
      expect game.current_bet
             |> to(eq 500)
    end
  end
end
