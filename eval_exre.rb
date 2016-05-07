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
suff = "#{n}_#{t}"

leaks = {}
extra_leaks = {}
sims(1, n, t).each do |data|
  data[:responses].each_with_index do |r, i|
    leaks[i] ||= [0.0, 0]
    leaks[i][0] += post_given_know(data[:prior_s], r[:direct])
    leaks[i][1] += 1

    extra_leaks[i] ||= Array.new(n-2, 0.0)
    probs = r[:extra].map do |ex|
      post_given_resp(n, ex, data[:prob_ex], data[:prior_s], r[:queries], t)
    end.sort.reverse
    probs.each_with_index { |pr, j| extra_leaks[i][j] += pr }
  end
end
leaks.each { |k, v| leaks[k] = v[0] / v[1] }
total = sims(1,n,t).size.to_f
extra_leaks.each { |k, v| v.map! { |pr| pr / total } }

is = (1..[20, n - 1].min)
qmin = 1.0/0
qmax = -1.0/0
is.each do |i|
  dist = total_query_dist_given_org(i, n, t)
  qn = dist.keys.min
  qx = dist.keys.max
  if qn < qmin
    qmin = qn
  end
  if qx > qmax
    qmax = qx
  end
end

File.open("omega_exre_#{suff}.gp", 'w') do |f|
  is.each do |i|
    f.puts "$data#{i} <<EOD"
    dist = total_query_dist_given_org(i, n, t)
    total = dist.values.reduce(:+).to_f
    (qmin..qmax).each do |q|
      f.puts "#{i}\t#{q}\t#{dist[q] / total}"
    end
    f.puts "EOD"
  end
  f.puts <<EOD
unset key
set terminal pdf
set view 74,222
set xrange [#{is.begin}:#{is.end}]
set yrange [#{qmin}:#{qmax}]
set xlabel 'I'
set ylabel 'Ω'
set zlabel 'P(Ω|I)'
set xyplane 0.1
set style data lines
EOD
  f.puts "splot #{is.map { |i| "'$data#{i}' linetype rgb '#{gradient([0, 0, 255], [255, 0, 0], is.begin, is.end, i)}'" }.join(', ')}"
end

File.open("qdist_exre_#{suff}.gp", 'w') do |f|
  is.each do |i|
    f.puts "$data#{i} <<EOD"
    dist = post_query_dist_given_org(i, n, t)
    (1..qmax).each do |q|
      f.puts "#{i}\t#{q}\t#{dist[q]}"
    end
    f.puts "EOD"
  end
  f.puts <<EOD
unset key
set terminal pdf
set view 74,222
set xrange [#{is.begin}:#{is.end}]
set yrange [1:#{qmax}]
set xlabel 'I'
set ylabel 'Q'
set zlabel 'P(Q|I)'
set xyplane 0.1
set style data lines
EOD
  f.puts "splot #{is.map { |i| "'$data#{i}' linetype rgb '#{gradient([0, 255, 255], [0, 0, 255], is.begin, is.end, i)}'" }.join(', ')}"
end

# create a 3D plot of extra response distribution for each query
File.open("exre_dist_#{suff}.gp", 'w') do |f|
  f.puts "$data << EOD"
  leaks.each do |i, d|
    f.puts "#{i + 1}\t0\t#{d}"
  end
  f.puts "EOD"
  extra_leaks.each do |i, dist|
    f.puts "$datad#{i} << EOD"
    f.puts "#{i + 1}\t0\t#{leaks[i]}"
    dist.each_with_index do |pr, j|
      f.puts "#{i + 1}\t#{j + 1}\t#{pr}"
    end
    f.puts "EOD"
  end
  f.puts <<-CMD
set terminal pdf
unset key
set xyplane 0.0
set zrange [0:1]
set xlabel 'Attacker'
set ylabel 'Other Peers'
set zlabel 'P(S|response)' rotate parallel
set ytics offset -1
set view 66,132
set style data lines
splot $data linetype rgb 'black', #{leaks.each_key.map { |i| "'$datad#{i}' linetype rgb '#{gradient([0, 0, 255], [18, 157, 0], 0, leaks.size - 1, i)}'" }.join(', ')}
  CMD
end

# create a data file of just direct response distribution
File.open("exre_#{suff}.data", 'w') do |f|
  leaks.each do |j, pr|
    f.puts "#{j+1}\t#{pr}"
  end
end
