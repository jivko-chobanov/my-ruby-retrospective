class Integer
        def prime_divisors
                res = []
                number = self.abs
                upper_limit = ( number / 2 ).ceil
                2.upto( upper_limit ) do |divisor|
                        if number % divisor == 0
                                skip = 0
                                res.each do |old_divisor|
                                        if divisor % old_divisor == 0
                                                skip = 1
                                                break;
                                        end
                                end
                                if skip != 1
                                        res.push divisor
                                end
                        end
                end
                if res == []
                        res = [number]
                end
                res
        end
end

class Range
        def fizzbuzz
                self.collect do |n|
                        if n % 3 == 0 and n % 5 == 0
                                :fizzbuzz
                        elsif n % 5 == 0
                                :buzz
                        elsif n % 3 == 0
                                :fizz
                        else
                                n
                        end
                end
        end
end

class Hash
        def group_values
                res = {}
                self.each do |key, val|
                        if res.has_key?(val)
                                res[val].push key
                        else
                                res[val] = [key]
                        end
                end
                res
        end
end

class Array
        def densities
                self.collect do |item|
                        self.select { |item2| item2 == item }.size
                end
        end
end
