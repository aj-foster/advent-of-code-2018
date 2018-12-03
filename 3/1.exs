# In part 1 we're given information about rectangular areas (called "claims") on the XY-plane, and
# asked to calculate the total area that is covered by two or more overlapping areas.
#
# The following is a naive solution that effectively plays battleship: it asks each coordinate point
# if it has two overlapping claims, and counts the "yes" responses. This is almost certainly not the
# most efficient way to do it, but we're going to use this opportunity to try out Elixir's async
# tasks. The goal is to run each coordinate point in its own Elixir process (a lightweight memory
# segmentation that is scheduled by the Erlang scheduler, NOT an OS process). It'll be fun!
#
# ...just make sure your computer is on AC power before trying this.

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

# Split each of the coordinates into a separate async Task that returns as a stream. In each process
# we ask how many claims cover the given coordinate point. Some processing is necessary to extract
# the counts from the task return values (they are wrapped in {:ok, _}) and remove any counts less
# than two. In the end we want to count the number of coordinate points with more than two claims.
#
coordinates
|> Task.async_stream(fn {x, y} ->
  Enum.count(claims, fn claim ->
    x >= claim["x_start"] && x <= claim["x_end"] && y >= claim["y_start"] && y <= claim["y_end"]
  end)
end)
|> Stream.map(fn {:ok, count} -> count end)
|> Stream.filter(fn count -> count > 1 end)
|> Enum.count()
|> IO.inspect(label: "Part One")
