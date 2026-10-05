local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local ShopController = require(Players.LocalPlayer.PlayerScripts.Controllers.ShopController)
local StaticViewModel = require(Players.LocalPlayer.PlayerScripts.Modules.StaticModel.StaticViewModel)
local SkinHologram = {}
SkinHologram.__index = SkinHologram

function SkinHologram.new(part)
	local self = setmetatable({}, SkinHologram)
	self.Part = part
	self.HologramViewModel = nil
	self.SkinViewModel = nil
	self._connections = {}
	self._index = 0
	self._next_increment = 0
	self._last_change = 0
	self:_Init()
	return self
end

function SkinHologram:Set(p)
	if self.HologramViewModel then
		self.HologramViewModel:Destroy()
		self.HologramViewModel = nil
	end

	if self.SkinViewModel then
		self.SkinViewModel:Destroy()
		self.SkinViewModel = nil
	end

	if not p then
		return
	end

	self._last_change = tick()
	self.HologramViewModel = StaticViewModel.new(p)
	self.HologramViewModel:SetWrap({
		Name = "Hologram"
	})
	self.HologramViewModel:ScaleTo(4)
	self.SkinViewModel = StaticViewModel.new(p)
	self.SkinViewModel:ScaleTo(4)
	self:Update(0)
end

function SkinHologram:Increment(p)
	local _GetSkinNames = self:_GetSkinNames()

	if #_GetSkinNames == 0 then
		self:Set(nil)
		return
	end

	local v

	if p then
		v = (self._index - 1) % #_GetSkinNames + 1
	else
		v = self._index % #_GetSkinNames + 1
	end

	self._index = v
	self:Set(_GetSkinNames[self._index])
end

function SkinHologram:Update(_)
	if tick() > self._next_increment then
		self._next_increment = tick() + 10
		self:Increment()
	end

	local v = tick() - self._last_change
	local v2

	if v > 1.5 then
		v2 = false
	else
		v2 = math.floor(10 * v - v ^ 3) % 2 == 1
	end

	if self.HologramViewModel then
		self.HologramViewModel:PivotTo(self.Part.CFrame)
		local hologramViewModel = self.HologramViewModel
		local v3

		if v2 then
			v3 = self.Part
		end

		hologramViewModel:SetParent(v3)
	end

	if self.SkinViewModel then
		self.SkinViewModel:PivotTo(self.Part.CFrame)
		local skinViewModel = self.SkinViewModel
		local v3

		if not v2 then
			v3 = self.Part
		end

		skinViewModel:SetParent(v3)
	end
end

function SkinHologram:Destroy()
	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self._connections = {}
	self:Set(nil)
end

function SkinHologram:_GetSkinNames()
	local names = {}

	for _, v in pairs(ShopController:GetDailyShop()) do
		local reward = v.Rewards[1]

		if CosmeticLibrary.Cosmetics[reward.Name].Type == "Skin" then
			table.insert(names, reward.Name)
		end
	end

	return names
end

function SkinHologram:_Init()
	table.insert(self._connections, ShopController.DailyShopRefreshed:Connect(function()
		self:Increment(true)
	end))
end

return SkinHologram