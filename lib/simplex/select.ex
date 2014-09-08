defmodule Simplex.Select do
  alias Simplex.Request

  def select(select_expression, params \\ %{}) do
    params
    |> Map.merge(%{"Action" => "Select", "SelectExpression" => select_expression})
    |> Request.get
  end

end
