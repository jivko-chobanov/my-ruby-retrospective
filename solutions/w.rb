watch('.rb') do
  system 'clear'
  success = system 'testrb t.rb'

  if success
    puts 'OK'
  else
    puts "Tests failed ;("
  end
end
