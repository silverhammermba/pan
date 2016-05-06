# generate Makefile dependencies for gnuplots

ARGV.each do |file|
  if file.end_with? '.gp'
    s =  File.read(file)
    deps = s.scan(/"([^"\\]*(\\.[^"\\]*)*)"|\'([^\'\\]*(\\.[^\'\\]*)*)\'/).flatten.compact.select { |str| str.end_with? '.data' }
    next if deps.empty?

    puts "chart_#{File.basename(file, '.gp')}.pdf: #{deps.join(' ')}"
  elsif file.end_with? '.tex'
    s = File.read(file)
    deps = s.scan(/\{([^{}]+.pdf)\}/).flatten
    next if deps.empty?

    puts "#{File.basename(file, '.tex')}.pdf: #{deps.join(' ')}"
  else
    exit 1
  end
end
