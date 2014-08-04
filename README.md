# js-match

[![NPM](http://img.shields.io/npm/v/js-match.svg?style=flat)](https://npmjs.org/package/js-match)
[![License](http://img.shields.io/npm/l/js-match.svg?style=flat)](https://github.com/TabDigital/js-match)

[![Build Status](http://img.shields.io/travis/TabDigital/js-match.svg?style=flat)](http://travis-ci.org/TabDigital/js-match)
[![Dependencies](http://img.shields.io/david/TabDigital/js-match.svg?style=flat)](https://david-dm.org/TabDigital/js-match)
[![Dev dependencies](http://img.shields.io/david/dev/TabDigital/js-match.svg?style=flat)](https://david-dm.org/TabDigital/js-match)

Validates an entire Javascript object against a set of nested matchers.
This can be useful to quickly validate:

- a JSON config file
- the structure of an HTTP request payload

*Note:* `js-match` will always ignore extra fields, as long as the set of matchers passes. This conforms with the robustness principle of "be conservative in what you do, be liberal in what you accept".

## Basic usage

```
npm install js-match --save
```

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
{ match: 'uri'     }
{ match: 'file'    }
{ match: 'dollars' }
{ match: 'uuid-v4' }
{ match: 'enum', values: ['foo', 'bar'] }
```

You can also register custom matchers for advanced logic:

```coffee
jsm.matchers['custom-id'] = (value) ->
  if not value.match /[0-9a-f]{10}/i
    return "should be an ID of the form 8d9f0ab3c5"

jsm.validate object,
  name:     { match: 'string'    }
  uniqueId: { match: 'custom-id' }
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

Matchers can also return custom messages:

```coffee
person =
  name: { match: 'string', message: 'this is a custom message' }
  age:  { match: 'number' }

# success
errors = jsm.validate {name: 'Bob', age: 30}, person
errors.should.eql []

# failure
errors = jsm.validate {name: 12, age: 30}, person
errors.should.eql [
  {path: 'name', value: 12, error: 'this is a custom message'}
]
```
## Nested configs

`js-match` supports nested objects, arrays, and primitives:

```coffee
jsm.validate object,
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

## Custom schemas

You can either nest the matchers directly, like above, or extract them into separate "schemas":

```coffee
auth =
  accountNumber: { match: 'integer' }
  password:      { match: 'string' }

jsm.validate object,
  name: { match: 'string' }
  auth: { schema: auth }
```

You can also pass a function that dynamically returns a schema:

```coffee
dynamic = (parent, value) ->
  if parent.type is 'A'
    { match: 'number' }
  else
    { match: 'string' }

jsm.validate object,
  type:  { match: 'string' }
  value: { schema: dynamic }
```

## Required and optional fields

By default, all fields are assumed to be required.
Fields can be manually marked as optional:

```coffee
jsm.validate object,
  username: { match: 'string' }
  password: { match: 'string', optional: true }
```

Validation will ignore missing optional fields, but will run the matcher if an optional field is present.
E.g. it won't complain if `password` isn't there, but will if `password` is a number.

You could also use optional on a "schema" matcher:

```coffee
account =
  number:  { match 'integer' }
  suburb:  { match 'string'  }

jsm.validate object,
  username: { match: 'string' }
  password: { match: 'string' }
  account:  { schema: account, optional: true }
```

Validation will pass if `account` is missing, but will run the matcher if `account` node is present. E.g. it will complain if you have the `account` node without presenting the `number` or `suburb` leaf under the account node.
