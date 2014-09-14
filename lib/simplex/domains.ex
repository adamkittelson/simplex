defmodule Simplex.Domains do
  alias Simplex.Request

  def create(name) do
    Request.get(%{"Action" => "CreateDomain", "DomainName" => name})
  end

  def list(params \\ %{}) do
    params
    |> Map.merge(%{"Action" => "ListDomains"})
    |> Request.get
  end

  def delete(name) do
    Request.get(%{"Action" => "DeleteDomain", "DomainName" => name})
  end

end
