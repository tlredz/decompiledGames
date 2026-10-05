local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.Common.Utils)
local HourlyWheelController = require(ReplicatedStorage.Controllers.HourlyWheelController)
return Observers.observeTagNoAncestry("HourlyWheelSpinRewardIn", function(p)
	local rewardTextChangedConnection = HourlyWheelController.RewardTextChanged:Connect(function(text)
		p.Text = text
	end)
	return function()
		rewardTextChangedConnection:Disconnect()
	end
end)