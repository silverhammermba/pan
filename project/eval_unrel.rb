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

n = Integer(ARGV[0], 10)
rd = Integer(ARGV[1], 10)
r = rd.to_f / 100
suff = "#{n}_#{rd}"

leaks = Hash.new
sims(1, n, r).each do |data|
  data[:responses].each do |res|
    post = post_given_resp(n, res[1], r, data[:prior_s], res[2], r)
    leaks[res[0]] ||= [0.0, 0]
    leaks[res[0]][0] += post
    leaks[res[0]][1] += 1
  end
end
leaks.each { |k, v| leaks[k] = v[0] / v[1] }

is = (1..[20, n - 1].min)
qmin = 1.0/0
qmax = -1.0/0
is.each do |i|
  dist = total_query_dist_given_org(i, n, r)
  qn = dist.keys.min
  qx = dist.keys.max
  if qn < qmin
    qmin = qn
  end
  if qx > qmax
    qmax = qx
  end
end

File.open("omega_unrel_#{suff}.gp", 'w') do |f|
  is.each do |i|
    f.puts "$data#{i} <<EOD"
    dist = total_query_dist_given_org(i, n, r)
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

File.open("qdist_unrel_#{suff}.gp", 'w') do |f|
  is.each do |i|
    f.puts "$data#{i} <<EOD"
    dist = post_query_dist_given_org(i, n, r)
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

File.open("unrel_#{suff}.data", 'w') do |f|
  leaks.each do |j, post|
    f.puts "#{j}\t#{post}"
  end
end
