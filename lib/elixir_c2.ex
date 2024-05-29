defmodule ElixirC2 do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {ElixirC2Server, {"localhost", 4000}}
    ]

    opts = [strategy: :one_for_one, name: ElixirC2.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
