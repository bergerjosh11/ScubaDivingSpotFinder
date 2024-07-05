require 'net/http'
require 'json'
require 'geocoder'
require 'dotenv/load'

class ScubaDivingSpotFinder
  API_URL = 'https://api.divesites.com/sites'
  API_KEY = ENV['DIVESITES_API_KEY']

  def initialize(zip_code, radius)
    @zip_code = zip_code
    @radius = radius
  end

  def fetch_coordinates
    results = Geocoder.search(@zip_code)
    if results.any?
      [results.first.latitude, results.first.longitude]
    else
      raise "Invalid ZIP code: #{@zip_code}"
    end
  end

  def fetch_spots
    coordinates = fetch_coordinates
    uri = URI("#{API_URL}/search?lat=#{coordinates[0]}&lng=#{coordinates[1]}&dist=#{@radius}&key=#{API_KEY}")
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end

  def filter_spots(spots)
    spots.select { |spot| spot['interest'] > 7 && spot['water_clarity'] > 8 }
  end

  def display_spots
    spots = fetch_spots['results']
    filtered_spots = filter_spots(spots)
    
    if filtered_spots.empty?
      puts "No suitable diving spots found near #{@zip_code}."
    else
      puts "Best diving spots near #{@zip_code}:"
      filtered_spots.each do |spot|
        puts "Name: #{spot['name']}"
        puts "Interest Level: #{spot['interest']}"
        puts "Water Clarity: #{spot['water_clarity']}"
        puts "Description: #{spot['description']}"
        puts "------------------------------------"
      end
    end
  end
end

# Example usage
puts "Enter your ZIP code:"
zip_code = gets.chomp
radius = 50 # Radius in kilometers
finder = ScubaDivingSpotFinder.new(zip_code, radius)
finder.display_spots
