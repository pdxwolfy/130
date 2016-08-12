require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!

require_relative 'car'

class CarTest < MiniTest::Test
  def setup
    @car = Car.new
  end

  def test_wheels
    assert_equal 4, @car.wheels
  end

  def test_car_exists
    assert @car
  end

  def test_name_is_nil
    assert_nil @car.name
  end

  def test_raise_initialize_with_arg
    assert_raises ArgumentError do
      Car.new name: 'Joey'
    end
  end

  def test_instance_of_car
    assert_instance_of Car, @car
  end

  def test_includes_car
    arr = [1, 2, 3]
    arr << @car

    assert_includes arr, @car
  end

  def test_value_equality
    @car.name = 'Kim'

    @car2 = Car.new
    @car2.name = 'Kim'

    assert_equal @car2, @car
    refute_same @car2, @car
  end
end

#------------------------------------------------------------------------------

describe 'Car#new' do
  before do
    @car = Car.new
  end

  it 'exists' do
    assert @car
  end

  it 'is a Car' do
    @car.must_be_instance_of Car
  end

  it 'raises an ArgumentError when passed an argument' do
    proc { Car.new name: 'Joey' }.must_raise ArgumentError
  end
end

#------------------------------------------------------------------------------

describe 'Car#wheels' do
  before do
    @car = Car.new
  end

  it 'has 4 wheels' do
    @car.wheels.must_equal 4
  end
end

#------------------------------------------------------------------------------

describe 'Car#name' do
  before do
    @car = Car.new
  end

  it 'does not have a name' do
    @car.name.must_be_nil
  end
end

#------------------------------------------------------------------------------

# describe 'Cars in collections' do
#   before do
#     @car = Car.new
#   end
#
#   it 'includes a Car' do
#     arr = [1, 2, 3]
#     arr << @car
#
#     arr.must_include @car
#   end
# end
