{Context} = require './Context'

a = Context.withValue Context.background(), {a: 1}

[b, cancel] = Context.withCancel a
b.then (v)->
	console.log 'b exit', v

[c, cancel_c] = Context.withTimeout b, 1000
c.then (v)->
	console.log 'c exit', v

[d, cancel_d] = Context.withTimeout c, 2000
d.then (v)->
	cancel(Context.reason 'test')
	console.log 'd exit', v

e = Context.withValue b, {a: 2}
e.then (v)->
	console.log 'e exit', v

console.log e
