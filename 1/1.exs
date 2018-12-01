# In part 1, we're given a file with a list of integers and asked to find the
# sum of the integers. Each integer is on its own line in the file.
#
# I've elected to use Elixir's Stream module here, which is built to lazily
# evaluate a long stream of input. While we could almost certainly load the
# entire input file into memory and process it eagerly, this is a good
# opportunity to practice stream processing.
#
# In this solution I'm referring to several functions using &. As long as a
# function accepts the correct number of functions, in the correct order, we
# can pass its name instead of an anonymous function. For example:
#
#     Stream.map(enum, fn (element) -> String.trim(element) end)
#
# is equivalent to:
#
#     Stream.map(enum, &String.trim/1)
#
# Perhaps the most confusing one is `Enum.reduce(enum, 0, &Kernel.+/2)`. Besides
# the trick just mentioned, this is also using the fact that the addition
# operator `+` is a function on the Kernel module. We can say:
#
#     a + b
#
# is the same as:
#
#     Kernel.+(a, b)
#
# Since the plus function accepts the correct arguments (the current element in
# the enumerable, and the accumulator we're using to track the sum) and adds
# them together, we'll call it by name in our reducer.

# 1. Read in the input file line-by-line.
# 2. Remove whitespace, specifically '\n', from each line.
# 3. Parse the string into an integer.
# 4. Reduce using addition with an initial sum of zero.
# 5. Print the result.
#
File.stream!("input.txt")
|> Stream.map(&String.trim/1)
|> Stream.map(&String.to_integer/1)
|> Enum.reduce(0, &Kernel.+/2)
|> IO.inspect(label: "Part One")
