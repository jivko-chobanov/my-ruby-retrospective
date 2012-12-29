class Expr
  def self.classes_by_operation
    {
      :*        => Multiplication,
      :+        => Addition,
      :number   => Number,
      :variable => Variable,
      :-        => Negation,
      :sin      => Sin,
      :cos      => Cos,
    }
  end

  def self.build(tree)
    tree.size == 3 ? Binary.build(tree) : Unary.build(tree)
  end

  def self.class_name(tree)
    classes_by_operation[tree.first]
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
    @operation = Expr::classes_by_operation.invert[self.class]
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
end

class Multiplication < Binary
  def evaluate(env = {})
    @left.evaluate(env) * @right.evaluate(env)
  end

  def neutral_element
    Expr.build [:number, 1]
  end

  def simplify
    simplified = super
    if simplified.is_a?(Multiplication)
      if simplified.left == Expr.build([:number, 0]) or simplified.right == Expr.build([:number, 0])
        return Expr.build [:number, 0]
      end
    end
    simplified
  end

  def derive(variable_name)
    Addition.new(
      Multiplication.new(@left, @right.derive(variable_name)), 
      Multiplication.new(@right, @left.derive(variable_name))
    ).simplify
  end
end

class Addition < Binary
  def evaluate(env = {})
    @left.evaluate(env) + @right.evaluate(env)
  end

  def neutral_element
    Expr.build [:number, 0]
  end

  def derive(variable_name)
    Addition.new(@left.derive(variable_name), @right.derive(variable_name)).simplify
  end
end

class Value < Unary
  def simplify
    self
  end
end

class Number < Value
  def evaluate(env = {})
    @arg
  end

  def derive(variable_name)
    Expr.build [:number, 0]
  end 
end

class Variable < Value
  def evaluate(env = {})
    env[@arg]
  end

  def derive(variable_name)
    if variable_name == @arg
      Expr.build [:number, 1]
    else 
      Expr.build [:number, 0]
    end
  end 
end

class Negation < Unary
  def simplify
    if @arg.is_a? Negation
      @arg.arg.simplify
    else
      Negation.new @arg.simplify
    end
  end

  def evaluate(env = {})
    -@arg.evaluate(env)
  end
end

class Sin < Unary
  def evaluate(env = {})
    Math.sin @arg.evaluate(env)
  end

  def simplify
    case @arg
      when Expr.build([:number, 0])
        Expr.build([:number, 0])
      when Expr.build([:number, Math::PI])
        Expr.build [:number, 0]
      when Expr.build([:number, Math::PI / 2])
        Expr.build [:number, 1]
      when Expr.build([:number, 3 * Math::PI / 2])
        Expr.build [:-, [:number, 1]]
      else
        Sin.new @arg.simplify
    end
  end

  def derive(variable_name)
    Multiplication.new(@arg.derive(variable_name), Cos.new(@arg)).simplify
  end
end

class Cos < Unary
  def evaluate(env = {})
    Math.cos @arg.evaluate(env)
  end
  
  def simplify
    case @arg
      when Expr.build([:number, 0])
        Expr.build [:number, 1]
      when Expr.build([:number, Math::PI])
        Expr.build [:-, [:number, 1]]
      when Expr.build([:number, Math::PI / 2])
        Expr.build [:number, 0]
      when Expr.build([:number, 3 * Math::PI / 2])
        Expr.build [:number, 0]
      else
        Cos.new @arg.simplify
    end
  end

  def derive(variable_name)
    Multiplication.new(@arg.derive(variable_name), Negation.new(Sin.new(@arg))).simplify
  end
end
