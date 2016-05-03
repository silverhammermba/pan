#!/usr/bin/env ruby
# evaluate the unreliable peers protocol

require './pan'

# simulate the P2P network
#   i starting origins
#   n peers
#   r chance of peer responding
def simulate i, n, r
  ps = i.to_f / n
  data = {prior_s: ps, responses: [], total_queries: 0, kdist: []}

  k = i
  while k < n
    m = 0
    loop do
      # record how many people know at this point
      data[:kdist][data[:total_queries]] = k
      # record number of queries so far
      data[:total_queries] += 1
      # check if anyone responded
      m = k.times.count { rand < r }
      break if m > 0 # if so we can record the response
      # TODO what happens if we record all the failed responses?
    end
    data[:responses] << [k, m, data[:total_queries] - 1]
    k += 1
  end
  data[:kdist][data[:total_queries]] = n

  data
end

n = 10
r = 0.25
total = 10
leaks = Hash.new 0.0
sims(1, n, r)[0...total].each do |data|
  data[:responses].each do |res|
    post = post_given_resp(n, res[1], r, data[:prior_s], res[2], r)
    leaks[res[0]] += post
  end
end
leaks.each { |k, v| leaks[k] = v.to_f / total }

base = baseline(n)

puts "$data << EOD"
leaks.each do |j, post|
  puts "#{j}\t#{post} #{base[j-1]}"
end
puts "EOD"
puts <<OPTS
set xlabel 'Query'
set ylabel 'P(S|response)'
plot $data using 1:2 with lines title 'Unreliable peers'
replot $data using 1:3 with lines title 'Worst-case'
OPTS
