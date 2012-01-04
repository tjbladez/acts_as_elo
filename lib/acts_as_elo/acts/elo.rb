module Acts
  module Elo
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def acts_as_elo(opts = {})
        default_rank =  opts[:default_rank] || 1200 

        unless opts.empty?
          class << self
            attr_accessor :acts_as_elo_options
          end
          @acts_as_elo_options = opts
        end

        class_eval do  
          attr_writer :elo_rank
          
          define_method(:elo_rank) do
            @elo_rank ||= default_rank
          end
          
          if opts[:method] && !methods.include?(:elo_opponent)
            define_method(:elo_opponent) do
              send(opts[:method].to_sym)
            end
          end
        end

        include Acts::Elo::InstanceMethods unless self.included_modules.include?(Acts::Elo::InstanceMethods)        
      end
    end   
    
    module InstanceMethods
      def elo_win!(opts={})
        begin
          source    = opts[:source] || elo_opponent
          one_way   = opts[:one_way]
          diff      = (source.elo_rank.to_f - elo_rank.to_f).abs
          expected  = 1 / (1 + 10 ** (diff / 400))
          send_opts = {one_way: true}
          if self.class.respond_to?(:acts_as_elo_options) && self.class.acts_as_elo_options[:sender]
            send_opts.merge!(source: self)
          end
          
          source.elo_lose!(send_opts) unless opts[:one_way]

          @elo_rank = (elo_rank + 10*(1-expected)).round

        rescue Exception => e
          puts "Exception: #{e.message}"
        end        
      end
      
      def elo_lose!(opts={})
        begin
          source    = opts[:source] || elo_opponent
          diff      = (source.elo_rank.to_f - elo_rank.to_f).abs
          expected  = 1 / (1 + 10 ** (diff / 400))
          send_opts = {one_way: true}
          
          if self.class.respond_to?(:acts_as_elo_options) && self.class.acts_as_elo_options[:sender]
            send_opts.merge!(source: self) 
          end
          
          source.elo_win!(send_opts) unless opts[:one_way]

          @elo_rank = (elo_rank + 10*(0-expected)).round          
        rescue Exception => e
          puts "Exception: #{e.message}"
        end
      end
    end 
  end
end