require 'telegram_bot'

load "token.rb"

bot = TelegramBot.new(token: TOKEN)
bot.get_updates(fail_silently: true) do |message|
  puts "@#{message.from.username}: #{message.text}"
  command = message.get_command_for(bot)


  message.reply do |reply|
    swift_code_text = "print( " + command.to_s + " )\n"

    swift_code_filename = "code_#{message.from.username}.swift"
    File.open(swift_code_filename, 'w') { |file| file.write( swift_code_text ) }

    swift_result = %x( swift #{swift_code_filename} )

    case swift_result
    when ""
      reply.text = "#{message.from.first_name}, compiler error in:\n#{swift_code_text}"
    else
      reply.text = swift_result
    end

    puts "sending #{reply.text.inspect} to @#{message.from.username}"

    reply.send_with(bot)
  end
end
