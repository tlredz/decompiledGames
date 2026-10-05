local v = nil
local Icon = require(game.ReplicatedStorage.Modules.Icon)
return {
	Btn = 1,
	SortOrder = 4,
	Val = "Region",
	Desc = "View the current server's location",
	Callback = function(p)
		if p == true and not v then
			v = Icon.new()
			v:lock()
			v:setRight()
			workspace:GetAttributeChangedSignal("ServerRegion"):Connect(function()
				v:setLabel(workspace:GetAttribute("ServerRegion"))
			end)
			v:setLabel(workspace:GetAttribute("ServerRegion"))
		elseif p == false and v then
			v:destroy()
			v = nil
		end
	end
}