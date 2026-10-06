local parent = script.Parent.Parent
require(parent.Types)
local External = require(parent.External)
local evaluate = require(parent.Graph.evaluate)

local function change(p)
	if p.validity == "busy" then
		return External.logError("infiniteLoop")
	end

	if not evaluate(p, true) then
		return
	end

	local v = os.clock() + 1 * External.safetyTimerMultiplier
	local v2 = { p }
	local v3 = {}
	local v4 = {}

	while not (v < os.clock()) do
		local flag = true

		for _, v5 in v2 do
			for k in v5.dependentSet do
				if k.validity == "valid" then
					table.insert(v3, k)
					table.insert(v4, k)
					flag = false
				elseif k.validity == "busy" then
					return External.logError("infiniteLoop")
				end
			end
		end

		table.clear(v2)

		if flag then
			local v5 = {}

			for _, v6 in v3 do
				v6.validity = "invalid"

				if v6.timeliness == "eager" then
					table.insert(v5, v6)
				end
			end

			table.sort(v5, function(a, b)
				return a.createdAt < b.createdAt
			end)

			for _, v6 in v5 do
				evaluate(v6, false)
			end

			return
		else
			v4, v2 = v2, v4
		end
	end

	return External.logError("infiniteLoop")
end

return change