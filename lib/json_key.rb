# frozen_string_literal: true

# Returns the PostgreSQL statement to get a JSON object field as text. Note this work for both
# JSON and JSONB type columns. More details:
# https://www.postgresql.org/docs/current/functions-json.html
class JSONKey < Arel::Nodes::InfixOperation
  def initialize(left, right)
    super("->>", left, Arel::Nodes.build_quoted(right))
  end
end
