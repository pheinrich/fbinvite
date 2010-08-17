require 'rubygems'
require 'json'
require 'net/https'
require 'uri'
def get_objects( parent, type )
  uri = URI.parse( "https://graph.facebook.com/#{parent}/#{type}?access_token=2227470867%7c2.RCgr2NKzwUjd5qSoJ9Xdcg__.3600.1281780000-722945093%7cE0ADBWeagDKwamgjNzJ4C6asV-8." )
  http = Net::HTTP.new( uri.host, uri.port )
  http.use_ssl = true
  request = Net::HTTP::Get.new( uri.request_uri )
  JSON.parse( http.request( request ).body )["data"]
end
def get_likes( parent )
  likes = get_objects( parent, 'likes' ).map { |like| like["name"] }
  get_objects( parent, 'interests' ).each { |interest| likes << interest["name"] }
  likes
end
myLikes, matches, who = get_likes( 'me' ), 0, 'No one'
get_objects( 'me', 'friends' ).each do |friend|
  likes = get_likes( friend["id"] )
  shared = likes.select { |like| myLikes.include? like }
  matches, who = shared.length, friend["name"] if shared.length > matches
end
puts "#{who} has #{matches} shared likes/interests"
