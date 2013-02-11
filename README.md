Oonad
=======
Monadic like macro for programatic control of OO like chained calls over tuple modules/records in Elixir.

In Elixir, the . operator is left associative, so we can write:

    a.
      b(something).
      c(something_else).
      ...
    
This can be used with tuple modules or records (which are implemented via tuple modules) to write elegant chain calls:

    defrecord Calculator, value: 0 do
      def inc(x, this), do: this.update_value(&1 + x)

      def div(0, _), do: {:error, :division_by_zero}
      def div(x, this), do: this.update_value(&1 / x)
    end
    
    Calculator.new.
      inc(10).
      div(2).
      inc(10).
      div(3).
      value   # 5
      
The oonad macro adds monadic like programability to the dot (.) operator, so we can do something in between calls. Usually, we want to check for errors or nils:

    import Oonad
    ...
    oonad do 
      Calculator.new.
        inc(4).
        div(0).
        inc(5).
        value
    end         # {:error, :division_by_zero}
    
In default implementation, on every left.right(...) call, if the left hand value is nil, or {:error, _}, than it will be returned instead of chaining through (which would usually cause an exception).

You can implement your own behavior:
    oonad monad: MyMonad do
      ...
    end
    
Where MyMonad is the module which implements bind/2 function. Here's the template:

    defmodule MyMonad do
      def bind(nil, _), do: nil
      def bind({:error, _} = error, _), do: error
      def bind(_, next), do: next.()
    end