defmodule DataScraper do

  @heroes_url "http://www.dota2.com/jsfeed/heropickerdata"

  def get_data() do
    case make_http_request do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        response = Jason.decode(body)
        {:ok, response}
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found"
      {:error, %HTTPoison.Error{ reason: reason}} ->
        IO.inspect reason
    end
  end

  def make_http_request do
    HTTPoison.get(@heroes_url)
  end
end
