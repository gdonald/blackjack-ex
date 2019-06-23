defmodule DealerHandSpec do
  use ESpec
  alias Blackjack.{DealerHand, Card, Hand}

  describe "DealerHand.get_value/2" do
    let :ace, do: %Card{value: 0}
    let :ten, do: %Card{value: 9}
    let :hand, do: %Hand{cards: [ace(), ten()]}

    context "down card is hidden" do
      let :dealer_hand, do: %DealerHand{hand: hand()}

      it "a soft count with [🂡, 🂫] and hidden down card returns 10" do
        expect DealerHand.get_value(dealer_hand(), :soft)
               |> to(eq 10)
      end

      it "a hard count with [🂡, 🂫] and hidden down card returns 10" do
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
end
