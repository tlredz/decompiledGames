local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HouseVipSignButton"
})
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v2 = nil
local instances = {}

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
	require(ReplicatedStorage.Modules.Client.Components.Housing.PropertyBusinessSign)
	local PropertyRoot = require(ReplicatedStorage.Modules.Shared.Components.Housing.PropertyRoot)
	local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
	local PlayerBagUtil = require(ReplicatedStorage.Modules.Shared.PlayerData.PlayerBagUtil)
	local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
	local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
	local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
	local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
	local Players = game:GetService("Players")
	local localPlayer = Players.LocalPlayer
	local value = PlayerBagUtil.GetPlayerBagInstance(localPlayer, "HouseNumber").Value
	local property = LotUtil.GetProperty(value)
	local propertyBusinessSignComponent = ComponentUtil.FindAndWaitForAncestorComponent(
		property,
		"PropertyRoot",
		PropertyRoot
	):GetPropertyBusinessSignComponent()
	local instance = self.Instance
	local time = instance:GetAttribute("Time") or 1
	local range = instance:GetAttribute("Range") or 1
	local greenCheckMark = instance:FindFirstChild("GreenCheckMark")
	table.insert(instances, instance)
	self._Janitor:Add(instance.MouseButton1Click:Connect(function()
		local function toggle()
			greenCheckMark.Visible = not greenCheckMark.Visible

			for _, v3 in instances do
				if v3 == self.Instance then
					continue
				end

				local greenCheckMark2 = v3:FindFirstChild("GreenCheckMark")

				if greenCheckMark2 then
					greenCheckMark2.Visible = false
				end
			end

			v2 = instance

			if propertyBusinessSignComponent then
				Remotes.fireServerComponent(
					propertyBusinessSignComponent.Instance,
					"PropertyBusinessSign:ToggleVipTextEffect",
					time,
					range
				)
			else
				Remotes.fireServer("Property:ToggleVipTextEffect", time, range)
			end
		end

		if UnlockableController.IsFeatureUnlocked(AdFeatures.VIP_HOUSE_SIGN_EFFECT.id, Gamepasses.VIP) then
			toggle()
		else
			GamepassController.Show(Gamepasses.VIP, nil, "house sign effect", nil, {
				id = AdFeatures.VIP_HOUSE_SIGN_EFFECT.id
			}, nil, "improved-housed-controls", AdFeatures.VIP_HOUSE_SIGN_EFFECT.id, function()
				if self.Instance.Parent == nil then
					return
				end

				if not greenCheckMark.Visible then
					toggle()
				end
			end)
		end
	end))
end

function v:Stop()
	instances = {}
	v2 = nil
	self._Janitor:Destroy()
end

return v