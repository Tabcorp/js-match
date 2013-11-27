# js-match

Validates an entire Javascript object against a set of nested matchers.

## Basic usage

```coffee
jsm = require 'js-match'

person =
  name: { match: 'string' }
  age:  { match: 'number' }

# success
errors = jsm.validate {name: 'Bob', age: 30}, person
errors.should.eql []

# failure
errors = jsm.validate {age: 'foo'}, person
errors.should.eql [
  'name is required',
  'age should be a number but foo is a string'
]
```

## Matchers

Values can be tested against a default set of matchers, for ex:

```coffee
{ match: 'string'  }
{ match: 'number'  }
{ match: 'boolean' }
{ match: 'ip'      }
{ match: 'url'     }
```

You can also register custom matchers for advanced logic:

```coffee
jsm.matchers['guid'] = (path, value) ->
  if not value.match /[0-9a-f]{32}/i
    return "#{path} should be a GUID, but was #{value}"

jsm.validate object,
  name:     { match: 'string' }
  uniqueId: { match: 'guid'   }
```


## Required

By default, all fields in the "schema" are assumed to be required.
Fields can be manually marked as optional:

```coffee
jsm.validate object,
  host: { match: 'url' }
  user: { match: 'string', optional: true }
  pass: { match: 'string', optional: true }
```

Validation will ignore missing optional fields, but will run the matcher if an optional field is present.


## Nested configs

`js-match` supports nested objects, arrays, and primitives:

```coffee
jsm.validate
  credentials:
    user:  { match: 'string' }
    pass:  { match: 'string' }
  machines: [
    host:  { match: 'string' }
    port:  { match: 'number' }
  ]
  values: [
    { match: 'number' }
  ]
```

which matches the following object:

```json
{
  "credentials": {
    "user": "bob",
    "pass": "p@ssw0rd"
  },
  "machines": [
    { "host": "serverX", "port": 3000 },
    { "host": "serverY", "port": 3000 }
  ],
  "values": [1, 2, 3, 4, 5]
}
```

Any errors will be returned with fully qualified paths, for ex:

```js
[
  'credentials.user is required',
  'machines[1].host should be a string, but 1234 is a number',
  'values[3] should be a number, but true is a boolean'
]
```
