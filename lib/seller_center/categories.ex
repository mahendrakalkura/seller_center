defmodule SellerCenter.Categories do
  @moduledoc false

  require Enum
  require File
  require JSX
  require List
  require SellerCenter

  def query(channel) do
    result = get_arguments(channel)
    result = SellerCenter.http_poison(result)
    result = SellerCenter.parse_response(result)
    result = parse_body(result)
    result
  end

  def parse_body({:ok, %{"SuccessResponse" => success_response}}) do
    result = {:ok, success_response}
    result = parse_body(result)
    result
  end

  def parse_body({:ok, %{"Body" => body}}) do
    result = {:ok, body}
    result = parse_body(result)
    result
  end

  def parse_body({:ok, %{"Categories" => categories}}) do
    categories = get_categories([], categories["Category"])
    result = {:ok, categories}
    result
  end

  def parse_body({:ok, _response}) do
    result = {:error, nil}
    result
  end

  def parse_body({:error, reason}) do
    result = {:error, reason}
    result
  end

  def get_arguments(channel) do
    method = :get
    url = channel["url"]
    body = ""
    headers = []
    params = %{
      "Action" => "GetCategoryTree",
    }
    params = SellerCenter.get_params(channel, params)
    options = [
      {:params, params},
    ]
    result = %{
      "method" => method,
      "url" => url,
      "body" => body,
      "headers" => headers,
      "options" => options,
    }
    result
  end

  def get_categories(parent, categories) when Kernel.is_map(categories) do
    categories = get_categories(parent, [categories])
    categories
  end

  def get_categories(parent, categories) when Kernel.is_list(categories) do
    categories = Enum.reduce(
      categories,
      %{},
      fn(category, categories) ->
        category = get_category(parent, category)
        Map.merge(categories, category)
      end
    )
    categories
  end

  def get_category(parent, category = %{"Children" => ""}) do
    guid = category["CategoryId"]
    name = get_name(parent, category["Name"])
    category = %{
      guid => name,
    }
    category
  end

  def get_category(parent, category) do
    parent = parent ++ [category["Name"]]
    category = get_categories(parent, category["Children"]["Category"])
    category
  end

  def get_name(parent, name) do
    name = parent ++ [name]
    name = Enum.join(name, " > ")
    name
  end
end