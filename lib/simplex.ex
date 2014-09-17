defmodule Simplex do
  use GenServer
  use Timex

  def new do
    start_link(%{})
  end

  def new(access_key, secret_access_key) do
    start_link(%{:aws_access_key => access_key, :aws_secret_access_key => secret_access_key})
  end

  def start_link(config, options \\ []) do
    config = config
             |> Map.put_new(:aws_access_key, System.get_env("AWS_ACCESS_KEY"))
             |> Map.put_new(:aws_secret_access_key, System.get_env("AWS_SECRET_ACCESS_KEY"))
             |> Map.put_new(:simpledb_url, System.get_env("SIMPLEDB_URL") || "https://sdb.amazonaws.com")

    GenServer.start_link(__MODULE__, config, options)
  end

  def aws_access_key(simplex) do
    GenServer.call(simplex, :get_aws_access_key)
  end

  def aws_access_key(simplex, access_key) do
    GenServer.call(simplex, {:set_aws_access_key, access_key})
  end

  def aws_secret_access_key(simplex) do
    GenServer.call(simplex, :get_aws_secret_access_key)
  end

  def aws_secret_access_key(simplex, secret_access_key) do
    GenServer.call(simplex, {:set_aws_secret_access_key, secret_access_key})
  end

  def simpledb_url(simplex) do
    GenServer.call(simplex, :get_simpledb_url)
  end

  def simpledb_url(simplex, url) do
    GenServer.call(simplex, {:set_simpledb_url, url})
  end

  defp needs_refresh?(:aws_access_key, config) do
    expiring?(config) or !config[:aws_access_key]
  end

  defp needs_refresh?(:aws_secret_access_key, config) do
    expiring?(config) or !config[:aws_secret_access_key]
  end

  # keys expired or expiring within the next 60 seconds
  defp expiring?(%{:expires_at => nil}), do: false
  defp expiring?(%{:expires_at => expires_at}) do
    expires_at = DateFormat.parse!(expires_at, "{ISOz}")
    Date.shift(Date.now, secs: 60) > expires_at
  end
  defp expiring?(_config), do: false

  defp load_credentials_from_metadata do
   try do
      %HTTPoison.Response{:body => role_name} = HTTPoison.get("http://169.254.169.254/latest/meta-data/iam/security-credentials/", [], [timeout: 500])
      %HTTPoison.Response{:body => body} = HTTPoison.get("http://169.254.169.254/latest/meta-data/iam/security-credentials/#{role_name}", [], [timeout: 500])
      Poison.decode!(body)
    rescue
      _ ->
        %{}
    end
  end

  defp refresh(config) do
    credentials_from_metadata = load_credentials_from_metadata
    update = %{
      :aws_access_key        => credentials_from_metadata["AccessKeyId"],
      :aws_secret_access_key => credentials_from_metadata["SecretAccessKey"],
      :expires_at            => credentials_from_metadata["Expiration"]
    }
    Map.merge(config, update)
  end


  ###################
  # Server Callbacks

  def init(config) do
    {:ok, config}
  end

  def handle_call(:get_aws_access_key, _from, config) do
    if needs_refresh?(:aws_access_key, config) do
      config = refresh(config)
      {:reply, config[:aws_access_key], config}
    else
      {:reply, config[:aws_access_key], config}
    end
  end

  def handle_call(:get_aws_secret_access_key, _from, config) do
    if needs_refresh?(:aws_secret_access_key, config) do
      config = refresh(config)
      {:reply, config[:aws_secret_access_key], config}
    else
      {:reply, config[:aws_secret_access_key], config}
    end
  end

  def handle_call(:get_simpledb_url, _from, config) do
    {:reply, config[:simpledb_url], config}
  end

  def handle_call({:set_aws_access_key, access_key}, _from, config) do
    config = config
             |> Map.put(:aws_access_key, access_key)
             |> Map.delete(:expires_at)
    {:reply, config[:aws_access_key], config}
  end

  def handle_call({:set_aws_secret_access_key, secret_access_key}, _from, config) do
    config = config
             |> Map.put(:aws_secret_access_key, secret_access_key)
             |> Map.delete(:expires_at)
    {:reply, config[:aws_secret_access_key], config}
  end

  def handle_call({:set_simpledb_url, url}, _from, config) do
    config = Map.put(config, :simpledb_url, url)
    {:reply, config[:simpledb_url], config}
  end

  def handle_info(_msg, config) do
    {:noreply, config}
  end

end
