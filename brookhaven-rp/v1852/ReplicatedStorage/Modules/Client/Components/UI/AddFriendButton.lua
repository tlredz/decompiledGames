local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local FriendController = require(ReplicatedStorage.Modules.Client.Telemetry.FriendController)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local RobloxFriendsUtil = require(ReplicatedStorage.Modules.Shared.Utils.RobloxFriendsUtil)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "AddFriendButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:SetTargetPlayerId(targetPlayerId: number?)
	self.TargetPlayerId = targetPlayerId
end

function v:Start()
	if self.Instance:IsA("TextButton") or self.Instance:IsA("ImageButton") then
		self._Janitor:Add(self.Instance.Activated:Connect(function()
			if self.TargetPlayerId == nil then
				return
			end

			local playerByUserId = Players:GetPlayerByUserId(self.TargetPlayerId)

			if playerByUserId == nil or playerByUserId == Players.LocalPlayer then
				return
			end

			TelemetryController.SendClientInteraction("sendFriendRequest", {
				trigger = self.Instance:GetAttribute("Trigger"),
				receiverID = self.TargetPlayerId
			})
			FriendController.AddFriendRequest(self.TargetPlayerId, "gifting")
			RobloxFriendsUtil.sendFriendRequest(playerByUserId)
		end))
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v