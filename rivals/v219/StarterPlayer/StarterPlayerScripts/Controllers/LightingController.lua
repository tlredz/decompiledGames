local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local EventLibrary = require(ReplicatedStorage.Modules.EventLibrary)
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local Equipment = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Equipment)
local lightingProfiles = Players.LocalPlayer.PlayerScripts.Modules.LightingProfiles
local lightingProfiles2 = Players.LocalPlayer.PlayerScripts.Assets.LightingProfiles
local v = not EventLibrary.IS_ACTIVE and "Lobby" or EventLibrary.EVENT_DETAILS.LOBBY_LIGHTING_PROFILE or "Lobby"
local EQUIPMENT_LIGHTING_PROFILE = EventLibrary.IS_ACTIVE and EventLibrary.EVENT_DETAILS.EQUIPMENT_LIGHTING_PROFILE or "Lobby"
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.LocalFighter = nil
	self._connections = {}
	self._assets = {}
	self._current_lighting_name = nil
	self:_Init()
	return self
end

function class:SetLighting(p)
	if p == self._current_lighting_name then
		return
	end

	self:_LoadMapLightingAssets("Default")
	self:_LoadMapLightingModule("Default")

	if p == "Default" then
		return
	end

	self:_LoadMapLightingAssets(p)
	self:_LoadMapLightingModule(p)
end

function class:_LoadMapLightingAssets(childName)
	local child = lightingProfiles2:FindFirstChild(childName)

	if not child then
		return
	end

	for _, _asset in pairs(self._assets) do
		_asset:Destroy()
	end

	self._assets = {}

	for _, clouds in pairs(child:GetChildren()) do
		local clone = clouds:Clone()
		clone.Name = "LightingController"
		clone.Parent = clouds:IsA("Clouds") and workspace.Terrain or Lighting
		table.insert(self._assets, clone)
	end
end

function class:_LoadMapLightingModule(childName)
	local module = lightingProfiles:FindFirstChild(childName) and require(lightingProfiles[childName])

	if not module then
		return
	end

	for k, v2 in pairs(module.TerrainMaterials or {}) do
		workspace.Terrain:SetMaterialColor(k, v2)
	end

	for k, v2 in pairs(module.TerrainProperties or {}) do
		workspace.Terrain[k] = v2
	end

	for k, v2 in pairs(module.LightingProperties or {}) do
		Lighting[k] = v2
	end

	for k, v2 in pairs(module.SoundServiceProperties or {}) do
		SoundService[k] = v2
	end
end

function class:_UpdateLighting()
	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self._connections = {}

	if Equipment.IsOpen then
		self:SetLighting(EQUIPMENT_LIGHTING_PROFILE)
	elseif SpectateController.CurrentDuelSubject then
		-- equivalent calls inferred from this helper; original call sites unknown
		local function update()
			local map = SpectateController.CurrentDuelSubject and SpectateController.CurrentDuelSubject.Map
			self:SetLighting(not map and "Default" or map:Get("LightingProfileOverride") or map.Name or "Default")
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function map_added(map)
			table.insert(self._connections, map:GetDataChangedSignal("LightingProfileOverride"):Connect(update))
			update() -- equivalent call inferred; original call site unknown
		end

		table.insert(self._connections, SpectateController.CurrentDuelSubject.MapAdded:Connect(map_added))

		if SpectateController.CurrentDuelSubject.Map then
			map_added(SpectateController.CurrentDuelSubject.Map) -- equivalent call inferred; original call site unknown
		end

		update() -- equivalent call inferred; original call site unknown
	elseif self.LocalFighter and self.LocalFighter:Get("IsInShootingRange") then
		self:SetLighting("Shooting Range")
	else
		self:SetLighting(v)
	end
end

function class:_HookLocalFighter()
	self.LocalFighter = FighterController:WaitForLocalFighter()
	self.LocalFighter:GetDataChangedSignal("IsInShootingRange"):Connect(function()
		self:_UpdateLighting()
	end)
	self:_UpdateLighting()
end

function class:_Setup()
	workspace.Terrain:ClearAllChildren()

	for _, child in pairs(Lighting:GetChildren()) do
		if child.Name == "REMOVE_AT_RUNTIME" then
			child:Destroy()
		end
	end
end

function class:_Init()
	SpectateController.DuelSubjectChanged:Connect(function()
		self:_UpdateLighting()
	end)
	Equipment.Opened:Connect(function()
		self:_UpdateLighting()
	end)
	self:_Setup()
	self:_UpdateLighting()
	task.spawn(self._HookLocalFighter, self)
end

return class._new()