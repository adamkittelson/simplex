defmodule SimplexTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup context do

    if env_aws_access_key = context[:env_aws_access_key] do
      System.put_env("SIMPLEX_AWS_ACCESS_KEY", env_aws_access_key)
    end

    if env_aws_secret_access_key = context[:env_aws_secret_access_key] do
      System.put_env("SIMPLEX_AWS_SECRET_ACCESS_KEY", env_aws_secret_access_key)
    end

    if env_simpledburl = context[:env_simpledb_url] do
      System.put_env("SIMPLEX_SIMPLEDB_URL", env_simpledburl)
    end

    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")

    on_exit fn ->
      Simplex.aws_access_key(nil)
      Simplex.aws_secret_access_key(nil)
      Simplex.simpledb_url(nil)
      System.delete_env("SIMPLEX_AWS_ACCESS_KEY")
      System.delete_env("SIMPLEX_AWS_SECRET_ACCESS_KEY")
      System.delete_env("SIMPLEX_SIMPLEDB_URL")
    end

    :ok
  end

  test "gets default simpledb_url" do
    assert "https://sdb.amazonaws.com" == Simplex.simpledb_url
  end

  @tag env_simpledb_url: "https://sdb.us-west-1.amazonaws.com"
  test "gets simpledb_url from environment" do
    assert "https://sdb.us-west-1.amazonaws.com" == Simplex.simpledb_url
  end

  test "sets simpledb_url" do
    assert "https://sdb.amazonaws.com" == Simplex.simpledb_url
    Simplex.simpledb_url "https://sdb.sa-east-1.amazonaws.com"
    assert "https://sdb.sa-east-1.amazonaws.com" == Simplex.simpledb_url
  end

  @tag env_aws_access_key: "some-access-key"
  test "gets aws_access_key from environment" do
    assert "some-access-key" == Simplex.aws_access_key
  end

  test "sets aws_access_key" do
    assert nil == Simplex.aws_access_key
    Simplex.aws_access_key "access-key"
    assert "access-key" == Simplex.aws_access_key
  end

  @tag env_aws_secret_access_key: "some-secret-access-key"
  test "gets aws_secret_access_key from environment" do
    assert "some-secret-access-key" == Simplex.aws_secret_access_key
  end

  test "sets aws_secret_access_key" do
    assert nil == Simplex.aws_secret_access_key
    Simplex.aws_secret_access_key "secret-access-key"
    assert "secret-access-key" == Simplex.aws_secret_access_key
  end

  test "gets access_key from IAM" do
    use_cassette "access_key_iam" do
      assert Simplex.aws_access_key == "1234"
      :meck.unload(:hackney)
    end
  end

  test "gets secret_key from IAM" do
    use_cassette "access_secret_key_iam" do
      assert Simplex.aws_secret_access_key == "5678"
      :meck.unload(:hackney)
    end
  end

end
