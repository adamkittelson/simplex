defmodule AttributesTest do
  use ExUnit.Case

  setup_all do
    {:ok, simplex} = Simplex.new("access-key", "secret-access-key")
    Process.register(simplex, :simplex)

    :ok
  end

  test "putting attributes" do
    :meck.expect(HTTPotion, :get, fn(_signed_request, [timeout: 30000]) ->
                                    %HTTPotion.Response{body: "<?xml version=\"1.0\"?>\n<PutAttributesResponse xmlns=\"http://sdb.amazonaws.com/doc/2009-04-15/\"><ResponseMetadata><RequestId>bbc9714d-6a32-5284-8d9e-0ef3c990b026</RequestId><BoxUsage>0.0000220035</BoxUsage></ResponseMetadata></PutAttributesResponse>",
                                    headers: ["Content-Type": "text/xml",
                                              "Transfer-Encoding": "chunked",
                                              Date: "Sat, 13 Sep 2014 22:11:11 GMT",
                                              Server: "Amazon SimpleDB"],
                                    status_code: 200}
                                  end)

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

    :meck.unload(HTTPotion)
  end

  test "getting attributes" do
    :meck.expect(HTTPotion, :get, fn(_signed_request, [timeout: 30000]) ->
                                    %HTTPotion.Response{body: "<?xml version=\"1.0\"?>\n<GetAttributesResponse xmlns=\"http://sdb.amazonaws.com/doc/2009-04-15/\"><GetAttributesResult><Attribute><Name>name</Name><Value>Adam</Value></Attribute><Attribute><Name>url</Name><Value>http://brightcove.com?also=some&amp;query=string&amp;just=because</Value></Attribute><Attribute><Name>email_addresses</Name><Value>adam@apathydrive.com</Value></Attribute><Attribute><Name>email_addresses</Name><Value>adam@zencoder.com</Value></Attribute><Attribute><Name>email_addresses</Name><Value>akittelson@brightcove.com</Value></Attribute></GetAttributesResult><ResponseMetadata><RequestId>8bd4b9ed-da4c-679f-f568-9a52eed61b67</RequestId><BoxUsage>0.0000093282</BoxUsage></ResponseMetadata></GetAttributesResponse>",
                                    headers: ["Content-Type": "text/xml",
                                              "Transfer-Encoding": "chunked",
                                              Date: "Sat, 13 Sep 2014 22:11:11 GMT",
                                              Server: "Amazon SimpleDB"],
                                    status_code: 200}
                                  end)

      {:ok, result, response} = Simplex.Attributes.get(:simplex, "AttributesTestDomain", "attribute_test_id")
      assert response.status_code == 200
      assert result == %{"name" => "Adam",
                         "url" => "http://brightcove.com?also=some&query=string&just=because",
                         "email_addresses" => ["akittelson@brightcove.com",
                                               "adam@zencoder.com",
                                               "adam@apathydrive.com"]}
      assert response.body == %{attributes: [%{name: "name", value: "Adam"},
                                             %{name: "url",  value: "http://brightcove.com?also=some&query=string&just=because"},
                                             %{name: "email_addresses", value: "adam@apathydrive.com"},
                                             %{name: "email_addresses", value: "adam@zencoder.com"},
                                             %{name: "email_addresses", value: "akittelson@brightcove.com"}],
                                box_usage: "0.0000093282",
                                request_id: "8bd4b9ed-da4c-679f-f568-9a52eed61b67"}
    :meck.unload(HTTPotion)
  end

  test "deleting attributes" do
    :meck.expect(HTTPotion, :get, fn(_signed_request, [timeout: 30000]) ->
                                    %HTTPotion.Response{body: "<?xml version=\"1.0\"?>\n<DeleteAttributesResponse xmlns=\"http://sdb.amazonaws.com/doc/2009-04-15/\"><ResponseMetadata><RequestId>c4cd105f-f065-1ea5-8d78-3ffe919b4cc5</RequestId><BoxUsage>0.0000219907</BoxUsage></ResponseMetadata></DeleteAttributesResponse>",
                                    headers: ["Content-Type": "text/xml",
                                              "Transfer-Encoding": "chunked",
                                              Date: "Sat, 13 Sep 2014 22:11:11 GMT",
                                              Server: "Amazon SimpleDB"],
                                    status_code: 200}
                                  end)

    {:ok, result, response} = Simplex.Attributes.delete(:simplex, "AttributesTestDomain",
                                                        "attribute_test_id",
                                                         %{},
                                                         %{"Name" => "name", "Value" => "Adam"})
    assert response.status_code == 200
    assert result == nil
    assert response.body == %{box_usage: "0.0000219907",
                              request_id: "c4cd105f-f065-1ea5-8d78-3ffe919b4cc5"}
    :meck.unload(HTTPotion)
  end

end