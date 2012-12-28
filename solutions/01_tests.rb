require_relative 'solution.rb'
class TestTask1 < MiniTest::Unit::TestCase
  def test_prime_divisors_positive
    assert_equal [2, 3], 12.prime_divisors 
    assert_equal [2], 16.prime_divisors 
    assert_equal [2], 2.prime_divisors 
  end
  
  def test_prime_divisors_negative
    assert_equal [2, 3], -12.prime_divisors 
    assert_equal [2], -16.prime_divisors 
    assert_equal [2], -2.prime_divisors 
    #refute 
  end

  def test_fizzbuzz
    assert_equal [1, 2], (1..2).fizzbuzz
    assert_equal [1, 2, :fizz, 4, :buzz, :fizz], (1..6).fizzbuzz
    assert_equal [14, :fizzbuzz, 16], (14..16).fizzbuzz
  end

  def test_group_values
    assert_equal({1 => [:a]}, {:a => 1}.group_values)
    assert_equal({1 => [:a], 2 => [:b]}, {:a => 1, :b => 2}.group_values)
    assert_equal({1 => [:a, :b]}, {:a => 1, :b => 1}.group_values)
    assert_equal({1 => [:a, :b], 2 => [:c]}, {:a => 1, :b => 1, :c => 2}.group_values)
  end

  def test_densities
    assert_equal [1], [:a].densities
    assert_equal [2, 2], [:a, :a].densities
    assert_equal [1, 2, 2], [:a, :b, :b].densities
    assert_equal [1, 2, 2, 1], [:a, :b, :b, :c].densities
    assert_equal [2, 2, 2, 2], [:a, :b, :b, :a].densities
  end
end
