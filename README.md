# ChronologicalEnum

ChronologicalEnum is a Ruby gem that extends ActiveRecord enums to provide dynamic scopes for enums with values in a specified order.

For example
```ruby
class MyClass < ApplicationRecord
  enum status: { created: 0, processed: 1, finished: 2 }, _chronological: true
end

# Scope examples
MyClass.after_created # returns records with status greater than created
MyClass.before_finished # returns records with status lower than finished
MyClass.after_or_processed # returns records with status greater or equal to processed
MyClass.before_or_processed # returns records with status lower or equal to finished
```

It also supports prefixes and suffixes.
```ruby
class MyClass < ApplicationRecord
  enum status: { created: 0, processed: 1, finished: 2 }, _prefix: 'my', _suffix: 'enum',_chronological: true
end

MyClass.after_my_status_enum # returns records with status greater than created
```

The enum values have to be integers otherwise ChronologicalEnum would not work.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'chronological_enum'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install chronological_enum

## Usage

Just add `_chronological: true` to your enum definition as shown above.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nicmey/chronological_enum. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/nicmey/chronological_enum/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the chronologicalEnum project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/nicmey/chronological_enum/blob/main/CODE_OF_CONDUCT.md).
