# In part 2 we're asked to find the single rectangular area ("claim") that does not overlap with
# any other claim.
#
# This is another naive solution that asks each coordinate point whether it has overlapping claims,
# and removes those claims from the list of candidates. This has a guaranteed O(x * y) runtime,
# where x and y are the maximum X and Y coordinates. It just so happens that x and y are similar to
# the total number of claims (n) in my input file, so O(x * y) is not significantly worse than the
# O(n^2) runtime we would get when checking each claim against every other claim. However, it might
# end up that the O(n^2) solution is faster because each claim can stop checking for overlap with
# other claims as soon as it finds one overlap, while we continue to check every coordinate no
# matter what.

# Extract the vital information from the input file using named Regex captures.
capture_parts = fn string ->
  Regex.named_captures(
    ~r/\#(?<id>\d+) @ (?<left>\d+),(?<top>\d+): (?<width>\d+)x(?<height>\d+)/,
    string
  )
end

# We receive information about the boundaries of the claims as distance from the left, distance from
# the top, width, and height. Here we transform that information into X and Y boundaries (inclusive)
# since we'll use those later.
#
transform_bounds = fn claim ->
  %{
    "id" => String.to_integer(claim["id"]),
    "x_start" => String.to_integer(claim["left"]) + 1,
    "x_end" => String.to_integer(claim["left"]) + String.to_integer(claim["width"]),
    "y_start" => String.to_integer(claim["top"]) + 1,
    "y_end" => String.to_integer(claim["top"]) + String.to_integer(claim["height"])
  }
end

# 1. Read in the input file line-by-line.
# 2. Remove whitespace, specifically '\n', from each line.
# 3. Parse the string into a map containing the crucial information.
# 4. Transform left/top/width/height info into X/Y bounds.
#
stream =
  File.stream!("input.txt")
  |> Stream.map(&String.trim/1)
  |> Stream.map(capture_parts)
  |> Stream.map(transform_bounds)

# Since we'll naively check every single coordinate point, we need to find how far to go in each
# direction.

# First, we look for the maximum X value.
max_x =
  stream
  |> Stream.map(fn claim -> claim["x_end"] end)
  |> Enum.max()
  |> IO.inspect(label: "Maximum X Value")

# Second, we look for the maximum Y value.
max_y =
  stream
  |> Stream.map(fn claim -> claim["y_end"] end)
  |> Enum.max()
  |> IO.inspect(label: "Maximum Y Value")

# Transform the claims from Stream -> List.
claims =
  stream
  |> Enum.into([])

# Create a list of all coordinate points in the area.
coordinates =
  for x <- 1..max_x,
      y <- 1..max_y,
      do: {x, y}

# Create a list of all claim IDs. At the start, this is our list of candidates for the
# non-overlapping claim.
#
claim_ids =
  1..length(claims)
  |> Enum.into([])

# Split each of the coordinates into a separate async Task that returns as a stream. In each process
# we generate a list of claim IDs covering the coordinate. Some processing is necessary to extract
# the IDs from the task return values (they are wrapped in {:ok, _}) and remove any lists with less
# than two claims. In the end we want to flatten the list of IDs and remove them as candidates.
#
overlapping_claims =
  coordinates
  |> Task.async_stream(fn {x, y} ->
    claims
    |> Enum.filter(fn claim ->
      x >= claim["x_start"] && x <= claim["x_end"] && y >= claim["y_start"] && y <= claim["y_end"]
    end)
    |> Enum.map(fn claim ->
      claim["id"]
    end)
  end)
  |> Stream.map(fn {:ok, claims} -> claims end)
  |> Stream.filter(fn claims ->
    length(claims) > 1
  end)
  |> Stream.flat_map(& &1)
  |> Stream.uniq()
  |> Enum.into([])

# Remove overlapping claims from the candidates.
candidates = claim_ids -- overlapping_claims

# We expect a single candidate to remain.
IO.inspect(length(candidates), label: "Number of candidates")
IO.inspect(Enum.at(candidates, 0), label: "Part Two")
