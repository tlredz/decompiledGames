local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HouseTeleportHome"
})
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local ZipLineConstants = require(ReplicatedStorage.Modules.Shared.World.ZipLineConstants)
require(ReplicatedStorage.Modules.Client.Components.UI.Panels.House.HouseMenu)
require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)

function v:Construct()
	self._Janitor = Janitor.new()
	game.Workspace:WaitForChild("WorkspaceCom"):WaitForChild("001_MapHouseTeleports")
	game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Player8Handler"):WaitForChild("PlaneShaker")
end

function v.Start(p)
	p.Instance.Activated:Connect(function()
		local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")

		if not humanoid then
			return
		end

		if humanoid and humanoid.SeatPart then
			NotificationController.Notify("You are in a seat, please stand up to teleport home")
			return
		end

		local localPlayer = Players.LocalPlayer

		if localPlayer:HasTag(ZipLineConstants.HANDLE_TAG) then
			NotificationController.Notify("You are on a zip line, please dismount to teleport home")
			return
		end

		PanelController.Close("MainGUIHandler", "MainHouseMenu")
		local _001_MapHouseTeleports = game.Workspace.WorkspaceCom["001_MapHouseTeleports"]
		local planeShaker = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Player8Handler"):WaitForChild("PlaneShaker")
		local _001_MapHouseTeleport = _001_MapHouseTeleports["House" .. localPlayer.PlayersBag:FindFirstChild("HouseNumber").Value]
		local value = _001_MapHouseTeleport.Angle.Value

		if _001_MapHouseTeleport ~= nil and localPlayer ~= nil and localPlayer.Character ~= nil and humanoid.Sit == false and planeShaker.Disabled == true and localPlayer.Character:FindFirstChild("LeftHand") ~= nil then
			local leftHand = localPlayer.Character:FindFirstChild("LeftHand")

			if localPlayer.Character:FindFirstChild("UpperTorso") and not leftHand:FindFirstChild("HandFire") then
				localPlayer.Character.UpperTorso.CFrame = CFrame.new(_001_MapHouseTeleport.Position + createVector(
					0,
					4,
					0
				)) * CFrame.Angles(0, value, 0)
			end
		end
	end)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v