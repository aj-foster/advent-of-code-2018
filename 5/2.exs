# In part 2, we're asked to consider the effect of removing a single letter from the polymer
# strings. By doing so, we may allow further reductions to take place. Our goal is to find the
# letter that allows the greatest additional reduction to take place, and report the resulting
# length.
#
# My first iteration used single-character strings as the unit for letters. The code averaged a
# runtime of 10sec on my input. After converting to Erlang characters and charlists, the same code
# runs in 3sec.

defmodule Day5 do
  @moduledoc """
  Provides `reduce_polymer/1` for reducing polymer strings according to the instructions.
  """

  @doc """
  Convert a single-character string to an Erlang character.
  """
  @spec string_to_char(String.t()) :: char()
  def string_to_char(string) do
    String.to_charlist(string)
    |> Enum.at(0)
  end

  @doc """
  Fully reduce a polymer string by removing lower/upper pairs of letters.

  We expect the polymer to be a list of characters.
  """
  @spec reduce_polymer(charlist()) :: charlist()
  def reduce_polymer(polymer) do
    old_length = length(polymer)

    {polymer, letter} = Enum.reduce(polymer, {[], nil}, &reducer/2)
    polymer = [letter | polymer]

    cond do
      length(polymer) == old_length ->
        polymer

      true ->
        reduce_polymer(polymer)
    end
  end

  # Considering the current and the previous letter, construct a new list without matched pairs.
  @spec reducer(char(), {charlist(), char()}) :: {charlist(), char()}
  defp reducer(letter, {new_polymer, prev_letter}) do
    cond do
      # Skip ahead if we're at the start, or if the previous letter was removed.
      prev_letter == nil ->
        {new_polymer, letter}

      # Continue normally if we have the double upper or double lower pairs.
      letter == prev_letter ->
        {[prev_letter | new_polymer], letter}

      # Leave out lower/upper pairs.
      letter == :string.to_upper(prev_letter) ->
        {new_polymer, nil}

      # Leave out upper/lower pairs.
      letter == :string.to_lower(prev_letter) ->
        {new_polymer, nil}

      # Add in unmatched letters.
      true ->
        {[prev_letter | new_polymer], letter}
    end
  end
end

# 1. Read in the input file byte-by-byte.
# 2. Reject the final newline character.
# 3. Convert the strings to individual characters.
# 4. Drop each letter into a list.
# 5. Fully reduce the polymer list.
#
polymer =
  File.stream!("input.txt", [], 1)
  |> Stream.reject(&(&1 == "\n"))
  |> Stream.map(&Day5.string_to_char/1)
  |> Enum.into([])
  |> Day5.reduce_polymer()

# 1. Generate a list of letters present in the polymer.
# 2. Find the length of the polymer that results when removing each letter and reducing.
# 3. Find the minimum length and report the result.
#
polymer
|> Enum.map(&:string.to_lower/1)
|> Enum.uniq()
|> Enum.map(fn letter ->
  polymer
  |> Enum.reject(fn entry ->
    :string.to_lower(entry) == letter
  end)
  |> Day5.reduce_polymer()
  |> length()
end)
|> Enum.min()
|> IO.inspect(label: "Part Two")
