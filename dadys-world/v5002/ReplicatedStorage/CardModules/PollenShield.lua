local ReplicatedStorage = game:GetService("ReplicatedStorage")
local cardModifiers = workspace.Info.CardModifiers
local PollenShield = {}
PollenShield.Name = "Air Freshener"
PollenShield.Icon = "rbxassetid://140473871512049"
PollenShield.Description = "Decreases the chance of a Spring Fever floor occurring."

function PollenShield.CanAppearInVote()
	local success, result = pcall(function()
		local HolidayEventConfig = require(ReplicatedStorage.SharedData.HolidayEventConfig)
		return HolidayEventConfig.ENABLED and (HolidayEventConfig.ContentFlag == "Easter" or HolidayEventConfig.CURRENT_EVENT:match("Easter"))
	end)
	return success and result
end

function PollenShield.ApplyCardEffects()
	if not cardModifiers:FindFirstChild(script.Name) then
		local numberValue = Instance.new("NumberValue")
		numberValue.Name = script.Name
		numberValue.Value = 0.9
		numberValue.Parent = cardModifiers
	end
end

return PollenShield