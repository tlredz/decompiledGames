local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Promise"))
local v = {
	ParticleEmitter = true,
	Trail = true,
	Beam = true
}
local VisualEffectsUtil = {}
VisualEffectsUtil.cache = {}
VisualEffectsUtil.transparencyCache = {}

function VisualEffectsUtil.ForInstanceOfAttribute(folder, attributeName: string, callback)
	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:GetAttribute(attributeName) ~= attributeName then
			continue
		end

		local v2 = descendant
		Promise.new(function(callback2)
			callback(v2)
			callback2()
		end)
	end
end

function VisualEffectsUtil.ForParticles(folder, callback)
	for _, descendant in pairs(folder:GetDescendants()) do
		if not v[descendant.ClassName] then
			continue
		end

		local v2 = descendant
		Promise.new(function(callback2)
			callback(v2)
			callback2()
		end)
	end
end

function VisualEffectsUtil.ForParticlesOfAttribute(folder, attributeName: string, callback)
	local descendants = folder:GetDescendants()

	for _, emitter in pairs(descendants) do
		if not (emitter:GetAttribute(attributeName) and emitter:IsA("ParticleEmitter")) then
			continue
		end

		local v2 = emitter
		Promise.new(function(callback2)
			callback(v2)
			callback2()
		end)
	end
end

function VisualEffectsUtil.TweenTransparencyForChildren(instance, transparency: number, p2)
	for _, part in pairs(instance:GetChildren()) do
		if part:IsA("BasePart") then
			TweenService:Create(part, p2, {
				Transparency = transparency
			}):Play()
		end
	end
end

function VisualEffectsUtil.SetEnabledStateOfParticles(instance, enabled: boolean)
	assert(type(enabled) == "boolean", "Must be a type of boolean")

	for _, child in pairs(instance:GetChildren()) do
		if v[child.ClassName] then
			child.Enabled = enabled
		end
	end
end

function VisualEffectsUtil.EmitParticles(instance, value: number)
	assert(type(value) == "number", "Must be a type of number")

	for _, child in pairs(instance:GetChildren()) do
		if v[child.ClassName] then
			child:Emit(value)
		end
	end
end

function VisualEffectsUtil.SetPartVisibilityOfAttribute(folder, attributeName: string, flag: boolean)
	local descendants = folder:GetDescendants()

	for _, part in pairs(descendants) do
		if part:GetAttribute(attributeName) and part:IsA("BasePart") then
			part.Transparency = flag and 0 or 1
		end
	end
end

function VisualEffectsUtil.TweenPartVisibilityOfAttribute(folder, attributeName: string, transparency: number, p2)
	local descendants = folder:GetDescendants()

	for _, part in pairs(descendants) do
		if part:GetAttribute(attributeName) and part:IsA("BasePart") then
			TweenService:Create(part, p2, {
				Transparency = transparency
			}):Play()
		end
	end
end

function VisualEffectsUtil.SetEnabledEffectsOfAttribute(folder, attributeName: string, enabled: boolean)
	local descendants = folder:GetDescendants()

	for _, descendant in pairs(descendants) do
		if descendant:GetAttribute(attributeName) and v[descendant.ClassName] then
			descendant.Enabled = enabled
		end
	end
end

function VisualEffectsUtil.EmitOfAttribute(folder, attributeName: string, p: number)
	local descendants = folder:GetDescendants()

	for _, emitter in pairs(descendants) do
		if emitter:GetAttribute(attributeName) and emitter:IsA("ParticleEmitter") then
			emitter:Emit(p)
		end
	end
end

function VisualEffectsUtil.ShootParticleBeam(vector: Vector3, p, p2: number, color: Color3?, p3: number?, flag: boolean)
	BeamParticle.new(vector, p, p2, color, p3, flag)
end

return VisualEffectsUtil