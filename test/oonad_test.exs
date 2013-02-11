Code.require_file "../test_helper.exs", __FILE__

defmodule OonadTest do
  use ExUnit.Case
  import Oonad
  
  defrecord Calculator, value: 0 do
    def inc(x, this), do: this.update_value(&1 + x)
    
    def div(0, _), do: {:error, :division_by_zero}
    def div(x, this), do: this.update_value(&1 / x)
    
    def makenil(_), do: nil
  end

  test "oonad" do
    assert oonad(do: Calculator.new.inc(4).div(2).value) == 2
    assert oonad(do: Calculator.new.inc(4).div(0).value) == {:error, :division_by_zero}
    assert oonad(do: Calculator.new.inc(4).makenil.value) == nil
    assert oonad(do: nil.inc(4).div(0).value) == nil
    
    a = Calculator.new
    assert oonad(do: a) == a
    assert oonad(do: a.inc(1)) == a.inc(1)
  end
  
  defmodule CustomMonad do
    def bind(1, _), do: :one
    def bind(:one, _), do: :two
    def bind(_, _), do: nil
  end
  
  test "custom monad" do
    assert oonad(monad: CustomMonad, do: 1.x) == :one
    assert oonad(monad: CustomMonad, do: 1.x.y) == :two
    assert oonad(monad: CustomMonad, do: 1.x.y.z.z) == nil
  end
  
  test "expanded form" do
    assert (oonad do Calculator.new.inc(4).div(2).value end) == 2
    assert (oonad monad: CustomMonad do 1.x.y end) == :two
  end
end
