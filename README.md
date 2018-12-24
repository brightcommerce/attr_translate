# AttrTranslate

Rails concern for ActiveRecord attribute translation using PostgreSQL's JSONB datatype.

AttrTranslate is extracted from the Brightcommerce platform and is used in a number of other software projects.

## Installation

To install add the line to your Gemfile:

``` ruby
gem 'attr_translate'
```

And `bundle install`.

## How To Use

To add AttrTranslate to a model, include the concern and class method:

``` ruby
class Post < ActiveRecord::Base
  include AttrTranslate

  attr_translate :title, :body
end
```

For convenience the `attr_translate` class method is aliased internally as `attr_translates`.

To autoload AttrTranslate for all models, add the following to an initializer:

``` ruby
require 'attr_translate/active_record'
```

You then don't need to `include AttrTranslate` in any model, but you still need to add the `attr_translate` class method.

### Setup

Each attribute that will have translations will need to be setup appropriately in your model's migration. Append `_translations` to the column name, and set the column type to `:jsonb`. To aid in search, setup an index using the `gin` index type. Each translation will be stored using the locale as a key in a hash and converted to JSON.

``` ruby
class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |table|
      table.column :title_translations, :jsonb, default: {}, index: {using: 'gin'}
      table.column :body_translations, :jsonb, default: {}, index: {using: 'gin'}
      table.timestamps
    end
  end
end
```

## Dependencies

AttrTranslate gem has the following runtime dependencies:
- activerecord >= 5.1.4
- activesupport >= 5.1.4

## Compatibility

Tested with MRI 2.4.2 against Rails 5.2.2.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Credit

This gem was written and is maintained by [Jurgen Jocubeit](https://github.com/JurgenJocubeit), CEO and President Brightcommerce, Inc.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Copyright

Copyright 2018 Brightcommerce, Inc.
