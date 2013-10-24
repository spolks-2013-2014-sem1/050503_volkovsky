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
