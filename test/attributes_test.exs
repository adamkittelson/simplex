defmodule AttributesTest do
  use ExUnit.Case
  use ExVCR.Mock

  setup_all do
    {:ok, simplex} = Simplex.new("access-key", "secret-access-key")
    Process.register(simplex, :simplex)

    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
    :ok
  end

  test "putting attributes" do
    use_cassette "put_attributes" do

      {:ok, result, response} = Simplex.Attributes.put(:simplex,
                                                       "AttributesTestDomain",
                                                       "attribute_test_id",
                                                       %{"name" => {:replace, "Adam"},
                                                         "email_addresses" => ["adam@apathydrive.com",
                                                                               "adam@zencoder.com",
                                                                               "akittelson@brightcove.com"]})
      assert response.status_code == 200
      assert result == nil
      assert response.body == %{box_usage: "0.0000220035",
                                request_id: "bbc9714d-6a32-5284-8d9e-0ef3c990b026"}
    end
  end

  test "getting attributes" do
    use_cassette "get_attributes" do
      {:ok, result, response} = Simplex.Attributes.get(:simplex, "AttributesTestDomain", "attribute_test_id")
      assert response.status_code == 200
      assert result == %{"name" => "Adam",
                         "email_addresses" => ["akittelson@brightcove.com",
                                               "adam@zencoder.com",
                                               "adam@apathydrive.com"]}
      assert response.body == %{attributes: [%{name: "name", value: "Adam"},
                                             %{name: "email_addresses", value: "adam@apathydrive.com"},
                                             %{name: "email_addresses", value: "adam@zencoder.com"},
                                             %{name: "email_addresses", value: "akittelson@brightcove.com"}],
                                box_usage: "0.0000093282",
                                request_id: "8bd4b9ed-da4c-679f-f568-9a52eed61b67"}
    end
  end

  test "deleting attributes" do
    use_cassette "delete_attributes" do
      {:ok, result, response} = Simplex.Attributes.delete(:simplex, "AttributesTestDomain",
                                                          "attribute_test_id",
                                                           %{},
                                                           %{"Name" => "name", "Value" => "Adam"})
      assert response.status_code == 200
      assert result == nil
      assert response.body == %{box_usage: "0.0000219907",
                                request_id: "c4cd105f-f065-1ea5-8d78-3ffe919b4cc5"}
    end
  end

end