require 'twitter'
require 'yaml'
require 'parallel'

current_dir = File.expand_path(File.dirname(__FILE__))
CONFIG = YAML.load_file("#{current_dir}/config.yml").freeze

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = CONFIG['CONSUMER_KEY']
  config.consumer_secret     = CONFIG['CONSUMER_SECRET']
  config.access_token        = CONFIG['ACCESS_TOKEN']
  config.access_token_secret = CONFIG['ACCESS_TOKEN_SECRET']
end

user = client.user
tweets = []

begin
  loop do
    tweets = client.user_timeline
    Parallel.map(tweets, in_processes: 8) do |tweet|
      puts "Destroy: #{tweet.id} : #{tweet.text}"
      client.destroy_tweet(tweet)
    end
  end
rescue => e
  puts e.message
end
