%w(rubygems json net/https uri).each { |file| require file }  # necessary includes

def get_objects( parent, type )  # retrieve an array of child objects
  uri = URI.parse( "https://graph.facebook.com/#{parent}/#{type}?access_token=#{ENV['FBAPI_TOKEN']}" )
  http = Net::HTTP.new( uri.host, uri.port )
  http.use_ssl = true
  JSON.parse( http.request( Net::HTTP::Get.new( uri.request_uri ) ).body )["data"]
end

def get_likes( parent )  # retrieve a user's 'likes' and 'interests' (both necessary?)
  likes = get_objects( parent, 'likes' ).map { |like| like["name"] }
  get_objects( parent, 'interests' ).each { |interest| likes << interest["name"] }
  likes
end

myLikes, matches, who = get_likes( 'me' ), 0, 'No one'  # init my own likes/interests
get_objects( 'me', 'friends' ).each do |friend|  # visit each of my friends
  likes = get_likes( friend["id"] )
  shared = likes.select { |like| myLikes.include? like }  # count our shared items
  matches, who = shared.length, friend["name"] if shared.length > matches  # track max
end

puts "#{who} has #{matches} shared likes/interests"  # display result
