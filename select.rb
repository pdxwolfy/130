#!/usr/bin/env ruby

require 'minitest/autorun'

def select(array)
  result = []
  index = 0
  last_index = array.size
  while index < last_index
    result.push array[index] if yield array[index]
    index += 1
  end
  result
end

class Tester < Minitest::Test
  def setup
    @array = [1, 2, 3, 4, 5]
  end

  def test_odd
    assert_equal [1, 3, 5], select(@array) { |num| num.odd? }
  end

  def test_even
    assert_equal [2, 4], select(@array) { |num| num.even? }
  end

  def test_puts
    assert_equal [], select(@array) { |num| puts num }
  end

  def test_num_plus_1
    assert_equal @array, select(@array) { |num| num + 1 }
  end
end
