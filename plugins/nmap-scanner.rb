class Nmap_scanner
  require 'nmap/parser'
  require 'ipaddr'
  require 'yaml'
  
  include Cinch::Plugin

  match /nmap\s(.+[^\s]\s||\s)(\w+.+?||\s)$/, method: :nmap

  def nmap(m, args = nil, host)
	begin
	  host = IPSocket::getaddress(host.chomp)
	  IPAddr.new(host)
	rescue Exception => e
	  
	  m.reply "Invalid Host!"
	  m.reply "nmap help: nmap [options] <target>"
	  m.reply "Valid options: syn, udp, ping"
	  die = true
	end
	
	if die then return else 0 end
	
    switches = ''
    scan_file = "scan-#{Time.now.strftime("%Y_%m_%d_%H:%M:%S")}-#{m.user.nick}.yml"
	
	if !args.nil? 
	  arg_map = Hash['syn' => '-sS', 'udp' => '-sU', 'ping' => '-sP']
	  arg_array = args.split(/,/)
	  arg_array.each{|arg| switches = switches + " " + arg_map["#{arg.strip}"]}
	end
	m.reply "Running scan on #{host}..."
	parser = Nmap::Parser.parsescan(if args.nil? then "nmap" else "sudo nmap" end, "#{switches} #{host}")
    
	File.open("scans/#{scan_file}", 'w') {|f| f.write(YAML::dump(parser)) }
	
    m.reply "Nmap args: #{parser.session.scan_args}"
    m.reply "Runtime: #{parser.session.scan_time} seconds"
    
    parser.hosts("up") do |host|
      m.reply "#{host.addr} is up:"
      [:tcp, :udp].each do |type|
        host.getports(type, "open") do |port|
          srv = port.service
            m.reply "Port #{port.num}/#{port.proto} (#{srv.name}) is open"
        end
      end
    end
    if parser.hosts("down").count < 2
      parser.hosts("down") do |host|
        m.reply "#{host.addr} is down or blocking our pings, try running with param: syn"
      end
	end
  end

end