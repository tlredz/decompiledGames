local ReplicatedStorage = game:GetService("ReplicatedStorage")
local cardModifiers = workspace.Info.CardModifiers
local PartyCrashers = {}
PartyCrashers.Name = "Party Crashers"
PartyCrashers.Icon = "rbxassetid://114505539574752"
PartyCrashers.Description = "Decreases the chance of a Haunted Gala floor occurring."

function PartyCrashers.CanAppearInVote()
	local success, result = pcall(function()
		local HolidayEventConfig = require(ReplicatedStorage.SharedData.HolidayEventConfig)
		return HolidayEventConfig.ENABLED and (HolidayEventConfig.ContentFlag == "Halloween" or HolidayEventConfig.CURRENT_EVENT:match("Halloween"))
	end)
	return success and result
end

function PartyCrashers.ApplyCardEffects()
	if not cardModifiers:FindFirstChild(script.Name) then
		local numberValue = Instance.new("NumberValue")
		numberValue.Name = script.Name
		numberValue.Value = 0.9
		numberValue.Parent = cardModifiers
	end
end

return PartyCrashers