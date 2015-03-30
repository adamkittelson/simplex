defmodule SelectTest do
  use ExUnit.Case

  setup_all do
    {:ok, simplex} = Simplex.new("access-key", "secret-access-key")
    Process.register(simplex, :simplex)

    :ok
  end

  test "select queries" do
    :meck.expect(HTTPotion, :get, fn(_signed_request, [timeout: 30000]) ->
                                    %HTTPotion.Response{body: "<?xml version=\"1.0\"?>\n<SelectResponse xmlns=\"http://sdb.amazonaws.com/doc/2009-04-15/\"><SelectResult><Item><Name>select_test_1</Name><Attribute><Name>name</Name><Value>Adam</Value></Attribute><Attribute><Name>email_addresses</Name><Value>adam@zencoder.com</Value></Attribute><Attribute><Name>email_addresses</Name><Value>adam@apathydrive.com</Value></Attribute><Attribute><Name>email_addresses</Name><Value>akittelson@brightcove.com</Value></Attribute></Item><Item><Name>select_test_2</Name><Attribute><Name>name</Name><Value>Nova</Value></Attribute><Attribute><Name>email_addresses</Name><Value>nova@apathydrive.com</Value></Attribute></Item></SelectResult><ResponseMetadata><RequestId>1d8bf722-fcbe-74e7-bc47-14c30b3281ad</RequestId><BoxUsage>0.0000320033</BoxUsage></ResponseMetadata></SelectResponse>",
                                    headers: ["Content-Type": "text/xml",
                                              "Transfer-Encoding": "chunked",
                                              Date: "Sat, 13 Sep 2014 22:11:11 GMT",
                                              Server: "Amazon SimpleDB"],
                                    status_code: 200}
                                  end)

    {:ok, result, response} = Simplex.Select.select(:simplex, "select * from SelectTestDomain")
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

    :meck.unload(HTTPotion)
  end

end
