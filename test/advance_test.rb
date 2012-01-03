require 'pathname'
require Pathname.new('.') + 'helper'

# When user answers the question based on the on current rank of the user 
# and current rank of the question both user and question ranks will be updated
class User
  include Acts::Elo
  
  attr_accessor :questions
  
  acts_as_elo :one_way => true,
end

class Question
  include Acts::Elo
  
  attr_accessor :user
  
  acts_as_elo :sender => true, :method => :user
end


context "User with many questions" do
  helper(:question) { |user| Question.new.tap {|q| q.user = user} }
  
  setup  { User.new }
  hookup { topic.questions = [question(topic), question(topic)] }
  
  asserts(:elo_rank).equals(1200)
  asserts("questions have default ranks"){ topic.questions.map(&:elo_rank)}.equals([1200, 1200])
  
  context "when question is answered correctly" do
    hookup { topic.questions.each {|q| q.elo_rank = 1200 }}
    hookup { topic.questions.first.elo_lose!}
    
    asserts(:elo_rank).equals(1205)
    asserts("questions have their ranks updated"){ topic.questions.map(&:elo_rank)}.equals([1195, 1200])
  end
  
  context "when question is answered incorrectly" do
    hookup { topic.questions.each {|q| q.elo_rank = 1200 }}
    hookup { topic.questions.first.elo_win! }
        
    asserts(:elo_rank).equals(1195)
    asserts("questions have their ranks updated"){ topic.questions.map(&:elo_rank)}.equals([1205, 1200])
  end
end