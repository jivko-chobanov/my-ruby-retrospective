require_relative 'solution.rb'
class TestTask3 < MiniTest::Unit::TestCase
  def test_=
    a = Expr.build [:+, [:number, 2], [:number, 3]]

    b = Expr.build [:+, [:number, 2], [:number, 3]]
    c = Expr.build [:+, [:number, 33333], [:number, 3]]
    d = Expr.build [:+, [:number, 3], [:number, 2]]

    assert a == b, '=='
    assert not(a == c), 'not =='
    assert not(a == d), 'not =='
  end
 
  def test_evaluate_binary
    a = Expr.build [:+, [:number, 2], [:number, 3]]
    b = Expr.build [:+, [:variable, :x], [:variable, :y]]
    c = Expr.build [:*, [:variable, :x], [:number, 3]]
    d = Expr.build [:*, [:variable, :x], [:+, [:variable, :x], [:variable, :y]]]

    assert_equal a.evaluate, 5, 'no variables'
    assert_equal b.evaluate(x: 1, y: 2), 3, 'x y'
    assert_equal c.evaluate(x: 2), 6, 'x * 3'
    assert_equal d.evaluate(x: 2, y: 3), 10, 'x * (x+y)'
  end
end

__END__
  def test_evaluate_unary
    e = Expr.build [:-, [:number, 2]]
    f = Expr.build [:sin, [:number, Math::PI / 6]]
    g = Expr.build [:cos, [:number, Math::PI / 6]]

    assert_equal e.evaluate, -2, 'negation of 2'
    assert_equal f.evaluate, Math.sin(Math::PI / 6), 'sin 30'
    assert_equal g.evaluate, Math.cos(Math::PI / 6), 'sin 30'
  end

  def test_simplify_no_trigonometry
    a = Expr.build [:number, 2]
    b = Expr.build [:+, [:number, 2], [:number, 0]]
    c = Expr.build [:*, [:number, 2], [:number, 1]]

    assert_equal a.simplify, a, 'number'
    assert_equal b.simplify, a, 'sum'
    assert_equal c.simplify.tree, [:number, 2], 'multipl'
  end

  def test_simplify_trigonometry
    zero = Expr.build [:number, 0]
    a = Expr.build [:sin, [:number, 0]]
    b = Expr.build [:sin, [:number, Math::PI]]
    c = Expr.build [:cos, [:number, Math::PI / 2]]

    assert_equal a.simplify, zero, 'sin 0'
    assert_equal b.simplify, zero, 'sin pi'
    assert_equal c.simplify, zero, 'cos pi/2'
  end

  def test_derivative
    a = Expr.build [:variable, :x]
    b = Expr.build [:number, 3]
    c = Expr.build [:*, b.tree, a.tree]

    assert_equal a.derive(:x), Expr.build([:number, 1]), "x'"
    assert_equal b.derive(:x), Expr.build([:number, 0]), "3'"
    assert_equal c.derive(:x), Expr.build([:number, 3]), "3x'"
  end
end
