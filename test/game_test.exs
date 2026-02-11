defmodule GameTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  alias Blackjack.{Card, DealerHand, Game, Hand, PlayerHand, Shoe}

  describe "Game.insure_hand!/1" do
    test "returns false" do
      seven = %Card{value: 6}
      player_hand = %PlayerHand{hand: %Hand{cards: [seven, seven]}}
      game = %Game{player_hands: [player_hand]}

      [player_hand] = Game.insure_hand!(game).player_hands
      assert player_hand.bet == 250
      assert player_hand.paid
      assert player_hand.played
      assert player_hand.status == :lost
    end
  end

  describe "Game.needs_to_offer_insurance?/1" do
    test "when dealer up card is an ace and player hand is not blackjack - returns true" do
      ace = %Card{value: 0}
      six = %Card{value: 5}
      seven = %Card{value: 6}
      dealer_hand = %DealerHand{hand: %Hand{cards: [ace, six]}}
      player_hand = %PlayerHand{hand: %Hand{cards: [seven, seven]}}

      assert Game.needs_to_offer_insurance?(dealer_hand, player_hand)
    end

    test "when dealer up card is an ace and player hand is blackjack - returns false" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      dealer_hand = %DealerHand{hand: %Hand{cards: [ace, ace]}}
      player_hand = %PlayerHand{hand: %Hand{cards: [ace, ten]}}

      refute Game.needs_to_offer_insurance?(dealer_hand, player_hand)
    end

    test "when dealer up card is not an ace - returns false" do
      seven = %Card{value: 6}
      dealer_hand = %DealerHand{hand: %Hand{cards: [seven, seven]}}
      player_hand = %PlayerHand{hand: %Hand{cards: [seven, seven]}}

      refute Game.needs_to_offer_insurance?(dealer_hand, player_hand)
    end
  end

  describe "Game.shuffle/1" do
    test "needs to shuffle - shuffles the shoe" do
      game = %Game{
        shoe: %Shoe{
          cards: []
        }
      }

      game = Game.shuffle(game)

      assert length(game.shoe.cards) == 52
    end

    test "does not need to shuffle - does not shuffle the shoe" do
      shoe = Shoe.new_regular(1)
      game = %Game{shoe: shoe}

      game = Game.shuffle(game)

      assert length(game.shoe.cards) == 52
    end
  end

  describe "Game.normalize_deck_type!/1" do
    test "deck type is too high - normalizes the deck type to regular" do
      game = %Game{deck_type: 7}

      game = Game.normalize_deck_type!(game)
      assert game.deck_type == 1
    end

    test "deck type is too low - normalizes the deck type to regular" do
      game = %Game{deck_type: 0}

      game = Game.normalize_deck_type!(game)
      assert game.deck_type == 1
    end

    test "deck type is already normal - does not change the deck type" do
      game = %Game{deck_type: 1}

      game = Game.normalize_deck_type!(game)
      assert game.deck_type == 1
    end
  end

  describe "Game.normalize_num_decks!/1" do
    test "deck count is too high - normalizes the number of decks to 8" do
      game = %Game{num_decks: 9}

      game = Game.normalize_num_decks!(game)
      assert game.num_decks == 8
    end

    test "deck count is too low - normalizes the number of decks to 1" do
      game = %Game{num_decks: 0}

      game = Game.normalize_num_decks!(game)
      assert game.num_decks == 1
    end

    test "deck count is already normal - does not change the number of decks" do
      game = %Game{num_decks: 1}

      game = Game.normalize_num_decks!(game)
      assert game.num_decks == 1
    end
  end

  describe "Game.current_player_hand/1" do
    test "returns the current player hand" do
      seven = %Card{value: 6}
      player_hand = %PlayerHand{}
      player_hand_7_7 = %PlayerHand{hand: %Hand{cards: [seven, seven]}}
      game = %Game{player_hands: [player_hand, player_hand_7_7]}

      assert Game.current_player_hand(game) == player_hand
    end
  end

  describe "Game.all_bets/1" do
    test "returns 1000" do
      seven = %Card{value: 6}
      player_hand = %PlayerHand{bet: 1000}
      player_hand_7_7 = %PlayerHand{hand: %Hand{cards: [seven, seven]}}
      game = %Game{player_hands: [player_hand, player_hand_7_7]}

      assert Game.all_bets(game) == 1500
    end
  end

  describe "Game.more_hands_to_play?/1" do
    test "one player hand - returns false" do
      game = %Game{current_player_hand_index: 0, player_hands: [%PlayerHand{}]}

      refute Game.more_hands_to_play?(game)
    end

    test "two player hands, currently on the first hand - returns true" do
      game = %Game{current_player_hand_index: 0, player_hands: [%PlayerHand{}, %PlayerHand{}]}

      assert Game.more_hands_to_play?(game)
    end

    test "two player hands, currently on the second hand - returns false" do
      game = %Game{current_player_hand_index: 1, player_hands: [%PlayerHand{}, %PlayerHand{}]}

      refute Game.more_hands_to_play?(game)
    end
  end

  describe "Game.needs_to_play_dealer_hand?/1" do
    test "one non-busted, non-blackjack hand - returns true" do
      seven = %Card{value: 6}
      player_hand_7_7 = %PlayerHand{hand: %Hand{cards: [seven, seven]}}
      game = %Game{player_hands: [player_hand_7_7]}

      assert Game.needs_to_play_dealer_hand?(game)
    end

    test "one non-busted, non-blackjack hand and a busted hand - returns true" do
      seven = %Card{value: 6}
      ten = %Card{value: 9}
      player_hand_7_7 = %PlayerHand{hand: %Hand{cards: [seven, seven]}}
      player_hand_10_10_10 = %PlayerHand{hand: %Hand{cards: [ten, ten, ten]}, paid: true}
      game = %Game{player_hands: [player_hand_7_7, player_hand_10_10_10]}

      assert Game.needs_to_play_dealer_hand?(game)
    end

    test "one non-busted, non-blackjack hand and a blackjack hand - returns true" do
      ace = %Card{value: 0}
      seven = %Card{value: 6}
      ten = %Card{value: 9}
      player_hand_7_7 = %PlayerHand{hand: %Hand{cards: [seven, seven]}}
      player_hand_A_10 = %PlayerHand{hand: %Hand{cards: [ace, ten]}}
      game = %Game{player_hands: [player_hand_7_7, player_hand_A_10]}

      assert Game.needs_to_play_dealer_hand?(game)
    end

    test "one busted hand - returns false" do
      ten = %Card{value: 9}
      player_hand_10_10_10 = %PlayerHand{hand: %Hand{cards: [ten, ten, ten]}, paid: true}
      game = %Game{player_hands: [player_hand_10_10_10]}

      refute Game.needs_to_play_dealer_hand?(game)
    end

    test "one blackjack hand - returns false" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      player_hand_A_10 = %PlayerHand{hand: %Hand{cards: [ace, ten]}}
      game = %Game{player_hands: [player_hand_A_10]}

      refute Game.needs_to_play_dealer_hand?(game)
    end
  end

  describe "Game.unhide_dealer_down_card!/1" do
    test "dealer hand is blackjack - flips dealer down card" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      dealer_hand = %DealerHand{hand: %Hand{cards: [ace, ten]}, hide_down_card: true}
      game = %Game{dealer_hand: dealer_hand}

      assert game.dealer_hand.hide_down_card
      game = Game.unhide_dealer_down_card!(game)
      refute game.dealer_hand.hide_down_card
    end

    test "dealer hand needs to be played - flips dealer down card" do
      six = %Card{value: 5}
      seven = %Card{value: 6}
      ten = %Card{value: 9}
      dealer_hand = %DealerHand{hand: %Hand{cards: [ten, six]}, hide_down_card: true}
      player_hand_7_7 = %PlayerHand{hand: %Hand{cards: [seven, seven]}}
      game = %Game{dealer_hand: dealer_hand, player_hands: [player_hand_7_7]}

      assert game.dealer_hand.hide_down_card
      game = Game.unhide_dealer_down_card!(game)
      refute game.dealer_hand.hide_down_card
    end

    test "dealer hand does not need to be played and not blackjack - does not flip dealer down card" do
      eight = %Card{value: 7}
      ten = %Card{value: 9}
      dealer_hand = %DealerHand{hand: %Hand{cards: [ten, eight]}, hide_down_card: true}
      player_hand_10_10_10 = %PlayerHand{hand: %Hand{cards: [ten, ten, ten]}, paid: true}
      game = %Game{dealer_hand: dealer_hand, player_hands: [player_hand_10_10_10]}

      assert game.dealer_hand.hide_down_card
      game = Game.unhide_dealer_down_card!(game)
      assert game.dealer_hand.hide_down_card
    end
  end

  describe "Game.deal_dealer_cards!/1" do
    test "soft 17 - takes a card" do
      ace = %Card{value: 0}
      six = %Card{value: 5}
      shoe = %Shoe{cards: [ace]}
      dealer_hand_A_6 = %DealerHand{hand: %Hand{cards: [ace, six]}, hide_down_card: false}
      game = %Game{shoe: shoe, dealer_hand: dealer_hand_A_6}

      assert length(game.dealer_hand.hand.cards) == 2
      game = Game.deal_dealer_cards!(game)
      assert length(game.dealer_hand.hand.cards) == 3
    end

    test "soft 18 - takes no cards" do
      ace = %Card{value: 0}
      seven = %Card{value: 6}
      ten = %Card{value: 9}
      shoe = %Shoe{cards: [ace]}
      dealer_hand_10_7 = %DealerHand{hand: %Hand{cards: [ten, seven]}, hide_down_card: false}
      game = %Game{shoe: shoe, dealer_hand: dealer_hand_10_7}

      assert length(game.dealer_hand.hand.cards) == 2
      game = Game.deal_dealer_cards!(game)
      assert length(game.dealer_hand.hand.cards) == 2
    end

    test "hard 16 - takes a card" do
      ace = %Card{value: 0}
      six = %Card{value: 5}
      ten = %Card{value: 9}
      shoe = %Shoe{cards: [ace]}
      dealer_hand_10_6 = %DealerHand{hand: %Hand{cards: [ten, six]}, hide_down_card: false}
      game = %Game{shoe: shoe, dealer_hand: dealer_hand_10_6}

      assert length(game.dealer_hand.hand.cards) == 2
      game = Game.deal_dealer_cards!(game)
      assert length(game.dealer_hand.hand.cards) == 3
    end

    test "hard 17 - takes no cards" do
      ace = %Card{value: 0}
      seven = %Card{value: 6}
      ten = %Card{value: 9}
      shoe = %Shoe{cards: [ace]}
      dealer_hand_10_7 = %DealerHand{hand: %Hand{cards: [ten, seven]}, hide_down_card: false}
      game = %Game{shoe: shoe, dealer_hand: dealer_hand_10_7}

      assert length(game.dealer_hand.hand.cards) == 2
      game = Game.deal_dealer_cards!(game)
      assert length(game.dealer_hand.hand.cards) == 2
    end
  end

  describe "Game.normalize_current_bet!/1" do
    test "current bet has sufficient money and is in range - does not alter the current bet" do
      game = %Game{current_bet: 500}

      game = Game.normalize_current_bet!(game)
      assert game.current_bet == 500
    end

    test "current bet has insufficient money - alters the current bet" do
      game = %Game{current_bet: 10500}

      game = Game.normalize_current_bet!(game)
      assert game.current_bet == 10000
    end

    test "current bet is more than max bet - alters the current bet" do
      game = %Game{money: 10_000_000, current_bet: 10_000_500}

      game = Game.normalize_current_bet!(game)
      assert game.current_bet == 10_000_000
    end

    test "current bet is less than min bet - alters the current bet" do
      game = %Game{current_bet: 499}

      game = Game.normalize_current_bet!(game)
      assert game.current_bet == 500
    end
  end

  describe "Game.save_game!/1" do
    test "persists a save game file to disk" do
      game = %Game{}

      Game.save_game!(game)
      assert File.read!("bj.txt") == "1|10000|500|1|1"
    end
  end

  describe "Game.load_game!/1" do
    test "reads a persisted game file from disk" do
      game = %Game{num_decks: 0, money: 0, current_bet: 0}

      File.write(game.save_file, "1|10000|500")
      game = Game.load_game!(game)
      assert game.num_decks == 1
      assert game.money == 10000
      assert game.current_bet == 500
    end

    test "reads a persisted game file with face_type from disk" do
      game = %Game{num_decks: 0, money: 0, current_bet: 0}

      File.write(game.save_file, "2|5000|250|2")
      game = Game.load_game!(game)
      assert game.num_decks == 2
      assert game.money == 5000
      assert game.current_bet == 250
      assert game.face_type == 2
    end

    test "reads a persisted game file with face_type and deck_type from disk" do
      game = %Game{num_decks: 0, money: 0, current_bet: 0}

      File.write(game.save_file, "2|5000|250|2|3")
      game = Game.load_game!(game)
      assert game.num_decks == 2
      assert game.money == 5000
      assert game.current_bet == 250
      assert game.face_type == 2
      assert game.deck_type == 3
    end
  end

  describe "Game.pay_player_hands!/1" do
    test "dealer: 18, player: [19] - pays one player hand" do
      eight = %Card{value: 7}
      nine = %Card{value: 8}
      ten = %Card{value: 9}
      dealer_hand_10_8 = %DealerHand{hand: %Hand{cards: [ten, eight]}, hide_down_card: false}
      player_hand_10_9 = %PlayerHand{hand: %Hand{cards: [ten, nine]}}
      game = %Game{dealer_hand: dealer_hand_10_8, player_hands: [player_hand_10_9]}

      game = Game.pay_player_hands!(game)
      assert game.money == 10500
    end

    test "dealer: 18, player: [17, 19, 22] - pays one player hand" do
      two = %Card{value: 1}
      seven = %Card{value: 6}
      eight = %Card{value: 7}
      nine = %Card{value: 8}
      ten = %Card{value: 9}
      dealer_hand_10_8 = %DealerHand{hand: %Hand{cards: [ten, eight]}, hide_down_card: false}
      player_hand_10_7 = %PlayerHand{hand: %Hand{cards: [ten, seven]}}
      player_hand_10_9 = %PlayerHand{hand: %Hand{cards: [ten, nine]}}
      player_hand_10_2_10 = %PlayerHand{hand: %Hand{cards: [ten, two, ten]}, paid: true}

      game = %Game{
        dealer_hand: dealer_hand_10_8,
        player_hands: [player_hand_10_7, player_hand_10_9, player_hand_10_2_10]
      }

      game = Game.pay_player_hands!(game)
      assert game.money == 10000
    end

    test "dealer: 22, player: [17, 19, 22] - pays two player hands" do
      two = %Card{value: 1}
      seven = %Card{value: 6}
      nine = %Card{value: 8}
      ten = %Card{value: 9}

      dealer_hand_10_2_10 = %DealerHand{
        hand: %Hand{cards: [ten, two, ten]},
        hide_down_card: false
      }

      player_hand_10_7 = %PlayerHand{hand: %Hand{cards: [ten, seven]}}
      player_hand_10_9 = %PlayerHand{hand: %Hand{cards: [ten, nine]}}
      player_hand_10_2_10 = %PlayerHand{hand: %Hand{cards: [ten, two, ten]}, paid: true}

      game = %Game{
        dealer_hand: dealer_hand_10_2_10,
        player_hands: [player_hand_10_7, player_hand_10_9, player_hand_10_2_10]
      }

      game = Game.pay_player_hands!(game)
      assert game.money == 11000
    end
  end

  describe "Game.play_dealer_hand!/1" do
    test "needs to play the dealer hand - plays the dealer hand" do
      ace = %Card{value: 0}
      six = %Card{value: 5}
      nine = %Card{value: 8}
      ten = %Card{value: 9}
      shoe = %Shoe{cards: [ace]}
      dealer_hand_10_6 = %DealerHand{hand: %Hand{cards: [ten, six]}, hide_down_card: false}
      player_hand_10_9 = %PlayerHand{hand: %Hand{cards: [ten, nine]}}
      game = %Game{shoe: shoe, dealer_hand: dealer_hand_10_6, player_hands: [player_hand_10_9]}

      game = Game.play_dealer_hand!(game)
      assert game.money == 10500
    end

    test "does not need to play the dealer hand - does not play, player busted and already paid" do
      ace = %Card{value: 0}
      eight = %Card{value: 7}
      ten = %Card{value: 9}
      shoe = %Shoe{cards: [ace]}
      dealer_hand_10_8 = %DealerHand{hand: %Hand{cards: [ten, eight]}, hide_down_card: false}
      player_hand_10_10_10 = %PlayerHand{hand: %Hand{cards: [ten, ten, ten]}, paid: true}

      game = %Game{
        shoe: shoe,
        dealer_hand: dealer_hand_10_8,
        player_hands: [player_hand_10_10_10]
      }

      game = Game.play_dealer_hand!(game)
      assert game.money == 10000
    end
  end

  describe "Game.clear/1" do
    test "outputs escape sequences to clear terminal" do
    end
  end

  describe "Game.format_money/1" do
    test "outputs money as a formatted string - 1.0" do
      assert Game.format_money(1.0) == "1.00"
    end

    test "outputs money as a formatted string - 1.5" do
      assert Game.format_money(1.5) == "1.50"
    end

    test "outputs money as a formatted string - 1.75" do
      assert Game.format_money(1.75) == "1.75"
    end

    test "outputs money as a formatted string - 1.234" do
      assert Game.format_money(1.234) == "1.23"
    end
  end

  describe "Game.to_s/1" do
    test "returns game as a string" do
      ace = %Card{value: 0}
      six = %Card{value: 5}
      nine = %Card{value: 8}
      ten = %Card{value: 9}
      dealer_hand_10_6 = %DealerHand{hand: %Hand{cards: [ten, six]}, hide_down_card: false}
      player_hand_10_9 = %PlayerHand{hand: %Hand{cards: [nine, ten]}}
      player_hand_A_10 = %PlayerHand{hand: %Hand{cards: [ace, ten]}}

      game = %Game{
        dealer_hand: dealer_hand_10_6,
        player_hands: [player_hand_10_9, player_hand_A_10]
      }

      expected =
        "\r\n Dealer:\r\n 🂪 🂦 ⇒  16\r\n\r\n Player $100.00:\r\n 🂩 🂪 ⇒  19  $5.00 ⇐  \r\n\r\n 🂡 🂪 ⇒  21  $5.00  \r\n\r\n"

      assert Game.to_s(game) == expected
    end
  end

  describe "Game.draw_hands/1" do
    test "draws the game as a string" do
      ace = %Card{value: 0}
      six = %Card{value: 5}
      nine = %Card{value: 8}
      ten = %Card{value: 9}
      dealer_hand_10_6 = %DealerHand{hand: %Hand{cards: [ten, six]}, hide_down_card: false}
      player_hand_10_9 = %PlayerHand{hand: %Hand{cards: [nine, ten]}}
      player_hand_A_10 = %PlayerHand{hand: %Hand{cards: [ace, ten]}}

      game = %Game{
        dealer_hand: dealer_hand_10_6,
        player_hands: [player_hand_10_9, player_hand_A_10]
      }

      expected =
        "\e[H\e[2J\r\n Dealer:\r\n 🂪 🂦 ⇒  16\r\n\r\n Player $100.00:\r\n 🂩 🂪 ⇒  19  $5.00 ⇐  \r\n\r\n 🂡 🂪 ⇒  21  $5.00  \r\n\r\n"

      assert capture_io(fn -> Game.draw_hands(game) end) == expected
    end
  end
end
