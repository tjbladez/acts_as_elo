require 'pathname'
require Pathname.new('.') + 'helper'


class Player
  include Acts::Elo
  
  attr_accessor :elo_opponent
  acts_as_elo
end


context "Two players are opponents of each other" do
  setup { [Player.new, Player.new] }
  hookup do 
    topic.first.elo_opponent = topic.last
    topic.last.elo_opponent  = topic.first
  end
  
  asserts("default ranks are 1200") {
    topic.map(&:elo_rank)
  }.equals([1200, 1200])

  context "when first one wins" do
    $k = true
    hookup {topic.each {|pl| pl.elo_rank = 1200 }}
    hookup {topic.first.elo_win!}
    
    asserts("ranks are updated") {topic.map(&:elo_rank)}.equals([1205, 1195])
  end

  context "when first one wins" do
    hookup {topic.each {|pl| pl.elo_rank = 1200 }}    
    hookup {topic.first.elo_lose!}
    
    asserts("ranks are updated") {topic.map(&:elo_rank)}.equals([1195, 1205])
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


class PlayerWithEnemy
  include Acts::Elo
  
  attr_accessor :enemy
  acts_as_elo :method => :enemy
end

context "Two players with custom method to get elo opponent" do
  setup { [PlayerWithEnemy.new, PlayerWithEnemy.new] }
  hookup do 
    topic.first.enemy = topic.last
    topic.last.enemy  = topic.first
  end
  
  asserts("default ranks are 1200") {topic.map(&:elo_rank)}.equals([1200, 1200])

  context "when first one wins" do
    hookup {topic.each {|pl| pl.elo_rank = 1200 }}
    hookup {topic.first.elo_win!}
    
    asserts("ranks are updated") {topic.map(&:elo_rank)}.equals([1205, 1195])
  end

  context "when first one wins" do
    hookup {topic.each {|pl| pl.elo_rank = 1200 }}    
    hookup {topic.first.elo_lose!}
    
    asserts("ranks are updated") {topic.map(&:elo_rank)}.equals([1195, 1205])
  end
end
