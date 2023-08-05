# frozen_string_literal: true

module ArelTools
  module_function

  def quoted(expr)
    case expr
    when String
      Arel::Nodes::Quoted.new(expr)
    else
      expr
    end
  end

  def named_function(name, *exprs)
    exprs = exprs.map { |expr| quoted(expr) }
    Arel::Nodes::NamedFunction.new(name, exprs)
  end

  def concat(*exprs)
    named_function("CONCAT", *exprs)
  end

  def length(expr)
    named_function("LENGTH", expr)
  end
end
