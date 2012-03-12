require 'pathname'
require Pathname.new('.') + 'helper'

# When user answers the question based on the on current rank of the user
# and current rank of the question both user and question ranks will be updated
class User
  include Acts::Elo

  attr_accessor :questions
  acts_as_elo
end

class Question
  include Acts::Elo

  attr_accessor :user
  acts_as_elo
end


context "User with many questions" do
  helper(:question) { |user| Question.new.tap {|q| q.user = user} }

  setup  { User.new }
  hookup { topic.questions = [question(topic), question(topic)] }

  asserts(:elo_rank).equals(1200)
  asserts("questions have default ranks"){ topic.questions.map(&:elo_rank)}.equals([1200, 1200])

  context "when question is answered correctly" do
    hookup { topic.questions.each {|q| q.elo_rank = 1200 }}
    hookup { topic.questions.first.elo_lose!(topic)}

    asserts(:elo_rank).equals(1215)
    asserts("questions have their ranks updated"){ topic.questions.map(&:elo_rank)}.equals([1185, 1200])
  end

  context "when question is answered incorrectly" do
    hookup { topic.questions.each {|q| q.elo_rank = 1200 }}
    hookup { topic.questions.first.elo_win!(topic) }

    asserts(:elo_rank).equals(1185)
    asserts("questions have their ranks updated"){ topic.questions.map(&:elo_rank)}.equals([1215, 1200])
  end
end

class ProfessionalPlayer
  include Acts::Elo
  acts_as_elo :default_rank => 2400
end

class IntermediatePlayer
  include Acts::Elo
  acts_as_elo :default_rank => 2000
end

context "Professional player is playing against the intermediate player" do
  setup { [ProfessionalPlayer.new, IntermediatePlayer.new] }

  asserts("default ranks are 2400 and 2000") {
    topic.map(&:elo_rank)
  }.equals([2400, 2000])

  context "when the professional wins" do
    hookup {topic.first.elo_rank = 2400}
    hookup {topic.last.elo_rank = 2000}

    hookup {topic.first.elo_win!(topic.last)}

    asserts("the professional is barely rewarded") {topic.first.elo_rank}.equals(2401)
    asserts("the intermediate barely loses rank") {topic.last.elo_rank}.equals(1999)
  end
  context "when the intermediate player wins" do
    hookup {topic.first.elo_rank = 2400}
    hookup {topic.last.elo_rank = 2000}

    hookup {topic.last.elo_win!(topic.first)}

    asserts("the professional loses some rank") {topic.first.elo_rank}.equals(2391)
    asserts("the intermediate rewarded greatly") {topic.last.elo_rank}.equals(2014)
  end
end



