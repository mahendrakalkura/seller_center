How to install?
===============

Step 1
------

Add `:sellercenter_readme_io` to `def application()` in your `mix.exs`.

```
def application() do
  [
    applications: [
      ...
      :sellercenter_readme_io,
      ...
    ]
  ]
end
```

Step 2
------

Add `:sellercenter_readme_io` to `def deps()` in your `mix.exs`.

```
def deps do
  [
    ...
    {:sellercenter_readme_io, git: "https://github.com/mahendrakalkura/sellercenter.readme.io.git"},
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
iex(2)> SellercenterReadmeIo.Categories.query(channel)
{:ok, [...]}
iex(3)> SellercenterReadmeIo.Attributes.query(channel, "...")
{:ok, [...]}
```
