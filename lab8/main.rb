require 'securerandom'
require '../spolks_lib/connection'
require '../spolks_lib/utils'
require_relative 'tcp'
require_relative 'udp'

opts = Utils::ArgParser.new
opts.parse!


%w(TERM INT).each do |signal|
  Signal.trap signal do
    exit
  end
end

if opts[:listen]
  opts[:udp] ? udp_server(opts) : tcp_server(opts)
elsif !opts[:listen]? && opts[:filepath]?
  opts[:udp] ? udp_client(opts) : tcp_client(opts)
else
  puts opts
end
