# generate Makefile dependencies for gnuplots

Dir.glob('*.gp').each do |plot|
  s =  File.read(plot)
  deps = s.scan(/"([^"\\]*(\\.[^"\\]*)*)"|\'([^\'\\]*(\\.[^\'\\]*)*)\'/).flatten.compact.select { |str| str.end_with? '.data' }
  next if deps.empty?

  puts "chart_#{File.basename(plot, '.gp')}.pdf: #{deps.join(' ')}"
end

Dir.glob('*.tex').each do |tex|
  s = File.read(tex)
  deps = s.scan(/\{([^{}]+.pdf)\}/).flatten
  next if deps.empty?

  puts "#{File.basename(tex, '.tex')}.pdf: #{deps.join(' ')}"
end
