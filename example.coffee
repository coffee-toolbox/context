{Context} = require './Context'

doAdd = (pctx, value, timeout)->
	[ctx, cancel] = Context.withTimeout pctx, timeout
	slowAdd ctx.value.input, value
	.then (v)->
		cancel()
		console.log v
	ctx.then (v)->
		console.log v

slowAdd = (a, b)->
	new Promise (res)->
		setTimeout ->
			res a + b
		, 1000

ctx = Context.withValue Context.background(), {input: 1}
doAdd ctx, 1, 500
doAdd ctx, 2, 1500
