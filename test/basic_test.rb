require 'pathname'
require Pathname.new('.') + 'helper'


class Player
  include Acts::Elo
  
  attr_accessor :opponent
  
  acts_as_elo :opponent
end



context "Two player are opponents of each other" do
  setup do
    @first = Player.new 
    @second = Player.new
    @first.opponent = @second
    @second.opponent = @first
    @first
  end
  asserts("first default elo rank of 1200") { @first.elo_rank}.equals(1200)
  asserts("second default elo rank of 1200") { @second.elo_rank}.equals(1200)  
  asserts("second is an opponent of first") { @first.opponent}.equals{@second}
  asserts("first is an opponent of second") { @second.opponent}.equals{@first}
  context "when first one wins" do
    setup { @first.elo_win! }
    asserts("first elo rank is updated") {@first.elo_rank}.equals(1300)
    asserts("second elo rank is updated"){@second.elo_rank}.equals(1100)
  end
end

class PlayerWithDefaultRank
  include Acts::Elo

  attr_reader :enemy
  acts_as_elo :opponent, :default_rank => 1300
end
context "Testing default for elo rank" do
  setup { PlayerWithDefaultRank.new }
  asserts(:elo_rank).equals(1300)
end
