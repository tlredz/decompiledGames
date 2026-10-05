local createVector = vector.create
game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("TweenService")
local Players = game:GetService("Players")
local Trove = require(ReplicatedStorage.packages.Trove)
local CameraShaker = require(ReplicatedStorage.packages.CameraShaker)
require(ReplicatedStorage.packages.CameraShaker.CameraShakePresets)
require(ReplicatedStorage.packages.CameraShaker.CameraShakeInstance)
local SebasUtil = require(ReplicatedStorage.client.modules.SebasUtil)
local Projectile = require(ReplicatedStorage.client.modules.Projectile)
require(script.Parent.GroundCrater)
local fireball = script.Fireball
local vFXDebris = workspace:WaitForChild("VFXDebris")
local currentCamera = workspace.CurrentCamera
local Fireball = {}
Fireball.__index = Fireball
Random.new(os.time())

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function quadraticEaseOut(p)
	local v = p * p
	return v + (1 - (1 - p) * (1 - p) - v) * p
end

local function shakeCam(p)
	currentCamera.CFrame *= p
end

local v = CameraShaker.new(Enum.RenderPriority.Last.Value, shakeCam)
v:Start()

function Fireball.new(char, color: Color3)
	local self = setmetatable({}, Fireball)
	self.Trove = Trove.new()
	self.Char = char
	self.Color = color
	self.CamShakeEnabled = char == Players.LocalPlayer.Character
	self.Properties = {
		FireballSpeed = 180
	}
	self.Trove:AttachToInstance(char)
	return self
end

function Fireball:Play(vector2: Vector3, cframe: CFrame)
	local humanoidRootPart = self.Char:FindFirstChild("HumanoidRootPart")
	local humanoid = self.Char:FindFirstChildOfClass("Humanoid")

	if not (humanoidRootPart and humanoid) then
		return
	end

	local clone = fireball.Fireball:Clone()
	self.Trove:Add(clone)
	clone.Parent = vFXDebris
	clone.CFrame = CFrame.lookAt(vector2, cframe.Position)
	self.Fireball = clone

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			descendant.Color = ColorSequence.new(self.Color)
		elseif descendant:IsA("PointLight") then
			descendant.Color = self.Color
		end
	end

	if self.CamShakeEnabled then
		v:ShakeOnce(2, 10, 0, 0.35)
	end

	self._running = true
	local unit = (cframe.Position - vector2).Unit
	local v2 = Projectile.new(vector2, unit, {
		Speed = self.Properties.FireballSpeed,
		Model = clone,
		IgnoreList = { self.Char, vFXDebris },
		Acceleration = createVector(0, 0, 0),
		Range = 2000
	})
	self.Trove:Add(v2, "Stop")
	v2.Hit:Connect(function(p)
		self:Hit(p)
	end)

	repeat
		task.wait()
	until not self._running

	task.wait(3)
end

function Fireball:Hit(p)
	self._running = false

	if p == nil then
		return
	end

	if self.CamShakeEnabled then
		v:ShakeOnce(3, 10, 0, 0.8)
	end

	SebasUtil:DisableAllParticles(self.Fireball)
	SebasUtil:fadeAllLights(self.Fireball, 1)
	local folder = fireball.Hit:clone()
	self.Trove:Add(folder)
	folder.Parent = vFXDebris
	folder.Position = p.Position

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			descendant.Color = ColorSequence.new(self.Color)
		elseif descendant:IsA("PointLight") then
			descendant.Color = self.Color
		end
	end

	SebasUtil:EmitAll(folder)
	SebasUtil:fadeAllLights(folder, 1)
end

function Fireball:Clean()
	self.Trove:Clean()
	setmetatable(self, nil)
end

return Fireball