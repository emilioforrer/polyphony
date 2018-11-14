# frozen_string_literal: true

require 'modulation'

Rubato = import('../../lib/rubato')

async def my_sleep(t)
  puts "#{t} start"
  await sleep(t)
  puts "#{t} done"
end

spawn do
  puts "#{Time.now} waiting..."
  await supervise do |s|
    s << my_sleep(1)
    s << my_sleep(2)
    s << my_sleep(3)
    s << async {
      puts "fiber count: #{Rubato::FiberPool.size}"
    }
  end
  puts "#{Time.now} done waiting"
end
