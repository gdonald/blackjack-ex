defmodule PlayerHandTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  alias Blackjack.{Card, Game, Hand, PlayerHand, Shoe}

  describe "PlayerHand.deal_card!/2" do
    test "returns stuff" do
      ace = %Card{value: 0}
      eight = %Card{value: 7}
      shoe = %Shoe{cards: [ace]}
      player_hand_8_8 = %PlayerHand{hand: %Hand{cards: [eight, eight]}}
      game = %Game{shoe: shoe, player_hands: [player_hand_8_8]}

      {player_hand, game} = PlayerHand.deal_card!(player_hand_8_8, game)

      assert length(player_hand.hand.cards) == 3
      assert length(game.shoe.cards) == 0
    end
  end

  describe "PlayerHand.draw_actions/2" do
    test "returns stuff" do
      eight = %Card{value: 7}
      game = %Game{}
      player_hand_8_8 = %PlayerHand{hand: %Hand{cards: [eight, eight]}}

      output = capture_io(fn ->
        PlayerHand.draw_actions(game, player_hand_8_8)
      end)

      assert output == " (H) Hit  (S) Stand  (P) Split  (D) Double  \r\n"
    end
  end

  describe "PlayerHand.pay!/3" do
    test "paid hand - returns the hand" do
      player_hand = %PlayerHand{paid: true}

      assert PlayerHand.pay!(player_hand, false, 21) == {player_hand, 0}
    end

    test "unpaid, tied hands - returns {player_hand, 0}" do
      ten = %Card{value: 9}
      eight = %Card{value: 7}
      player_hand_10_8 = %PlayerHand{hand: %Hand{cards: [ten, eight]}}

      {player_hand, money} = PlayerHand.pay!(player_hand_10_8, 18, false)
      assert player_hand.paid
      assert player_hand.status == :push
      assert money == 0
    end

    test "unpaid, player has 12, dealer busted - returns {player_hand, 500}" do
      ace = %Card{value: 0}
      player_hand_A_A = %PlayerHand{hand: %Hand{cards: [ace, ace]}}

      {player_hand, money} = PlayerHand.pay!(player_hand_A_A, 22, true)
      assert player_hand.paid
      assert player_hand.status == :won
      assert money == 500
    end

    test "unpaid, player has blackjack, dealer has 20 - returns {player_hand, 750}" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      player_hand_A_10 = %PlayerHand{hand: %Hand{cards: [ace, ten]}}

      {player_hand, money} = PlayerHand.pay!(player_hand_A_10, 20, false)
      assert player_hand.paid
      assert player_hand.status == :won
      assert money == 750
    end

    test "unpaid, player has 20, dealer has 19 - returns {player_hand, 500}" do
      ten = %Card{value: 9}
      player_hand_10_10 = %PlayerHand{hand: %Hand{cards: [ten, ten]}}

      {player_hand, money} = PlayerHand.pay!(player_hand_10_10, 19, false)
      assert player_hand.paid
      assert player_hand.status == :won
      assert money == 500
    end

    test "unpaid, player has 18, dealer has 20 - returns {player_hand, -500}" do
      ten = %Card{value: 9}
      eight = %Card{value: 7}
      player_hand_10_8 = %PlayerHand{hand: %Hand{cards: [ten, eight]}}

      {player_hand, money} = PlayerHand.pay!(player_hand_10_8, 20, false)
      assert player_hand.paid
      assert player_hand.status == :lost
      assert money == -500
    end
  end

  describe "PlayerHand.promoted_bet/1" do
    test "blackjack - is promoted" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      player_hand_A_10 = %PlayerHand{hand: %Hand{cards: [ace, ten]}}

      assert PlayerHand.promoted_bet(player_hand_A_10) == 750
    end

    test "non-blackjack - is not promoted" do
      ten = %Card{value: 9}
      seven = %Card{value: 6}
      player_hand_10_7 = %PlayerHand{hand: %Hand{cards: [ten, seven]}}

      assert PlayerHand.promoted_bet(player_hand_10_7) == 500
    end
  end

  describe "PlayerHand.get_value/2" do
    test "a soft count with [🂡, 🂫] returns 21" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      player_hand_A_10 = %PlayerHand{hand: %Hand{cards: [ace, ten]}}

      assert PlayerHand.get_value(player_hand_A_10, :soft) == 21
    end

    test "a hard count with [🂡, 🂫] returns 11" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      player_hand_A_10 = %PlayerHand{hand: %Hand{cards: [ace, ten]}}

      assert PlayerHand.get_value(player_hand_A_10, :hard) == 11
    end

    test "force hard count - soft count with [🂡, 🂡, 🂫] returns 12" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      player_hand_A_A_10 = %PlayerHand{hand: %Hand{cards: [ace, ace, ten]}}

      assert PlayerHand.get_value(player_hand_A_A_10, :soft) == 12
    end
  end

  describe "PlayerHand.is_busted?/1" do
    test "returns true" do
      eight = %Card{value: 7}
      player_hand_8_8_8 = %PlayerHand{hand: %Hand{cards: [eight, eight, eight]}}

      assert PlayerHand.is_busted?(player_hand_8_8_8)
    end

    test "returns false" do
      eight = %Card{value: 7}
      player_hand_8_8 = %PlayerHand{hand: %Hand{cards: [eight, eight]}}

      refute PlayerHand.is_busted?(player_hand_8_8)
    end
  end

  describe "PlayerHand.is_played?/1" do
    test "returns true for played hand" do
      player_hand = %PlayerHand{played: true}

      assert PlayerHand.is_played?(player_hand)
    end

    test "returns true for stood hand" do
      player_hand = %PlayerHand{stood: true}

      assert PlayerHand.is_played?(player_hand)
    end

    test "returns true for blackjack" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      player_hand_A_10 = %PlayerHand{hand: %Hand{cards: [ace, ten]}}

      assert PlayerHand.is_played?(player_hand_A_10)
    end

    test "returns true for soft 21" do
      seven = %Card{value: 6}
      player_hand_7_7_7 = %PlayerHand{hand: %Hand{cards: [seven, seven, seven]}}

      assert PlayerHand.is_played?(player_hand_7_7_7)
    end

    test "returns true for hard 21" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      player_hand_A_10_10 = %PlayerHand{hand: %Hand{cards: [ace, ten, ten]}}

      assert PlayerHand.is_played?(player_hand_A_10_10)
    end

    test "returns true for busted hand" do
      eight = %Card{value: 7}
      player_hand_8_8_8 = %PlayerHand{hand: %Hand{cards: [eight, eight, eight]}}

      assert PlayerHand.is_busted?(player_hand_8_8_8)
    end
  end

  describe "PlayerHand.handle_busted_hand!/2" do
    test "busted hand - returns updated player_hand and game" do
      eight = %Card{value: 7}
      player_hand_8_8_8 = %PlayerHand{hand: %Hand{cards: [eight, eight, eight]}}
      game = %Game{}

      {player_hand, game} = PlayerHand.handle_busted_hand!(player_hand_8_8_8, game)
      assert player_hand.paid
      assert player_hand.status == :lost
      assert game.money == 9500
    end

    test "not busted hand - returns updated player_hand and game" do
      eight = %Card{value: 7}
      player_hand_8_8 = %PlayerHand{hand: %Hand{cards: [eight, eight]}}
      game = %Game{}

      {player_hand, game} = PlayerHand.handle_busted_hand!(player_hand_8_8, game)
      refute player_hand.paid
      assert player_hand.status == :unknown
      assert game.money == 10000
    end
  end

  describe "PlayerHand.is_done?/2" do
    test "returns true" do
      eight = %Card{value: 7}
      hand_8_8 = %Hand{cards: [eight, eight]}
      player_hand = %PlayerHand{hand: hand_8_8, played: true}

      {result, player_hand, _game} = PlayerHand.is_done?(player_hand, %Game{})
      assert result
      assert player_hand.played
    end

    test "returns false" do
      eight = %Card{value: 7}
      player_hand_8_8 = %PlayerHand{hand: %Hand{cards: [eight, eight]}}

      {result, player_hand, _game} = PlayerHand.is_done?(player_hand_8_8, %Game{})
      refute result
      refute player_hand.played
    end
  end

  describe "PlayerHand.can_split?/2" do
    test "a stood hand - cannot split" do
      player_hand = %PlayerHand{stood: true}

      refute PlayerHand.can_split?(player_hand, %Game{})
    end

    test "cannot split more than 7 hands - returns false" do
      game = %Game{player_hands: (for _ <- 1..7, do: %PlayerHand{})}

      [player_hand | _rest] = game.player_hands
      refute PlayerHand.can_split?(player_hand, game)
    end

    test "cannot split without enough money - returns false" do
      ten = %Card{value: 9}
      player_hand_10_10 = %PlayerHand{hand: %Hand{cards: [ten, ten]}}
      game = %Game{money: 1499, player_hands: (for _ <- 1..2, do: player_hand_10_10)}

      [player_hand | _rest] = game.player_hands
      refute PlayerHand.can_split?(player_hand, game)
    end

    test "cannot split a hand with different card values - returns false" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      player_hand_A_10 = %PlayerHand{hand: %Hand{cards: [ace, ten]}}

      refute PlayerHand.can_split?(player_hand_A_10, %Game{})
    end

    test "cannot split a hand with more than 2 cards - returns false" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      player_hand_A_A_10 = %PlayerHand{hand: %Hand{cards: [ace, ace, ten]}}

      refute PlayerHand.can_split?(player_hand_A_A_10, %Game{})
    end

    test "can split a hand with matching card values - returns true" do
      ten = %Card{value: 9}
      player_hand_10_10 = %PlayerHand{hand: %Hand{cards: [ten, ten]}}

      assert PlayerHand.can_split?(player_hand_10_10, %Game{})
    end
  end

  describe "PlayerHand.can_double?/2" do
    test "a stood hand - cannot double" do
      player_hand = %PlayerHand{stood: true}

      refute PlayerHand.can_double?(player_hand, %Game{})
    end

    test "cannot double a hand with more than 2 cards - returns false" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      player_hand_A_A_10 = %PlayerHand{hand: %Hand{cards: [ace, ace, ten]}}
      game = %Game{player_hands: [player_hand_A_A_10]}

      [player_hand | _rest] = game.player_hands
      refute PlayerHand.can_double?(player_hand, game)
    end

    test "cannot double a blackjack - returns false" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      player_hand_A_10 = %PlayerHand{hand: %Hand{cards: [ace, ten]}}
      game = %Game{player_hands: [player_hand_A_10]}

      [player_hand | _rest] = game.player_hands
      refute PlayerHand.can_double?(player_hand, game)
    end

    test "cannot double without enough money - returns false" do
      ace = %Card{value: 0}
      eight = %Card{value: 7}
      player_hand_A_8 = %PlayerHand{hand: %Hand{cards: [ace, eight]}}
      game = %Game{money: 1499, player_hands: (for _ <- 1..2, do: player_hand_A_8)}

      [player_hand | _rest] = game.player_hands
      refute PlayerHand.can_double?(player_hand, game)
    end

    test "can double - returns true" do
      ace = %Card{value: 0}
      eight = %Card{value: 7}
      player_hand_A_8 = %PlayerHand{hand: %Hand{cards: [ace, eight]}}
      game = %Game{money: 1500, player_hands: (for _ <- 1..2, do: player_hand_A_8)}

      [player_hand | _rest] = game.player_hands
      assert PlayerHand.can_double?(player_hand, game)
    end
  end

  describe "PlayerHand.can_stand?/1" do
    test "a non-stood hand - can stand" do
      ten = %Card{value: 9}
      player_hand_10_10 = %PlayerHand{hand: %Hand{cards: [ten, ten]}}

      assert PlayerHand.can_stand?(player_hand_10_10)
    end

    test "a stood hand - cannot stand" do
      player_hand = %PlayerHand{stood: true}

      refute PlayerHand.can_stand?(player_hand)
    end

    test "a busted hand - returns false" do
      ten = %Card{value: 9}
      player_hand_10_10_10 = %PlayerHand{hand: %Hand{cards: [ten, ten, ten]}}

      refute PlayerHand.can_stand?(player_hand_10_10_10)
    end

    test "a blackjack - returns false" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      player_hand_A_10 = %PlayerHand{hand: %Hand{cards: [ace, ten]}}

      refute PlayerHand.can_stand?(player_hand_A_10)
    end
  end

  describe "PlayerHand.can_hit?/1" do
    test "a non-stood hand - can stand" do
      ten = %Card{value: 9}
      player_hand_10_10 = %PlayerHand{hand: %Hand{cards: [ten, ten]}}

      assert PlayerHand.can_hit?(player_hand_10_10)
    end

    test "a stood hand - cannot stand" do
      player_hand = %PlayerHand{stood: true}

      refute PlayerHand.can_hit?(player_hand)
    end

    test "a played hand - cannot stand" do
      player_hand = %PlayerHand{played: true}

      refute PlayerHand.can_hit?(player_hand)
    end

    test "a hard 21 - returns false" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      player_hand_A_10_10 = %PlayerHand{hand: %Hand{cards: [ace, ten, ten]}}

      refute PlayerHand.can_hit?(player_hand_A_10_10)
    end

    test "a blackjack - returns false" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      player_hand_A_10 = %PlayerHand{hand: %Hand{cards: [ace, ten]}}

      refute PlayerHand.can_hit?(player_hand_A_10)
    end

    test "a busted hand - returns false" do
      ten = %Card{value: 9}
      player_hand_10_10_10 = %PlayerHand{hand: %Hand{cards: [ten, ten, ten]}}

      refute PlayerHand.can_hit?(player_hand_10_10_10)
    end
  end

  describe "PlayerHand.get_sign/1" do
    test "returns a minus" do
      assert PlayerHand.get_sign(%PlayerHand{status: :lost}) == "-"
    end

    test "returns a plus" do
      assert PlayerHand.get_sign(%PlayerHand{status: :won}) == "+"
    end

    test "returns an empty string" do
      assert PlayerHand.get_sign(%PlayerHand{}) == ""
    end
  end

  describe "PlayerHand.get_bet/1" do
    test "returns the bet as a formatted string" do
      assert PlayerHand.get_bet(%PlayerHand{}) == "$5.00"
    end
  end

  describe "PlayerHand.get_arrow/3" do
    test "returns an arrow" do
      assert PlayerHand.get_arrow(%PlayerHand{}, 0, %Game{}) == " ⇐"
    end

    test "returns an empty string for non-current index" do
      assert PlayerHand.get_arrow(%PlayerHand{}, 1, %Game{}) == ""
    end

    test "returns an empty string for non-current hand" do
      assert PlayerHand.get_arrow(%PlayerHand{}, 0, %Game{current_player_hand_index: 1}) == ""
    end

    test "returns an empty string for played hand" do
      assert PlayerHand.get_arrow(%PlayerHand{played: true}, 0, %Game{}) == ""
    end
  end

  describe "PlayerHand.get_status/1" do
    test "returns Busted!" do
      ten = %Card{value: 9}
      hand_10_10_10 = %Hand{cards: [ten, ten, ten]}
      player_hand = %PlayerHand{hand: hand_10_10_10, status: :lost}

      assert PlayerHand.get_status(player_hand) == "Busted!"
    end

    test "returns Lose!" do
      ten = %Card{value: 9}
      hand_10_10 = %Hand{cards: [ten, ten]}
      player_hand = %PlayerHand{hand: hand_10_10, status: :lost}

      assert PlayerHand.get_status(player_hand) == "Lose!"
    end

    test "returns Blackjack!" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      hand_A_10 = %Hand{cards: [ace, ten]}
      player_hand = %PlayerHand{hand: hand_A_10, status: :won}

      assert PlayerHand.get_status(player_hand) == "Blackjack!"
    end

    test "returns Won!" do
      ten = %Card{value: 9}
      hand_10_10 = %Hand{cards: [ten, ten]}
      player_hand = %PlayerHand{hand: hand_10_10, status: :won}

      assert PlayerHand.get_status(player_hand) == "Won!"
    end

    test "returns Push" do
      player_hand = %PlayerHand{status: :push}

      assert PlayerHand.get_status(player_hand) == "Push"
    end
  end

  describe "PlayerHand.to_s/3" do
    test "returns player hand as a string" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      player_hand_A_10 = %PlayerHand{hand: %Hand{cards: [ace, ten]}}

      assert PlayerHand.to_s(player_hand_A_10, 0, %Game{}) == " 🂡 🂪 ⇒  21  $5.00 ⇐  \r\n\r\n"
    end
  end
end
