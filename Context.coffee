{EventEmitter} = require '@coffee-toolbox/eventemitter'

# @parent is a Context whose cancellation cancels this context.
# the constructor should not be called directly, use .background()
# .withValue(), .withCancel() or .withTimeout().
# the Context is a Promise-like value, passing a cancellation reason
# to the function passed to .whenCancelled, and has a .whenThrown to
# deal with exceptions.
class Context
	constructor: (@parent)->
		undefined

	whenCancelled: (f)->
		@p.then f

	whenThrown: (f)->
		@p.catch f

	@CANCELLED: 'context cancelled'
	@TIMEOUTED: 'context timeouted'

	# reason: (reason: string) -> string
	@reason: (reason)->
		"context cancelled: #{reason}"

	# -> Context
	# An empty Context used as the top-level context.
	@background: ->
		ctx = new Context {}
		ctx.value = Object.freeze {}
		# a promise that never settles.
		ctx.p = new Promise ->
			undefined
		ctx

	# Create a new Context that wrapping an object into the @parent
	# This new Context cancels when parent cancelled.
	# Parent context's value is extended by `value`.
	# Note that .value is frozen to prevent mutation.
	# (parent: Context, value: Object) -> Context
	@withValue: (parent, value)->
		console.assert parent instanceof Context
		console.assert value instanceof Object
		ctx = new Context parent
		ctx.value = Object.assign {}, parent.value, value
		ctx.value = Object.freeze ctx.value
		ctx.p = parent.p

		ctx

	# Create a new cancellable Context.
	# Returns the new context and its cancellation function.
	# if no `reason` passed to the `cancel` function, default value
	# Context.CANCELLED is used.
	# (parent: Context) -> [ctx: Context, cancel: (reason: string?) -> string]
	@withCancel: (parent)->
		console.assert parent instanceof Context
		ctx = new Context parent
		ctx.value = parent.value
		pc = new Promise (res)->
			ctx.$e = new EventEmitter()
			ctx.$e.once 'cancel', (reason)->
				if reason?
					res reason
				else
					res Context.CANCELLED

		pp = parent.p

		ctx.p = Promise.race [pp, pc]
		cancel = (reason)->
			ctx.$e.emit 'cancel', reason

		[ctx, cancel]

	# Create a new cancellable Context that automatically cancel itself
	# when timeouted.
	# Returns the new context and its cancellation function.
	# if no `reason` passed to the `cancel` function, default value
	# Context.CANCELLED is used.
	# If it is timeouted, Context.TIMEOUTED is passed to thened function.
	# (parent: Context)-> [ctx: Context, cancel: function]
	@withTimeout: (parent, timeout)->
		console.assert parent instanceof Context
		console.assert timeout >= 0
		ctx = new Context parent
		ctx.value = parent.value
		pc = new Promise (res)->
			ctx.$e = new EventEmitter()
			ctx.$e.once 'cancel', (reason)->
				if reason?
					res reason
				else
					res Context.CANCELLED
		pt = new Promise (res)->
			ctx.$e.once 'timeout', ->
				res Context.TIMEOUTED
		id = setTimeout ->
			ctx.$e.emit 'timeout'
		, timeout

		pp = parent.p

		ctx.p = Promise.race [pp, pc, pt]
		cancel = (reason)->
			clearTimeout id
			ctx.$e.emit 'cancel', reason

		[ctx, cancel]

module.exports =
	Context: Context
