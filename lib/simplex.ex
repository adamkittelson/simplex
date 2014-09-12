defmodule Simplex do
  use Application
  alias Simplex.Config

  def start(_type, args) do
    Simplex.Supervisor.start_link
  end

  def aws_access_key do
    Config.aws_access_key || System.get_env("SIMPLEX_AWS_ACCESS_KEY")
  end

  def aws_access_key(key) do
    Config.aws_access_key(key)
  end

  def aws_secret_access_key do
    Config.aws_secret_access_key || System.get_env("SIMPLEX_AWS_SECRET_ACCESS_KEY")
  end

  def aws_secret_access_key(key) do
    Config.aws_secret_access_key(key)
  end

  def simpledb_url do
    Config.simpledb_url || System.get_env("SIMPLEX_SIMPLEDB_URL") || "https://sdb.amazonaws.com"
  end

  def simpledb_url(url) do
    Config.simpledb_url(url)
  end

end
