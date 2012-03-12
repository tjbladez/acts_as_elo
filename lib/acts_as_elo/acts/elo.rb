module Acts
  module Elo
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # `acts_as_elo` hooks into your object to provide you with the ability to
      # set and get `elo_rank` attribute
      # Available options are:
      # * default_rank - change the starting rank
      # * one_way - limits update of the rank to only self
      # * proficiency_map - hash that has two keys
      #    * rank_limits  - array of two elements, ranks that limit categories of
      #                     player proficiency. Between novice and intermediate; intermediate and pro.
      #                     Defaults: 1299, 2399
      #    * coefficients - proficiency coefficient for each category.
      #                     Defaults: 30 for novice, 15 for intermediate, 10 for a pro
      def acts_as_elo(opts = {})
        default_rank    =  opts[:default_rank] || 1200
        proficiency_map =  opts[:proficiency_map] || {:coefficients => [30, 15, 10],
                                                      :rank_limits  => [1299, 2399] }

        unless opts.empty?
          class << self
            attr_accessor :acts_as_elo_options
          end
          @acts_as_elo_options = opts
        end

        class_eval do
          if Object::const_defined?("ActiveRecord") && self.ancestors.include?(ActiveRecord::Base)

            define_method(:elo_rank) do
              self[:elo_rank] ||= default_rank
            end

          else

            attr_writer :elo_rank
            define_method(:elo_rank) do
              @elo_rank ||= default_rank
            end
          end

          define_method(:elo_proficiency_map) do
            proficiency_map
          end
        end

        include Acts::Elo::InstanceMethods unless self.included_modules.include?(Acts::Elo::InstanceMethods)
      end
    end

    module InstanceMethods
      def elo_win!(opponent, opts={})
        elo_update(opponent, opts.merge!(:result => :win))
      end

      def elo_lose!(opponent, opts={})
        elo_update(opponent, opts.merge!(:result => :lose))
      end

      def elo_draw!(opponent, opts={})
        elo_update(opponent, opts.merge!(:result => :draw))
      end

      def elo_update(opponent, opts={})
        begin
          if self.class.respond_to?(:acts_as_elo_options) && self.class.acts_as_elo_options[:one_way]
            one_way = true
          end
          one_way   ||= opts[:one_way]
          send_opts = {one_way: true}

          # Formula from: http://en.wikipedia.org/wiki/Elo_rating_system
          diff        = opponent.elo_rank.to_f - elo_rank.to_f
          expected    = 1 / (1 + 10 ** (diff / 400))
          coefficient = elo_proficiency_map[:coefficients][1]

          if elo_rank < elo_proficiency_map[:rank_limits].first
            coefficient = elo_proficiency_map[:coefficients].first
          end

          if elo_rank > elo_proficiency_map[:rank_limits].last
            coefficient = elo_proficiency_map[:coefficients].last
          end

          if opts[:result] == :win
            points = 1
            send_opts.merge!(result: :lose)
          elsif opts[:result] == :lose
            points = 0
            send_opts.merge!(result: :win)
          elsif opts[:result] == :draw
            points = 0.5
            send_opts.merge!(result: :draw)
          end

          opponent.elo_update(self, send_opts) unless one_way

          self.elo_rank = (elo_rank + coefficient*(points-expected)).round
        rescue Exception => e
          puts "Exception: #{e.message}"
        end
      end
    end
  end
end