# PlumberGirl takes care of your Elixir piping issues!


[![Build status](https://travis-ci.org/ruby2elixir/plumber_girl.svg "Build status")](https://travis-ci.org/ruby2elixir/plumber_girl)
[![Hex version](https://img.shields.io/hexpm/v/plumber_girl.svg "Hex version")](https://hex.pm/packages/plumber_girl)
![Hex downloads](https://img.shields.io/hexpm/dt/plumber_girl.svg "Hex downloads")

----

PlumberGirl provides some macros to enable [railsway-oriented programming](http://fsharpforfunandprofit.com/rop/) in Elixir.

Collected from code snippets and wrapped into a simple library for your convenience.


For more examples please check the tests here:
- [Examples](https://github.com/ruby2elixir/plumber_girl/blob/master/test/plumber_girl_test.exs)


## Sources for inspiration + copying
- http://www.zohaib.me/railway-programming-pattern-in-elixir/
- https://github.com/remiq/railway-oriented-programming-elixir
- https://gist.github.com/zabirauf/17ced02bdf9829b6956e (Railway Oriented Programming macros in Elixir)


Installation
------

1. Add rop to your list of dependencies in `mix.exs`:
```elixir
def deps do
  [{:plumber_girl, "~> 0.9.5"}]
end
```


## Usage
Call

```elixir
use PlumberGirl
```

in your module. That will give you access to following macros/functions:

### `>>>`
No need to stop pipelining in case of an error somewhere in the middle


used like: `1 |> fn1 >>> fn2 >>> fn3 >>> fn4`

```elixir
defmodule TripleArrowExample do
  use PlumberGirl
  def tagged_inc(v) do
    IO.puts "inc for #{v}" # sideeffect for demonstration
    {:ok, v + 1}
  end

  def error_fn(_) do
    {:error, "I'm a bad fn!"}
  end

  def raising_fn(_) do
    raise "I'm raising!"
  end

  def result do
    1 |> tagged_inc >>> tagged_inc >>> tagged_inc
  end

  def error_result do
    1 |> tagged_inc >>> tagged_inc >>> error_fn >>> tagged_inc
  end

  def raising_result do
    1 |> tagged_inc >>> tagged_inc >>> raising_fn >>> tagged_inc
  end
end

iex> TripleArrowExample.result
inc for 1
inc for 2
inc for 3
{:ok, 4}

### increases twice, errors and tries to increase again
### notice that after errored result we don't execute any function anymore in the pipeline,
### e.g. only tagged_inc before error_fn were executed.
iex> TripleArrowExample.error_result
inc for 1
inc for 2
{:error, "I'm a bad fn!"}

### raises... We'll fix it in a later example for try_catch!
iex> TripleArrowExample.raising_result
inc for 1
inc for 2
** (RuntimeError) I'm raising!
```


### `bind`
Wraps a simple function to return a tagged tuple with `:ok` to comply to the protocol `{:ok, result}`: e.g.

```elixir
defmodule BindExample do
  use PlumberGirl
  def inc(v) do
    v + 1
  end

  def only_last_pipe_tagged_result(v) do
    v |> inc |> bind(inc)
  end

  def result_fully_tagged(v) do
    v |> bind(inc) >>> bind(inc) >>> bind(inc)
  end
end
iex> BindExample.only_last_pipe_tagged_result(2)
{:ok, 4}

iex> BindExample.result_fully_tagged(2)
{:ok, 5}
```


### `try_catch`

Wraps raising functions to return a tagged tuple `{:error, ErrorMessage}`  to comply with the protocol

```elixir
# modified example from TripleArrowExample to handle raising functions
defmodule TryCatchExample do
  use PlumberGirl
  def tagged_inc(v) do
    IO.puts "inc for #{v}" # sideeffect for demonstration
    {:ok, v + 1}
  end

  def raising_fn(_) do
    raise "I'm raising!"
  end

  def result do
    1 |> tagged_inc >>> tagged_inc >>> tagged_inc
  end

  def raising_result_wrapped(v) do
    v |> tagged_inc >>> tagged_inc >>> try_catch(raising_fn) >>> tagged_inc
  end
end

iex> TryCatchExample.raising_result_wrapped(1)
inc for 1
inc for 2
{:error, %RuntimeError{message: "I'm raising!"}}
```


#### `tee`

Like a similar Unix utility it does some work and returns the input. See [tee (command), Unix](https://en.wikipedia.org/wiki/Tee_(command)).



```elixir
defmodule TeeExample do
  use PlumberGirl
  def tagged_inc(v) do
    IO.puts "inc for #{v}" # sideeffect for demonstration
    {:ok, v + 1}
  end

  def calc(v) do
    v |> tee(tagged_inc) >>> tee(tagged_inc) >>> tee(tagged_inc)
  end
end

# notice how the incremented value is not passed through the pipeline,
# but just the original argument `1`
iex> TeeExample.calc(1)
inc for 1
inc for 1
inc for 1
_{:ok, 1}
```


### `ok`

A simple utility function to extract the value from `{:ok, result}` tuple and to raise the error in `{:error, ErrorStruct}`.

```elixir
defmodule OkExample do
  use PlumberGirl
  def ok_result do
    {:ok, 1} |> ok
  end

  def error_result do
    {:error, %ArithmeticError{}} |> ok
  end

  def any_value_result do
    "bad value" |> ok
  end
end

iex> OkExample.ok_result
1

iex> OkExample.error_result
** (ArithmeticError) bad argument in arithmetic expression
    (rop) lib/rop.ex:70: Rop.ok/1


iex> OkExample.any_value_result
** (RuntimeError) bad value
    (rop) lib/rop.ex:71: Rop.ok/1
```




Background information
----------------------

### Some discussions about Railsway programming:
- http://www.zohaib.me/railway-programming-pattern-in-elixir/
- http://www.zohaib.me/monads-in-elixir-2/
- http://insights.workshop14.io/2015/10/18/handling-errors-in-elixir-no-one-say-monad.html
- http://blog.danielberkompas.com/2015/09/03/better-pipelines-with-monadex.html
- http://onor.io/2015/08/27/railway-oriented-programming-in-elixir/
- http://www.zohaib.me/railway-programming-pattern-in-elixir/
- http://fsharpforfunandprofit.com/posts/recipe-part2/
- https://www.reddit.com/r/programming/comments/30coly/railway_oriented_programming_in_elixir/

### Code (Railsway Programming)
- https://github.com/remiq/railway-oriented-programming-elixir/blob/master/lib/rop.ex
- https://gist.github.com/zabirauf/17ced02bdf9829b6956e (Railway Oriented Programming macros in Elixir) -> Rop
- https://github.com/CrowdHailer/OK/blob/master/lib/ok.ex
- https://gist.github.com/danielberkompas/52216db76d764a68dfa3 -> pipeline.ex

### Code (Monads)
- https://github.com/rmies/monad.git
- https://github.com/rob-brown/MonadEx.git
- https://github.com/slogsdon/elixir-control.git
- https://github.com/niahoo/monk.git
- https://github.com/knrz/towel.git


### Alternatives
  - https://github.com/batate/elixir-pipes - Macros for more flexible composition with the Elixir Pipe operator
  - https://github.com/vic/ok_jose - Pipe elixir functions that match {:ok,_}, {:error,_} tuples or custom patterns.
