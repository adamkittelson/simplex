defmodule Simplex.Request do
  alias Simplex.Parameters
  alias Simplex.Response
  use Timex

  @max_attempts 5

  def get(params, simplex) do
    response = signed_request(params, simplex)
               |> execute
    Response.handle(params["Action"], response)
  end

  def get_with_retry(params, simplex) do
    response = signed_request(params, simplex)
               |> execute_with_retry
    Response.handle(params["Action"], response)
  end

  def execute(signed_request), do: HTTPoison.get(signed_request, [], [timeout: 30000])

  def execute_with_retry(signed_request, attempts \\ 0, last_response \\ nil)
  def execute_with_retry(signed_request, attempts, _last_response) when attempts < @max_attempts do
    try do
      attempts |> delay |> :timer.sleep
      case HTTPoison.get(signed_request, [], [timeout: 30000]) do
        %HTTPoison.Response{status_code: status_code} = response when status_code >= 500 and status_code < 600 ->
          execute_with_retry signed_request, attempts + 1, response
        response ->
          response
      end
    rescue
      e in HTTPoison.HTTPError -> e
        execute_with_retry signed_request, attempts + 1, e
    end
  end
  def execute_with_retry(_signed_request, _attempts, last_response), do: last_response

  def delay(0), do: 0
  def delay(attempt_number) do
    :random.seed(:os.timestamp)

    (:math.pow(4, attempt_number) * 100)
    |> trunc
    |> :random.uniform
  end

  def signed_request(params, simplex) do
    config = Simplex.configuration(simplex)

    uri = URI.parse(config[:simpledb_url])

    query = query_string(params, config)

    request = Enum.join(["GET", uri.host, uri.path || "/", query], "\n")

    signature = :crypto.hmac(:sha256, String.to_char_list(config[:aws_secret_access_key]), String.to_char_list(request))
                |> :base64.encode
                |> URI.encode
                |> String.replace("/", "%2F")
                |> String.replace("+", "%2B")
                |> String.replace("=", "%3D")

    "#{uri.scheme}://#{uri.authority}#{uri.path || "/"}?#{query}&Signature=#{signature}"
  end

  defp auth_params(config) do
    [
      AWSAccessKeyId: config[:aws_access_key],
      SignatureVersion: 2,
      SignatureMethod: "HmacSHA256",
      Timestamp: DateFormat.format!(Date.now, "{ISOz}")
    ] ++ auth_token(config)
  end

  defp auth_token(%{token: token}),  do: [SecurityToken: token]
  defp auth_token(_aws_credentials), do: []

  defp query_string(params, config) do
    Parameters.from_map(params) ++ [{:Version, config[:simpledb_version]}] ++ auth_params(config)
    |> Enum.sort
    |> URI.encode_query
    |> String.replace("+", "%20")
  end

end
