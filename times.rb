#!/usr/bin/env ruby

def times(number)
  index = 0
  while index < number
    yield index
    index += 1
  end
  number
end

result = times(5) do |num|
  puts num 
end
puts "=> #{result}"
