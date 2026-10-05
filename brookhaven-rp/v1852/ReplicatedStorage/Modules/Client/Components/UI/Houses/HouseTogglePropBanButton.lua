local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HouseTogglePropBanButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
	local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
	local houseNumber = game.Players.LocalPlayer.PlayersBag:FindFirstChild("HouseNumber")
	local propertyPermissions = LotUtil.GetPropertyPermissions(houseNumber.Value)
	self.isBlocked = propertyPermissions:IsPropPlacementBlockedForOthers()
	self.Instance.EnabledIcon.Visible = not self.isBlocked
	self.Instance.DisabledIcon.Visible = self.isBlocked
	local instance = self.Instance
	self._Janitor:Add(instance.MouseButton1Click:Connect(function()
		self.isBlocked = propertyPermissions:TrySetPropPlacementBlockedForOthers(not self.isBlocked)
		self.Instance.EnabledIcon.Visible = not self.isBlocked
		self.Instance.DisabledIcon.Visible = self.isBlocked
		NotificationController.Notify("Prop placement " .. (self.isBlocked and "disabled ❌ " or "enabled ✅ "))
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v