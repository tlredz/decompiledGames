local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SettingsKeys = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.SettingsKeys)
local Allegiance = require(ReplicatedStorage.CAM.Global.Allegiance)
local ParticleBudget = {}
local v = {}
local v2

if RunService:IsClient() then
	local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
	v2 = DataValue.new(SettingsKeys.Particles.Path, SettingsKeys.Particles.Default, SettingsKeys.Scope)
	v.Mine = DataValue.new(SettingsKeys.ParticlesMine.Path, SettingsKeys.ParticlesMine.Default, SettingsKeys.Scope)
	v.Allies = DataValue.new(
		SettingsKeys.ParticlesAllies.Path,
		SettingsKeys.ParticlesAllies.Default,
		SettingsKeys.Scope
	)
	v.Others = DataValue.new(
		SettingsKeys.ParticlesOthers.Path,
		SettingsKeys.ParticlesOthers.Default,
		SettingsKeys.Scope
	)
else
	v2 = nil
end

function ParticleBudget.Owned(owner, p)
	local typeName = typeof(p)

	if typeName == "table" then
		local clone = table.clone(p)
		clone.Owner = owner
		return clone
	else
		if typeName == "number" then
			return {
				Timer = p,
				Owner = owner
			}
		elseif typeName == "Color3" then
			return {
				Color = p,
				Owner = owner
			}
		end

		return {
			Owner = owner
		}
	end
end

local function shareOf(object, p: number)
	if object == nil then
		return p
	end

	local v3 = object:Get()

	if type(v3) == "number" then
		return (math.clamp(v3, 0, 1))
	end

	return p
end

local characterOf

characterOf = function(parent)
	if type(parent) == "table" then
		for _, item in parent do
			local v3 = characterOf(item)

			if v3 ~= nil then
				return v3
			end
		end
	else
		if typeof(parent) ~= "Instance" then
			return nil
		end

		if parent:IsA("Player") then
			return parent.Character
		end

		for _ = 1, 6 do
			if parent == nil then
				return nil
			end

			if parent:IsA("Model") and parent:FindFirstChildOfClass("Humanoid") ~= nil then
				return parent
			else
				parent = parent.Parent
			end
		end
	end

	return nil
end

local object = setmetatable({}, {
	__mode = "k"
})

local function sideOf(p)
	local v3 = object[p]
	local now = os.clock()

	if v3 ~= nil and now - v3.At < 2 then
		return v3.Side
	end

	local localPlayer = Players.LocalPlayer
	local character

	if localPlayer ~= nil then
		character = localPlayer.Character
	end

	local side = "Others"

	if Allegiance.PlayerBehind(p) == nil then
		side = "Npc"
	elseif character ~= nil then
		side = (p == character or Allegiance.SameOwner(character, p)) and "Mine" or Allegiance.Allied(character, p) and "Allies" or side
	end

	object[p] = {
		Side = side,
		At = now
	}
	return side
end

local object2 = setmetatable({}, {
	__mode = "k"
})

function ParticleBudget.Stamp(instance, p)
	if p == nil or typeof(instance) ~= "Instance" then
		return
	end

	object2[instance] = p
end

local function stampedOwner(parent)
	for _ = 1, 8 do
		if parent == nil then
			return nil
		end

		local v3 = object2[parent]

		if v3 ~= nil then
			return v3
		end

		parent = parent.Parent
	end

	return nil
end

function ParticleBudget.Share(p, p2)
	local v3 = v2
	local default = SettingsKeys.Particles.Default

	if v3 ~= nil then
		local v4 = v3:Get()

		if type(v4) == "number" then
			default = math.clamp(v4, 0, 1)
		end
	end

	if default <= 0 then
		return 0
	end

	if p == nil then
		p = stampedOwner(p2)
	end

	local v5 = characterOf(p)

	if v5 == nil then
		return default
	end

	local v7 = v[sideOf(v5)]
	local v8

	if v7 == nil then
		v8 = 1
	else
		local v9 = v7:Get()
		v8 = type(v9) ~= "number" and 1 or math.clamp(v9, 0, 1)
	end

	return default * v8
end

function ParticleBudget.Muted(p, p2)
	return ParticleBudget.Share(p, p2) <= 0
end

function ParticleBudget.Scale(p: number?, p2, p3)
	if p == nil then
		return nil
	end

	if p <= 0 then
		return p
	end

	local share = ParticleBudget.Share(p2, p3)

	if share <= 0 then
		return 0
	end

	if share >= 1 then
		return p
	end

	return (math.round(p * share))
end

function ParticleBudget:Emit(p: number?, p2)
	local scaled = ParticleBudget.Scale(p == nil and 16 or p, p2, self)

	if scaled == nil or scaled <= 0 then
		return
	end

	self:Emit(scaled)
end

local object3 = setmetatable({}, {
	__mode = "k"
})

function ParticleBudget:Rate(p)
	if not self:IsA("ParticleEmitter") then
		return
	end

	local ouwAuthoredRate = self:GetAttribute("OuwAuthoredRate")

	if typeof(ouwAuthoredRate) ~= "number" then
		ouwAuthoredRate = self.Rate
		self:SetAttribute("OuwAuthoredRate", ouwAuthoredRate)
	end

	if p == nil then
		p = stampedOwner(self)
	end

	object3[self] = p == nil or p

	if ouwAuthoredRate <= 0 then
		return
	end

	local share = ParticleBudget.Share(p, self)

	if not (share >= 1) then
		ouwAuthoredRate *= share
	end

	if self.Rate ~= ouwAuthoredRate then
		self.Rate = ouwAuthoredRate
	end
end

local function reRate()
	for k, v3 in object3 do
		if k.Parent == nil then
			continue
		end

		local rate = ParticleBudget.Rate

		if v3 == true then
			v3 = nil
		end

		rate(k, v3)
	end
end

if v2 ~= nil then
	v2.Changed:Connect(reRate)

	for _, v3 in v do
		v3.Changed:Connect(function()
			table.clear(object)
			reRate()
		end)
	end
end

return ParticleBudget