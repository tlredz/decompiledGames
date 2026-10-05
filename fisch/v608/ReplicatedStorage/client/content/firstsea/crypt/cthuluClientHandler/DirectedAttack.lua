local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Trove = require(ReplicatedStorage.packages.Trove)
local CameraShaker = require(ReplicatedStorage.packages.CameraShaker)
require(ReplicatedStorage.packages.CameraShaker.CameraShakePresets)
require(ReplicatedStorage.packages.CameraShaker.CameraShakeInstance)
local SebasUtil = require(ReplicatedStorage.client.modules.SebasUtil)
local Projectile = require(ReplicatedStorage.client.modules.Projectile)
require(ReplicatedStorage.client.modules.GroundCrater)
local directedAttack = script:WaitForChild("DirectedAttack")
local vFXDebris = workspace:WaitForChild("VFXDebris")
local currentCamera = workspace.CurrentCamera
local DirectedAttack = {}
DirectedAttack.__index = DirectedAttack
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

function DirectedAttack.new(char)
	local self = setmetatable({}, DirectedAttack)
	self.Trove = Trove.new()
	self.Char = char
	self.CamShakeEnabled = char == Players.LocalPlayer.Character
	self.Properties = {
		FireballSpeed = 150,
		Radius = 100,
		SpikeWaves = 6,
		SpikeAmount = 4
	}
	self.Trove:AttachToInstance(char)
	return self
end

function DirectedAttack:Play(vector2: Vector3, vector3: Vector3)
	local humanoidRootPart = self.Char:FindFirstChild("HumanoidRootPart")
	local humanoid = self.Char:FindFirstChildOfClass("Humanoid")

	if not (humanoidRootPart and humanoid) then
		return
	end

	local clone = directedAttack.Projectile:Clone()
	self.Trove:Add(clone)
	clone.Parent = vFXDebris
	clone.CFrame = CFrame.lookAt(vector2, vector3)
	self.Fireball = clone

	if self.CamShakeEnabled then
		v:ShakeOnce(2, 10, 0, 0.35)
	end

	self._running = true
	local unit = (vector3 - vector2).Unit
	local v2 = Projectile.new(vector2, unit, {
		Speed = self.Properties.FireballSpeed,
		Model = clone,
		IgnoreList = { self.Char, vFXDebris, workspace.active.bosses.cthulu.CathuluChainBreakIK },
		Acceleration = createVector(0, 0, 0),
		Range = 5000
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

function DirectedAttack:Hit(p)
	self._running = false

	if p == nil then
		return
	end

	if self.CamShakeEnabled then
		v:ShakeOnce(6, 10, 0, 1)
	end

	SebasUtil:DisableAllParticles(self.Fireball)
	SebasUtil:fadeAllLights(self.Fireball, 1)
	local clone = directedAttack.Hit:clone()
	self.Trove:Add(clone)
	clone.Parent = vFXDebris
	clone.Position = p.Position
	SebasUtil:EmitAll(clone)
	SebasUtil:fadeAllLights(clone, 1)
	local v2 = self.Properties.Radius / 2.3 / self.Properties.SpikeWaves

	if (self.Char:GetPivot().Position - p.Position).Magnitude < 10 then
		ReplicatedStorage.events.clientTakeDamage:FireServer(25)
	end

	for i = 1, self.Properties.SpikeWaves do
		for i2 = 1, self.Properties.SpikeAmount do
			local v3 = i2
			local v4 = i
			self.Trove:Add(task.spawn(function()
				local v5 = math.rad(360 / self.Properties.SpikeAmount) * (v3 * random:NextNumber(0.7, 1.3))
				local clone2 = directedAttack.Spike:Clone()
				self.Trove:Add(clone2)
				clone2.Parent = vFXDebris
				clone2.Size *= random:NextNumber(0.5, 1.5) * v4 / 4
				clone2.CFrame = CFrame.new(p.Position) * CFrame.Angles(0, v5, 0)
				clone2.CFrame *= CFrame.new(0, clone2.Size.Y / 3, random:NextNumber(v4 * v2 * 0.8, v4 * v2 * 1.2)) * CFrame.Angles(
					math.rad((random:NextNumber(30, 45))),
					3.141592653589793 * random:NextNumber(-1, 1),
					0
				)
				local tween = TweenService:Create(clone2, TweenInfo.new(0.15), {
					CFrame = clone2.CFrame,
					Color = clone2.Color
				})
				clone2.Color = Color3.fromRGB(0, 0, 0)
				clone2.CFrame *= CFrame.new(0, -clone2.Size.Y, 0)
				tween:Play()
				task.wait(1)
				TweenService:Create(clone2, TweenInfo.new(0.5), {
					Color = Color3.fromRGB(0, 0, 0),
					Transparency = 1
				}):Play()
			end))
		end

		task.wait(0.05)
	end
end

function DirectedAttack:Clean()
	self.Trove:Clean()
	setmetatable(self, nil)
end

setmetatable(DirectedAttack, {
	__index = function(_, p)
		error(string.format("%q is not a valid member of %q", tostring(p), script.Name), 2)
	end
})
return DirectedAttack