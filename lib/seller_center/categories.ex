defmodule SellerCenter.Categories do
  @moduledoc false

  def query(channel) do
    arguments = get_arguments(channel)
    response = SellerCenter.http_poison(arguments)
    body = SellerCenter.parse_response(response)
    parse_body(body)
  end

  def get_arguments(channel) do
    url = channel["url"]
    params = %{
      "Action" => "GetCategoryTree",
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
    {:ok, %{"SuccessResponse" => %{"Body" => %{"Categories" => categories}}}}
  ) do
    categories = get_categories([], categories["Category"])
    categories = List.flatten(categories)
    categories = Enum.uniq(categories)
    categories = Enum.sort_by(
      categories, fn(category) -> String.downcase(category["guid"]) end
    )
    {:ok, categories}
  end

  def parse_body({:ok, _response}) do
    {:error, nil}
  end

  def parse_body({:error, reason}) do
    {:error, reason}
  end

  def get_categories(parent, categories) when Kernel.is_map(categories) do
    get_categories(parent, [categories])
  end

  def get_categories(parent, categories) when Kernel.is_list(categories) do
    Enum.map(categories, fn(category) -> get_category(parent, category) end)
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
    get_categories(parent, category["Children"]["Category"])
  end

  def get_name(parent, name) do
    name = parent ++ [name]
    Enum.join(name, " > ")
  end
end
