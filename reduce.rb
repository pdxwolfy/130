#!/usr/bin/env ruby

require 'minitest/autorun'

def reduce(array, init = nil)
  accum = init
  index = 0
  while index < array.size
    accum = yield accum, array[index]
    index += 1
  end

  accum
end

class Tester < Minitest::Test
  def setup
    @array = [1, 2, 3, 4, 5]
  end

  def test_sum
    assert_equal 15, reduce(@array) { |accum, value| accum + value}
  end

  def test_prod
    assert_equal 120, reduce(@array, 1) { |accum, value| accum * value}
  end

  def test_concat
    assert_equal '012345', reduce(@array) { |accum, value| "#{accum}#{value}"}
  end

  def test_concat_with_init
    result = reduce(@array, '*') do |accum, value|
      "#{accum}#{value}"
    end
    assert_equal '*12345', result
  end
end
