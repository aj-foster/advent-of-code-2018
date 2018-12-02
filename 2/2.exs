# In part 2, we're asked to find which two strings differ by only one letter,
# and input the characters they have in common.
#
# The method here is high in both time and space complexity, as it uses the
# cross product of the list of strings (every possible pairing of two strings)
# and calculates the difference of each pair.

# Here we once again input the file and clean up whitespace before dumping the
# strings into a list as character lists.
#
list =
  File.stream!("input.txt")
  |> Stream.map(&String.trim/1)
  |> Stream.map(&String.to_charlist/1)
  |> Enum.into([])

# This creates every possible pair {x, y} of two strings from the list,
# including the reflexive pairing (a string paired with itself).
#
cross = for x <- list, y <- list, do: {x, y}

# We want to find the first pairing that has exactly one difference.
pair =
  Enum.find(cross, fn {x, y} ->
    # We need to know the index of one list to check the other list.
    x = Enum.with_index(x)

    # A simple count: how many letters don't match?
    1 ==
      Enum.count(x, fn {letter, index} ->
        letter != Enum.at(y, index)
      end)
  end)
  |> IO.inspect(label: "Part 2")

# At the moment, this does not give us the full answer. We still need to pick
# out the different character and remove it in order to get our final answer.
