require 'nokogiri'
require 'open-uri'
require 'uri'
require 'net/http'
require 'openssl'
require 'yaml'

def recipes_urls(source: :jamie_oliver)
  recipes_urls = []

  case source
    when :jamie_oliver
      base_url = "https://www.jamieoliver.com"
      url = "https://www.jamieoliver.com/recipes/vegetables-recipes/"
      10.times do |i|
        id_name = "gtm_recipe_subcat_#{i}"
        xpath = "//a[@id='#{id_name}']/@href"
        recipe_path = doc.xpath(xpath)
        recipe_url = "#{base_url}#{recipe_path}"
        recipes_urls << recipe_url    
      end 
    # dummy example
    when :ah
      base_url = "https://www.ah.nl/allerhande/recept"
      url = "https://www.ah.nl/allerhande/recept/R-R1197006/lauwwarme-tomatensalade-met-orzo-parmaham-en-pijnboompitjes"
      recipes_urls = ["https://www.ah.nl/allerhande/recept/R-R1197006/lauwwarme-tomatensalade-met-orzo-parmaham-en-pijnboompitjes"]
  end
  
  recipes_urls
end

def secrets
  @secrets ||= YAML.load_file('credentials.yml')
end

def parse_recipes_from_urls
  recipes_urls = recipes_urls(source: :ah)

  recipes_urls.each do |recipe_url|
    response = get_recipe_data(recipe_url: recipe_url)
    puts response
  end
end


def get_recipe_data(recipe_url:)
  return unless recipe_url

  url = URI("https://mycookbook-io1.p.rapidapi.com/recipes/rapidapi")
 
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Post.new(url)
  request["content-type"] = 'text/plain'
  request["X-RapidAPI-Key"] = secrets['mycookbook-api-key']
  request["X-RapidAPI-Host"] = 'mycookbook-io1.p.rapidapi.com'
  request.body = recipe_url

  response = http.request(request)
  response.read_body
end

parse_recipes_from_urls

