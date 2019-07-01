defmodule DealerHandSpec do
  use ESpec
  alias Blackjack.{DealerHand, Card, Game, Hand, Shoe}

  let :ace, do: %Card{value: 0}
  let :ten, do: %Card{value: 9}
  let :hand, do: %Hand{cards: [ten(), ace()]}

  describe "DealerHand.get_value/2" do
    context "down card is hidden" do
      let :dealer_hand, do: %DealerHand{hand: hand()}

      it "a soft count with [🂫, 🂡] and hidden down card returns 10" do
        expect DealerHand.get_value(dealer_hand(), :soft)
               |> to(eq 10)
      end

      it "a hard count with [🂫, 🂡] and hidden down card returns 10" do
        expect DealerHand.get_value(dealer_hand(), :hard)
               |> to(eq 10)
      end
    end

    context "force hard count" do
      let :dealer_hand,
          do: %DealerHand{
            hand: %Hand{
              cards: [ace(), ace(), ten()]
            },
            hide_down_card: false
          }

      it "a soft count with [🂡, 🂡, 🂫] returns 12" do
        expect DealerHand.get_value(dealer_hand(), :soft)
               |> to(eq 12)
      end
    end

    context "down card is visible" do
      let :dealer_hand, do: %DealerHand{hand: hand(), hide_down_card: false}

      it "a soft count with [🂡, 🂫] and unhidden down card returns 21" do
        expect DealerHand.get_value(dealer_hand(), :soft)
               |> to(eq 21)
      end

      it "a hard count with [🂡, 🂫] and unhidden down card returns 11" do
        expect DealerHand.get_value(dealer_hand(), :hard)
               |> to(eq 11)
      end
    end
  end

  describe "DealerHand.card_val/3" do
    context "down card is hidden" do
      let :dealer_hand, do: %DealerHand{hide_down_card: true}

      it "returns 0 for first card" do
        expect DealerHand.card_val(dealer_hand(), 0, ten())
               |> to(eq 10)
      end

      it "returns 10 for second card" do
        expect DealerHand.card_val(dealer_hand(), 1, ten())
               |> to(eq 0)
      end
    end

    context "down card is visible" do
      let :dealer_hand, do: %DealerHand{hide_down_card: false}

      it "returns 10 for first card" do
        expect DealerHand.card_val(dealer_hand(), 0, ten())
               |> to(eq 10)
      end

      it "returns 10 for second card" do
        expect DealerHand.card_val(dealer_hand(), 1, ten())
               |> to(eq 10)
      end
    end
  end

  describe "DealerHand.is_busted?/1" do
    let :eight, do: %Card{value: 7}

    it "returns true" do
      dealer_hand = %DealerHand{
        hide_down_card: false,
        hand: %Hand{
          cards: [eight(), eight(), eight()]
        }
      }
      expect DealerHand.is_busted?(dealer_hand)
             |> to(be_true())
    end

    it "returns false" do
      dealer_hand = %DealerHand{
        hide_down_card: false,
        hand: %Hand{
          cards: [eight(), eight()]
        }
      }
      expect DealerHand.is_busted?(dealer_hand)
             |> to(be_false())
    end
  end

  describe "DealerHand.up_card_is_ace?/1" do
    it "returns true" do
      dealer_hand = %DealerHand{
        hand: %Hand{
          cards: [ace(), ten()]
        }
      }
      expect DealerHand.up_card_is_ace?(dealer_hand)
             |> to(be_true())
    end

    it "returns false" do
      dealer_hand = %DealerHand{
        hand: %Hand{
          cards: [ten(), ace()]
        }
      }
      expect DealerHand.up_card_is_ace?(dealer_hand)
             |> to(be_false())
    end
  end

  describe "DealerHand.card_face/3" do
    context "down card is hidden" do
      let :dealer_hand, do: %DealerHand{hide_down_card: true}

      it "returns face for first card" do
        expect DealerHand.card_face(dealer_hand(), 0, ten())
               |> to(eq "🂪")
      end

      it "returns card back for second card" do
        expect DealerHand.card_face(dealer_hand(), 1, ten())
               |> to(eq "🂠")
      end
    end

    context "down card is visible" do
      let :dealer_hand, do: %DealerHand{hide_down_card: false}

      it "returns face for first card" do
        expect DealerHand.card_face(dealer_hand(), 0, ten())
               |> to(eq "🂪")
      end

      it "returns face for second card" do
        expect DealerHand.card_face(dealer_hand(), 1, ten())
               |> to(eq "🂪")
      end
    end
  end

  describe "DealerHand.to_s/1" do
    context "down card is hidden" do
      let :dealer_hand, do: %DealerHand{hand: hand(), hide_down_card: true}

      it "returns face for first card" do
        expect DealerHand.to_s(dealer_hand())
               |> to(eq " 🂪 🂠 ⇒  10")
      end
    end

    context "down card is visible" do
      let :dealer_hand, do: %DealerHand{hand: hand(), hide_down_card: false}

      it "returns face for second card" do
        expect DealerHand.to_s(dealer_hand())
               |> to(eq " 🂪 🂡 ⇒  21")
      end
    end
  end

  describe "DealerHand.deal_card!/1" do
    let :shoe, do: %Shoe{cards: [ace(), ten()]}
    let :hand, do: %Hand{}
    let :dealer_hand, do: %DealerHand{hand: hand()}
    let :game, do: %Game{shoe: shoe(), dealer_hand: dealer_hand()}

    it "removes a shoe card and puts it in the hand" do
      expect length(dealer_hand().hand.cards)
             |> to(eq 0)
      expect length(shoe().cards)
             |> to(eq 2)

      game = DealerHand.deal_card!(game())
      expect length(game.dealer_hand.hand.cards)
             |> to(eq 1)
      expect length(game.shoe.cards)
             |> to(eq 1)

      [card | _rest] = game.dealer_hand.hand.cards
      expect card
             |> to(eq ace())
      [card | _rest] = game.shoe.cards
      expect card
             |> to(eq ten())
    end
  end
end
