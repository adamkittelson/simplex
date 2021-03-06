defmodule Simplex.Select do
  alias Simplex.Request

  def select(simplex, select_expression, params \\ %{}) do
    params
    |> Map.merge(%{"Action" => "Select", "SelectExpression" => select_expression})
    |> Request.get_with_retry(simplex)
  end

end
