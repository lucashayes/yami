require 'whois'

class Hello
  include Cinch::Plugin

  match /ip\s(\d+\.\d+\.\d+\.\d+)(\s.+?$||$)/, method: :ip_whois
  
  def ip_whois(m, ip, args="")
    w = Whois.whois(ip)
    hash, strings, args = {}, [], args.split
    w = w.to_s.split("\n").each {|line| begin; hash[line.split(':')[0].to_sym] = line.split(' ',2)[1]; rescue Exception; end }
    args.each do |arg|
      strings.push "#{arg}: #{hash[arg.to_sym]}"
    end
	if strings == []
      m.reply "Netrange: #{hash[:NetRange]}"
      m.reply "Netname:  #{hash[:NetHandle]}"
      m.reply "Organization: #{hash[:OrgName]}"
      m.reply "Country: #{hash[:Country]}"
	end

   strings.each do |string|
     m.reply string
   end
  end
  
end