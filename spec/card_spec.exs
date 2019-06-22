defmodule CardSpec do
  use ESpec
  alias Blackjack.Card

  let :ace, do: %Card{value: 0}
  let :ten, do: %Card{value: 9}
  let :nine, do: %Card{value: 8}

  describe "Card.to_s/1" do
    it "returns an Ace of Spades" do
      expect Card.to_s(ace()) |> to(eq "🂡")
    end

    it "returns a card back" do
      card = %Card{value: 13, suit_value: 0}
      expect Card.to_s(card) |> to(eq "🂠")
    end
  end

  describe "Card.is_ace?/1" do
    it "returns true" do
      expect Card.is_ace?(ace()) |> to(be_true())
    end

    it "returns false" do
      card = %Card{value: 1, suit_value: 0}
      expect Card.is_ace?(card) |> to(be_false())
    end
  end

  describe "Card.is_ten?/1" do
    it "returns true" do
      expect Card.is_ten?(ten()) |> to(be_true())
    end

    it "returns false" do
      expect Card.is_ten?(nine()) |> to(be_false())
    end
  end

  describe "Card.val/1" do
    it "returns 9" do
      expect Card.val(nine()) |> to(eq 9)
    end

    it "returns 10" do
      expect Card.val(ten()) |> to(eq 10)
    end
  end

  describe "Card.one_or_eleven/3" do
    it "doing a soft count and a total of 11 returns 1" do
      expect Card.one_or_eleven(:soft, 1, 11)
             |> to(eq 1)
    end

    it "doing a soft count and a total of 10 returns 11" do
      expect Card.one_or_eleven(:soft, 1, 10)
             |> to(eq 11)
    end

    it "doing a hard count with a total of 11 returns 1" do
      expect Card.one_or_eleven(:hard, 1, 11)
             |> to(eq 1)
    end

    it "doing a hard count with a total of 10 returns 1" do
      expect Card.one_or_eleven(:hard, 1, 10) |> to(eq 1)
    end
  end
end
