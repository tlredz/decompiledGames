local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ReplicatedClass = require(ReplicatedStorage.Modules.ReplicatedClass)
local Utility = require(ReplicatedStorage.Modules.Utility)
require(ReplicatedStorage.Modules.Signal)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local v = {
	Docks = { "rbxassetid://17813065011", 0.25, 0 },
	Station = { "rbxassetid://17813065464", 0.25, 13 },
	["Big Station"] = { "rbxassetid://17813065464", 0.25, 13 },
	Backrooms = { "rbxassetid://17813170797", 1, 0 },
	Construction = { "rbxassetid://93752516938586", 1, 0 },
	["Big Backrooms"] = { "rbxassetid://17813170797", 1, 0 },
	Onyx = { "rbxassetid://12099785239", 0.375, 0 },
	["Big Onyx"] = { "rbxassetid://12099785239", 0.375, 0 },
	Splash = { "rbxassetid://18963688210", 0.75, 0 },
	["Big Splash"] = { "rbxassetid://18963688210", 0.75, 0 },
	["Zombie Tower"] = { "rbxassetid://90122406367653", 0.25, 0 },
	Iceberg = { "rbxassetid://103004663415392", 0.25, 0 },
	Village = { "rbxassetid://103004663415392", 0.25, 0 },
	Studio = { "rbxassetid://90866007129930", 1, 0 },
	Westown = { "rbxassetid://116999944271223", 1, 0 }
}
local object = setmetatable({}, ReplicatedClass)
object.__index = object

function object.new(data, clientDuel)
	local object2 = setmetatable(ReplicatedClass.new(data), object)
	object2.Name = data.Name
	object2.Model = data.Model
	object2.ClientDuel = clientDuel
	object2.Data.IsHidden = nil
	object2.Data.LightingProfileOverride = nil
	object2._destroyed = false
	object2._connections = {}
	object2._active_connections = {}
	object2._seed = data.Seed
	object2._on_hidden_update_callback = nil
	object2._textures_deleted = false
	object2._shadows_deleted = false
	object2._ambience_sound = nil
	object2._spectate_part = nil
	object2._lighting_objects_folder = object2.Model:FindFirstChild("LightingObjects")
	object2._lighting_objects_folders = not object2._lighting_objects_folder and {} or object2._lighting_objects_folder:GetChildren() or {}
	object2:_Init()
	return object2
end

function object:IsRendered()
	return self.ClientDuel:IsRendered()
end

function object:GetSpectatePart()
	if not self._spectate_part then
		self._spectate_part = self.Model:FindFirstChild("Spectate")
	end

	return self._spectate_part
end

function object.GetScoreboardDisplay(_)
	return nil
end

function object:SetHidden(p)
	if p == self:Get("IsHidden") then
		return
	end

	for _, _active_connection in pairs(self._active_connections) do
		_active_connection:Disconnect()
	end

	self._active_connections = {}
	self:SetReplicate("IsHidden", p)
	local model = self.Model
	local parent

	if not p then
		parent = workspace or nil
	end

	model.Parent = parent
	self:_UpdateAmbience()

	if p then
		return
	end

	table.insert(
		self._active_connections,
		PlayerDataController:GetSettingChangedSignal("Textures Disabled"):Connect(function()
			self:_UpdateTextures()
		end)
	)
	table.insert(
		self._active_connections,
		PlayerDataController:GetSettingChangedSignal("Shadows Disabled"):Connect(function()
			self:_UpdateShadows()
		end)
	)
	self:_UpdateTextures()
	self:_UpdateShadows()
end

function object:CreateSound(...)
	if self:Get("IsHidden") then
		return
	else
		return Utility:CreateSound(...)
	end
end

function object:Destroy()
	self._destroyed = true

	for _, _active_connection in pairs(self._active_connections) do
		_active_connection:Disconnect()
	end

	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	if self._ambience_sound then
		self._ambience_sound:Destroy()
	end

	ReplicatedClass.Destroy(self)
end

function object:_UpdateLightingObjects()
	local lightingProfileOverride = self:Get("LightingProfileOverride") or self.Name

	for _, _lighting_objects_folder in pairs(self._lighting_objects_folders) do
		local parent

		if _lighting_objects_folder.Name == lightingProfileOverride then
			parent = self._lighting_objects_folder or nil
		end

		_lighting_objects_folder.Parent = parent
	end
end

function object:_UpdateHidden()
	local success, result = pcall(function()
		self:SetHidden(not self.ClientDuel:Get("IsSpectating"))
	end)

	if not success then
		warn("Failed to hide/unhide map, error:", result)
	end
end

function object:_UpdateAmbience()
	if self:Get("IsHidden") and self._ambience_sound then
		self._ambience_sound:Destroy()
		self._ambience_sound = nil
	else
		local v2 = not self:Get("IsHidden") and not self._ambience_sound and v[self.Name]

		if v2 then
			self._ambience_sound = Utility:CreateSound(v2[1], v2[2], 1, script, true)
			self._ambience_sound.Looped = true
			self._ambience_sound.TimePosition = v2[3]
		end
	end
end

function object:_UpdateShadows()
	if self._shadows_deleted or self:Get("IsHidden") or not PlayerDataController:GetSetting("Shadows Disabled") then
		return
	end

	self._shadows_deleted = true
	Utility:DisableShadows(self.Model)
end

function object:_UpdateTextures()
	if self._textures_deleted or self:Get("IsHidden") or not PlayerDataController:GetSetting("Textures Disabled") then
		return
	end

	self._textures_deleted = true
	Utility:DisableTextures(self.Model)
end

function object:_Init()
	table.insert(self._connections, self.ClientDuel:GetDataChangedSignal("IsSpectating"):Connect(function()
		self:_UpdateHidden()
	end))
	self:GetDataChangedSignal("LightingProfileOverride"):Connect(function()
		self:_UpdateLightingObjects()
	end)
	self:_UpdateHidden()
	task.defer(self._UpdateLightingObjects, self)
end

return object