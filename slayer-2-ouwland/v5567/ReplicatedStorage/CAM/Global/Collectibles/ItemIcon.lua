local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FightingStyles = require(ReplicatedStorage.CAM.Global.Collectibles.FightingStyles)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
return {
	For = function(p, p2: string)
		local item = Items[p2]
		local icon = item == nil and "" or item.Icon or ""

		if p2 == FightingStyles.TOOL_NAME then
			local _, v = FightingStyles.For(p)

			if v ~= nil and v.Icon ~= nil then
				icon = v.Icon
			end
		end

		return icon
	end
}