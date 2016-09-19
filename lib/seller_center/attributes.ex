defmodule SellerCenter.Attributes do
  @moduledoc false

  require Map
  require SellerCenter

  def query(channel, primary_category) do
    arguments = get_arguments(channel, primary_category)
    response = SellerCenter.http_poison(arguments)
    body = SellerCenter.parse_response(response)
    parse_body(channel, body)
  end

  def parse_body(channel, {:ok, %{"SuccessResponse" => success_response}}) do
    body = {:ok, success_response}
    parse_body(channel, body)
  end

  def parse_body(channel, {:ok, %{"Body" => body}}) do
    body = {:ok, body}
    parse_body(channel, body)
  end

  def parse_body(channel, {:ok, %{"Attribute" => attributes}}) do
    attributes = Enum.map(
      attributes, fn(attribute) -> get_attribute(channel, attribute) end
    )
    attributes = Enum.uniq(attributes)
    {:ok, attributes}
  end

  def parse_body(channel, {:ok, %{"ErrorResponse" => error_response}}) do
    body = {:ok, error_response}
    parse_body(channel, body)
  end

  def parse_body(channel, {:ok, %{"Head" => head}}) do
    body = {:ok, head}
    parse_body(channel, body)
  end

  def parse_body(_channel, {:ok, %{"ErrorCode" => error_code}}) do
    {:ok, error_code}
  end

  def parse_body(_channel, {:ok, _attributes}) do
    {:error, nil}
  end

  def parse_body(_channel, {:error, reason}) do
    {:error, reason}
  end

  def get_arguments(channel, primary_category) do
    method = :get
    url = channel["url"]
    body = ""
    headers = []
    params = %{
      "Action" => "GetCategoryAttributes",
      "PrimaryCategory" => primary_category,
    }
    params = SellerCenter.get_params(channel, params)
    options = [
      {:params, params},
      {:recv_timeout, Application.get_env(:httpoison, :timeout, nil)},
      {:timeout, Application.get_env(:httpoison, :timeout, nil)},
    ]
    %{
      "method" => method,
      "url" => url,
      "body" => body,
      "headers" => headers,
      "options" => options,
    }
  end

  def get_attribute(channel, attribute) do
    {name, name_es} = get_names(channel, attribute)

    {description, description_es} = get_descriptions(channel, attribute)

    is_mandatory = get_is_mandatory(attribute)

    options = get_options(channel, attribute)
    options = Enum.into(options, %{})

    type = get_type(options, attribute)

    %{
      "name" => name,
      "name_es" => name_es,
      "description" => description,
      "description_es" => description_es,
      "is_mandatory" => is_mandatory,
      "type" => type,
      "options" => options,
    }
  end

  def get_names(%{"language" => "en"}, attribute) do
    {attribute["Label"], ""}
  end

  def get_names(%{"language" => "es"}, attribute) do
    {"", attribute["Label"]}
  end

  def get_names(_channel, attribute) do
    {attribute["Label"], ""}
  end

  def get_descriptions(%{"language" => "en"}, attribute) do
    {attribute["Description"], ""}
  end

  def get_descriptions(%{"language" => "es"}, attribute) do
    {"", attribute["Description"]}
  end

  def get_descriptions(_channel, attribute) do
    {attribute["Description"], ""}
  end

  def get_is_mandatory(%{"isMandatory" => "1"}) do
    true
  end

  def get_is_mandatory(_attribute) do
    false
  end

  def get_type(options, %{"InputType" => "checkbox"})
    when Kernel.map_size(options) == 0 do
    ~s(input[type="checkbox"])
  end

  def get_type(options, %{"InputType" => "datefield"})
    when Kernel.map_size(options) == 0 do
    ~s(input[type="date"])
  end

  def get_type(options, %{"InputType" => "datetime"})
    when Kernel.map_size(options) == 0 do
    ~s(input[type="datetime"])
  end

  def get_type(options, %{"InputType" => "dropdown"})
    when Kernel.map_size(options) == 0 do
    ~s(select)
  end

  def get_type(options, %{"InputType" => "multiselect"})
    when Kernel.map_size(options) == 0 do
    ~s(select[multiple="multiple"])
  end

  def get_type(options, %{"InputType" => "numberfield"})
    when Kernel.map_size(options) == 0 do
    ~s(input[type="number"])
  end

  def get_type(options, %{"InputType" => "textarea"})
    when Kernel.map_size(options) == 0 do
    ~s(textarea)
  end

  def get_type(options, %{"InputType" => "textfield"})
    when Kernel.map_size(options) == 0 do
    ~s(input[type="text"])
  end

  def get_type(options, _type) when Kernel.map_size(options) == 0 do
    ~s(input[type="text"])
  end

  def get_type(options, _type) when Kernel.map_size(options) != 0 do
    "select"
  end

  def get_options(_channel, %{"Options" => options})
    when Kernel.is_bitstring(options) do
    []
  end

  def get_options(channel, %{"Options" => options})
    when Kernel.is_map(options) do
    options = [options]
    get_options(channel, options)
  end

  def get_options(channel, %{"Options" => options})
    when Kernel.is_list(options) do
    get_options(channel, options)
  end

  def get_options(_channel, %{"Option" => options})
    when Kernel.is_bitstring(options) do
    []
  end

  def get_options(channel, %{"Option" => options})
    when Kernel.is_map(options) do
    options = [options]
    get_options(channel, options)
  end

  def get_options(channel, %{"Option" => options})
    when Kernel.is_list(options) do
    get_options(channel, options)
  end

  def get_options(channel, options) do
    options = Enum.map(options, fn(option) -> get_option(channel, option) end)
    Enum.uniq(options)
  end

  def get_option(%{"language" => "en"}, option) do
    {option["Name"], option["Name"]}
  end

  def get_option(%{"language" => "es"}, option) do
    {option["Name"], ""}
  end

  def get_option(_channel, option) do
    {option["Name"], option["Name"]}
  end
end
