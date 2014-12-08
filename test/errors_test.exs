defmodule ErrorsTest do
  use ExUnit.Case
  use ExVCR.Mock

  setup_all do
    {:ok, simplex} = Simplex.new("access-key", "secret-access-key")
    Process.register(simplex, :simplex)

    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
    :ok
  end

  test "Client Error" do
    use_cassette "client_error" do
      {:error, errors, response} = Simplex.Attributes.put(:simplex,
                                                          "AttributesTestDomain",
                                                          "attribute_test_id",
                                                          %{})
      assert response.status_code == 400
      assert errors == ["MissingParameter: No attributes"]
      assert response.body == %{errors: [%{box_usage: "0.0000219907",
                                           code: "MissingParameter",
                                           message: "No attributes"}],
                                request_id: nil}
    end
  end

  @tag timeout: 90000
  test "Server Error" do
    use_cassette "server_error" do
      {:error, errors, response} = Simplex.Attributes.put(:simplex,
                                                          "AttributesTestDomain",
                                                          "attribute_test_id",
                                                          %{})
      assert response.status_code == 500
      assert errors == ["InternalError: Request could not be executed due to an internal service error."]
      assert response.body == %{errors: [%{code: "InternalError",
                                           message: "Request could not be executed due to an internal service error."}]}
    end
  end

end