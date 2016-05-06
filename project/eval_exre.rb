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

n = Integer(ARGV[0], 10)
t = Integer(ARGV[1], 10)
leaks = []
sims(1, n, t).each do |data|
  data[:responses].each_with_index do |r, i|
    probs = r[:extra].map do |ex|
      post_given_resp(n, ex, data[:prob_ex], data[:prior_s], r[:queries], t)
    end.sort.reverse
    probs.unshift post_given_know(data[:prior_s], r[:direct])

    leaks[i] ||= Hash.new(0.0)
    probs.each_with_index { |pr, j| leaks[i][j] += pr }
  end
end
total = sims(1,n,t).size.to_f
leaks.each { |dist| dist.each { |k, v| dist[k] = v / total } }

# create a 3D plot of extra response distribution for each query
File.open("exre_dist_#{n}_#{t}.gp", 'w') do |f|
  f.puts "$data << EOD"
  leaks.each_with_index do |d, i|
    f.puts "#{i + 1}\t0\t#{d[0]}"
  end
  f.puts "EOD"
  leaks.each_with_index do |dist, i|
    f.puts "$datad#{i} << EOD"
    (dist.keys.min..dist.keys.max).each do |k|
      f.puts "#{i + 1}\t#{k}\t#{dist[k]}"
    end
    f.puts "EOD"
  end
  f.puts <<-CMD
set terminal pdf
unset key
set xyplane 0.1
set xlabel 'Peer'
set ylabel 'Other Peers'
set zlabel 'P(S|response)' rotate parallel
set ytics offset -1
set view 66,132
set style data lines
splot $data linetype rgb 'black', #{leaks.each_index.map { |i| "'$datad#{i}' linetype rgb '#{gradient([0, 0, 255], [18, 157, 0], 0, leaks.size - 1, i)}'" }.join(', ')}
  CMD
end

# create a data file of just direct response distribution
File.open("exre_#{n}_#{t}.data", 'w') do |f|
  leaks.each_with_index do |d, j|
    f.puts "#{j+1}\t#{d[0]}"
  end
end
