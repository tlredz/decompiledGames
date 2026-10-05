local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FFlagClient = require(ReplicatedStorage.ClientGameModules.FFlagClient)
local DuoPassController = require(ReplicatedStorage.Controllers.UI.DuoPassController)
local DuoPassData = require(ReplicatedStorage.Shared.DuoPassData)
local Observers = require(ReplicatedStorage.Packages.Observers)
return Observers.observeTagNoAncestry("DuoPassNPC", function(instance)
	if not instance:HasTag("UIPromptNPC") then
		warn((`DuoPassNPC tag should be used with UIPromptNPC! {instance:GetFullName()}`))
		return
	end

	local function updateEndTime()
		local v

		if FFlagClient:IsDataReady() then
			v = FFlagClient:GetKey(DuoPassData.GetFFlagKey("EndTime"))
		end

		instance:SetAttribute("EndTime", DuoPassController.IsEnabled and v or 0)
	end

	local enabledSignalConnection = DuoPassController.EnabledSignal:Connect(updateEndTime)
	task.spawn(updateEndTime)
	return function()
		enabledSignalConnection:Disconnect()
		instance:SetAttribute("EndTime", nil)
	end
end)