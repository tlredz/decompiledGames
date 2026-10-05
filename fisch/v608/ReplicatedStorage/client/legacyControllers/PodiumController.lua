local ReplicatedStorage = game:GetService("ReplicatedStorage")
local components = ReplicatedStorage:WaitForChild("client").components
local Podium = require(components.Podium)
return {
	IsEnabled = function(_, p)
		local v = typeof(p) ~= "table" and { p } or p
		local v2 = false

		for _, v3 in Podium:GetAll() do
			if not table.find(v, v3.Name) then
				continue
			end

			if v3.Placed ~= true then
				return false
			end

			v2 = true
		end

		return v2
	end
}