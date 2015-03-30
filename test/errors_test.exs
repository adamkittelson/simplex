defmodule ErrorsTest do
  use ExUnit.Case

  setup_all do
    {:ok, simplex} = Simplex.new("access-key", "secret-access-key")
    Process.register(simplex, :simplex)

    :ok
  end

  test "Client Error" do
    :meck.expect(HTTPotion, :get, fn(_signed_request, [timeout: 30000]) ->
                                    %HTTPotion.Response{body: "<?xml version=\"1.0\"?>\n<Response><Errors><Error><Code>MissingParameter</Code><Message>No attributes</Message><BoxUsage>0.0000219907</BoxUsage></Error></Errors><RequestID>2cc5d1ca-2e08-7d24-06d3-cbc84698c503</RequestID></Response>",
                                    headers: ["Content-Type": "text/xml",
                                              "Transfer-Encoding": "chunked",
                                              Date: "Sat, 13 Sep 2014 22:11:11 GMT",
                                              Server: "Amazon SimpleDB"],
                                    status_code: 400}
                                  end)

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

    :meck.unload(HTTPotion)
  end

  @tag timeout: 90000
  test "Server Error" do
    :meck.expect(HTTPotion, :get, fn(_signed_request, [timeout: 30000]) ->
                                    %HTTPotion.Response{body: "<?xml version=\"1.0\"?>\n<Response><Errors><Error><Code>InternalError</Code><Message>Request could not be executed due to an internal service error.</Message><BoxUsage>0.0000219907</BoxUsage></Error></Errors><RequestID>2cc5d1ca-2e08-7d24-06d3-cbc84698c503</RequestID></Response>",
                                    headers: ["Content-Type": "text/xml",
                                              "Transfer-Encoding": "chunked",
                                              Date: "Sat, 13 Sep 2014 22:11:11 GMT",
                                              Server: "Amazon SimpleDB"],
                                    status_code: 500}
                                  end)

    {:error, errors, response} = Simplex.Attributes.put(:simplex,
                                                        "AttributesTestDomain",
                                                        "attribute_test_id",
                                                        %{})
    assert response.status_code == 500
    assert errors == ["InternalError: Request could not be executed due to an internal service error."]
    assert response.body == %{errors: [%{code: "InternalError",
                                         message: "Request could not be executed due to an internal service error."}]}

    :meck.unload(HTTPotion)
  end

end