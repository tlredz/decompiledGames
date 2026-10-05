local createVector = vector.create
game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Trove = require(ReplicatedStorage.packages.Trove)
local CameraShaker = require(ReplicatedStorage.packages.CameraShaker)
require(ReplicatedStorage.packages.CameraShaker.CameraShakePresets)
require(ReplicatedStorage.packages.CameraShaker.CameraShakeInstance)
local SebasUtil = require(ReplicatedStorage.client.modules.SebasUtil)
require(ReplicatedStorage.client.modules.Projectile)
require(ReplicatedStorage.client.modules.GroundCrater)
local aOEAttack = script.AOEAttack
local vFXDebris = workspace:WaitForChild("VFXDebris")
local currentCamera = workspace.CurrentCamera
local AOEAttack = {}
AOEAttack.__index = AOEAttack
local random = Random.new(os.time())

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

function AOEAttack.new(char)
	local self = setmetatable({}, AOEAttack)
	self.Trove = Trove.new()
	self.Char = char
	self.CamShakeEnabled = char == Players.LocalPlayer.Character
	self.Properties = {
		Radius = 600,
		SpikeWaves = 6,
		SpikeAmount = 6
	}
	self.Trove:AttachToInstance(char)
	return self
end

function AOEAttack:Play(position: Vector3)
	local humanoidRootPart = self.Char:FindFirstChild("HumanoidRootPart")
	local humanoid = self.Char:FindFirstChildOfClass("Humanoid")

	if not (humanoidRootPart and humanoid) then
		return
	end

	local clone = aOEAttack.Sparks1:Clone()
	self.Trove:Add(clone)
	clone.Parent = vFXDebris
	clone.Position = position
	SebasUtil:EmitAll(clone)

	if self.CamShakeEnabled then
		v:ShakeOnce(12, 10, 0, 1.3)
	end

	script.start:Play()
	task.wait()
	local clone2 = aOEAttack.Crack:Clone()
	self.Trove:Add(clone2)
	clone2.Parent = vFXDebris
	clone2.Position = position + createVector(0, 0.1, 0)
	SebasUtil:EmitAll(clone2)
	local clone3 = aOEAttack.Dust:Clone()
	self.Trove:Add(clone3)
	clone3.Parent = vFXDebris
	clone3.Position = position + Vector3.new(0, clone3.Size.Y / 2, 0)
	SebasUtil:EmitAll(clone3)
	local clone4 = aOEAttack.FireRing:Clone()
	self.Trove:Add(clone4)
	clone4.Parent = vFXDebris
	clone4.Position = position
	local tween = TweenService:Create(clone4, TweenInfo.new(0.65), {
		Size = Vector3.new(
			clone4.Size.X,
			clone4.Size.Y + self.Properties.Radius,
			clone4.Size.Z + self.Properties.Radius
		)
	})
	tween:Play()
	local v2 = self.Properties.Radius / 2.3 / self.Properties.SpikeWaves

	for i = 1, self.Properties.SpikeWaves do
		for i2 = 1, self.Properties.SpikeAmount do
			local v3 = i2
			local v4 = i
			self.Trove:Add(task.spawn(function()
				local v5 = math.rad(360 / self.Properties.SpikeAmount) * (v3 * random:NextNumber(0.7, 1.3))
				local clone5 = aOEAttack.Spike:Clone()
				self.Trove:Add(clone5)
				clone5.Parent = vFXDebris
				clone5.Size *= random:NextNumber(0.5, 1.5) * v4 / 4
				clone5.CFrame = CFrame.new(position) * CFrame.Angles(0, v5, 0)
				clone5.CFrame *= CFrame.new(0, clone5.Size.Y / 3, random:NextNumber(v4 * v2 * 0.8, v4 * v2 * 1.2)) * CFrame.Angles(
					math.rad((random:NextNumber(30, 45))),
					3.141592653589793 * random:NextNumber(-1, 1),
					0
				)
				local tween2 = TweenService:Create(clone5, TweenInfo.new(0.2), {
					CFrame = clone5.CFrame,
					Color = clone5.Color
				})
				clone5.Color = Color3.fromRGB(0, 0, 0)
				clone5.CFrame *= CFrame.new(0, -clone5.Size.Y, 0)
				tween2:Play()
				task.wait(1)
				TweenService:Create(clone5, TweenInfo.new(0.5), {
					Color = Color3.fromRGB(0, 0, 0),
					Transparency = 1
				}):Play()
			end))
		end

		task.wait(0.05)
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { workspace.active.bosses.cthulu:FindFirstChild("AOEIndicator") }
	raycastParams.FilterType = Enum.RaycastFilterType.Include

	if workspace:Raycast(humanoidRootPart.CFrame.Position, createVector(0, -3.5, 0), raycastParams) then
		ReplicatedStorage.events.clientTakeDamage:FireServer(34)
	end

	tween.Completed:Wait()
	SebasUtil:DisableAllParticles(clone4)
	task.wait(1)
	SebasUtil:DisableAllParticles(clone3)
	task.wait(3)
end

function AOEAttack.Hit(_, _) end

function AOEAttack:Clean()
	self.Trove:Clean()
	setmetatable(self, nil)
end

setmetatable(AOEAttack, {
	__index = function(_, p)
		error(string.format("%q is not a valid member of %q", tostring(p), script.Name), 2)
	end
})
return AOEAttack