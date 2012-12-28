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

    assert_equal 5, a.evaluate, 'no variables'
    assert_equal 3, b.evaluate(x: 1, y: 2), 'x y'
    assert_equal 6, c.evaluate(x: 2), 'x * 3'
    assert_equal 10, d.evaluate(x: 2, y: 3), 'x * (x+y)'
  end

  def test_evaluate_unary
    e = Expr.build [:-, [:number, 2]]
    f = Expr.build [:sin, [:number, Math::PI / 6]]
    g = Expr.build [:cos, [:number, Math::PI / 6]]

    assert_equal -2, e.evaluate, 'negation of 2'
    assert_equal Math.sin(Math::PI / 6), f.evaluate, 'sin 30'
    assert_equal Math.cos(Math::PI / 6), g.evaluate, 'sin 30'
  end

  def test_simplify_no_trigonometry
    a = Expr.build [:number, 2]
    a_var = Expr.build [:number, :x]

    b = Expr.build [:+, [:number, 2], [:number, 0]]
    b_var = Expr.build [:+, [:number, :x], [:number, 0]]
    
    c = Expr.build [:*, [:number, 2], [:number, 1]]
    c_zero = Expr.build [:*, [:number, 2], [:number, 0]]
    zero = Expr.build [:number, 0]

    assert_equal a, a.simplify, 'number'
    assert_equal a, b.simplify, 'sum'
    assert_equal a_var, b_var.simplify, 'sum with var'
    assert_equal a, c.simplify, 'multipl 1'
    assert_equal zero, c_zero.simplify, 'multipl 0'
  end

  def test_simplify_trigonometry
    zero = Expr.build [:number, 0]
    one = Expr.build [:number, 1]
    minus_one = Expr.build [:-, [:number, 1]]
    
    a_two = Expr.build [:sin, [:number, 2]]
    a_zero       = Expr.build [:sin, [:number, 0]]
    b_zero       = Expr.build [:sin, [:number, Math::PI]]
    c_one        = Expr.build [:sin, [:number, Math::PI / 2]]
    d_minus_one  = Expr.build [:sin, [:number, 3 * Math::PI / 2]]
    e_one        = Expr.build [:cos, [:number, 0]]
    f_minus_one  = Expr.build [:cos, [:number, Math::PI]]
    j_zero       = Expr.build [:cos, [:number, Math::PI / 2]]
    h_zero       = Expr.build [:cos, [:number, 3 * Math::PI / 2]]

    assert_equal a_two, a_two.simplify
    assert_equal zero, a_zero.simplify
    assert_equal zero, b_zero.simplify
    assert_equal one, c_one.simplify
    assert_equal minus_one, d_minus_one.simplify
    assert_equal one, e_one.simplify
    assert_equal minus_one, f_minus_one.simplify
    assert_equal zero, j_zero.simplify
    assert_equal zero, h_zero.simplify
  end

  def test_recursive_simplify_and_immutable_simplify
    five = Expr.build [:number, 5]
    five_complicated = Expr.build([:+,
      [:sin, [:number, 0]],
      [:*,
        [:-, [:-, [:number, 1]]],
        [:number, 5],
      ],
    ])

    assert_equal five, five_complicated.simplify
    refute_equal five, five_complicated
  end

  def test_derivative
    a = Expr.build [:variable, :x]
    b = Expr.build [:number, 3]
    c = Expr.build [:*, [:variable, :x], [:number, 3]]

    d = Expr.build [:+, [:variable, :x], [:variable, :x]]
    d2 = Expr.build [:+, [:number, 1], [:number, 1]]

    sin2 = Expr.build [:*, [:number, 2], [:cos, [:*, [:number, 2], [:variable, :a]]]]
    cos2 = Expr.build [:*, [:number, 2], [:-, [:sin, [:*, [:number, 2], [:variable, :a]]]]]

    assert_equal Expr.build([:number, 1]), a.derive(:x), "x'"
    assert_equal Expr.build([:number, 0]), b.derive(:x), "3'"
    assert_equal Expr.build([:number, 0]), a.derive(:y), "3xdy"
    assert_equal Expr.build([:number, 3]), c.derive(:x), "3x'"
    assert_equal d2, d.derive(:x), "(x + x)'"
    assert_equal sin2, Expr.build([:sin, [:*, [:number, 2], [:variable, :a]]]).derive(:a), "(sin(2x))'"
    assert_equal cos2, Expr.build([:cos, [:*, [:number, 2], [:variable, :a]]]).derive(:a), "(sin(2x))'"
  end
end
