local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Net = require(ReplicatedStorage.Packages.Net)
local UniverseIds = require(ReplicatedStorage.Shared.UniverseIds)
local ServerInfo = require(ReplicatedStorage.ServerInfo)
local Utils = require(ReplicatedStorage.Common.Utils)
local Replion = require(ReplicatedStorage.Packages.Replion)
local Trove = require(ReplicatedStorage.Packages.Trove)
local NotificationController = require(ReplicatedStorage.Controllers.NotificationController)
require("@game/ReplicatedStorage/Types/Templates/Lobbies")
local localPlayer = Players.LocalPlayer
local remoteEvent = Net:RemoteEvent("PlaceTeleport")
local v = ServerInfo.isProTradingPlazaServer() and "TradingPlaza" or "ProTradingPlaza"
return Observers.observeTagNoAncestry("ProTradePlazaPortal", function(instance)
	local maid = Trove.new()
	task.spawn(function()
		local prompt = instance:WaitForChild("Prompt", 60)
		local proximityPrompt = prompt and prompt:WaitForChild("ProximityPrompt", 60)

		if not proximityPrompt then
			return
		end

		maid:Add(proximityPrompt.Triggered:Connect(function()
			proximityPrompt.Enabled = false
			task.delay(2, function()
				proximityPrompt.Enabled = true
			end)

			if v == "ProTradingPlaza" and not UniverseIds.ProTradingPlaza.Accessible(localPlayer) then
				NotificationController:SendNotification((`You need {Utils.ValueConvertor:ShrinkNumber(50000)} RAP to join the Pro Trade Plaza!`))
			else
				remoteEvent:FireServer(v)
			end
		end))
		local center = instance:WaitForChild("Center", 60)
		local proTradePlaza = center and center:WaitForChild("ProTradePlaza", 60)

		if not proTradePlaza then
			return
		end

		local function updateLock()
			local visible = not UniverseIds[v].Accessible(localPlayer)
			proTradePlaza.Frame.LockedOverlay.Visible = visible
			proTradePlaza.Frame.LockIcon.Visible = visible
			proTradePlaza.Frame.LockedOverlay.Requirement.Text = `{Utils.ValueConvertor:ShrinkNumber(50000)} RAP REQUIRED`
			local v3 = v == "ProTradingPlaza" and "Pro Trade Plaza" or "Normal Trade Plaza"
			proTradePlaza.Frame.Title.Text = v3
			proximityPrompt.ObjectText = v3
			proximityPrompt.Enabled = not visible
		end

		if v == "ProTradingPlaza" then
			maid:Add(localPlayer:GetAttributeChangedSignal("TotalRAP"):Connect(updateLock))
			maid:Add(Replion.Client:WaitReplion("Inventory"):OnChange("Tokens", updateLock))
		end

		updateLock()
	end)
	return function()
		maid:Destroy()
	end
end)