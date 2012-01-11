require 'pathname'
require Pathname.new('.') + 'helper'

class Player
  include Acts::Elo
  
  acts_as_elo
end


context "Two players are opponents of each other" do
  setup { [Player.new, Player.new] }
  
  asserts("default ranks are 1200") {
    topic.map(&:elo_rank)
  }.equals([1200, 1200])

  context "when first one wins" do
    hookup {topic.each {|pl| pl.elo_rank = 1200 }}
    hookup {topic.first.elo_win!(topic.last)}
    
    asserts("ranks are updated") {topic.map(&:elo_rank)}.equals([1205, 1195])
  end

  context "when first one loses" do
    hookup {topic.each {|pl| pl.elo_rank = 1200 }}    
    hookup {topic.first.elo_lose!(topic.last)}
    
    asserts("ranks are updated") {topic.map(&:elo_rank)}.equals([1195, 1205])
  end

  context "when they draw" do
    hookup {topic.each {|pl| pl.elo_rank = 1200 }}    
    hookup {topic.first.elo_draw!(topic.last)}
    
    asserts("ranks are updated") {topic.map(&:elo_rank)}.equals([1200, 1200])
  end

end

class PlayerWithDefaultRank
  include Acts::Elo
  acts_as_elo :default_rank => 1300
end

context "Testing default for elo rank" do
  setup { PlayerWithDefaultRank.new }
  asserts(:elo_rank).equals(1300)
end


