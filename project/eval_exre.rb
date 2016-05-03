#!/usr/bin/env ruby
# evaluate the extra responses protocol

require './pan'

# simulate the P2P network
#   i starting origins
#   n peers
#   t expected number of peers to receive an extra response
def simulate i, n, t
  er = t.to_f / (n-2)
  ps = i.to_f / n
  data = {prior_s: ps, responses: [], total_queries: 0, kdist: []}

  k = i
  j = 1
  while k < n
    data[:kdist][data[:total_queries]] = k
    data[:total_queries] += 1
    data[:responses] << [j, k, data[:total_queries] - 1]

    extra = ((k+1)...n).count { k.times.any? { rand < er } }

    k += 1 + extra
    j += 1
  end
  data[:kdist][data[:total_queries]] = n

  data
end

n = 100
t = 1
leaks = Hash.new 0.0
sims(1, n, t).each do |data|
  data[:responses].each do |res|
    post = post_given_know(data[:prior_s], res[1])
    leaks[res[0]] += post
  end
end
total = sims(1,n,t).size
leaks.each { |k, v| leaks[k] = v.to_f / total }

base = baseline(n)

puts "$data << EOD"
(1..n).each do |j|
  puts "#{j}\t#{leaks[j] || ??}\t#{base[j-1]}"
end
puts "EOD"
puts <<OPTS
set xlabel 'Query'
set ylabel 'P(S|response)'
plot $data using 1:2 with lines title 'Extra responses'
replot $data using 1:3 with lines title 'Worst-case'
OPTS
