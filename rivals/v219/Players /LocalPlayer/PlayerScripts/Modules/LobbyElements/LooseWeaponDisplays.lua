local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
require(ReplicatedStorage.Modules.CosmeticLibrary)
require(ReplicatedStorage.Modules.ItemLibrary)
local ShopLibrary = require(ReplicatedStorage.Modules.ShopLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local LobbyController = require(Players.LocalPlayer.PlayerScripts.Controllers.LobbyController)
local LooseWeaponDisplay = require(Players.LocalPlayer.PlayerScripts.Modules.LooseWeaponDisplay)
local LobbyElement = require(Players.LocalPlayer.PlayerScripts.Modules.LobbyElement)
local object = setmetatable({}, LobbyElement)
object.__index = object

function object._new(...)
	local self = setmetatable(LobbyElement.new(...), object)
	self.Displays = {}
	self:_Init()
	return self
end

function object:Shuffle()
	local v = {}

	for _, v2 in pairs(PlayerDataController:Get("WeaponInventory")) do
		v[v2.Name] = true
	end

	local v2 = {}

	for _, v3 in pairs(ShopLibrary:GetReleasedOwnableWeapons(
		CONSTANTS.WEAPON_EARLY_ACCESS_TIME_OFFSET,
		ShopLibrary.OwnableWeaponsAlphabetized
	)) do
		if not v[v3] then
			table.insert(v2, math.random(1, #v2 + 1), v3)
		end
	end

	local v3 = {}

	for i = 1, #self.Displays do
		table.insert(v3, math.random(1, #v3 + 1), i)
	end

	for _, v4 in pairs(v3) do
		self.Displays[v4]:ChangeWeapon(self:_VerifyLooseWeaponDisplayWeapon(table.remove(v2, 1)))
	end
end

function object:Update(p2)
	for _, display in pairs(self.Displays) do
		display:Update(p2)
	end
end

function object:_VerifyLooseWeaponDisplayWeapon(p)
	if p and not PlayerDataController:GetWeaponData(p) then
		return p
	end

	return nil
end

function object:_ObjectAdded(p2)
	local v = LooseWeaponDisplay.new(p2)
	table.insert(self.Displays, v)
end

function object:_Init()
	LobbyController.LocalFighter:GetDataChangedSignal("IsInDuel"):Connect(function()
		if not LobbyController.LocalFighter:Get("IsInDuel") then
			self:Shuffle()
		end
	end)
	PlayerDataController:GetDataChangedSignal("WeaponInventory"):Connect(function()
		for _, display in pairs(self.Displays) do
			display:ChangeWeapon(self:_VerifyLooseWeaponDisplayWeapon(display.CurrentWeapon))
		end
	end)
	CollectionService:GetInstanceAddedSignal("LobbyLooseWeaponDisplay"):Connect(function(p)
		self:_ObjectAdded(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("LobbyLooseWeaponDisplay")) do
		task.spawn(self._ObjectAdded, self, v)
	end

	self:Shuffle()
end

return object._new()