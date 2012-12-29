class Expr
  @@classes_by_operation = {}

  def self.build(tree)
    tree.size == 3 ? Binary.build(tree) : Unary.build(tree)
  end

  def self.class_name(tree)
    @@classes_by_operation[tree.first]
  end

  def -@
    Negation.new self
  end

  def *(other)
    Multiplication.new self, other
  end

  def +(other)
    Addition.new self, other
  end
end

class Binary < Expr
  attr_reader :left, :right, :operation

  def self.build(tree)
    class_name(tree).new Expr.build(tree[1]), Expr.build(tree[2])
  end

  def initialize(left, right)
    @left = left
    @right = right
    @operation = @@classes_by_operation.invert[self.class]
  end

  def ==(other)
    other.is_a? Binary and 
      @left == other.left and @right == other.right
  end

  def neutral_element
    null
  end

  def simplify
    sides = [@left.simplify, @right.simplify]
    
    sides.delete_if do |side|
      side == neutral_element
    end
    
    sides.size > 0 ? sides.inject(operation) : neutral_element
  end

  def derive(var)
    compute_derivative(@left, @right, @left.derive(var), @right.derive(var)).simplify
  end
end

class Unary < Expr
  attr_reader :arg

  def self.build(tree)
    if tree[1].is_a? Array
      arg = Expr.build(tree[1])
    else
      arg = tree[1]
    end

    class_name(tree).new arg
  end

  def initialize(arg)
    @arg = arg
  end
    
  def ==(other)
    other.is_a? Unary and @arg == other.arg
  end

  def simplify
    @arg = @arg.simplify
  end

  def derive(var)
    compute_derivative(@arg, @arg.derive(var)).simplify
  end
end

class Multiplication < Binary
  @@classes_by_operation[:*] = self

  def evaluate(env = {})
    @left.evaluate(env) * @right.evaluate(env)
  end

  def neutral_element
    Number::ONE
  end

  def simplify
    simplified = super
    if simplified.is_a?(Multiplication)
      if simplified.left == Number::ZERO or simplified.right == Number::ZERO
        return Number::ZERO
      end
    end
    simplified
  end

  def compute_derivative(x, y, dx, dy)
    x * dy + y * dx
  end
end

class Addition < Binary
  @@classes_by_operation[:+] = self

  def evaluate(env = {})
    @left.evaluate(env) + @right.evaluate(env)
  end

  def neutral_element
    Number::ZERO
  end

  def compute_derivative(x, y, dx, dy)
    dx + dy
  end
end

class Value < Unary
  def simplify
    self
  end
end

class Number < Value
  @@classes_by_operation[:number] = self

  ZERO = Number.new 0
  ONE = Number.new 1

  def evaluate(env = {})
    @arg
  end

  def derive(var)
    Number::ZERO
  end 
end

class Variable < Value
  @@classes_by_operation[:variable] = self

  def evaluate(env = {})
    if env.include? @arg
      env[@arg]
    else
      raise ArgumentError,
        "The expression has a variable #@arg which is not defined in environment"
    end
  end

  def derive(var)
    if var == @arg
      Number::ONE
    else 
      Number::ZERO
    end
  end 
end

class Negation < Unary
  @@classes_by_operation[:-] = self

  def simplify
    @arg.is_a?(Negation) ? @arg.arg.simplify : Negation.new(@arg.simplify)
  end

  def evaluate(env = {})
    -@arg.evaluate(env)
  end

  def compute_derivative(x, dx)
    -dx
  end
end

class Sin < Unary
  @@classes_by_operation[:sin] = self

  def evaluate(env = {})
    Math.sin @arg.evaluate(env)
  end

  def simplify
    case @arg
      when Number::ZERO
        Expr.build([:number, 0])
      when Expr.build([:number, Math::PI])
        Number::ZERO
      when Expr.build([:number, Math::PI / 2])
        Number::ONE
      when Expr.build([:number, 3 * Math::PI / 2])
        Expr.build [:-, [:number, 1]]
      else
        Sin.new @arg.simplify
    end
  end

  def compute_derivative(x, dx)
    dx * Cos.new(x)
  end
end

class Cos < Unary
  @@classes_by_operation[:cos] = self

  def evaluate(env = {})
    Math.cos @arg.evaluate(env)
  end
  
  def simplify
    case @arg
      when Number::ZERO
        Number::ONE
      when Expr.build([:number, Math::PI])
        Expr.build [:-, [:number, 1]]
      when Expr.build([:number, Math::PI / 2])
        Number::ZERO
      when Expr.build([:number, 3 * Math::PI / 2])
        Number::ZERO
      else
        Cos.new @arg.simplify
    end
  end

  def compute_derivative(x, dx)
    dx * -Sin.new(x)
  end
end
