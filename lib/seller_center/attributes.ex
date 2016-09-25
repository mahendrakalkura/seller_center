defmodule SellerCenter.Attributes do
  @moduledoc false

  def query(channel, primary_category) do
    arguments = get_arguments(channel, primary_category)
    response = SellerCenter.http_poison(arguments)
    body = SellerCenter.parse_response(response)
    parse_body(channel, body)
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

  def parse_body(channel, {:ok, %{"SuccessResponse" => success_response}})
    when Kernel.is_map(success_response) do
    body = {:ok, success_response}
    parse_body(channel, body)
  end

  def parse_body(channel, {:ok, %{"Body" => body}}) when Kernel.is_map(body) do
    body = {:ok, body}
    parse_body(channel, body)
  end

  def parse_body(channel, {:ok, %{"Attribute" => attributes}})
    when Kernel.is_list(attributes) do
    attributes = Enum.map(
      attributes, fn(attribute) -> get_attribute(channel, attribute) end
    )
    attributes = Enum.uniq(attributes)
    attributes = Enum.sort_by(
      attributes,
      fn(attribute) ->
        case channel["language"] do
          "es" -> String.downcase(attribute["name_es"])
          _language -> String.downcase(attribute["name"])
        end
      end
    )
    {:ok, attributes}
  end

  def parse_body(channel, {:ok, %{"ErrorResponse" => error_response}})
    when Kernel.is_map(error_response) do
    body = {:ok, error_response}
    parse_body(channel, body)
  end

  def parse_body(channel, {:ok, %{"Head" => head}}) when Kernel.is_map(head) do
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

  def get_attribute(channel, attribute) do
    guid = attribute["Name"]

    {name, name_es} = get_names(channel, attribute)

    {description, description_es} = get_descriptions(channel, attribute)

    is_mandatory = get_is_mandatory(attribute)

    options = get_options(channel, attribute)

    type = get_type(options, attribute)

    %{
      "guid" => guid,
      "name" => name,
      "name_es" => name_es,
      "description" => description,
      "description_es" => description_es,
      "is_mandatory" => is_mandatory,
      "options" => options,
      "type" => type,
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

  def get_options(_channel, %{"Options" => options})
    when Kernel.is_bitstring(options) do
    []
  end

  def get_options(channel, %{"Options" => options})
    when Kernel.is_map(options) do
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
    options = Enum.filter(
      options, fn([key, _value]) -> String.length(key) > 0 end
    )
    options = Enum.uniq(options)
    Enum.sort_by(options, fn([key, _value]) -> key end)
  end

  def get_option(%{"language" => "es"}, option) do
    name = option["Name"]
    name = String.trim(name)
    [name, ""]
  end

  def get_option(_channel, option) do
    name = option["Name"]
    name = String.trim(name)
    [name, name]
  end

  def get_type(options, %{"InputType" => "checkbox"})
    when Kernel.length(options) == 0 do
    ~s(input[type="checkbox"])
  end

  def get_type(options, %{"InputType" => "datefield"})
    when Kernel.length(options) == 0 do
    ~s(input[type="date"])
  end

  def get_type(options, %{"InputType" => "datetime"})
    when Kernel.length(options) == 0 do
    ~s(input[type="datetime"])
  end

  def get_type(options, %{"InputType" => "dropdown"})
    when Kernel.length(options) == 0 do
    ~s(select)
  end

  def get_type(options, %{"InputType" => "multiselect"})
    when Kernel.length(options) == 0 do
    ~s(select[multiple="multiple"])
  end

  def get_type(options, %{"InputType" => "numberfield"})
    when Kernel.length(options) == 0 do
    ~s(input[type="number"])
  end

  def get_type(options, %{"InputType" => "textarea"})
    when Kernel.length(options) == 0 do
    ~s(textarea)
  end

  def get_type(options, %{"InputType" => "textfield"})
    when Kernel.length(options) == 0 do
    ~s(input[type="text"])
  end

  def get_type(options, _type) when Kernel.length(options) == 0 do
    ~s(input[type="text"])
  end

  def get_type(options, _type) when Kernel.length(options) != 0 do
    "select"
  end
end
