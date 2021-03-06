require 'optparse'

module Utils

  class ArgParser
    def initialize
      @options = {}

      @optparse = OptionParser.new do |opts|
      
        opts.on(/^([0-9]{1,3}\.){3}[0-9]{1,3}$/) do |ip|
          @options[:addr] = ip
        end
  
        opts.on(/^[0-9]+$/) do |port|
          @options[:port] = port
        end
      
        @options[:filepath] = nil
        opts.on(/.+/) do |filepath|
          @options[:filepath] = filepath
        end

        @options[:udp] = false
        opts.on('-u') do 
          @options[:udp] = true
        end

        @options[:listen] = false
        opts.on('-l') do 
          @options[:listen] = true
        end

        @options[:verbose] = false
        opts.on('-v') do 
          @options[:verbose] = true
        end
      end
    end

    def [](label)
      @options[label]
    end

    def parse!
      @optparse.parse!
    end
  end
end
