require 'net/http'
require 'json'

url= URI('http://localhost:3000/api/cats')
response_string= Net::HTTP.get(url)
hash = JSON.parse(response_string)
puts 'The basic way'
p response_string.class
p response_string
p hash.class
p hash