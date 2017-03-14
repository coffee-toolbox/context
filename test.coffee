{Context} = require './Context'

a = Context.withValue Context.background(), {a: 1}

[b, cancel] = Context.withCancel a
b.whenCancelled (v)->
	console.log 'b exit', v

[c, cancel_c] = Context.withTimeout b, 1000
c.whenCancelled (v)->
	console.log 'c exit', v

[d, cancel_d] = Context.withTimeout c, 2000
d.whenCancelled (v)->
	cancel(Context.reason 'test')
	console.log 'd exit', v

e = Context.withValue b, {a: 2}
e.whenCancelled (v)->
	console.log 'e exit', v

console.log e
