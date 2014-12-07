defmodule DomainsTest do
  use ExUnit.Case
  use ExVCR.Mock

  setup_all do
    {:ok, simplex} = Simplex.new("access-key", "secret-access-key")
    Process.register(simplex, :simplex)

    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
    :ok
  end

  test "creating a domain" do
    use_cassette "create_domain" do
      {:ok, result, response} = Simplex.Domains.create(:simplex, "test_domain")
      assert response.status_code == 200
      assert result == nil
      assert response.body == %{box_usage: "0.0055590278",
                                request_id: "70e2100f-fd4e-92b5-5f7d-769198125bf7"}
    end
  end

  test "listing domains" do
    use_cassette "list_domains" do
      {:ok, result, response} = Simplex.Domains.list(:simplex)
      assert response.status_code == 200
      assert result == ["test", "test_domain"]
      assert response.body == %{box_usage: "0.0000071759",
                                request_id: "8d85ba40-c3f1-5ff5-50ea-9dfdc2fa103c",
                                next_token: nil,
                                result: ["test", "test_domain"]}
    end
  end

  test "deleting a domain" do
    use_cassette "delete_domain" do
      {:ok, result, response} = Simplex.Domains.delete(:simplex, "test_domain")
      assert response.status_code == 200
      assert result == nil
      assert response.body == %{box_usage: "0.0055590278",
                                request_id: "e4aead9f-b877-c4dc-98eb-3cc9538699d9"}
    end
  end

end