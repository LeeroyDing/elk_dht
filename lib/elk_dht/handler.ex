defmodule ElkDHT.Handler do
  use GenServer
  @server __MODULE__

  require Logger

  # Public interface
  
  @doc """
  Start the handler server.
  """
  def start_link do
    GenServer.start_link __MODULE__, :ok, [name: @server]
  end

  def socket do
    GenServer.call @server, :socket
  end

  # Private

  defp handle_msg(%{"y" => "r", "t" => trans_id, "r" => (args = %{"id" => node_id})}, ip = {a, b, c, d}, port) do
    Logger.debug "Response message from #{a}.#{b}.#{c}.#{d}:#{port}, t:#{Hexate.encode(trans_id)}, id:#{Hexate.encode(node_id)}"
  end

  # Callbacks
  def init(:ok) do
    case :gen_udp.open 0, [{:active, true}] do
      {:ok, socket} -> {:ok, %{socket: socket}}
      {:error, reason} -> {:stop, reason}                 
    end
  end

  def handle_call(:socket, _from, state = %{socket: socket}) do
    {:reply, socket, state}
  end

  def handle_info({:udp, socket, ip = {a, b, c, d}, port, data}, state) do
    File.write!("/Users/Leeroy/packet", to_string(data))
    Logger.debug "Got packet from #{a}.#{b}.#{c}.#{d}:#{port}."
    message = Bencode.decode!(to_string(data))
    Logger.debug "DHT msg_type: #{message["y"]}"
    handle_msg message, ip, port
    {:noreply, state}
  end
end
