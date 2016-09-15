defmodule SellercenterReadmeIo.Attributes do
  @moduledoc false

  require Map
  require SellercenterReadmeIo

  def query(channel, primary_category) do
    method = :get
    url = channel["url"]
    body = ""
    headers = []
    params = %{
      "Action" => "GetCategoryAttributes",
      "PrimaryCategory" => primary_category,
    }
    params = SellercenterReadmeIo.get_params(channel, params)
    options = [
      {:params, params}
    ]
    result = SellercenterReadmeIo.parse_http(HTTPoison.request(method, url, body, headers, options))
    result = parse_body(channel, result)
    result
  end

  def parse_body(channel, {:ok, %{"SuccessResponse" => success_response}}) do
    result = {:ok, success_response}
    result = parse_body(channel, result)
    result
  end

  def parse_body(channel, {:ok, %{"Body" => body}}) do
    result = {:ok, body}
    result = parse_body(channel, result)
    result
  end

  def parse_body(channel, {:ok, %{"Attribute" => attributes}}) do
    attributes = Enum.map(attributes, fn(attribute) -> get_attribute(channel, attribute) end)
    attributes = Enum.uniq(attributes)
    result = {:ok, attributes}
    result
  end

  def parse_body(channel, {:ok, %{"ErrorResponse" => error_response}}) do
    result = {:ok, error_response}
    result = parse_body(channel, result)
    result
  end

  def parse_body(channel, {:ok, %{"Head" => head}}) do
    result = {:ok, head}
    result = parse_body(channel, result)
    result
  end

  def parse_body(_channel, {:ok, %{"ErrorCode" => error_code}}) do
    result = {:ok, error_code}
    result
  end

  def parse_body(_channel, {:ok, _attributes}) do
    result = {:error, nil}
    result
  end

  def parse_body(_channel, {:error, reason}) do
    result = {:error, reason}
    result
  end

  def get_attribute(channel, attribute) do
    {name, name_es} = get_names(channel, attribute)
    {description, description_es} = get_descriptions(channel, attribute)
    is_mandatory = get_is_mandatory(attribute)
    options = get_options(channel, attribute)
    options = Enum.into(options, %{})
    type = get_type(options, attribute)
    attribute = %{
      "name" => name,
      "name_es" => name_es,
      "description" => description,
      "description_es" => description_es,
      "is_mandatory" => is_mandatory,
      "type" => type,
      "options" => options,
    }
    attribute
  end

  def get_names(%{"language" => "en"}, attribute) do
    names = {attribute["Label"], ""}
    names
  end

  def get_names(%{"language" => "es"}, attribute) do
    names = {"", attribute["Label"]}
    names
  end

  def get_names(_channel, attribute) do
    names = {attribute["Label"], ""}
    names
  end

  def get_descriptions(%{"language" => "en"}, attribute) do
    descriptions = {attribute["Description"], ""}
    descriptions
  end

  def get_descriptions(%{"language" => "es"}, attribute) do
    descriptions = {"", attribute["Description"]}
    descriptions
  end

  def get_descriptions(_channel, attribute) do
    descriptions = {attribute["Description"], ""}
    descriptions
  end

  def get_is_mandatory(%{"isMandatory" => "0"}) do
    is_mandatory = false
    is_mandatory
  end

  def get_is_mandatory(%{"isMandatory" => "1"}) do
    is_mandatory = true
    is_mandatory
  end

  def get_is_mandatory(_) do
    is_mandatory = false
    is_mandatory
  end

  def get_type(options, %{"InputType" => "checkbox"}) when Kernel.map_size(options) == 0 do
    type = ~s(input[type="checkbox"])
    type
  end

  def get_type(options, %{"InputType" => "datefield"}) when Kernel.map_size(options) == 0 do
    type = ~s(input[type="date"])
    type
  end

  def get_type(options, %{"InputType" => "datetime"}) when Kernel.map_size(options) == 0 do
    type = ~s(input[type="datetime"])
    type
  end

  def get_type(options, %{"InputType" => "dropdown"}) when Kernel.map_size(options) == 0 do
    type = ~s(select)
    type
  end

  def get_type(options, %{"InputType" => "multiselect"}) when Kernel.map_size(options) == 0 do
    type = ~s(select[multiple="multiple"])
    type
  end

  def get_type(options, %{"InputType" => "numberfield"}) when Kernel.map_size(options) == 0 do
    type = ~s(input[type="number"])
    type
  end

  def get_type(options, %{"InputType" => "textarea"}) when Kernel.map_size(options) == 0 do
    type = ~s(textarea)
    type
  end

  def get_type(options, %{"InputType" => "textfield"}) when Kernel.map_size(options) == 0 do
    type = ~s(input[type="text"])
    type
  end

  def get_type(options, _type) when Kernel.map_size(options) == 0 do
    type = ~s(input[type="text"])
    type
  end

  def get_type(options, _type) when Kernel.map_size(options) != 0 do
    type = "select"
    type
  end

  def get_options(channel, %{"Options" => options}) do
    options = get_options(channel, options)
    options
  end

  def get_options(channel, %{"Option" => options}) do
    options = get_options(channel, options)
    options
  end

  def get_options(_channel, "") do
    options = []
    options
  end

  def get_options(channel, options) do
    options = Enum.map(options, fn(option) -> get_option(channel, option) end)
    options = Enum.uniq(options)
    options
  end

  def get_option(%{"language" => "en"}, option) do
    option = {option["Name"], option["Name"]}
    option
  end

  def get_option(%{"language" => "es"}, option) do
    option = {option["Name"], ""}
    option
  end

  def get_option(_channel, option) do
    option = {option["Name"], option["Name"]}
    option
  end
end
