defmodule DomainsTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    Simplex.aws_access_key "access-key"
    Simplex.aws_secret_access_key "secret-access-key"

    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
    HTTPoison.start
    :ok
  end

  test "creating a domain" do
    use_cassette "create_domain" do
      {:ok, result, response} = Simplex.Domains.create("test_domain")
      assert response.status_code == 200
      assert result == nil
    end
  end

  test "listing domains" do
    use_cassette "list_domains" do
      {:ok, result, response} = Simplex.Domains.list
      assert response.status_code == 200
      assert result == ["test", "test_domain"]
    end
  end

  test "deleting a domain" do
    use_cassette "delete_domain" do
      {:ok, result, response} = Simplex.Domains.delete("test_domain")
      assert response.status_code == 200
      assert result == nil
    end
  end

end