defmodule SellerCenter.Attributes do
  @moduledoc false

  def query(channel, primary_category) do
    arguments = get_arguments(channel, primary_category)
    response = SellerCenter.http_poison(arguments)
    body = SellerCenter.parse_response(response)
    parse_body(channel, body)
  end

  def get_arguments(channel, primary_category) do
    url = channel["url"]
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
      "method" => :get,
      "url" => url,
      "body" => "",
      "headers" => [],
      "options" => options,
    }
  end

  def parse_body(
    channel,
    {:ok, %{"SuccessResponse" => %{"Body" => %{"Attribute" => attributes}}}}
  ) do
    attributes = Enum.map(
      attributes, fn(attribute) -> get_attribute(channel, attribute) end
    )
    attributes = Enum.uniq(attributes)
    attributes = Enum.sort_by(
      attributes, fn(attribute) -> String.downcase(attribute["guid"]) end
    )
    {:ok, attributes}
  end

  def parse_body(
    _channel,
    {:ok, %{"ErrorResponse" => %{"Head" => %{"ErrorCode" => error_code}}}}
  ) do
    {:ok, error_code}
  end

  def parse_body(_channel, {:ok, _contents}) do
    {:error, nil}
  end

  def parse_body(_channel, {:error, reason}) do
    {:error, reason}
  end

  def get_attribute(channel, attribute) do
    guid = attribute["Name"]
    {name, name_es} = get_names(channel, attribute)
    {description, description_es} = get_descriptions(channel, attribute)
    is_mandatory = get_is_mandatory(channel, attribute)
    options = get_options(channel, attribute)
    type = get_type(channel, attribute, options)
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

  def get_names(%{"language" => "es"}, attribute) do
    {"", attribute["Label"]}
  end

  def get_names(_channel, attribute) do
    {attribute["Label"], ""}
  end

  def get_descriptions(%{"language" => "es"}, attribute) do
    {"", attribute["Description"]}
  end

  def get_descriptions(_channel, attribute) do
    {attribute["Description"], ""}
  end

  def get_is_mandatory(_channel, %{"isMandatory" => "1"}) do
    true
  end

  def get_is_mandatory(_channel, _attribute) do
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

  def get_type(_channel, %{"InputType" => "checkbox"}, []) do
    ~s(input[type="checkbox"])
  end

  def get_type(_channel, %{"InputType" => "datefield"}, []) do
    ~s(input[type="date"])
  end

  def get_type(_channel, %{"InputType" => "datetime"}, []) do
    ~s(input[type="datetime"])
  end

  def get_type(_channel, %{"InputType" => "dropdown"}, []) do
    ~s(select)
  end

  def get_type(_channel, %{"InputType" => "multiselect"}, []) do
    ~s(select)
  end

  def get_type(_channel, %{"InputType" => "numberfield"}, []) do
    ~s(input[type="number"])
  end

  def get_type(_channel, %{"InputType" => "textarea"}, []) do
    ~s(textarea)
  end

  def get_type(_channel, %{"InputType" => "textfield"}, []) do
    ~s(input[type="text"])
  end

  def get_type(_channel, _attribute, []) do
    ~s(input[type="text"])
  end

  def get_type(_channel, _attribute, _options) do
    "select"
  end
end
