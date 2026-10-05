local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local HouseUtil = require(ReplicatedStorage.Modules.Shared.Game.HouseUtil)
local PlayerBagUtil = require(ReplicatedStorage.Modules.Shared.PlayerData.PlayerBagUtil)
local v = Component.new({
	Tag = "HouseCamsTitleLabel"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local playerBagInstance = PlayerBagUtil.GetPlayerBagInstance(Players.LocalPlayer, "HouseNumber")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateTitle()
		local houseType = HouseUtil.GetHouseType(playerBagInstance.Value)
		self.Instance.Text = houseType == "Landmark" and "Landmark Security Cams" or "House Security Cams"
	end

	updateTitle() -- equivalent call inferred; original call site unknown
	self._Janitor:Add(playerBagInstance.Changed:Connect(updateTitle))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v