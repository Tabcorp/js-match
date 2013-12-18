# js-match

Validates an entire Javascript object against a set of nested matchers.
This can be useful to quickly validate:

- a JSON config file
- the structure of an HTTP request payload

*Note:* `js-match` will always ignore extra fields, as long as the set of matchers passes. This conforms with the robustness principle of "be conservative in what you do, be liberal in what you accept".

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
  {path: 'name', error: 'required'},
  {path: 'age',  value: 'foo', error: 'should be a number'}
]
```

## Matchers

Values can be tested against a default set of matchers, for ex:

```coffee
{ match: 'string'  }
{ match: 'number'  }
{ match: 'boolean' }
{ match: 'ip'      }
{ match: 'host'    }
{ match: 'url'     }
{ match: 'file'    }
{ match: 'dollars' }
```

You can also register custom matchers for advanced logic:

```coffee
jsm.matchers['guid'] = (value) ->
  if not value.match /[0-9a-f]{32}/i
    return "should be a GUID"

jsm.validate object,
  name:     { match: 'string' }
  uniqueId: { match: 'guid'   }
```

Matchers can also take optional parameters:

```coffee
jsm.matchers['age'] = (value, options) ->
  if value < options.min or value > options.max
    return "should be an age between #{options.min} and #{options.max}"

jsm.validate object,
  name:  { match: 'string' }
  age:   { match: 'age', min: 1, max: 100 }
```

## Required

By default, all fields in the "schema" are assumed to be required.
Fields can be manually marked as optional:

```coffee
jsm.validate object,
  username: { match: 'string' }
  password: { match: 'string', optional: true }
```

Validation will ignore missing optional fields, but will run the matcher if an optional field is present.
E.g. it won't complain if `password` isn't there, but will if `password` is a number.


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
  {path: 'credentials.user', error: 'required'},
  {path: 'machines[1].host', value: 1234, error: 'should be a string'},
  {path: 'values[3]', value: true, error: 'should be a number'}
]
```
