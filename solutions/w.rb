watch(/(?<task_name>\d\d).*\.rb/) do |m|
  system 'clear'
  success = system "testrb #{m[:task_name]}_tests.rb"

  if success
    puts "OK OK OK OK OK OK OK OK OK OK OK\n\n"
  else
    puts "Tests failed ;(- - - - - - - - - - - - - \n\n"
  end
end
