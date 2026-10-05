return table.freeze({
	bind = function(p, p2, callback)
		script.Bind:Fire(p, p2, callback)
		return function()
			script.Unbind:Fire(p)
		end
	end
})