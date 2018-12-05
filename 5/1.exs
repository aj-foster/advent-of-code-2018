# In part 1, we're asked to take a long string of letters (the "polymer") and reduce it by pairing
# off lowercase and capital pairs of the same letters and removing them. As pairs are removed, this
# may introduce further pairs that can be removed. At the end, we would like to know the length
# of a fully-reduced polymer.
#
# My first iteration used single-character strings as the unit for letters. The code averaged a
# runtime of 4.5s on my input. After converting to Erlang characters and charlists, the same code
# runs in 1.5s.

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
# 6. Calculate its new length and print the result.
#
File.stream!("input.txt", [], 1)
|> Stream.reject(&(&1 == "\n"))
|> Stream.map(&Day5.string_to_char/1)
|> Enum.into([])
|> Day5.reduce_polymer()
|> length()
|> IO.inspect(label: "Part One")
