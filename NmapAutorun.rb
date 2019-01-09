require "ostruct"
require "nmap/program"
require "optparse"
C  = "\033[36m" # cyan
W  = "\033[0m"  # white (default)
RE="\033[31m"   # red
G  = "\033[1;32m" # green bold
class ExploitScan
	VERSION = 1.0
	TIMEUTC = Time.now.utc
	def initialize(single_target,file_scanner,firewall_target)
		@single_target = single_target
		@file_scanner = file_scanner
		@firewall_target = firewall_target
	end
	
	def scanner_verbose
		begin
			Nmap::Program.scan do |nmap|
				nmap.verbose = true
				if @file_scanner.length > 1
					nmap.target_file = @file_scanner
				elsif @single_target.length > 1
					nmap.ports = '1-65535'
					nmap.targets = @single_target
				end
			end
		rescue Interrupt
			puts "#{W}"
		end
	end
	
	def scan_firewall_vulnerabilities
		if @firewall_target.length > 1
			begin
				Nmap::Program.sudo_scan do |nmap|
					nmap.syn_scan = true
					nmap.udp_scan = true
					nmap.null_scan = true
					nmap.fin_scan = true
					nmap.xmas_scan = true
					nmap.targets = @firewall_target
				end
			rescue RProgram::ProgramNotFound
				puts "#{RE}Need Sudo or Root Access#{W}"
			end
		end
	end

	
end


if __FILE__ == $0

	if ARGV.empty?
		puts "#{RE}ruby #{__FILE__} -h get help#{W}"
		exit
	end
	
	options = OpenStruct.new
	options.single_target = ''
	options.file_scanner = ''
	options.firewall_target = ''
	opts = OptionParser.new do |opts|
		opts.banner = "Nmapautorun #{ExploitScan::VERSION}"
		opts.on("-h",	"--help",	"-?",	"--?",	"Get help") do |help|
			puts "#{C}#{opts}#{W}"
			exit
		end
		
		
		opts.on("-v",	"--version","Get version") do |ver|
			puts "Version #{ExploitScan::VERSION}"
			exit
		end
		
		
		opts.on("-t",	"--target [Domain]",	"Scan Firewall to Find Vulnerabilities [Need Root Access]") do |firewall|
			options.firewall_target = firewall
		end
		
		
		opts.on("-s",	"--single [DOMAIN]",	"Full Port Scan with Verbosity") do |target|
			system('printf "\t\t██████╗  █████╗ ██╗███████╗███████╗\n\t\t██╔══██╗██╔══██╗██║██╔════╝██╔════╝\n\t\t██████╔╝███████║██║███████╗█████╗\n\t\t██╔══██╗██╔══██║██║╚════██║██╔══╝\n\t\t██║  ██║██║  ██║██║███████║███████╗\n\t\t╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝\n\t\t" | lolcat')
			puts "#{C}[#{ExploitScan::TIMEUTC}]#{G}"
			options.single_target = target
		end
		
		
		opts.on("-f",	"--file [FILE]",	"Input file for scan port with verbosity") do |file|
			system('printf "\t\t██████╗  █████╗ ██╗███████╗███████╗\n\t\t██╔══██╗██╔══██╗██║██╔════╝██╔════╝\n\t\t██████╔╝███████║██║███████╗█████╗\n\t\t██╔══██╗██╔══██║██║╚════██║██╔══╝\n\t\t██║  ██║██║  ██║██║███████║███████╗\n\t\t╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝\n\t\t" | lolcat')
			puts "#{C}[#{ExploitScan::TIMEUTC}]#{G}"
			options.file_scanner = file
		end
		
		
	end
	
	
	opts.parse!(ARGV)
	run = ExploitScan.new(options.single_target,options.file_scanner,options.firewall_target)
	
	run.scanner_verbose
	run.scan_firewall_vulnerabilities
	puts "#{W}"
end