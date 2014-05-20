## ActsAsElo

### What is it?

Provides sophisticated yet easy to understand ranking system with minimum changes to the system.
Elo ranking system is heavily used in tournaments, player rankings in chess, sports, leader boards, multiplayer games, ranking of test questions, tasks etc.

Read more about it on [wiki](http://en.wikipedia.org/wiki/Elo_rating_system)

### Usage

`acts_as_elo` is very easy to use

1. Install: `gem install acts_as_elo`
2. Add `include Acts::Elo` and `acts_as_elo`
3. Call any of the 3 methods: `elo_win!`, `elo_lose!` and `elo_draw!`

### Example

```ruby

class Player
  include Acts::Elo
  acts_as_elo
end

bob, jack = Player.new, Player.new
bob.elo_rank # => 1200
jack.elo_rank # => 1200

bob.elo_win!(jack)
bob.elo_rank # => 1215
jack.elo_rank # => 1985
```

### License

Released under the MIT License. See the [LICENSE][license] file for further details.

[license]: https://github.com/tjbladez/acts_as_elo/blob/master/LICENSE