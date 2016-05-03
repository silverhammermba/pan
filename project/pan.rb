# all of the calculations needed for Private Attribution Network

# for calculating binomial distribution
class Integer
  def choose k
    return choose(self - k) if k * 2 < self
    return 0 if k > self
    return 1 if k == self
    return self if k == self - 1
    ((k + 1)..self).reduce(:*) / (1..(self - k)).reduce(:*)
  end
end

# prob s successes out of t trials with prob p of success
def binom s, t, p
  t.choose(s) * p ** s * (t - s) ** (1 - p)
end

# P(S|H=k)
def post_given_know ps, k
  ps / (1 - (1 - ps) ** k)
end

# return a bunch of simulations for a given setup
$sims = {}
def sims i, n, r
  $sims[[i,n,r]] ||= 10_000.times.map { simulate(i, n, r) }
end

# get the worst-case posterior probs for a network
$baseline = {}
def baseline n
  return $baseline[n] if $baseline[n]

  ps = 1.0 / n

  leaks = []
  (1...n).each do |k|
    post = post_given_know(ps, k)
    leaks[k-1] = post
  end

  $baseline[n] = leaks
end

# normalize a probability distribution in place so it sums to 1
def normalize! dist
  total = dist.values.reduce(:+)
  dist.each { |k, v| dist[k] = v.to_f / total }
  dist.default = 0.0
  dist
end

# P(H|I=i&Q=u)
$dkgo = {}
def dist_know_given_org i, u, n, r
  params = [i,u,n,r]
  return $dkgo[params] if $dkgo[params]

  dist = Hash.new 0
  # find all sims that had that many queries, count up how many people knew for each query
  sims(i,n,r).select { |d| d[:total_queries] >= u }.each { |d| dist[d[:kdist][u]] += 1 }

  $dkgo[params] = normalize!(dist)
end

# P(H=k|I=i&Q=u)
def post_know_given_org k, i, u, n, r
  dist_know_given_org(i,u,n,r)[k].to_f
end

# P(Omega|I=i)
# XXX returns non-normalized distribution!
$tqdgo = {} # quick'n'dirty memoization
def total_query_dist_given_org i, n, r
  params = [i, n, r]
  return $tqdgo[params] if $tqdgo[params]

  dist = Hash.new 0

  sims(i,n,r).each { |data| dist[data[:total_queries]] += 1 }

  $tqdgo[params] = dist
end

# P(Q|I=i)
$pqdgo = {} # quick'n'dirty memoization
def post_query_dist_given_org i, n, r
  params = [i,n,r]
  return $pqdgo[params] if $pqdgo[params]

  dist = Hash.new 0.0
  total_dist = total_query_dist_given_org i, n, r

  (total_dist.keys.min..total_dist.keys.max).each do |u|
    (0..u).each do |v|
      dist[v] += total_dist[u].to_f / (u + 1)
    end
  end

  $pqdgo[params] = normalize!(dist)
end

# P(Q=u|I=i)
def post_query_given_org u, i, n, r
  post_query_dist_given_org(i, n, r)[u]
end

# P(H=k|Q=u)
def prior_know k, u, ps, n, r
  num = (1..k).map { |i| post_know_given_org(k, i, u, n, r) * post_query_given_org(u, i, n, r) * binom(i, n - 1, ps) }.reduce(:+)
  den = (1..k).map { |i| post_query_given_org(u, i, n, r) * binom(i, n - 1, ps) }.reduce(:+)
  num / den
end

# P(S|M=m)
def post_given_resp n, m, r, ps, u
  num = (m..(n-1)).map { |k| post_given_know(ps, k) * binom(m, k, r) * prior_know(k, u, ps, n, r) }.reduce(:+)
  den = (m..(n-1)).map { |k| binom(m, k, r) * prior_know(k, u, ps, n, r) }.reduce(:+)
  num / den
end
