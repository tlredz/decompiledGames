local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local Finisher = require(ReplicatedStorage.Modules.Finisher)
local Spring = require(ReplicatedStorage.Modules.Spring)
local object = setmetatable({}, Finisher)
object.__index = object

function object.new(...)
	local self = setmetatable(Finisher.new(...), object)
	self:_Init()
	return self
end

function object:PlayClient()
	for _, instance in pairs(self:_GetObjects(true)) do
		if instance:IsA("BasePart") then
			instance.LocalTransparencyModifier = 1
		elseif instance:IsA("Decal") or instance:IsA("Texture") or instance:IsA("Beam") or instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("SurfaceAppearance") then
			instance:Destroy()
		end
	end

	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local cframe = CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0)
	local playerFromCharacter = self._is_humanoid and Players:GetPlayerFromCharacter(self._subject.Parent)
	local teamColor = playerFromCharacter and playerFromCharacter:GetAttribute("TeamID") and DuelLibrary:GetTeamColor(playerFromCharacter:GetAttribute("TeamID"))
	local clone = script.Model:Clone()
	clone.Part.BillboardGui.Headshot.Image = not playerFromCharacter and "" or string.format(
		CONSTANTS.HEADSHOT_IMAGE,
		playerFromCharacter.UserId
	)
	clone.Parent = self._subject

	if teamColor then
		clone.Extra.Neon.Color = teamColor
		clone.Extra.Ring.Color = teamColor
		clone.Extra.NeonCone.Color = teamColor
		clone.Extra.Model["Meshes/HandLamp_01c"].Beam.Color = ColorSequence.new(teamColor)
	end

	local _GetObjects = self:_GetObjects(true)
	local v = Spring.new(rootPart.Position, 1, 2)
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		v.Target = self:_GetGroundPosition(rootPart.Position, _GetObjects)
		clone:PivotTo(CFrame.new(v.Value.X, v.Target.Y, v.Value.Z) * cframe)
	end)
	table.insert(self._connections, renderSteppedConnection)
	self:CreateSound("rbxassetid://80428386536466", 1.25, 1, nil, true, 5)
	self:CreateSound("rbxassetid://138661631832263", 1.5, 1, nil, true, 5)
	wait(3)
	renderSteppedConnection:Disconnect()
	wait(7)
end

function object:_Init() end

return object