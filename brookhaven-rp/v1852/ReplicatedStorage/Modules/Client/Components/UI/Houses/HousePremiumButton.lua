local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HouseTelemetry = require(ReplicatedStorage.Modules.Client.Components.UI.Houses.HouseTelemetry)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HousePremiumButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local Players = game:GetService("Players")
	local localPlayer = Players.LocalPlayer
	local game8Settings = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Player8Handler"):WaitForChild("Game8Settings")
	local module = require(game8Settings)
	local playersHouse = module.PlayersHouse
	local PlayerBagUtil = require(ReplicatedStorage.Modules.Shared.PlayerData.PlayerBagUtil)
	local HouseUtil = require(ReplicatedStorage.Modules.Shared.Game.HouseUtil)
	local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
	local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
	local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
	local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
	local gettingHouse = module.GettingHouse
	local value = PlayerBagUtil.GetPlayerBagInstance(localPlayer, "HouseNumber").Value
	local houseType = HouseUtil.GetHouseType(value)

	if houseType == "Apartment" or houseType == "Motel" then
		self.Instance.Visible = false
		return
	end

	local property = LotUtil.GetProperty(value)

	if not property then
		warn("Property not found")
		return
	end

	local instance = self.Instance
	self.checkmark = self.Instance:FindFirstChild("GreenCheckMark")
	local v2 = false
	local maid = Janitor.new()
	self._Janitor:Add(maid)

	local function bindPool(_001_PoolAdd)
		maid:Cleanup()

		if _001_PoolAdd == nil then
			self.checkmark.Visible = false
			return
		end

		v2 = _001_PoolAdd:GetAttribute("Free") == true

		if v2 then
			self.Instance.Icon.Visible = false
			self.Instance.IconFree.Visible = true
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function syncCheckmark()
			self.checkmark.Visible = _001_PoolAdd:GetAttribute("IsOpen") == true
		end

		if _001_PoolAdd:GetAttribute("IsOpen") ~= nil then
			syncCheckmark() -- equivalent call inferred; original call site unknown
		end

		maid:Add(_001_PoolAdd:GetAttributeChangedSignal("IsOpen"):Connect(syncCheckmark))
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function refreshPool()
		local _001_PoolAdd = property:FindFirstChild("001_PoolAdd", true)
		local visible

		if _001_PoolAdd == nil then
			visible = false
		else
			visible = _001_PoolAdd:FindFirstChild("PoolCover") ~= nil
		end

		self.Instance.Visible = visible

		if not visible then
			_001_PoolAdd = nil
		end

		bindPool(_001_PoolAdd)
	end

	self._Janitor:Add(instance.MouseButton1Click:Connect(function()
		HouseTelemetry.Click(self.Tag)

		if v2 or UnlockableController.IsFeatureUnlocked("HousePool", Gamepasses.PREMIUM) then
			playersHouse:FireServer("PoolOnOff")
		else
			GamepassController.Show(Gamepasses.PREMIUM, nil, "house sign effect", nil, {
				id = "HousePool"
			}, nil, "improved-housed-controls", "HousePool", function()
				if self.Instance.Parent == nil or property.Parent == nil then
					return
				end

				playersHouse:FireServer("PoolOnOff", true)
			end)
		end
	end))
	self._Janitor:Add(playersHouse.OnClientEvent:Connect(function(p: string)
		if p == "PoolOn" then
			self.checkmark.Visible = true
		elseif p == "PoolOff" then
			self.checkmark.Visible = false
		end
	end))
	local _001_PoolAdd = property:FindFirstChild("001_PoolAdd", true)
	local visible2

	if _001_PoolAdd == nil then
		visible2 = false
	else
		visible2 = _001_PoolAdd:FindFirstChild("PoolCover") ~= nil
	end

	self.Instance.Visible = visible2

	if not visible2 then
		_001_PoolAdd = nil
	end

	bindPool(_001_PoolAdd)
	self._Janitor:Add(gettingHouse.OnClientEvent:Connect(function(p: string)
		if p == "LoadingGuiStop" then
			if not self.skippedFirstRequest then
				self.skippedFirstRequest = true
				return
			end

			refreshPool() -- equivalent call inferred; original call site unknown
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v