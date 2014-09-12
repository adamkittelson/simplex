# Simplex

[![Build Status](https://travis-ci.org/adamkittelson/simplex.svg)](https://travis-ci.org/adamkittelson/simplex)
[![Coverage Status](https://img.shields.io/coveralls/adamkittelson/simplex.svg)](https://coveralls.io/r/adamkittelson/simplex)

An Elixir library for interacting with the [Amazon SimpleDB](http://aws.amazon.com/simpledb/) API.

Requires Elixir ~> 1.0.0

## Installation

Install the [Hex.pm](http://hex.pm) package

1. Add simplex to your `mix.exs` dependencies:

    ```elixir
    def deps do
      [
        {:simplex, github: "adamkittelson/simplex"}
      ]
    end
    ```

2. Add `:simplex` to your application dependencies:

    ```elixir
    def application do
      [applications: [:simplex]]
    end
    ```

#### AWS Keys

To communicate with the SimpleDB API you'll need to provide your AWS Access and Secret keys.

There are two ways to provide your keys to the Simplex library:

1. Set them from within your application
    ```elixir
    Simplex.aws_access_key "your-access-key"
    Simplex.aws_secret_access_key "your-secret-access-key"
    ```

2. Set them as the environment variables `SIMPLEX_AWS_ACCESS_KEY` and `SIMPLEX_AWS_SECRET_ACCESS_KEY`
    ```
    SIMPLEX_AWS_ACCESS_KEY=your-access-key SIMPLEX_AWS_SECRET_ACCESS_KEY=your-secret-access-key iex -S mix
    ```

#### SimpleDB URL

By default Simplex will send all requests to the us-east-1 SimpleDB url: `https://sdb.amazonaws.com`. If you want to use a [different region](http://docs.aws.amazon.com/general/latest/gr/rande.html#sdb_region) you can change the url by:

1. Setting it from within your application
    ```elixir
    Simplex.simpledb_url "https://sdb.us-west-1.amazonaws.com"
    ```

2. Set it as the environment variable `SIMPLEX_SIMPLEDB_URL`
    ```
    SIMPLEX_SIMPLEDB_URL=https://sdb.us-west-1.amazonaws.com iex -S mix
    ```

## Responses

Simplex will respond to SimpleDB requests with a 3 element tuple, either `{:ok, result, response}` or `{:error, messages, response}`

#### %Simplex.Response{}

A Simplex response (third element of the tuple above) has the following fields:

1. body: A Map containing the parsed body of the response
2. status_code: The HTTP status code of the response
3. headers: The response headers
4. raw_body: The raw string of the response body. (XML)

#### Pattern Matching

You can pattern match to determine how to handle the response:

  ```elixir
  case Simplex.Domains.create "new_domain" do
    {:ok, result, response} ->
      # some happy path stuff here
    {:error, messages, response} ->
      # handle problems
  end
  ```

## Domains

[Create](http://docs.aws.amazon.com/AmazonSimpleDB/latest/DeveloperGuide/SDB_API_CreateDomain.html) a new domain.

  ````elixir
  Simplex.Domains.create "new_domain"
  ````

[List](http://docs.aws.amazon.com/AmazonSimpleDB/latest/DeveloperGuide/SDB_API_ListDomains.html) domains.

  ````elixir
  Simplex.Domains.list

  Simplex.Domains.list(%{"MaxNumberOfDomains" => "10", "NextToken" => "token-from-previous-list-response"})
  ````

[Delete](http://docs.aws.amazon.com/AmazonSimpleDB/latest/DeveloperGuide/SDB_API_DeleteDomain.html) a domain.

  ````elixir
  Simplex.Domains.delete "domain_to_delete"
  ````

## Attributes

[Get](http://docs.aws.amazon.com/AmazonSimpleDB/latest/DeveloperGuide/SDB_API_GetAttributes.html) attributes of an item.

  ````elixir
  Simplex.Attributes.get("your_domain", "your_item_name")

  Simplex.Attributes.get("your_domain", "your_item_name", %{"AttributeName" => "some_attribute", "ConsistentRead" => "true"})
  ````

[Put](http://docs.aws.amazon.com/AmazonSimpleDB/latest/DeveloperGuide/SDB_API_PutAttributes.html) attributes on an item (or create a new item).

  ````elixir
  # Attribute values can be strings, lists of strings, or a 
  # two-element tuple of :replace and a string or list of strings
  # The replace tuple indicates that the value should replace the existing
  # value for that attribute, rather than be added to its values
  
  Simplex.Attributes.put("your_domain", 
                         "your_item_name", 
                         %{"some_key"        => "some_value",
                           "another_key"     => ["a", "list", "of", "values"],
                           "yet_another_key" => {:replace, "a value to replace the existing value(s) of yet_another_key"},
                           "one_last_key     => {:replace, ["values", "to", "replace", "one_last_key's", "previous", "value(s)"]}})

  # put "some_value" in the "some_key" attribute only if
  # "other_key" has the "other_value" value
  Simplex.Attributes.put("your_domain",
                         "your_item_name", 
                         %{"some_key" => "some_value"},
                         %{"Name" => "other_key", "Value" => "other_value"})
  ````

[Delete](http://docs.aws.amazon.com/AmazonSimpleDB/latest/DeveloperGuide/SDB_API_DeleteAttributes.html) attributes on an item (or delete an item).

  ````elixir
  # Delete the "some_value" value from the "some_key" attribute
  Simplex.Attributes.delete("your_domain",
                            "your_item_name",
                            %{"some_key" => "some_value"})

  # Delete "your_item_name" if it doesn't have the "some_key" attribute
  Simplex.Attributes.delete("your_domain",
                            "your_item_name",
                            %{},
                            %{"Name" => "some_key", "Exists" => "false"})
  ````

## Select

[Select](http://docs.aws.amazon.com/AmazonSimpleDB/latest/DeveloperGuide/SDB_API_Select.html) attributes from items matching an expression.

  ````elixir
  Simplex.Select.select("select * from your_domain where some_key = 'some_value'")
  ````

----
