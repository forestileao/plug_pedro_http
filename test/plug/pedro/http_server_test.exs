defmodule Plug.Pedro.HttpServerTest do
  use ExUnit.Case
  doctest Plug.Pedro.HttpServer

  test "greets the world" do
    assert Plug.Pedro.HttpServer.hello() == :world
  end
end
