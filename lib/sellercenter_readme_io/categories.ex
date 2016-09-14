defmodule SellercenterReadmeIo.Categories do
  @moduledoc false

  require Enum
  require File
  require JSX
  require List
  require SellercenterReadmeIo

  def query(channel) do
    method = :get
    url = channel["url"]
    body = ""
    headers = []
    params = %{
      "Action" => "GetCategoryTree",
    }
    params = SellercenterReadmeIo.get_params(channel, params)
    options = [
      {:params, params}
    ]
    response = SellercenterReadmeIo.parse_http(HTTPoison.request(method, url, body, headers, options))
    response = parse_http(response)
    response
  end

  def parse_http({:ok, %{"SuccessResponse" => success_response}}) do
    response = {:ok, success_response}
    response = parse_http(response)
    response
  end

  def parse_http({:ok, %{"Body" => body}}) do
    response = {:ok, body}
    response = parse_http(response)
    response
  end

  def parse_http({:ok, %{"Categories" => categories}}) do
    categories = get_categories([], categories["Category"])
    {:ok, categories}
  end

  def parse_http({:ok, _response}) do
    {:error, ""}
  end

  def parse_http({:error, reason}) do
    {:error, reason}
  end

  def get_categories(parent, categories) when Kernel.is_map(categories) do
    categories = get_categories(parent, [categories])
    categories
  end

  def get_categories(parent, categories) when Kernel.is_list(categories) do
    categories = Enum.map(categories, fn(category) -> get_category(parent, category) end)
    categories = List.flatten(categories)
    categories = Enum.uniq(categories)
    categories
  end

  def get_category(parent, category = %{"Children" => ""}) do
    guid = category["CategoryId"]
    name = get_name(parent, category["Name"])
    %{
      "guid" => guid,
      "name" => name,
    }
  end

  def get_category(parent, category) do
    parent = parent ++ [category["Name"]]
    categories = get_categories(parent, category["Children"]["Category"])
    categories
  end

  def get_name(parent, name) do
    name = parent ++ [name]
    name = Enum.join(name, " > ")
    name
  end
end
