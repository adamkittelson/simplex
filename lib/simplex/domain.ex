defmodule Simplex.Domains do
  alias Simplex.Request

  def create(name) when is_list(name), do: name |> to_string |> create
  def create(name) do
    Request.get(%{"Action" => "CreateDomain", "DomainName" => name})
  end

  def list(params \\ %{}) do
    params
    |> Map.merge(%{"Action" => "ListDomains"})
    |> Request.get
  end

  def delete(name) when is_list(name), do: name |> to_string |> delete
  def delete(name) do
    Request.get(%{"Action" => "DeleteDomain", "DomainName" => name})
  end

end
