defmodule Simplex do
  alias Simplex.Request
  import SweetXml

  defmodule Success do
    defstruct status_code: nil, body: %{}, metadata: %{}, full_response: nil
  end

  defmodule ClientError do
    defstruct status_code: nil, body: %{}, full_response: nil

    def human(%ClientError{body: body} = error) do
      body[:errors]
      |> Enum.map(&("#{&1[:code]}: #{&1[:message]}"))
      |> Enum.join("\n")
    end
  end

  defmodule ServerError do
    defstruct status_code: nil, body: %{}, full_response: nil, human: nil

    def human(%ClientError{body: body} = error) do
      body[:errors]
      |> Enum.map(&("#{&1[:code]}: #{&1[:message]}"))
      |> Enum.join("\n")
    end
  end

  def error(%HTTPoison.Response{status_code: code, body: body} = response) when code >= 400 and code < 500 do
    body = body
           |> xmap(response: [~x"//Response",
                     errors: [~x".//Errors/Error"l,
                        code: ~x".//Code/text()",
                        message: ~x".//Message/text()",
                        box_usage: ~x".//BoxUsage/text()"
                      ],
                     request_id: ~x".//RequestId/text()"])
    %ClientError{status_code: code, body: body[:response], full_response: response}
  end

  def error(%HTTPoison.Response{status_code: code, body: body} = response) when code >= 500 and code < 600 do
    body = body
           |> xmap(response: [~x"//Response",
                     errors: [~x".//Errors/Error"l,
                        code: ~x".//Code/text()",
                        message: ~x".//Message/text()"
                      ]])
    %ServerError{status_code: code, body: body[:response], full_response: response}
  end
end
