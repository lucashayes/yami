require 'cinch'

Dir[File.dirname(__FILE__) + '/plugins/*.rb'].each do |file| 
  require_relative 'plugins/' + File.basename(file, File.extname(file))
end

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = "Yami"
    c.server = "irc.alphachat.net"
    c.channels = ["#voltron"]
    c.plugins.plugins = [Hello, Nmap_scanner]
    c.plugins.prefix = /^>/
  end
  on :message, /^>reload/ do |m|
	Dir[File.dirname(__FILE__) + '/plugins/*.rb'].each {|file| load file; m.reply "#{file}: reloaded"}
    m.reply "Reloaded!"
  end
  
  on :message, /^>restart/ do |m|
    m.reply "Restarting!"
	#`ruby #{__FILE__}`
	bot.quit 'Restarting!'
	`ruby #{__FILE__}`
  end
  
end


  
bot.start
