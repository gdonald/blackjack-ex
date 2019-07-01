defmodule HandSpec do
  use ESpec
  alias Blackjack.{Card, Hand, Shoe}

  let :ace, do: %Card{value: 0}
  let :ten, do: %Card{value: 9}

  describe "Hand.is_blackjack?/1" do
    let :hand_1, do: %Hand{cards: [ace(), ten()]}
    let :hand_2, do: %Hand{cards: [ten(), ace()]}
    let :hand_3, do: %Hand{cards: [ten()]}
    let :hand_4, do: %Hand{cards: [ten(), ace(), ten()]}

    it "[🂡, 🂫] returns true" do
      expect(Hand.is_blackjack?(hand_1()))
      |> to(be_true())
    end

    it "[🂫, 🂡] returns true" do
      expect(Hand.is_blackjack?(hand_2()))
      |> to(be_true())
    end

    it "[🂫] returns false" do
      expect(Hand.is_blackjack?(hand_3()))
      |> to(be_false())
    end

    it "[🂫, 🂡, 🂫] returns false" do
      expect(Hand.is_blackjack?(hand_4()))
      |> to(be_false())
    end
  end

  describe "Hand.final_count/2" do
    let :values, do: [1, 10]

    it "a soft count with [1, 10] returns 21" do
      expect Hand.final_count(values(), :soft)
             |> to(eq 21)
    end

    it "a hard count with [1, 10] returns 11" do
      expect Hand.final_count(values(), :hard)
             |> to(eq 11)
    end
  end

  describe "Hand.deal_card!/2" do
    let :shoe, do: %Shoe{cards: [ace(), ten()]}
    let :hand, do: %Hand{}

    it "removes a shoe card and puts it in the hand" do
      expect length(hand().cards)
             |> to(eq 0)
      expect length(shoe().cards)
             |> to(eq 2)

      {hand, shoe} = Hand.deal_card!(hand(), shoe())
      expect length(hand.cards)
             |> to(eq 1)
      expect length(shoe.cards)
             |> to(eq 1)

      [card | _rest] = hand.cards
      expect card
             |> to(eq ace())
      [card | _rest] = shoe.cards
      expect card
             |> to(eq ten())
    end
  end
end
