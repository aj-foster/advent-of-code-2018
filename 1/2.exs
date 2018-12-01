# For part 2, we're asked to continue cycling through the input numbers until we
# see the same sum of frequencies twice, and report the repeated sum.
#
# We can infinitely cycle through the stream of input using `Stream.cycle/1`.
# Doing this could result in an infinite loop if we never find a repeated sum,
# but we can trust that the input will have a repeat.
#
# While part 1 used a simple reduction using addition, here we need to keep
# track of the history of the sum. To do this, we can expand the accumulator
# to include a MapSet of all previous sums.
#
# Why a MapSet? One, because I'd never used one and felt like it. Two (the real
# reason), at each step of the way we need to ask, "Have we seen this sum
# before?" With a MapSet, I *believe* we can answer this question in O(1) time
# because it uses a map to store the elements. If we were to use a List to
# store the previously seen sums, we would have to perform an O(n) traversal of
# the entire (growing!) list at each step.

defmodule Day1 do
  @moduledoc """
  Why bother creating a module here? Because functions are defined in modules,
  and I wanted to define a separate function for the reducer. We could have also
  defined an inline anonymous function using `fn (...) -> ... end`.
  """

  @typedoc """
  Tuple containing the current sum of the stream and a set of all previous sums.

  Creating a type like this is mostly for documentation. Since we have a weird
  accumulator in our reduce function, it's good to document its structure.
  """
  @type t :: {integer(), MapSet.t()}

  @doc """
  Reducer function for the stream of integers.

  Arguments:
    delta - current change in frequency we're considering
    sum - current sum of the frequencies
    seen_sums - set containing all frequencies we've seen

  Any reduce_while function is expected to return {:cont, _} to continue the
  reduction or {:halt, _} to stop it. We'll stop this reduction if we find a
  sum of frequencies that was previously seen.
  """
  @spec reduce_until_repeat(integer(), t()) :: {:cont, t()} | {:halt, integer()}
  def reduce_until_repeat(delta, {sum, seen_sums}) do
    new_sum = sum + delta

    cond do
      MapSet.member?(seen_sums, new_sum) ->
        {:halt, new_sum}

      true ->
        {:cont, {new_sum, MapSet.put(seen_sums, new_sum)}}
    end
  end
end

# At the start, we have a sum of zero and the only sum we've seen is zero.
initial_accumulator = {0, MapSet.new([0])}

# 1. Read in the input file line-by-line.
# 2. Infinitely cycle through the input until the reducer halts.
# 3. Remove whitespace, specifically '\n', from each line.
# 4. Parse the string into an integer.
# 5. Run the reducer (above).
# 6. Print the result.
#
File.stream!("input.txt")
|> Stream.cycle()
|> Stream.map(&String.trim/1)
|> Stream.map(&String.to_integer/1)
|> Enum.reduce_while(initial_accumulator, &Day1.reduce_until_repeat/2)
|> IO.inspect(label: "Part Two")
