#!/usr/bin/env ruby
# evaluate the extra responses protocol

require './pan'
require 'set'

# simulate the P2P network
#   i starting origins
#   n peers
#   t expected number of peers to receive an extra response
def simulate i, n, t
  er = t.to_f / (n-2)
  ps = i.to_f / n
  data = {prior_s: ps, prob_ex: er, total_queries: 0, kdist: []}

  # every peer (other than origins) might get to do a direct query and/or get extra responses
  know = Array.new(n - i) { false }
  data[:direct_res] = Array.new(n - i) { nil }
  data[:extra_res] = Array.new(n - i) { Set.new }

  k = i
  while k < n
    # record current knowledge dist
    data[:kdist][data[:total_queries]] = k
    # gonna make a new query
    data[:total_queries] += 1
    # pick a peer who (maybe?) knows the least
    j = 0
    min = 1.0/0
    know.each_index do |l|
      next if know[l]
      if data[:extra_res][l].size < min
        min = data[:extra_res][l].size
        j = l
        break if min == 0
      end
    end

    # record responses
    extra = 0
    know.each_index do |l|
      # if this is the querying peer
      if l == j
        # they get a direct response
        data[:direct_res][l] = k
        know[l] = true
        next
      end
      # else see how many extra responses we got (can't send to itself)
      reses = (k - (know[l] ? 1 : 0)).times.count { rand < er }

      # if we got respones
      if reses > 0
        # record it
        data[:extra_res][l] << [reses, data[:total_queries]-1]
        # check if this spread knowledge
        if !know[l]
          know[l] = true
          extra += 1
        end
      end
    end

    k += 1 + extra
  end
  data[:kdist][data[:total_queries]] = n

  data
end

# TODO figure out why this is so close to worst case
# extra response probs should ALWAYS be lower
# probably has to do with the sorting?
n = 30
t = 1
leaks = Hash.new 0.0
total = 1000
sims(1, n, t)[0...total].each do |data|
  x = data[:direct_res].each_index.map do |l|
    prob = 0.0
    if data[:direct_res][l]
      prob = post_given_know(data[:prior_s], data[:direct_res][l])
    end
    data[:extra_res][l].each do |ex|
      p = post_given_resp(n, ex[0], data[:prob_ex], data[:prior_s], ex[1], t)
      prob = p if p > prob
    end
    prob
  end.sort.reverse
  x.each.with_index { |p, l| leaks[l + 1] += p }
end
leaks.each { |k, v| leaks[k] = v.to_f / total }

base = baseline(n)

puts "$data << EOD"
(1...n).each do |j|
  puts "#{j}\t#{leaks[j] || ??}\t#{base[j-1]}"
end
puts "EOD"
puts <<OPTS
set xlabel 'Query'
set ylabel 'P(S|response)'
plot $data using 1:2 with lines title 'Extra responses'
replot $data using 1:3 with lines title 'Worst-case'
OPTS
