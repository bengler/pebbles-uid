# Pebbles::Uid

Handle unique identifiers in the Pebblestack universe conveniently.

## Unique Identifiers

A valid Uid is in the format `species[.genus]:path[$oid]`.

### Species

The species is one or more dot-delimited labels.

The first label uniquely identifies which pebble the resource originated from.
Any secondary labels are grouped into a `genus`, which identify sub-types within
a given pebble.

### Path

The path is a dot-delimited set of labels, the first of which (realm) is required.

### Oid

The object identifier can be any string, including another Uid.
The oid is optional when creating a new resource.

## Installation

Add this line to your application's Gemfile:

    gem 'pebbles-uid'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pebbles-uid

## Usage

### Identifying an existing resource

    uid = Pebbles::Uid.new('post.card:tourism.norway.fjords$1234')

    uid.realm
    => "tourism"

    uid.species
    => "post.card"

    uid.genus
    => "card"

    uid.path
    => "tourism.norway.fjords"

    uid.oid
    => 1234

    uid.parsed
    => ['post.card', 'tourism.norway.fjords', '1234']

    uid.to_s
    => 'post.card:tourism.norway.fjords$1234'

    uid.to_hash
    => {'species' => 'post.card', 'path_0' => 'tourism', 'path_1' => 'norway', 'path_2' => 'fjords', 'oid' => '1234'}

    uid.to_hash(:verbose => true, :suffix => '')
    => {'species_0_' => 'post', 'species_1_' => 'card', 'path_0_' => 'tourism', 'path_1_' => 'norway', 'path_2_' => 'fjords', 'oid_' => '1234'}

    uid.to_hash(:verbose => true, :suffix => 'xyz', :species => 'klass', :path => 'label' => :oid => 'id')
    => {'klass_0_xyz' => 'post', 'klass_1_xyz' => 'card', 'label_0_xyz' => 'tourism', 'label_1_xyz' => 'norway', 'label_2_xyz' => 'fjords', 'id_xyz' => '1234'}

### Locating one or more resource

TODO: implement Pebbles::Uid.query that supports wildcards.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
