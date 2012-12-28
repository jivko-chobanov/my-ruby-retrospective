module Tree
  def label
    self.class::LABEL
  end
end

class Expr
  def Expr.build(tree)
    expr_main_classes = [Number, Variable, Negation, Sine, Cosine, Addition, Multiplication]
    expr_main_classes.each do |expr_class|
      if expr_class::LABEL == tree[0]
        return expr_class.new(*tree.drop(1))
      end
    end
  end

  def ==(other)
    tree == other.tree
  end

  def evaluate(environment={})
    @linguistic_construction.evaluate environment
  end

  def simplify
    @linguistic_construction.simplify
  end
end

class Unary < Expr
  def initialize(tree)
    @expr = Expr.build tree
  end

  def simplify
    self
  end

  def tree
    [label, value]
  end
end

class Binary < Expr
  def initialize(tree1, tree2)
    @expr1 = Expr.build tree1
    @expr2 = Expr.build tree2
  end

  def evaluate(environment={}, operation)
    operation.to_proc.(
      @expr1.evaluate(environment),
      @expr2.evaluate(environment)
    )
  end

  def tree
    [label, @expr1.tree, @expr2.tree]
  end
end

class Number < Unary
  LABEL = :number

  include Tree

  def initialize(number)
    @number = number
  end

  def evaluate(environment={})
    @number
  end

  def value
    @number
  end

  def derive(variable_name)
    Expr.build [:number, 0]
  end
end

class Variable < Unary
  LABEL = :variable

  include Tree

  def initialize(variable_name)
    @variable_name = variable_name
  end

  def evaluate(environment={})
    environment.fetch @variable_name, "undefined variable #{@variable_name}"
  end

  def value
    @variable_name
  end

  def derive(variable_name)
    if variable_name == @variable_name
      Expr.build [:number, 1]
    else
      self
    end
  end
end

class Negation < Unary
  LABEL = :-

  include Tree

  def initialize(tree)
    super
  end

  def evaluate(environment={})
    -1 * @expr.evaluate(environment)
  end

  def simplify
    simplified_expr = @expr.simplify
    if simplified_expr.tree == [:number, 0]
      return simplified_expr
    else
      Expr.build [LABEL, simplified_expr.tree]
    end
  end

  def value
    @expr.tree
  end

  def derive(variable_name)
    Expr.build [LABEL, @expr.derive(variable_name).tree]
  end
end

class Sine < Unary
  LABEL = :sin

  include Tree

  attr_reader :expr

  def initialize(tree)
    super
  end

  def evaluate(environment={})
    Math.sin @expr.evaluate(environment)
  end

  def simplify
    simplified_expr = @expr.simplify
    if [[:number, 0],[:number, Math::PI]].include? simplified_expr.tree
      return Expr.build [:number, 0]
    else
      Expr.build [LABEL, simplified_expr.tree]
    end
  end

  def value
    @expr.tree
  end

  def derive(variable_name)
    Expr.build [:*,
      simplify.expr.derive(variable_name).tree,
      [:cos, simplify.expr]]
  end
end

class Cosine < Unary
  LABEL = :cos

  include Tree

  attr_reader :expr

  def initialize(tree)
    super
  end

  def evaluate(environment={})
    Math.cos @expr.evaluate(environment)
  end

  def simplify
    simplified_expr = @expr.simplify
    if simplified_expr.tree == [:number, Math::PI / 2]
      return Expr.build [:number, 0]
    else
      Expr.build [LABEL, simplified_expr.tree]
    end
  end

  def value
    @expr.tree
  end

  def derive(variable_name)
    Expr.build [:*,
      simplify.expr.derive(variable_name).tree,
      [:-, [:sin, simplify.expr]]]
  end
end

class Addition < Binary
  LABEL = :+

  include Tree

  def initialize(tree1, tree2)
    super
  end

  def evaluate(environment={})
    super environment, :+
  end

  def simplify
    [@expr1, @expr2].map(&:simplify)
    if @expr1.tree == [:number, 0]
      return @expr2
    elsif @expr2.tree == [:number, 0]
      return @expr1
    end
    if @expr1.tree[0] == :number and @expr2.tree[0] == :number
      return Expr.build [:number, @expr1.evaluate + @expr2.evaluate]
    end
    self
  end

  def derive(variable_name)
    Expr.build [:+,
      simplify.expr1.derive(variable_name).tree,
      simplify.expr2.derive(variable_name).tree]
  end
end

class Multiplication < Binary
  LABEL = :*

  include Tree

  attr_reader :expr1, :expr2

  def initialize(tree1, tree2)
    super
  end

  def evaluate(environment={})
    super environment, :*
  end

  def simplify
    [@expr1, @expr2].map(&:simplify)
    if @expr1.tree == [:number, 1]
      return @expr2
    elsif @expr2.tree == [:number, 1]
      return @expr1
    end
    if @expr1.tree[0] == :number and @expr2.tree[0] == :number
      return Expr.build [:number, @expr1.evaluate * @expr2.evaluate]
    end
    self
  end

  def derive(variable_name)
    Expr.build [:+,
      [:*, simplify.expr1.derive(variable_name).tree, simplify.expr2.tree],
      [:*, simplify.expr2.derive(variable_name).tree, simplify.expr1.tree]]
  end
end
