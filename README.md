# Pebbles::Uid

Handle unique identifiers in the Pebblestack universe conveniently.

## Unique Identifiers

A valid Uid is in the format `species[.genus]:path[$oid]`.

### Species

The species is one or more dot-delimited labels.

The first label uniquely identifies which pebble the resource originated from.

Any secondary labels are grouped into a `genus`, which identify sub-types within a given pebble.

```
  post.doc
```

species is `post`, genus is `doc`

### Path

The path is a dot-delimited set of labels. The first label represents the realm, and is required.

A single resource may have multiple paths (and therefore multiple uids). For example:

    ```
       post.card:tourism.norway.fjords$42
       post.card:tourism.norway.west-coast$42
    ```

### Oid

The object identifier can be nearly any string, including another uid.

The oid _MUST_ be unique for any species and realm.

There are currently two characters which cannot be included in an oid:

`|` (pipe) and `,` (comma).

Oid is optional when creating a new resource.

## Queries

### For one specific resource

Across the pebblestack universe, you can query for a specific resource by passing a full Uid.

In addition, the wildcard query `species:realm.*$oid` will identify a single resource, e.g.:

    ```
      post.card:tourism.*$42
    ```

If a specific resource is targeted (i.e. species and oid are both unambiguous), then realm is required.

### For a collection of resources

#### Asterisks

The most permissive query consists of any species in any path, with any oid (implied):

    ```
      *:*
    ```

This is the equivalent to:

    ```
      *:*$*
    ```

Queries may not be made across multiple realms at one time. If realm is not specified in the path, then it is assumed that the application verifies realm if necessary.

In the context of a species or a path, you may specify any number of labels and terminate with an asterisk, which means: zero or more labels follow. E.g.:

    ```
      post.*:tourism.europe.*
    ```

NOTE: wildcard queries on genus is not yet supported.

This will return things like:

    ```
      post:tourism.europe$123
      post:tourism.europe.france.sightseeing$234
      post.card:tourism.europe.mountains$345
    ```

Asterisks may not occur in mid-sequence. In other words, `post:tourism.*.food` will not be accepted.

In the context of an oid, you either know the oid you want, or you don't. A query where oid is not specified at all is equivalent to an oid represented by an asterisk.

#### Pipes

A pipe signifies _or_.

This can be used in species at any position:

    ```
      unit|group:*
    ```

    ```
      post.doc|card:*
    ```

In a path, this can be used in any position except the first, as the realm must be unambiguous.

Thus:

    ```
      post:realm.label1|label2.something
    ```

The following is not allowed:

    ```
      post:realm1|realm2.*
    ```

If you wish to fetch a specific list of objects, you may use the pipe to delimit oids:

    ```
      post:realm.*$a|b|c|d|e|f|g
    ```

This is equivalent to the NOW deprecated comma-delimited uid query:

    ```
      post:realm.*$a,post:realm.*$b,post:realm.*$c,post:realm.*$d,post:realm.*$e,post:realm.*$f,post:realm.*$g,
    ```

NOTE: realm is required in this case, because each term in the list must refer to a single resource.

#### Caret

In both species and paths, a caret indicates ancestry up to the specified point:

    ```
      post:realm.europe.^norway.fjords.food
    ```

This represents everything at the following locations:

    ```
      post:realm.europe
      post:realm.europe.norway
      post:realm.europe.norway.fjords
      post:realm.europe.norway.fjords.food
    ```


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

    uid.to_s
    => 'post.card:tourism.norway.fjords$1234'

    uid.to_hash
    => {'species' => 'post.card', 'path_0' => 'tourism', 'path_1' => 'norway', 'path_2' => 'fjords', 'oid' => '1234'}

    uid.to_hash(:verbose => true, :suffix => '')
    => {'species_0_' => 'post', 'species_1_' => 'card', 'path_0_' => 'tourism', 'path_1_' => 'norway', 'path_2_' => 'fjords', 'oid_' => '1234'}

    uid.to_hash(:verbose => true, :suffix => 'xyz', :species => 'klass', :path => 'label' => :oid => 'id')
    => {'klass_0_xyz' => 'post', 'klass_1_xyz' => 'card', 'label_0_xyz' => 'tourism', 'label_1_xyz' => 'norway', 'label_2_xyz' => 'fjords', 'id_xyz' => '1234'}

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
