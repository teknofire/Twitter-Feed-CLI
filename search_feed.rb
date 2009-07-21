#!/usr/bin/env ruby

##
# Quick little script to display all twitter posts with the word "OSCON"
# Required gems:
#   * twitter
#   * htmlentities
#   * term-ansicolor
##

require 'rubygems'
require 'twitter'
require 'htmlentities'
require 'term/ansicolor'

search = ARGV.pop

last_seen = 0
delay = 10
coder = HTMLEntities.new

class Color
  class << self
    include Term::ANSIColor
  end
end

puts "Showing all \"#{Color.bold search}\" twitter messages"

while(1)
  Twitter::Search.new(search).to_a.reverse.each do |r|
    next if r.id <= last_seen
    last_seen = r.id
    created_at = Time.parse(r.created_at)
    
    puts <<-EOTXT
|#{Color.bold Color.green r.from_user}| #{coder.decode(r.text)}
|#{Color.bold Color.blue 'Posted'}| #{created_at}

    EOTXT
  end
  
	sleep delay
end
