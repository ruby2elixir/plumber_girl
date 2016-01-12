defmodule PlumberGirlTest do
  use ExSpec, async: true
  import ExUnit.CaptureIO
  use PlumberGirl
  doctest PlumberGirl


  describe ">>> macro" do
    test "returns the piped value in case of happy path" do
      assert (0 |> inc >>> inc >>> inc) == {:ok, 3}
    end

    test "returns the value of first error" do
      assert (0 |> inc >>> error) == {:error, "Error at 1"}
    end

    test "propagates the error" do
      assert (0 |> inc >>> error >>> inc >>> inc) == {:error, "Error at 1"}
    end

    test "propagates the correct error message" do
      assert (0 |> inc >>> inc >>> error >>> error >>> inc) == {:error, "Error at 2"}
    end
  end

  describe "try_catch macro" do
    test "catches and returns raised errors in a tagged tupple { :error, %SomeError{} } if something breaks" do
      assert (:raise |> try_catch(arithmetic_error)) == {:error, %ArithmeticError{}}
    end

    test "returns the value otherwise" do
      assert (:pass |> try_catch(arithmetic_error)) == 1
    end
  end

  describe "tee" do
    test "passes the arguments through after executing them in the function" do
      a = (fn ->
        0 |> simple_inc |> simple_inc |> tee(simple_sideeffect)
      end)

      assert a.() == {:ok, 2}
    end

    test "the sideeffect in the function is executed" do
      a = (fn ->
        0 |> simple_inc |> simple_inc |> tee(simple_sideeffect)
      end)
      assert capture_io(a) == "2\n"
    end
  end

  describe "bind" do
    test "wraps a function to return a tagged tuple `{:ok, result}` from the returned value" do
      a = 0 |> simple_inc |> bind(simple_inc)
      assert a == {:ok, 2}
    end
  end

  # returns an unrelated to passed-in arguments value + has a side-effect (logging)
  defp simple_sideeffect(a) do
    IO.inspect a
    :unrelated
  end

  defp inc(cnt) do
    {:ok, simple_inc(cnt)}
  end

  defp simple_inc(cnt) do
    cnt + 1
  end

  defp error(v) do
    {:error, "Error at #{v}"}
  end

  defp arithmetic_error(:pass) do
    1
  end

  defp arithmetic_error(:raise) do
    1 / 0
  end
end
