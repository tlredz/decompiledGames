local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HouseThemeButton"
})
local Players = game:GetService("Players")
local HouseTelemetry = require(ReplicatedStorage.Modules.Client.Components.UI.Houses.HouseTelemetry)
local localPlayer = Players.LocalPlayer
local PlayerBagUtil = require(ReplicatedStorage.Modules.Shared.PlayerData.PlayerBagUtil)
local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local value = PlayerBagUtil.GetPlayerBagInstance(localPlayer, "HouseNumber").Value
	local propertyRoot = LotUtil.GetPropertyRoot(value)

	if not propertyRoot then
		warn("Property root not found")
		return
	end

	local activeTheme = propertyRoot.Instance:FindFirstChild("ActiveTheme")

	if activeTheme and activeTheme:IsA("StringValue") then
		self.Instance:AddTag("Checked")
		self.Instance.Visible = true
		local flag = false
		self._Janitor:Add(self.Instance.Activated:Connect(function()
			if flag then
				return
			end

			flag = true
			task.delay(2, function()
				flag = false
			end)
			HouseTelemetry.Click(self.Tag)

			if self.Instance:HasTag("Checked") then
				self.Instance:RemoveTag("Checked")
				propertyRoot:ToggleActiveTheme(false)
			else
				self.Instance:AddTag("Checked")
				propertyRoot:ToggleActiveTheme(true)
			end
		end))
	else
		self.Instance:RemoveTag("Checked")
		self.Instance.Visible = false
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v