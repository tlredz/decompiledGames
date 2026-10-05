local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local v = Component.new({
	Tag = "VehicleBaby",
	Extensions = { OnlyRunOnPlayerHotbar }
})

function v:Construct()
	self._Janitor = Janitor.new()
	local instance = self.Instance
	local mouse = localPlayer:GetMouse()
	local handle = instance:FindFirstChild("Handle")
	self._Janitor:Add(instance.Activated:Connect(function()
		if mouse.Target ~= nil and mouse.Target:FindFirstChild("ClickDetector") ~= nil and mouse.Target:FindFirstChild("CarSeatTool") ~= nil and (handle.Position - mouse.Target.Position).Magnitude <= mouse.Target.ClickDetector.MaxActivationDistance then
			VehicleController.PutBabyInVehicle()
		end
	end))
end

function v.Start(_) end

function v:Stop()
	self._Janitor:Destroy()
end

return v