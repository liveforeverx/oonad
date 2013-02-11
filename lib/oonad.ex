defmodule Oonad do
  @moduledoc """
  Monadic like chaining of the . operator
  
  Example:
    defrecord Calculator, [:value] do
      def inc(x, this), do: this.update_value(&1 + x)

      def div(0, _), do: {:error, :division_by_zero}
      def div(x, this), do: this.update_value(&1 / x)
    end
    
    oonad do 
      Calculator.new(value: 0).
        inc(4).
        div(0).
        inc(5).
        value
    end
  """
  
  defmodule Std do
    def bind(nil, _), do: nil
    def bind({:error, _} = error, _), do: error
    def bind(_, next), do: next.()
  end
  
  defmacro oonad(opts) do
    transform(opts, opts[:do])
  end
  
  defmacro oonad(opts, block) do
    transform(opts, block[:do])
  end
  
  defp transform(opts, {:__block__, _, ops}), do: transform(opts, ops)
  
  defp transform(opts, {{:., context, [left, right]}, _, args}) do
    left = transform(opts, left)
    monad = opts[:monad] || Oonad.Std
    quote line: context[:line] do
      unquote(monad).bind(
        unquote(left), 
        fn() -> unquote(left).unquote(right)(unquote_splicing(args || [])) end
      )
    end
  end
  
  defp transform(_, any), do: any
end