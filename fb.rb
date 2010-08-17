#!/usr/bin/ruby

require 'rubygems'
require 'json'
require 'net/https'
require 'uri'

def get_objects( parent, type )
  # Construct the URI.
  uri = URI.parse( "https://graph.facebook.com/#{parent}/#{type}?access_token=2227470867%7c2.RCgr2NKzwUjd5qSoJ9Xdcg__.3600.1281780000-722945093%7cE0ADBWeagDKwamgjNzJ4C6asV-8." )

  # Make sure the connection uses SSL.
  http = Net::HTTP.new( uri.host, uri.port )
  http.use_ssl = true

  # Create the request, distinguishing ourselves as specialized user agent (why not?).
  request = Net::HTTP::Get.new( uri.request_uri )
  request.initialize_http_header( { "User-Agent" => "Facebook Seattle Invite Challenge" } )

  # Make the request, assume it works, and parse the resulting JSON into a Ruby object. 
  JSON.parse( http.request( request ).body )["data"]
end

def get_likes( parent )
  # Retrieve likes and interests as an array of strings, since we don't know if object names are unique
  # (identically named likes may have different ids--we don't know).
  likes = get_objects( parent, 'likes' ).map { |like| like["name"] }
  get_objects( parent, 'interests' ).each { |interest| likes << interest["name"] }
  likes
end

# Get the list of my own likes and interests.
myLikes = get_likes( 'me' )
matches = 0
who = 'No one'

# Retrieve my friends and compare each one's likes/interests to mine.
get_objects( 'me', 'friends' ).each do |friend|
  # Get a list of their likes, then select those that match.
  likes = get_likes( friend["id"] )
  shared = likes.select { |like| myLikes.include? like }

  # If they have more than anyone else so far, remember them.
  if shared.length > matches
    matches = shared.length
    who = friend["name"]
  end
end

# Output some information about our investigation.
puts 'My likes/interests:'
puts myLikes.join " "
puts "#{who} has #{matches} shared likes/interests"
