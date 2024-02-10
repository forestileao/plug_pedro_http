defmodule Plug.Pedro.HttpServer do
  @moduledoc """
  Documentation for `Plug.Pedro.HttpServer`.
  """
  @adapter Plug.Pedro.HttpServer.Conn

  def conn_from_req(req, method, path) do
    {:ok, {remote_ip, _}} = :inet.sockname(req)
    %URI{path: path, query: query} = URI.parse(path)
    %Plug.Conn{
      adapter: {@adapter, {req, method, path}},
      host: nil,
      method: Atom.to_string(method),
      owner: self(),
      path_info: path |> Path.relative_to("/") |> Path.split(),
      port: nil,
      remote_ip: remote_ip,
      query_string: query,
      req_headers: [],
      request_path: path,
      scheme: :http
    }
  end

  def init(req, method, path, plug: plug, options: opts) do
    conn = conn_from_req(req, method, path)
    %{adapter: {@adapter, _}} =
      conn
      |> plug.call(opts)
      |> maybe_send(plug)

    {:ok, req, {plug, opts}}
  end

  defp maybe_send(%Plug.Conn{state: :unset}, _plug), do: raise Plug.Conn.NotSentError
  defp maybe_send(%Plug.Conn{state: :set} = conn, _plug), do: raise Plug.Conn.send_resp(conn)
  defp maybe_send(%Plug.Conn{} = conn, _plug), do: conn
  defp maybe_send(otherConn, plug), do: raise """
  Pedro adapter expected #{inspect(plug)} to return a Plug.Conn, but got #{inspect(otherConn)}
  """
end
