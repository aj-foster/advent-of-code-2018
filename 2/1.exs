# In part 1, we're given a list of strings and asked to count the number of
# strings that have (1) a letter used exactly twice, and (2) a letter used
# exactly three times. Our final answer is the multiplication of those two
# numbers.
#
# I've once again elected to use Elixir's stream processing on the input file,
# though it does not make a big difference for this challenge. We ultimately
# need to reduce the data anyway, which happens eagerly.

defmodule Day2 do
  @moduledoc """
  This module provides two functions for deciding whether a sorted character
  list has double or triple letters.
  """

  @doc """
  Count the presence of letters used exactly three times, returning 0 or 1.

  We assume the character list is sorted.

  Normally we might implement this as a boolean function, but I'd like to call
  it within an addition statement, so instead we'll return 0 or 1. This function
  is part of a reduction in which we're counting the total number of times a
  string has a triple-letter, NOT how many triple-letters are in the string.

  We're leaning heavily on Elixir's multiple function clauses and pattern
  matching here. Most of the weird stuff you might read below is trying to
  avoid cases in which we discard some of a letter and end up matching three of
  the same letter on the next call.
  """
  @spec has_triples(charlist(), char() | nil) :: 0 | 1
  def has_triples(characters, last_used_character \\ nil)

  # If we're at the end of the list, there's no triple letter.
  def has_triples([], _), do: 0

  # If we find four in a row, we can skip this letter.
  def has_triples([a, a, a, a | tail], _), do: has_triples(tail, a)

  # Three in a row BUT we already matched on this letter: continue.
  def has_triples([a, a, a | tail], a), do: has_triples(tail, a)

  # Three in a row and we haven't matched this letter yet - AND the four in a
  # row case didn't match above - means we have a triple letter.
  def has_triples([a, a, a | _tail], _), do: 1

  # Any other case: continue.
  def has_triples([a | tail], _), do: has_triples(tail, a)

  @doc """
  Count the presence of letters used exactly two times, returning 0 or 1.

  See `has_triples/2` for more information.
  """
  @spec has_doubles(charlist(), char() | nil) :: 0 | 1
  def has_doubles(characters, last_used_character \\ nil)

  # If we're at the end of the list, there's no double letter.
  def has_doubles([], _), do: 0

  # If we find three in a row, we can skip this letter.
  def has_doubles([a, a, a | tail], _), do: has_doubles(tail, a)

  # Two in a row BUT we already matched on this letter: continue.
  def has_doubles([a, a | tail], a), do: has_doubles(tail, a)

  # Two in a row and we haven't matched this letter yet - AND the three in a
  # row case didn't match above - means we have a double letter.
  def has_doubles([a, a | _tail], _), do: 1

  # Any other case: continue.
  def has_doubles([a | tail], _), do: has_doubles(tail, a)
end

# 1. Read in the input file line-by-line.
# 2. Remove whitespace, specifically '\n', from each line.
# 3. Convert the strings into lists of characters.
# 4. Sort the characters of each string.
# 5. Reduce the list of strings (char lists) into a count of strings with
#    double and triple letters.
# 6. Use an anonymous function to complete the checksum multiplication.
# 7. Print the result.
#
File.stream!("input.txt")
|> Stream.map(&String.trim/1)
|> Stream.map(&String.to_charlist/1)
|> Stream.map(&Enum.sort/1)
|> Enum.reduce({0, 0}, fn x, {doubles, triples} ->
  {
    doubles + Day2.has_doubles(x),
    triples + Day2.has_triples(x)
  }
end)
|> (fn {x, y} -> x * y end).()
|> IO.inspect(label: "Part One")
