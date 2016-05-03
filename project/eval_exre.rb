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
  data[:responses] = []


  k = i
  j = 0
  while k < n
    # record current knowledge dist
    data[:kdist][data[:total_queries]] = k
    # gonna make a new query
    data[:total_queries] += 1

    z = know.each_index.find { |l| !know[l] }
    data[:responses][j] = {extra: [], queries: data[:total_queries] - 1}

    # record responses
    extra = 0
    know.each_index do |l|
      # if this is the querying peer
      if l == z
        # they get a direct response
        data[:responses][j][:direct] = k
        know[l] = true
        next
      end
      # else see how many extra responses we got (can't send to itself)
      reses = (k - (know[l] ? 1 : 0)).times.count { rand < er }

      # if we got respones
      if reses > 0
        # record it
        data[:responses][j][:extra] << reses

        # check if this spread knowledge
        if !know[l]
          know[l] = true
          extra += 1
        end
      end
    end

    k += 1 + extra
    j += 1
  end
  data[:kdist][data[:total_queries]] = n

  data
end

# TODO figure out why this is so close to worst case
# extra response probs should ALWAYS be lower
# probably has to do with the sorting?
n = 10
t = 1
leaks = []
total = 1000
sims(1, n, t)[0...total].each do |data|
  data[:responses].each_with_index do |r, i|
    probs = r[:extra].map do |ex|
      post_given_resp(n, ex, data[:prob_ex], data[:prior_s], r[:queries], t)
    end.sort.reverse
    probs.unshift post_given_know(data[:prior_s], r[:direct])

    leaks[i] ||= Hash.new(0.0)
    probs.each_with_index { |pr, j| leaks[i][j] += pr }
  end
end
leaks.each { |dist| dist.each { |k, v| dist[k] = v.to_f / total } }

puts "$data << EOD"
leaks.each_with_index do |d, i|
  puts "#{i + 1} 0 #{d[0]}"
end
puts "EOD"
leaks.each_with_index do |dist, i|
  puts "$datad#{i} << EOD"
  (dist.keys.min..dist.keys.max).each do |k|
    puts "#{i + 1} #{k} #{dist[k]}"
  end
  puts "EOD"
end
puts <<CMD
unset key
set style data lines
splot $data, #{leaks.each_index.map { |i| "'$datad#{i}'" }.join(', ')}
CMD
exit

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
