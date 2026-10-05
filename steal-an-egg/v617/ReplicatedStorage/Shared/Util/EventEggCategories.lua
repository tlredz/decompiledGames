local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdminAbuseEgg = require(ReplicatedStorage.Data.AdminAbuseEgg)
local DragonEgg = require(ReplicatedStorage.Data.DragonEgg)
local v = { AdminAbuseEgg, DragonEgg }
return table.freeze({
	IsEventEgg = function(p: string?)
		local v2 = false

		for _, v3 in v do
			if v2 then
				continue
			end

			if p == nil then
				v2 = false
			else
				v2 = v3.IsEventCategory(p)
			end
		end

		return v2
	end
})