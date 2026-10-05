local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
local Utility = require(ReplicatedStorage.Modules.Utility)
local FighterController = CONSTANTS.IS_CLIENT and require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local CameraController = CONSTANTS.IS_CLIENT and require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local object = setmetatable({}, Ragdoll)
object.__index = object

function object.new(...)
	local self = setmetatable(Ragdoll.new(...), object)
	self._fov_offset_key = HttpService:GenerateGUID(false)
	self:_Init()
	return self
end

function object:PlayClient(p)
	Ragdoll.PlayClient(self, p)

	if not p then
		local fighter = FighterController:GetFighter(self._eliminator)

		if not (fighter and fighter:Get("IsSpectating")) then
			return
		end
	end

	self:CreateSound("rbxassetid://74603473314180", 1.25, 0.95 + 0.1 * math.random(), script, true, 10)
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Parent = Lighting
	table.insert(self._destroy_these, colorCorrectionEffect)
	Utility:RenderstepForLoop(0, 100, 2, function(p2)
		if self._destroyed then
			return true
		end

		local v = p2 / 100
		local v2

		if v < 0.5 then
			v2 = 16 * v ^ 5
		else
			v2 = 1 - (-2 * v + 2) ^ 5 / 2
		end

		local v3 = 1 - v2
		colorCorrectionEffect.Brightness = 0.25 * v3
		colorCorrectionEffect.Contrast = 0.5 * v3
		colorCorrectionEffect.Saturation = 1 * v3
		CameraController:SetExternalFOVOffset(self._fov_offset_key, 10 * v3)
	end)
	colorCorrectionEffect:Destroy()
	CameraController:SetExternalFOVOffset(self._fov_offset_key, 0)
end

function object:Destroy()
	if CameraController then
		CameraController:SetExternalFOVOffset(self._fov_offset_key, 0)
	end

	Ragdoll.Destroy(self)
end

function object:_Init() end

return object