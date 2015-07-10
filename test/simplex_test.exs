defmodule SimplexTest do
  use ExUnit.Case
  use Timex

  setup context do

    if env_aws_access_key = context[:env_aws_access_key] do
      System.put_env("AWS_ACCESS_KEY", env_aws_access_key)
    end

    if env_aws_secret_access_key = context[:env_aws_secret_access_key] do
      System.put_env("AWS_SECRET_ACCESS_KEY", env_aws_secret_access_key)
    end

    if env_simpledburl = context[:env_simpledb_url] do
      System.put_env("SIMPLEDB_URL", env_simpledburl)
    end

    if env_simpledb_version = context[:env_simpledb_version] do
      System.put_env("SIMPLEDB_VERSION", env_simpledb_version)
    end

    on_exit fn ->
      System.delete_env("AWS_ACCESS_KEY")
      System.delete_env("AWS_SECRET_ACCESS_KEY")
      System.delete_env("SIMPLEDB_URL")
      System.delete_env("SIMPLEDB_VERSION")
    end

    :ok
  end

  test "gets default simpledb_version" do
    {:ok, simplex} = Simplex.new
    assert "2009-04-15" == Simplex.simpledb_version(simplex)
  end

  @tag env_simpledb_version: "2014-09-23"
  test "gets simpledb_version from environment" do
    {:ok, simplex} = Simplex.new
    assert "2014-09-23" == Simplex.simpledb_version(simplex)
  end

  test "sets simpledb_version" do
    {:ok, simplex} = Simplex.new
    assert "2009-04-15" == Simplex.simpledb_version(simplex)
    Simplex.simpledb_version(simplex, "2014-09-23")
    assert "2014-09-23" == Simplex.simpledb_version(simplex)
  end

  test "gets default simpledb_url" do
    {:ok, simplex} = Simplex.new
    assert "https://sdb.amazonaws.com" == Simplex.simpledb_url(simplex)
  end

  @tag env_simpledb_url: "https://sdb.us-west-1.amazonaws.com"
  test "gets simpledb_url from environment" do
    {:ok, simplex} = Simplex.new
    assert "https://sdb.us-west-1.amazonaws.com" == Simplex.simpledb_url(simplex)
  end

  test "sets simpledb_url" do
    {:ok, simplex} = Simplex.new
    assert "https://sdb.amazonaws.com" == Simplex.simpledb_url(simplex)
    Simplex.simpledb_url(simplex, "https://sdb.sa-east-1.amazonaws.com")
    assert "https://sdb.sa-east-1.amazonaws.com" == Simplex.simpledb_url(simplex)
  end

  @tag env_aws_access_key: "some-access-key"
  test "gets aws_access_key from environment" do
    {:ok, simplex} = Simplex.new
    assert "some-access-key" == Simplex.aws_access_key(simplex)
  end

  test "sets aws_access_key" do
    {:ok, simplex} = Simplex.new
    assert nil == Simplex.aws_access_key(simplex)
    Simplex.aws_access_key(simplex, "access-key")
    assert "access-key" == Simplex.aws_access_key(simplex)
  end

  @tag env_aws_secret_access_key: "some-secret-access-key"
  test "gets aws_secret_access_key from environment" do
    {:ok, simplex} = Simplex.new
    assert "some-secret-access-key" == Simplex.aws_secret_access_key(simplex)
  end

  test "sets aws_secret_access_key" do
    {:ok, simplex} = Simplex.new
    assert nil == Simplex.aws_secret_access_key(simplex)
    Simplex.aws_secret_access_key(simplex, "secret-access-key")
    assert "secret-access-key" == Simplex.aws_secret_access_key(simplex)
  end

  test "gets access_key from IAM" do
    :meck.expect(HTTPotion, :get, fn("http://169.254.169.254/latest/meta-data/iam/security-credentials/", [timeout: 500]) ->
                                      %HTTPotion.Response{body: "simpledb",
                                      headers: ["Content-Type": "text/plain",
                                                "Transfer-Encoding": "chunked",
                                                Date: "Sat, 13 Sep 2014 22:11:11 GMT",
                                                Server: "EC2ws"],
                                      status_code: 200}

                                    ("http://169.254.169.254/latest/meta-data/iam/security-credentials/simpledb", [timeout: 500]) ->
                                      %HTTPotion.Response{body: "{\n  \"Code\" : \"Success\",\n  \"LastUpdated\" : \"2014-09-16T20:08:30Z\",\n  \"Type\" : \"AWS-HMAC\",\n  \"AccessKeyId\" : \"1234\",\n  \"SecretAccessKey\" : \"5678\",\n  \"Token\" : \"token\",\n  \"Expiration\" : \"2014-09-17T02:37:56Z\"\n}",
                                      headers: ["Content-Type": "text/plain",
                                                "Transfer-Encoding": "chunked",
                                                Date: "Sat, 13 Sep 2014 22:11:11 GMT",
                                                Server: "EC2ws"],
                                      status_code: 200}
                                  end)

    {:ok, simplex} = Simplex.new
    assert "1234" == Simplex.aws_access_key(simplex)

    :meck.unload(HTTPotion)
  end

  test "gets secret_key from IAM" do
    :meck.expect(HTTPotion, :get, fn("http://169.254.169.254/latest/meta-data/iam/security-credentials/", [timeout: 500]) ->
                                      %HTTPotion.Response{body: "simpledb",
                                      headers: ["Content-Type": "text/plain",
                                                "Transfer-Encoding": "chunked",
                                                Date: "Sat, 13 Sep 2014 22:11:11 GMT",
                                                Server: "EC2ws"],
                                      status_code: 200}

                                    ("http://169.254.169.254/latest/meta-data/iam/security-credentials/simpledb", [timeout: 500]) ->
                                      %HTTPotion.Response{body: "{\n  \"Code\" : \"Success\",\n  \"LastUpdated\" : \"2014-09-16T20:08:30Z\",\n  \"Type\" : \"AWS-HMAC\",\n  \"AccessKeyId\" : \"1234\",\n  \"SecretAccessKey\" : \"5678\",\n  \"Token\" : \"token\",\n  \"Expiration\" : \"2014-09-17T02:37:56Z\"\n}",
                                      headers: ["Content-Type": "text/plain",
                                                "Transfer-Encoding": "chunked",
                                                Date: "Sat, 13 Sep 2014 22:11:11 GMT",
                                                Server: "EC2ws"],
                                      status_code: 200}
                                  end)

    {:ok, simplex} = Simplex.new
    assert "5678" == Simplex.aws_secret_access_key(simplex)

    :meck.unload(HTTPotion)
  end

  test "an expired key is expiring" do
    one_week_ago = Date.now |> Date.shift(weeks: -1) |> DateFormat.format!("{ISOz}")

    key = %{aws_access_key: "access_key",
            aws_secret_access_key: "secret_access_key",
            expires_at: one_week_ago,
            simpledb_url: "https://sdb.amazonaws.com",
            simpledb_version: "2009-04-15",
            token: "token"}

    assert Simplex.expiring?(key) == true
  end

  test "a key that expires 30 seconds from now is expiring" do
    thirty_seconds_from_now = Date.now |> Date.shift(secs: 30) |> DateFormat.format!("{ISOz}")

    key = %{aws_access_key: "access_key",
            aws_secret_access_key: "secret_access_key",
            expires_at: thirty_seconds_from_now,
            simpledb_url: "https://sdb.amazonaws.com",
            simpledb_version: "2009-04-15",
            token: "token"}

    assert Simplex.expiring?(key) == true
  end

  test "a key that expires 1 hour from now is not expiring" do
    one_hour_from_now = Date.now |> Date.shift(hours: 1) |> DateFormat.format!("{ISOz}")

    key = %{aws_access_key: "access_key",
            aws_secret_access_key: "secret_access_key",
            expires_at: one_hour_from_now,
            simpledb_url: "https://sdb.amazonaws.com",
            simpledb_version: "2009-04-15",
            token: "token"}

    assert Simplex.expiring?(key) == false
  end

  test "a key that expired at 2015-06-30T07:04:23Z is expiring" do
    key = %{aws_access_key: "access_key",
            aws_secret_access_key: "secret_access_key",
            expires_at: "2015-06-30T07:04:23Z",
            simpledb_url: "https://sdb.amazonaws.com",
            simpledb_version: "2009-04-15",
            token: "token"}

    assert Simplex.expiring?(key) == true
  end

end
