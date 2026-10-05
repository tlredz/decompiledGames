local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local SoundLibrary = require(ReplicatedStorage.Modules.SoundLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local ClientEnemy = require(Players.LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientEntity.ClientHumanoidEntity.ClientEnemy)
local slamParticles = Players.LocalPlayer.PlayerScripts.Assets.Misc.SlamParticles
local v = { "rbxassetid://72483809453170", "rbxassetid://129922197154277", "rbxassetid://113975047764762" }
local object = setmetatable({}, ClientEnemy)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientEnemy.new(...), object)
	self._slam_vulnerable_animation = self:_CreateAnimation("rbxassetid://129758877701887")
	self._slam_animation = self:_CreateAnimation("rbxassetid://97481875605208")
	self._preloaded_sounds = SoundLibrary:PreloadSounds(v, nil, "rbxassetid://98587858115094")
	self:_Init()
	return self
end

function object:ReplicateFromServer(p, ...)
	if p ~= "SlamEffect" then
		ClientEnemy.ReplicateFromServer(self, p, ...)
		return
	end

	if not self:IsRendered() then
		return
	end

	local v2, v3, v4, v5, v6 = ...
	local v7

	if v6 then
		v7 = self._slam_vulnerable_animation
	else
		v7 = self._slam_animation
	end

	local success, result = pcall(self.Humanoid.LoadAnimation, self.Humanoid, v7)

	if success then
		table.insert(self._animation_cleanup, result)
		result:Play()
	end

	wait(v4)
	Utility:CreateSound(
		"rbxassetid://98587858115094",
		0.875 + 0.25 * math.random(),
		0.9 + 0.2 * math.random(),
		self.RootPart,
		true,
		10,
		400,
		400
	)
	wait(v5)

	if not self:IsAlive() then
		return
	end

	local v8 = math.max(0, 1 - (self.RootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude / 400)
	CameraController:ShakeOnce(v8 * 50, v8 * 10, 0.1, 0.4, createVector(1, 1, 0), createVector(0, 0, 0))
	local clone = slamParticles:Clone()
	clone.CFrame = CFrame.new(v2) + createVector(0, 0.1, 0)
	clone.Parent = workspace
	BetterDebris:AddItem(clone, 10)
	Utility:ScaleParticleEmitter(clone, v3 / 32)
	Utility:PlayParticles(clone)

	for _, v9 in pairs(v) do
		Utility:CreateSound(
			v9,
			0.875 + 0.25 * math.random(),
			0.9 + 0.2 * math.random(),
			self.RootPart,
			true,
			10,
			400,
			400
		)
	end
end

function object:Destroy()
	for _, _preloaded_sound in pairs(self._preloaded_sounds) do
		_preloaded_sound:Destroy()
	end

	ClientEnemy.Destroy(self)
end

function object:_Setup()
	task.spawn(
		pcall,
		ContentProvider.PreloadAsync,
		ContentProvider,
		{ self._slam_animation, self._slam_vulnerable_animation }
	)
end

function object:_Init()
	self:_Setup()
end

return object