defmodule SellerCenter do
  @moduledoc false

  def http_poison(arguments) do
    HTTPoison.request(
      arguments["method"],
      arguments["url"],
      arguments["body"],
      arguments["headers"],
      arguments["options"]
    )
  end

  def parse_response(response) do
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, status_code}
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
    end
  end

  def get_params(channel, params_custom) do
    timestamp = get_timestamp()
    params_default = %{
      "Filter" => "all",
      "Format" => "JSON",
      "Timestamp" => timestamp,
      "UserID" => channel["user_id"],
      "Version" => "1.0",
    }
    params = Map.merge(params_default, params_custom)
    message = get_message(params)
    signature = get_signature(channel, message)
    params = Map.put(params, "Signature", signature)
    Enum.map(params, fn({key, value}) -> {key, value} end)
  end

  def get_timestamp() do
    timestamp = Timex.now("UTC")
    {:ok, timestamp} = Timex.format(timestamp, "{ISO:Extended}")
    timestamp
  end

  def get_message(params) do
    message = Enum.map(params, fn({key, value}) -> {key, value} end)
    message = Enum.sort(message)
    URI.encode_query(message)
  end

  def get_signature(channel, message) do
    signature = :crypto.hmac(:sha256, channel["api_key"], message)
    signature = Base.encode16(signature)
    String.downcase(signature)
  end
end
