defmodule DomainsTest do
  use ExUnit.Case

  setup_all do
    {:ok, simplex} = Simplex.new("access-key", "secret-access-key")
    Process.register(simplex, :simplex)

    :ok
  end

  test "creating a domain" do
    :meck.expect(HTTPotion, :get, fn(_signed_request, [timeout: 30000]) ->
                                    %HTTPotion.Response{body: "<?xml version=\"1.0\"?>\n<CreateDomainResponse xmlns=\"http://sdb.amazonaws.com/doc/2009-04-15/\"><ResponseMetadata><RequestId>70e2100f-fd4e-92b5-5f7d-769198125bf7</RequestId><BoxUsage>0.0055590278</BoxUsage></ResponseMetadata></CreateDomainResponse>",
                                    headers: ["Content-Type": "text/xml",
                                              "Transfer-Encoding": "chunked",
                                              Date: "Sat, 13 Sep 2014 22:11:11 GMT",
                                              Server: "Amazon SimpleDB"],
                                    status_code: 200}
                                  end)

    {:ok, result, response} = Simplex.Domains.create(:simplex, "test_domain")
    assert response.status_code == 200
    assert result == nil
    assert response.body == %{box_usage: "0.0055590278",
                              request_id: "70e2100f-fd4e-92b5-5f7d-769198125bf7"}

    :meck.unload(HTTPotion)
  end

  test "listing domains" do
    :meck.expect(HTTPotion, :get, fn(_signed_request, [timeout: 30000]) ->
                                    %HTTPotion.Response{body: "<?xml version=\"1.0\"?>\n<ListDomainsResponse xmlns=\"http://sdb.amazonaws.com/doc/2009-04-15/\"><ListDomainsResult><DomainName>test</DomainName><DomainName>test_domain</DomainName></ListDomainsResult><ResponseMetadata><RequestId>8d85ba40-c3f1-5ff5-50ea-9dfdc2fa103c</RequestId><BoxUsage>0.0000071759</BoxUsage></ResponseMetadata></ListDomainsResponse>",
                                    headers: ["Content-Type": "text/xml",
                                              "Transfer-Encoding": "chunked",
                                              Date: "Sat, 13 Sep 2014 22:11:11 GMT",
                                              Server: "Amazon SimpleDB"],
                                    status_code: 200}
                                  end)

    {:ok, result, response} = Simplex.Domains.list(:simplex)
    assert response.status_code == 200
    assert result == ["test", "test_domain"]
    assert response.body == %{box_usage: "0.0000071759",
                              request_id: "8d85ba40-c3f1-5ff5-50ea-9dfdc2fa103c",
                              next_token: nil,
                              result: ["test", "test_domain"]}

    :meck.unload(HTTPotion)
  end

  test "deleting a domain" do
    :meck.expect(HTTPotion, :get, fn(_signed_request, [timeout: 30000]) ->
                                    %HTTPotion.Response{body: "<?xml version=\"1.0\"?>\n<DeleteDomainResponse xmlns=\"http://sdb.amazonaws.com/doc/2009-04-15/\"><ResponseMetadata><RequestId>e4aead9f-b877-c4dc-98eb-3cc9538699d9</RequestId><BoxUsage>0.0055590278</BoxUsage></ResponseMetadata></DeleteDomainResponse>",
                                    headers: ["Content-Type": "text/xml",
                                              "Transfer-Encoding": "chunked",
                                              Date: "Sat, 13 Sep 2014 22:11:11 GMT",
                                              Server: "Amazon SimpleDB"],
                                    status_code: 200}
                                  end)

    {:ok, result, response} = Simplex.Domains.delete(:simplex, "test_domain")
    assert response.status_code == 200
    assert result == nil
    assert response.body == %{box_usage: "0.0055590278",
                              request_id: "e4aead9f-b877-c4dc-98eb-3cc9538699d9"}
    :meck.unload(HTTPotion)
  end

end