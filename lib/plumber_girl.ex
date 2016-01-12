defmodule PlumberGirl do
  defmacro __using__(_) do
    quote do
      import PlumberGirl
    end
  end


  @doc ~s"""
  Extracts the value from a tagged tuple like {:ok, value}
  Raises the value from a tagged tuple like {:error, value}
  Raise the arguments else

  For example:
      iex> ok({:ok, 1})
      1

      iex> ok({:error, "some"})
      ** (RuntimeError) some

      iex> ok({:anything, "some"})
      ** (ArgumentError) raise/1 expects an alias, string or exception as the first argument, got: {:anything, "some"}
  """
  def ok({:ok, x}), do: x
  def ok({:error, x}), do: raise x
  def ok(x), do: raise x


  @doc ~s"""
    No need to stop pipelining in case of an error somewhere in the middle

    Example:
      iex> inc = fn(x)-> {:ok, x+1} end
      iex> 1 |> (inc).() >>> (inc).()
      {:ok, 3}
  """
  defmacro left >>> right do
    quote do
      (fn ->
        case unquote(left) do
          {:ok, x} -> x |> unquote(right)
          {:error, _} = expr -> expr
        end
      end).()
    end
  end

  @doc ~s"""
    Wraps a simple function to return a tagged tuple with `:ok` to comply to the protocol `{:ok, result}`

    Example:
      iex> 1 |> Integer.to_string
      "1"
      iex> 1 |> bind(Integer.to_string)
      {:ok, "1"}


      iex> inc = fn(x)-> x+1 end
      iex> 1 |> bind((inc).()) >>> (inc).()
      3
      iex> 1 |> bind((inc).()) >>> bind((inc).())
      {:ok, 3}
  """
  defmacro bind(args, func) do
    quote do
      (fn ->
        result = unquote(args) |> unquote(func)
        {:ok, result}
      end).()
    end
  end

  @doc ~s"""
    Wraps raising functions to return a tagged tuple `{:error, ErrorMessage}` to comply with the protocol

    Example:
      iex> r = fn(_)-> raise "some" end
      iex> inc = fn(x)-> x + 1 end
      iex> 1 |> bind((inc).()) >>> try_catch((r).()) >>> bind((inc).())
      {:error, %RuntimeError{message: "some"}}
  """
  defmacro try_catch(args, func) do
    quote do
      (fn ->
        try do
          unquote(args) |> unquote(func)
        rescue
          e -> {:error, e}
        end
      end).()
    end
  end



  @doc ~s"""
    Like a similar Unix utility it does some work and returns the input as output.
    See [tee (command), Unix](https://en.wikipedia.org/wiki/Tee_(command)).

    Example:
      iex> inc = fn(x)-> IO.inspect(x); {:ok, x + 1} end
      iex> 1 |> tee((inc).()) >>> tee((inc).()) >>> tee((inc).())
      {:ok, 1}
  """
  defmacro tee(args, func) do
    quote do
      (fn ->
        unquote(args) |> unquote(func)
        {:ok, unquote(args)}
      end).()
    end
  end
end
