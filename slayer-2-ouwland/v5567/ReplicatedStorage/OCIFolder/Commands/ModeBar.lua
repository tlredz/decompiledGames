local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
return {
	Clearance = 1,
	Keys = {
		{
			Type = "Players",
			Required = true
		}
	},
	Server = function(_, list)
		for _, v in ipairs(list) do
			local getvaluesfolder = Utility.getvaluesfolder(v)
			local modeBar

			if getvaluesfolder ~= nil then
				modeBar = getvaluesfolder:FindFirstChild("ModeBar") or nil
			end

			if modeBar ~= nil then
				modeBar.Value = modeBar.MaxValue
			end
		end
	end
}