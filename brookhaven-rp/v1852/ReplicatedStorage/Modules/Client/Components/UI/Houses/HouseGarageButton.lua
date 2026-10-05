local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HouseTelemetry = require(ReplicatedStorage.Modules.Client.Components.UI.Houses.HouseTelemetry)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HouseGarageButton"
})
local _1Player1sHous1e = ReplicatedStorage.RE:WaitForChild("1Player1sHous1e")

local function hasGarageDoor(instance)
	if instance == nil then
		return false
	end

	return (instance:FindFirstChild("001_GarageDoor", true) or instance:FindFirstChild("001_Garage", true) or instance:FindFirstChild(
		"GarageDoors",
		true
	) or instance:FindFirstChild("GarageOpeners", true)) ~= nil
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local Players = game:GetService("Players")
	local localPlayer = Players.LocalPlayer
	local PlayerBagUtil = require(ReplicatedStorage.Modules.Shared.PlayerData.PlayerBagUtil)
	local HouseUtil = require(ReplicatedStorage.Modules.Shared.Game.HouseUtil)
	local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
	local game8Settings = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Player8Handler"):WaitForChild("Game8Settings")
	local module = require(game8Settings)
	local gettingHouse = module.GettingHouse
	local playerBagInstance = PlayerBagUtil.GetPlayerBagInstance(localPlayer, "HouseNumber")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getCurrentLotId()
		return playerBagInstance.Value
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function canUseGarageButton()
		local currentLotId = getCurrentLotId() -- equivalent call inferred; original call site unknown

		if currentLotId <= 0 then
			return false
		end

		local houseType = HouseUtil.GetHouseType(currentLotId)

		if houseType == "Apartment" or houseType == "Motel" then
			return false
		end

		return (hasGarageDoor(LotUtil.GetProperty(currentLotId)))
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateVisibility()
		local instance = self.Instance
		local visible = canUseGarageButton() -- equivalent call inferred; original call site unknown
		instance.Visible = visible
	end

	local instance = self.Instance
	self._Janitor:Add(instance.MouseButton1Click:Connect(function()
		local v2 = canUseGarageButton() -- equivalent call inferred; original call site unknown

		if v2 == false then
			return
		end

		HouseTelemetry.Click(self.Tag)
		_1Player1sHous1e:FireServer("GarageDoor")
	end))
	updateVisibility() -- equivalent call inferred; original call site unknown
	self._Janitor:Add(gettingHouse.OnClientEvent:Connect(function(p: string)
		if p == "LoadingGuiStop" or p == "BuyHouseSetUpUI" or p == "HouseSold" then
			updateVisibility() -- equivalent call inferred; original call site unknown
		end
	end))
	self._Janitor:Add(playerBagInstance.Changed:Connect(updateVisibility))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v