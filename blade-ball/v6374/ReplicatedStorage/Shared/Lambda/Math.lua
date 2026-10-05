local v = {}
local Record = require(script.Parent.Record)

function v.add(p: number, p2: number)
	return p + p2
end

function v.mult(p: number, p2: number)
	return p * p2
end

local self = setmetatable({}, {
	__index = function(_, p)
		local v2 = v[p]

		if not v2 then
			error("Attempt to call nil value")
		end

		return function(...)
			local v3 = {}
			local v4 = {}

			for k, v5 in next, { ... }, nil do
				local v6 = Record.Update(v5, (`Passed into Math.{p}`))
				v3[k] = v6
				v4[k] = Record.Evaluate(v6)
			end

			local v5 = { v2(unpack(v4)) }
			local v6 = {}

			for k, v7 in next, v5, nil do
				local v8 = v3[k]
				v6[k] = v8.status == Record.Invalid and v8 or #v8.logs > 1 and Record.Update(
					v7,
					(`Returned from Math.{p}`)
				) or Record.Evaluate(v7)
			end
		end
	end
})
local Merge = require(script.Parent.Merge)
v = Merge(math, v)
return self