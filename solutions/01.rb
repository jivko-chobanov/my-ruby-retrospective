class Integer
  def prime_divisors
    2.upto(abs).select { |n| n.prime? and remainder(n).zero? }
  end

  def prime?
    2.upto(Math.sqrt abs).all? { |n| remainder(n).nonzero? }
  end
end

class Range
  def fizzbuzz
    map do |n|
      if    n % 15 == 0 then :fizzbuzz
      elsif n % 5  == 0 then :buzz
      elsif n % 3  == 0 then :fizz
      else n
      end
    end
  end
end

class Hash
  def group_values
    each_with_object({}) do |(key, value), grouped_keys_by_value|
      grouped_keys_by_value[value] ||= []
      grouped_keys_by_value[value] << key
    end
  end
end

class Array
  def densities
    map { |element| count element }
  end
end
