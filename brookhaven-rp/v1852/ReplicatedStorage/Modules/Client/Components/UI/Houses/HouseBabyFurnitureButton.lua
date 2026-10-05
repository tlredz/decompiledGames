local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HouseBabyFurnitureButton"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function hasBabyButton(instance)
	if instance:HasTag("PropertyBaby") then
		return true
	end

	local _001_HouseControlGuiOpen = instance:FindFirstChild("001_HouseControlGuiOpen", true)
	return not (_001_HouseControlGuiOpen and not _001_HouseControlGuiOpen:FindFirstChild("BabyButton"))
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local Players = game:GetService("Players")
	local localPlayer = Players.LocalPlayer
	local PlayerBagUtil = require(ReplicatedStorage.Modules.Shared.PlayerData.PlayerBagUtil)
	local HouseUtil = require(ReplicatedStorage.Modules.Shared.Game.HouseUtil)
	local HouseTelemetry = require(ReplicatedStorage.Modules.Client.Components.UI.Houses.HouseTelemetry)
	local LegacyGame8Settings = require(ReplicatedStorage.Modules.Client.UI.LegacyGame8Settings)
	local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
	local gettingHouse = LegacyGame8Settings.GettingHouse
	local value = PlayerBagUtil.GetPlayerBagInstance(localPlayer, "HouseNumber").Value

	if HouseUtil.GetHouseType(value) == "Motel" then
		self.Instance.Visible = false
		return
	end

	local property = LotUtil.GetProperty(value)

	if not property then
		warn("Property not found")
		return
	end

	local instance = self.Instance
	self._Janitor:Add(instance.MouseButton1Click:Connect(function()
		HouseTelemetry.Click(self.Tag)

		if instance.GreenCheckMark.Visible then
			LegacyGame8Settings.PlayersHouse:FireServer("BabyOptionNo")
			instance.GreenCheckMark.Visible = false
		else
			LegacyGame8Settings.PlayersHouse:FireServer("BabyOptionYes")
			instance.GreenCheckMark.Visible = true
		end
	end))
	local propertyRoot = LotUtil.GetPropertyRoot(value)
	self._Janitor:Add(property.ChildAdded:Connect(function(child)
		if propertyRoot:GetDisplayName() == child.Name then
			instance.GreenCheckMark.Visible = true
		end
	end))
	self._Janitor:Add(property.ChildRemoved:Connect(function(child)
		if propertyRoot:GetDisplayName() == child.Name then
			instance.GreenCheckMark.Visible = false
		end
	end))
	local instance2 = self.Instance
	local babyButton = hasBabyButton(property) -- equivalent call inferred; original call site unknown
	instance2.Visible = babyButton
	self._Janitor:Add(gettingHouse.OnClientEvent:Connect(function(p: string)
		if p == "LoadingGuiStop" then
			local instance3 = self.Instance
			local babyButton2 = hasBabyButton(property) -- equivalent call inferred; original call site unknown
			instance3.Visible = babyButton2
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v