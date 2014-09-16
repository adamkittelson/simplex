defmodule Simplex.Config do
  use GenServer

  #############
  # Client API

  def aws_access_key do
    GenServer.call(__MODULE__, :get_aws_access_key)
  end

  def aws_access_key(aws_access_key) do
    GenServer.cast(__MODULE__, {:set_aws_access_key, aws_access_key})
  end

  def aws_secret_access_key do
    GenServer.call(__MODULE__, :get_aws_secret_access_key)
  end

  def aws_secret_access_key(aws_secret_access_key) do
    GenServer.cast(__MODULE__, {:set_aws_secret_access_key, aws_secret_access_key})
  end

  def simpledb_url do
    GenServer.call(__MODULE__, :get_simpledb_url)
  end

  def simpledb_url(url) do
    GenServer.cast(__MODULE__, {:set_simpledb_url, url})
  end

  def needs_refresh?(config) do
    !config[:aws_access_key] || !config[:aws_secret_access_key]
  end

  def load_credentials_from_metadata do
    %HTTPoison.Response{:body => role_name} = HTTPoison.get("http://169.254.169.254/latest/meta-data/iam/security-credentials/")
    %HTTPoison.Response{:body => body} = HTTPoison.get("http://169.254.169.254/latest/meta-data/iam/security-credentials/#{role_name}")
    require IEx
    IEx.pry
    Poison.decode!(body)
  end

  ###################
  # Server Callbacks

  def init(config) do
    {:ok, config}
  end

  def handle_call(:get_aws_access_key, _from, config) do
    {:reply, config[:aws_access_key], config}
  end

  def handle_call(:get_aws_secret_access_key, _from, config) do
    {:reply, config[:aws_secret_access_key], config}
  end

  def handle_call(:get_simpledb_url, _from, config) do
    {:reply, config[:simpledb_url], config}
  end

  def handle_cast({:set_aws_access_key, api_key}, config) do
    {:noreply, Map.put(config, :aws_access_key, api_key)}
  end

  def handle_cast({:set_aws_secret_access_key, api_key}, config) do
    {:noreply, Map.put(config, :aws_secret_access_key, api_key)}
  end

  def handle_cast({:set_simpledb_url, url}, config) do
    {:noreply, Map.put(config, :simpledb_url, url)}
  end

end