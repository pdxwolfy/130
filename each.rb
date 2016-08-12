#!/usr/bin/env ruby

def each(array)
  index = 0
  last_index = array.size
  while index < last_index
    yield array[index]
    index += 1
  end
  array
end

result = each([1, 2, 3]) do |value|
  puts value * value
end

puts "=> #{result}"
