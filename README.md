How to install?
===============

Step 1
------

Add `:seller_center` to `def application()` in your `mix.exs`.

```
def application() do
  [
    applications: [
      ...
      :seller_center,
      ...
    ]
  ]
end
```

Step 2
------

Add `:seller_center` to `def deps()` in your `mix.exs`.

```
def deps do
  [
    ...
    {:seller_center, git: "https://github.com/mahendrakalkura/seller_center.git"},
    ...
  ]
end
```

Step 3
------

Execute `mix deps.get`.

How to use?
===========

```
$ iex -S mix
iex(1)> channel = %{
...(1)>   "url" => "...",
...(1)>   "api_key" => "...",
...(1)>   "user_id" => "...",
...(1)>   "language" => "...",
...(1)> }
%{"api_key" => "...",
  "language" => "...",
  "url" => "...",
  "user_id" => "..."}
iex(2)> SellerCenter.Category.query(channel)
{:ok, [...]}
iex(3)> SellerCenter.Attribute.query(channel, "...")
{:ok, [...]}
```
