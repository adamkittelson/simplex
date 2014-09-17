defmodule SimplexTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

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

    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")

    on_exit fn ->
      System.delete_env("AWS_ACCESS_KEY")
      System.delete_env("AWS_SECRET_ACCESS_KEY")
      System.delete_env("SIMPLEDB_URL")
    end

    :ok
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
    use_cassette "access_key_iam" do
      {:ok, simplex} = Simplex.new
      assert "1234" == Simplex.aws_access_key(simplex)
      :meck.unload(:hackney)
    end
  end

  test "gets secret_key from IAM" do
    use_cassette "access_secret_key_iam" do
      {:ok, simplex} = Simplex.new
      assert "5678" == Simplex.aws_secret_access_key(simplex)
      :meck.unload(:hackney)
    end
  end

end
