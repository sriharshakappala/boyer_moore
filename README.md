# BoyerMoore

Inspired by https://github.com/jashmenn/boyermoore

BoyerMoore is the fastest substring search strategy.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'boyer_moore'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install boyer_moore

## Usage

```ruby
BoyerMoore.search("foobar", "bar")     # => 3
BoyerMoore.search("foobar", "oof")     # => nil
BoyerMoore.search("foobar", "foo")     # => 0

```
