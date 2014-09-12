defmodule Simplex.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(GenServer, [Simplex.Config, %{}, [name: Simplex.Config]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end