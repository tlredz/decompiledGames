local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FFlagClient = require(ReplicatedStorage.ClientGameModules.FFlagClient)
local TrioPassController = require(ReplicatedStorage.Controllers.UI.TrioPassController)
local Observers = require(ReplicatedStorage.Packages.Observers)
return Observers.observeTagNoAncestry("TrioPassNPC", function(instance)
	if not instance:HasTag("UIPromptNPC") then
		warn((`DuoPassNPC tag should be used with UIPromptNPC! {instance:GetFullName()}`))
		return
	end

	local function updateEndTime()
		local v

		if FFlagClient:IsDataReady() then
			v = FFlagClient:GetKey("SilentVeilTrioPassEndTime")
		end

		instance:SetAttribute("EndTime", TrioPassController.IsEnabled and v or 0)
	end

	local enabledSignalConnection = TrioPassController.EnabledSignal:Connect(updateEndTime)
	task.spawn(updateEndTime)
	return function()
		enabledSignalConnection:Disconnect()
		instance:SetAttribute("EndTime", nil)
	end
end)