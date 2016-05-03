#!/usr/bin/env ruby
# evaluate the deterministic (baseline) network

require './pan'

n = Integer(ARGV[0], 10)
base = baseline n

File.open('base.data', 'w') do |f|
  base.each_with_index do |pr, i|
    f.puts "#{i + 1}\t#{pr}"
  end
end
