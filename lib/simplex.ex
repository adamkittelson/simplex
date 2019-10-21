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
    config =
      config
      |> Map.put_new(:aws_access_key, System.get_env("AWS_ACCESS_KEY"))
      |> Map.put_new(:aws_secret_access_key, System.get_env("AWS_SECRET_ACCESS_KEY"))
      |> Map.put_new(:simpledb_url, System.get_env("SIMPLEDB_URL") || "https://sdb.amazonaws.com")
      |> Map.put_new(:simpledb_version, System.get_env("SIMPLEDB_VERSION") || "2009-04-15")

    GenServer.start_link(__MODULE__, config, options)
  end

  def aws_access_key(simplex) do
    configuration(simplex)[:aws_access_key]
  end

  def aws_access_key(simplex, access_key) do
    GenServer.call(simplex, {:set_aws_access_key, access_key})
  end

  def aws_secret_access_key(simplex) do
    configuration(simplex)[:aws_secret_access_key]
  end

  def aws_secret_access_key(simplex, secret_access_key) do
    GenServer.call(simplex, {:set_aws_secret_access_key, secret_access_key})
  end

  def configuration(simplex) do
    GenServer.call(simplex, :get_configuration)
  end

  def simpledb_url(simplex) do
    configuration(simplex)[:simpledb_url]
  end

  def simpledb_url(simplex, url) do
    GenServer.call(simplex, {:set_simpledb_url, url})
  end

  def simpledb_version(simplex) do
    configuration(simplex)[:simpledb_version]
  end

  def simpledb_version(simplex, version) do
    GenServer.call(simplex, {:set_simpledb_version, version})
  end

  defp needs_refresh?(config) do
    expiring?(config) or missing_keys?(config)
  end

  defp missing_keys?(config) do
    !config[:aws_access_key] or !config[:aws_secret_access_key]
  end

  # keys expired or expiring within the next 60 seconds
  def expiring?(%{:expires_at => nil}), do: false

  def expiring?(%{:expires_at => expires_at}) do
    expires_at = Timex.parse!(expires_at, "{ISO:Extended:Z}")
    sixty_seconds_from_now = Timex.shift(DateTime.utc_now(), seconds: 60)

    # :lt — the first date comes before the second one
    # :eq — both arguments represent the same date when coalesced to the same timezone.
    # :gt — the first date comes after the second one
    :gt == DateTime.compare(sixty_seconds_from_now, expires_at)
  end

  def expiring?(_config), do: false

  defp load_credentials_from_metadata do
    try do
      %HTTPotion.Response{:body => role_name} =
        HTTPotion.get("http://169.254.169.254/latest/meta-data/iam/security-credentials/",
          timeout: 500
        )

      %HTTPotion.Response{:body => body} =
        HTTPotion.get(
          "http://169.254.169.254/latest/meta-data/iam/security-credentials/#{role_name}",
          timeout: 500
        )

      Jason.decode!(body)
    rescue
      _ ->
        %{}
    end
  end

  defp refresh(config) do
    update = load_credentials_from_metadata()

    config
    |> Map.put(:aws_access_key, update["AccessKeyId"] || config[:aws_access_key])
    |> Map.put(
      :aws_secret_access_key,
      update["SecretAccessKey"] || config[:aws_secret_access_key]
    )
    |> Map.put(:expires_at, update["Expiration"] || config[:expires_at])
    |> Map.put(:token, update["Token"] || config[:token])
  end

  ###################
  # Server Callbacks

  def init(config) do
    {:ok, config}
  end

  def handle_call(:get_configuration, _from, config) do
    if needs_refresh?(config) do
      config = refresh(config)
      {:reply, config, config}
    else
      {:reply, config, config}
    end
  end

  def handle_call({:set_aws_access_key, access_key}, _from, config) do
    config =
      config
      |> Map.put(:aws_access_key, access_key)
      |> Map.delete(:expires_at)
      |> Map.delete(:token)

    {:reply, config[:aws_access_key], config}
  end

  def handle_call({:set_aws_secret_access_key, secret_access_key}, _from, config) do
    config =
      config
      |> Map.put(:aws_secret_access_key, secret_access_key)
      |> Map.delete(:expires_at)
      |> Map.delete(:token)

    {:reply, config[:aws_secret_access_key], config}
  end

  def handle_call({:set_simpledb_url, url}, _from, config) do
    config = Map.put(config, :simpledb_url, url)
    {:reply, config[:simpledb_url], config}
  end

  def handle_call({:set_simpledb_version, version}, _from, config) do
    config = Map.put(config, :simpledb_version, version)
    {:reply, config[:simpledb_version], config}
  end

  def handle_info(_msg, config) do
    {:noreply, config}
  end
end
