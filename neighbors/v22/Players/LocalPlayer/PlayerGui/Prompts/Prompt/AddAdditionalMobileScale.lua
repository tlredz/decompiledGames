local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UI = require(ReplicatedStorage.Modules.UI)
local parent = script.Parent
local v = {
	parent.AdultServer,
	parent.AgeCheckPrompt,
	parent.CustomServerJoin,
	parent.DailyRewardRestore,
	parent.DrawingClear,
	parent.OpenWorld,
	parent.UGCDisclaimer,
	parent.DeleteComment,
	parent.ConfirmationPrompt
}

if UI:GetDeviceType() == "Mobile" or UI:GetDeviceType() == "Tablet" then
	for _, parent2 in next, v, nil do
		local uIScale = parent2:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
		uIScale.Parent = parent2
		UI:RegisterConstantUIScale(uIScale, {
			PC = 1,
			Mobile = 1.5,
			Tablet = 1.3
		})
	end
end