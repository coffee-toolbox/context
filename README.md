# Context
A golang Context-like in coffeescript

### NOTE
Do NOT download from npm!

Just add the dependency that use https git repo url as a version.

    "@coffee-toolbox/context": "https://github.com/coffee-toolbox/context.git"

npm is evil that it limit the publish of more than one project.
And its restriction on version number is terrible for fast development that
require local reference. (npm link sucks!)
[why npm link sucks](https://github.com/webpack/webpack/issues/554)

It ruined my productivity for a whole three days!

For any one who values his life, please be away from npm.

----

## Introduction

Golang Context provide a hierachical way to carry timeout signal cancellation
signal and scoped values. Parent values and signals passed down to children.

## Usage:

```coffeescript
Context.CANCELLED: string
# Default value for cancel function

Context.TIMEOUTED: string
# Default value for timeouted signal

Context.reason (string) -> string
# Make value for customized cancellation reason

Context.background: -> Context
# An empty Context used as the top-level context.

Context.withValue: (parent: Context, value: Object) -> Context
# Create a new Context that wrapping an object into the @parent
# This new Context cancels when parent cancelled.
# Parent context's value is extended by `value`.
# Note that .value is frozen to prevent mutation.

Context.withCancel: (parent: Context) -> [ctx: Context, cancel: (reason: string?) ->]
# Create a new cancellable Context.
# Returns the new context and its cancellation function.
# if no `reason` passed to the `cancel` function, default value
# Context.CANCELLED is used.

Context.withTimeout: (parent: Context) -> [ctx: Context, cancel: (reason: string?) ->]
# Create a new cancellable Context that automatically cancel itself
# when timeouted.
# Returns the new context and its cancellation function.
# if no `reason` passed to the `cancel` function, default value
# Context.CANCELLED is used.
# If it is timeouted, Context.TIMEOUTED is passed to thened function.

# Context provide a Promise-like interface to handle its cancellation signals.
.whenCancelled: (f: (reason: string)-> any) -> Promise
# Pass a function that handles the cancellation signal

.whenThrown: (f: (error: thrown)-> any) -> Promise
# Pass a function that handles exceptions.

# Remind to call cancel() when the Context is done. Repeated calling of cancel()
# would do nothing.
```
## Example
```coffeescript
{Context} = require '@coffee-toolbox/context'

doAdd = (pctx, value, timeout)->
	[ctx, cancel] = Context.withTimeout pctx, timeout
	slowAdd ctx.value.input, value
	.then (v)->
		cancel()
		console.log v
	ctx.whenCancelled (v)->
		console.log v

slowAdd = (a, b)->
	new Promise (res)->
		setTimeout ->
			res a + b
		, 1000

ctx = Context.withValue Context.background(), {input: 1}
doAdd ctx, 1, 500
doAdd ctx, 2, 1500
###
context timeouted
2
3
context cancelled
###
```
