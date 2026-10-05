local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local BossPortalData = require(ReplicatedStorage.Shared.BossPortalData)
local Utils = require(ReplicatedStorage.Common.Utils)
return Observers.observeTagNoAncestry("BossFightExpiresTime", function(instance)
	local billboardGui = instance:FindFirstAncestorWhichIsA("BillboardGui")
	local connection = Utils.Thread.Every(1, function()
		local v = Utils.FFlag.GetFFlag((`{BossPortalData.Name}BossEndTime`)) or 0
		instance.Text = Utils.ValueConvertor:FormatTimeWithDaysFull((math.max(0, v - workspace:GetServerTimeNow())))

		if billboardGui then
			billboardGui.Enabled = v > 0
		end
	end)
	return function()
		connection:Disconnect()
	end
end)