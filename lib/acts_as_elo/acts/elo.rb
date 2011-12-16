module Acts
  module Elo
    def self.included(base)
      base.extend(ClassMethods)
      # base.send(:include, InstanceMethods)
    end
    
    module ClassMethods
      def acts_as_elo(method, opts = {})
        default_rank =  opts[:default_rank] || 1200 

        class_eval do  
          attr_writer :elo_rank
          
          define_method(:elo_rank) do
            @elo_rank ||= default_rank
          end
          
          define_method(:elo_opponent) do
            send(method.to_sym)
          end
        end

        include Acts::Elo::InstanceMethods unless self.included_modules.include?(Acts::Elo::InstanceMethods)        
      end
    end   
    
    module InstanceMethods
      def elo_win!(opts={})
        begin
          diff      = elo_opponent.elo_rank.to_f - elo_rank.to_f
          expected  = 1 / (1 + 10 ** (diff / 400))
          @elo_rank = (elo_rank + 10*(1-expected)).round

          elo_opponent.elo_lose!(one_way: true) unless opts[:one_way]
        rescue Exception => e
          puts "oh no"
        end        
      end
      def elo_lose!(opts={})
        begin
          diff      = elo_opponent.elo_rank.to_f - elo_rank.to_f
          expected  = 1 / (1 + 10 ** (diff / 400))
          @elo_rank = (elo_rank + 10*(0-expected)).round
          
          elo_opponent.elo_win!(one_way: true) unless opts[:one_way]
        rescue Exception => e
          puts "oh no"
        end
      end
    end 
  end
end