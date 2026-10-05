local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage2:WaitForChild("UserInputService"))
local Observers = require(ReplicatedStorage.Packages.Observers)
local FFlagClient = require(ReplicatedStorage.ClientGameModules.FFlagClient)
return Observers.observeTagNoAncestry("FFlagVisibility", function(instance)
	local fFlagKey = instance:GetAttribute("FFlagKey")

	if not fFlagKey then
		warn((`"FFlagKey" Attribute not found for {instance:GetFullName()}`))
		return nil
	end

	local function onUpdate()
		local v = FFlagClient:IsDataReady() and FFlagClient:GetKey(fFlagKey) == true

		if instance:IsA("LayerCollector") then
			instance.Enabled = v
		elseif instance:IsA("GuiObject") then
			instance.Visible = v
		end
	end

	local dataUpdatedEventConnection = FFlagClient.DataUpdatedEvent:Connect(onUpdate)
	task.spawn(onUpdate)
	return function()
		dataUpdatedEventConnection:Destroy()
	end
end)