defmodule SelectTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    Simplex.aws_access_key "access-key"
    Simplex.aws_secret_access_key "secret-access-key"

    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
    HTTPoison.start
    :ok
  end

  test "select queries" do
    use_cassette "select" do
      {:ok, result, response} = Simplex.Select.select("select * from SelectTestDomain")
      assert response.status_code == 200
      assert result == [%{attributes: %{"email_addresses" => "nova@apathydrive.com",
                                        "name" => "Nova"},
                          name: "select_test_2"},
                        %{attributes: %{"email_addresses" => ["akittelson@brightcove.com",
                                                              "adam@apathydrive.com",
                                                              "adam@zencoder.com"],
                                        "name" => "Adam"},
                          name: "select_test_1"}]
      assert response.body == %{box_usage: "0.0000320033",
                                items: [%{attributes: [%{name: "name",
                                                         value: "Adam"},
                                                       %{name: "email_addresses",
                                                         value: "adam@zencoder.com"},
                                                       %{name: "email_addresses",
                                                         value: "adam@apathydrive.com"},
                                                       %{name: "email_addresses",
                                                         value: "akittelson@brightcove.com"}],
                                          name: "select_test_1"},
                                        %{attributes: [%{name: "name",
                                                         value: "Nova"},
                                                       %{name: "email_addresses",
                                                         value: "nova@apathydrive.com"}],
                                          name: "select_test_2"}],
                                request_id: "1d8bf722-fcbe-74e7-bc47-14c30b3281ad"}
    end
  end

end
