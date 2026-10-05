require(script.Parent.types)
local Builder = {}

function Builder.remote(...)
	local metadata = {
		parameters = { ... },
		returns = {},
		middleware = {},
		unreliable = false
	}
	local v2 = {
		type = "event",
		metadata = metadata
	}

	function v2.returns(...)
		v2.type = "function"
		metadata.returns = { ... }
		return v2
	end

	function v2.middleware(...)
		for i = 1, select("#", ...) do
			table.insert(metadata.middleware, (select(i, ...)))
		end

		return v2
	end

	function v2.unreliable()
		metadata.unreliable = true
		return v2
	end

	return v2
end

function Builder.namespace(remotes)
	return {
		type = "namespace",
		remotes = remotes
	}
end

return Builder