watch('.rb') do
  system 'clear'
  success = system 'testrb 04_tests.rb'

  if success
    puts "OK OK OK OK OK OK OK OK OK OK OK\n\n"
  else
    puts "Tests failed ;(- - - - - - - - - - - - - \n\n"
  end
end
