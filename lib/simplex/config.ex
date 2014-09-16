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

  def needs_refresh?(key, config) do
    expiring?(config) or !config[key]
  end

  def expiring?(%{:expires_at => nil}), do: false
  def expiring?(%{:expires_at => expires_at}) do
    expires_at = DateFormat.parse!(expires_at, "{ISOz}")

    Date.shift(Date.now, secs: 60) > expires_at
  end
  def expiring?(_config), do: false

  def load_credentials_from_metadata do
    try do
      %HTTPoison.Response{:body => role_name} = HTTPoison.get("http://169.254.169.254/latest/meta-data/iam/security-credentials/", [], [timeout: 500])
      %HTTPoison.Response{:body => body} = HTTPoison.get("http://169.254.169.254/latest/meta-data/iam/security-credentials/#{role_name}", [], [timeout: 500])
      Poison.decode!(body)
    rescue
      _ ->
        %{}
    end
  end

  def refresh(config) do
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

  def handle_cast({:set_aws_access_key, api_key}, config) do
    config = config
             |> Map.put(:aws_access_key, api_key)
             |> Map.delete(:expires_at)
    {:noreply, config}
  end

  def handle_cast({:set_aws_secret_access_key, api_key}, config) do
    config = config
             |> Map.put(:aws_secret_access_key, api_key)
             |> Map.delete(:expires_at)
    {:noreply, Map.put(config, :aws_secret_access_key, api_key)}
  end

  def handle_cast({:set_simpledb_url, url}, config) do
    {:noreply, Map.put(config, :simpledb_url, url)}
  end

end