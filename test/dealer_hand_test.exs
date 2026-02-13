defmodule DealerHandTest do
  use ExUnit.Case
  alias Blackjack.{DealerHand, Card, Game, Hand, Shoe}

  describe "DealerHand.get_value/2" do
    test "down card is hidden - soft count with [🂫, 🂡] returns 10" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      hand = %Hand{cards: [ten, ace]}
      dealer_hand = %DealerHand{hand: hand}

      assert DealerHand.get_value(dealer_hand, :soft) == 10
    end

    test "down card is hidden - hard count with [🂫, 🂡] returns 10" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      hand = %Hand{cards: [ten, ace]}
      dealer_hand = %DealerHand{hand: hand}

      assert DealerHand.get_value(dealer_hand, :hard) == 10
    end

    test "force hard count - soft count with [🂡, 🂡, 🂫] returns 12" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      dealer_hand = %DealerHand{
        hand: %Hand{
          cards: [ace, ace, ten]
        },
        hide_down_card: false
      }

      assert DealerHand.get_value(dealer_hand, :soft) == 12
    end

    test "down card is visible - soft count with [🂡, 🂫] returns 21" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      hand = %Hand{cards: [ten, ace]}
      dealer_hand = %DealerHand{hand: hand, hide_down_card: false}

      assert DealerHand.get_value(dealer_hand, :soft) == 21
    end

    test "down card is visible - hard count with [🂡, 🂫] returns 11" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      hand = %Hand{cards: [ten, ace]}
      dealer_hand = %DealerHand{hand: hand, hide_down_card: false}

      assert DealerHand.get_value(dealer_hand, :hard) == 11
    end
  end

  describe "DealerHand.card_val/3" do
    test "down card is hidden - returns 0 for first card" do
      ten = %Card{value: 9}
      dealer_hand = %DealerHand{hide_down_card: true}

      assert DealerHand.card_val(dealer_hand, 0, ten) == 10
    end

    test "down card is hidden - returns 10 for second card" do
      ten = %Card{value: 9}
      dealer_hand = %DealerHand{hide_down_card: true}

      assert DealerHand.card_val(dealer_hand, 1, ten) == 0
    end

    test "down card is visible - returns 10 for first card" do
      ten = %Card{value: 9}
      dealer_hand = %DealerHand{hide_down_card: false}

      assert DealerHand.card_val(dealer_hand, 0, ten) == 10
    end

    test "down card is visible - returns 10 for second card" do
      ten = %Card{value: 9}
      dealer_hand = %DealerHand{hide_down_card: false}

      assert DealerHand.card_val(dealer_hand, 1, ten) == 10
    end
  end

  describe "DealerHand.is_busted?/1" do
    test "returns true" do
      eight = %Card{value: 7}
      dealer_hand = %DealerHand{
        hide_down_card: false,
        hand: %Hand{
          cards: [eight, eight, eight]
        }
      }

      assert DealerHand.is_busted?(dealer_hand)
    end

    test "returns false" do
      eight = %Card{value: 7}
      dealer_hand = %DealerHand{
        hide_down_card: false,
        hand: %Hand{
          cards: [eight, eight]
        }
      }

      refute DealerHand.is_busted?(dealer_hand)
    end
  end

  describe "DealerHand.up_card_is_ace?/1" do
    test "returns true" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      dealer_hand = %DealerHand{
        hand: %Hand{
          cards: [ace, ten]
        }
      }

      assert DealerHand.up_card_is_ace?(dealer_hand)
    end

    test "returns false" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      dealer_hand = %DealerHand{
        hand: %Hand{
          cards: [ten, ace]
        }
      }

      refute DealerHand.up_card_is_ace?(dealer_hand)
    end
  end

  describe "DealerHand.card_face/3" do
    test "down card is hidden - returns face for first card" do
      ten = %Card{value: 9}
      dealer_hand = %DealerHand{hide_down_card: true}

      assert DealerHand.card_face(dealer_hand, 0, ten, 1) == "🂪"
    end

    test "down card is hidden - returns card back for second card" do
      ten = %Card{value: 9}
      dealer_hand = %DealerHand{hide_down_card: true}

      assert DealerHand.card_face(dealer_hand, 1, ten, 1) == "🂠"
    end

    test "down card is visible - returns face for first card" do
      ten = %Card{value: 9}
      dealer_hand = %DealerHand{hide_down_card: false}

      assert DealerHand.card_face(dealer_hand, 0, ten, 1) == "🂪"
    end

    test "down card is visible - returns face for second card" do
      ten = %Card{value: 9}
      dealer_hand = %DealerHand{hide_down_card: false}

      assert DealerHand.card_face(dealer_hand, 1, ten, 1) == "🂪"
    end
  end

  describe "DealerHand.to_s/1" do
    test "down card is hidden - returns face for first card" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      hand = %Hand{cards: [ten, ace]}
      dealer_hand = %DealerHand{hand: hand, hide_down_card: true}

      assert DealerHand.to_s(dealer_hand, 1) == " 🂪 🂠 ⇒  10"
    end

    test "down card is visible - returns face for second card" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      hand = %Hand{cards: [ten, ace]}
      dealer_hand = %DealerHand{hand: hand, hide_down_card: false}

      assert DealerHand.to_s(dealer_hand, 1) == " 🂪 🂡 ⇒  21"
    end
  end

  describe "DealerHand.deal_card!/1" do
    test "removes a shoe card and puts it in the hand" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      shoe = %Shoe{cards: [ace, ten]}
      hand = %Hand{}
      dealer_hand = %DealerHand{hand: hand}
      game = %Game{shoe: shoe, dealer_hand: dealer_hand}

      assert length(dealer_hand.hand.cards) == 0
      assert length(shoe.cards) == 2

      game = DealerHand.deal_card!(game)
      assert length(game.dealer_hand.hand.cards) == 1
      assert length(game.shoe.cards) == 1

      [card | _rest] = game.dealer_hand.hand.cards
      assert card == ace
      [card | _rest] = game.shoe.cards
      assert card == ten
    end
  end
end
