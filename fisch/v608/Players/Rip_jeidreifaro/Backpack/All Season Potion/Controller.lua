local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local DataController = require(legacyControllers.DataController)
local SkinCrateController = require(legacyControllers:WaitForChild("SkinCrateController"))
local parent = script.Parent
parent.Activated:Connect(function()
	SkinCrateController:SetupSpin(DataController.getItemFromLink(parent).sub.Type)
end)
parent.Unequipped:Connect(function()
	SkinCrateController:HideSpin()
end)