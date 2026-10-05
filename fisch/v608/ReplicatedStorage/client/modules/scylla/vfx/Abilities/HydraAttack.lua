local createVector = vector.create
game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("SoundService")
game:GetService("TweenService")
game:GetService("Players")
local modules = script.Parent.Parent.Modules
local Trove = require(ReplicatedStorage.packages.Trove)
local SebasUtil = require(modules.SebasUtil)
require(modules.GroundCrater)
local assets = script.Parent.Parent.Assets
local scylla = ReplicatedStorage.resources.sounds.sfx.scylla
local vFXDebris = workspace:WaitForChild("VFXDebris")
local _ = workspace.CurrentCamera
local HydraAttack = {}
HydraAttack.__index = HydraAttack
Random.new(os.time())

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function quadBezier(p, p2, p3, p4)
	return (1 - p4) ^ 2 * p + 2 * (1 - p4) * p4 * p2 + p4 ^ 2 * p3
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function quadraticEaseOut(p)
	local v = p * p
	return v + (1 - (1 - p) * (1 - p) - v) * p
end

function HydraAttack.new(char)
	local self = setmetatable({}, HydraAttack)
	self.Trove = Trove.new()
	self.Char = char
	self.CamShakeEnabled = true
	self.Properties = {
		BallSpeed = 120
	}
	return self
end

function HydraAttack:_shootBall(p2: number, p3, vector2: Vector3, instance, instance2, callback)
	local clone = instance:Clone()
	self.Trove:Add(clone)
	clone.Parent = vFXDebris
	local position = p3.TransformedWorldCFrame.Position
	local v = position + (vector2 - position) * 0.4 + createVector(0, 80, 0)
	clone.Position = position
	SebasUtil:HeartbeatLoopFor((clone.Position - vector2).Magnitude / self.Properties.BallSpeed, function(_, _, p4)
		clone.Position = quadBezier(position, v, vector2, p4)
	end, function()
		local clone2 = instance2:Clone()
		self.Trove:Add(clone2)
		clone2.Position = vector2 + createVector(0, 1, 0)
		clone2.Parent = vFXDebris
		SebasUtil:EmitAll(clone2)
		SebasUtil:DisableAllParticles(clone)
		SebasUtil:fadeAllLights(clone, 0.5)
		clone.Transparency = 1
		SebasUtil:fadeAllLights(clone2, 3)
		SebasUtil:AppearAllBeams(clone2, 0.1)
		callback(vector2)
		self.Trove:Add(task.delay(1.5, function()
			SebasUtil:DisableAllBeams(clone2, 0.5)
		end))
	end, p2, function()
		return workspace:GetServerTimeNow()
	end)
end

function HydraAttack:playFireBall(p: number, callback, object2, callback2)
	if not self.Char:FindFirstChild("RootPart") then
		return
	end

	local jawR = self.Char.RootPart.Spine["Spine.009.R"]["Spine.010.R"]["Spine.011.R"]["Spine.012.R"]["Spine.013.R"]["Head.R"]["Jaw.R"]

	if not object2.IsPlaying then
		object2:Play()
	end

	self.Trove:Add(task.delay(1.5, function()
		scylla.fireball_cast:Play()
		self:_shootBall(p, jawR, callback(), assets.HydraAttack.Fireball, assets.HydraAttack.FireImpact, callback2)
	end))
end

function HydraAttack:playPlasmaBall(p: number, callback, object2, callback2)
	if not self.Char:FindFirstChild("RootPart") then
		return
	end

	if not object2.IsPlaying then
		object2:Play()
	end

	self.Trove:Add(task.delay(1.5, function()
		local jaw001R = self.Char.RootPart.Spine["Spine.014.R"]["Spine.015.R"]["Spine.016.R"]["Spine.017.R"]["Spine.018.R"]["Head.001.R"]["Jaw.001.R"]
		scylla.plasma_cast:Play()
		self:_shootBall(
			p,
			jaw001R,
			callback(),
			assets.HydraAttack.Plasmaball,
			assets.HydraAttack.PlasmaImpact,
			callback2
		)
	end))
end

function HydraAttack:playThunderBall(p: number, callback, object2, callback2)
	if not self.Char:FindFirstChild("RootPart") then
		return
	end

	if not object2.IsPlaying then
		object2:Play()
	end

	self.Trove:Add(task.delay(1.5, function()
		local jaw = self.Char.RootPart.Spine["Spine.009"]["Spine.010"]["Spine.011"]["Spine.012"]["Spine.013"].Head.Jaw
		scylla.lightning_cast:Play()
		self:_shootBall(p, jaw, callback(), assets.HydraAttack.Thunderball, assets.HydraAttack.BoltImpact, callback2)
	end))
end

function HydraAttack:playIceBall(p: number, callback, object2, callback2)
	if not self.Char:FindFirstChild("RootPart") then
		return
	end

	if not object2.IsPlaying then
		object2:Play()
	end

	self.Trove:Add(task.delay(1.5, function()
		local head001L = self.Char.RootPart.Spine["Spine.014.L"]["Spine.015.L"]["Spine.016.L"]["Spine.017.L"]["Spine.018.L"]["Head.001.L"]
		scylla.ice_cast:Play()
		self:_shootBall(p, head001L, callback(), assets.HydraAttack.iceball, assets.HydraAttack.IceImpact, callback2)
	end))
end

function HydraAttack:playAll(p: number, callback, p2, callback2)
	if not self.Char:FindFirstChild("RootPart") then
		return
	end

	self.Trove:Add(task.spawn(function()
		self:playFireBall(p, callback, p2, callback2)
	end))
	self.Trove:Add(task.spawn(function()
		self:playPlasmaBall(p, callback, p2, callback2)
	end))
	self.Trove:Add(task.spawn(function()
		self:playThunderBall(p, callback, p2, callback2)
	end))
	self.Trove:Add(task.spawn(function()
		self:playIceBall(p, callback, p2, callback2)
	end))
end

function HydraAttack:Clean()
	self.Trove:Clean()
	setmetatable(self, nil)
end

setmetatable(HydraAttack, {
	__index = function(_, p)
		error(string.format("%q is not a valid member of %q", tostring(p), script.Name), 2)
	end
})
return HydraAttack