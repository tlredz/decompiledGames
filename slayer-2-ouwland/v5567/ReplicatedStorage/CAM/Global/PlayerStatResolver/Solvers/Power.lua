local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local Breathings = require(ReplicatedStorage.CAM.Global.Powers.Breathings)
local DemonArts = require(ReplicatedStorage.CAM.Global.Powers.DemonArts)
return function(p, p2: string)
	local total = 0

	for _, v in Character_info_provider.GetEquippedPowers(p) do
		local v2 = Breathings[v] or DemonArts[v]
		local v3

		if not (v2 == nil or v2.Stats == nil) then
			v3 = v2.Stats[p2] or nil
		end

		if v3 == true then
			return true
		end

		if typeof(v3) == "number" then
			total += v3
		end
	end

	return total
end