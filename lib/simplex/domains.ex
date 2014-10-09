defmodule Simplex.Domains do
  alias Simplex.Request

  def create(simplex, name) do
    Request.get_with_retry(%{"Action" => "CreateDomain", "DomainName" => name}, simplex)
  end

  def list(simplex, params \\ %{}) do
    params
    |> Map.merge(%{"Action" => "ListDomains"})
    |> Request.get_with_retry(simplex)
  end

  def delete(simplex, name) do
    Request.get_with_retry(%{"Action" => "DeleteDomain", "DomainName" => name}, simplex)
  end

end
