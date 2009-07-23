#!/usr/bin/env ruby

##
# Quick little script to display all twitter posts based on a search term
# Required gems:
#   * twitter
#   * htmlentities
#   * term-ansicolor
##

require 'rubygems'
require 'twitter'
require 'htmlentities'
require 'term/ansicolor'
require 'active_support'

search = ARGV.pop

last_seen = 0
start_delay = 10
inc_delay = 5
max_delay = 60*5
sleep_count = 0
ctrlc_at=Time.now

delay = start_delay
coder = HTMLEntities.new

def usage
  puts "Usage: #{$0} <search>"
end

class Color
  class << self
    include Term::ANSIColor
  end
end

if search.nil? or search.empty?
  puts "Error: Please specify a search term to display"
  usage
  exit
end

puts "Showing all \"#{Color.bold search}\" twitter messages"

while(1)
  begin
    Twitter::Search.new(search).to_a.reverse.each do |r|
      next if r.id <= last_seen
      delay = start_delay
      last_seen = r.id
      created_at = Time.parse(r.created_at)
      
      puts <<-EOTXT
|#{Color.bold Color.green r.from_user}| #{coder.decode(r.text)}
|#{Color.bold Color.blue 'Posted'}| #{created_at}

      EOTXT
    end

    sleep delay
    delay += inc_delay unless delay >= max_delay
  rescue Interrupt
    exit if (Time.now - ctrlc_at) < 5.seconds
    
    puts "Press Ctrl-C again to exit"
    # Reset the delay and record when the interrupt was recieved in order to exit if we recieve another signal in a short time
    delay = start_delay
    ctrlc_at = Time.now
  rescue SocketError => e
    puts "Network error, will try again in 60 seconds"
    sleep 60
  rescue Crack::ParseError => e
    puts "Error: #{e}"
    sleep 10
  rescue => e
    puts "#{e.class.to_s} encountered: #{e.to_s}"
    puts e.backtrace
    puts "Sleeping for 60 seconds before trying again"
    sleep 60
  end
end
