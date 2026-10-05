local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
require(ReplicatedStorage.Datas.Animals)
local Traits = require(ReplicatedStorage.Datas.Traits)
local v = {}

for k in Traits do
	table.insert(v, k)
end

return Conch.register_type("Traits", {
	convert = function(p)
		if typeof(p) == "table" then
			local clone = table.clone(p)

			for k, v2 in clone do
				local v3 = tostring(v2)

				if not Traits[v3] then
					error((`Trait {v3} not found`))
				end

				clone[k] = v3
			end

			return clone
		else
			local v2 = tostring(p)

			if not Traits[v2] then
				error((`Trait {v2} not found`))
			end

			return { v2 }
		end
	end,
	analysis = {
		kind = "argument",
		optional = false,
		name = "traits",
		type = "{ Trait }"
	}
})