module Acts
  module Elo
    def self.included(base)
      base.extend(ClassMethods)
      # base.send(:include, InstanceMethods)
    end
    
    module ClassMethods
      def acts_as_elo(method, opts = {})
        default_rank =  opts[:default_rank] || 1200 
        
        class_eval <<-EOV
          def elo_win!
            send(:#{method})
          end
          
          def elo_rank
            @elo_rank ||= #{default_rank}
          end
        EOV
      end
    end    
  end
end