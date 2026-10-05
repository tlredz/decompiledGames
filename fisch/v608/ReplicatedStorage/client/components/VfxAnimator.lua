local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
Players = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(ReplicatedStorage.packages.Trove)
local emit = require(packages.emit)
require(ReplicatedStorage.client.legacyControllers.SettingsController)
local v = Component.new({
	Tag = "VfxAnimator"
})

function v:Construct()
	self.trove = Trove.new()
end

local function indexPath(child, value: string)
	for _, childName in value:split(".") do
		if childName == "" then
			continue
		end

		child = child and child:FindFirstChild(childName)

		if not child then
			return nil
		end
	end

	return child
end

-- equivalent calls inferred from this helper; original call sites unknown
local function emitPath(rig, p: string)
	local v2 = indexPath(rig, p)

	if v2 then
		emit.emit(v2)
	end
end

function v:PlayToolVfx(p2: string)
	local tool = self.rig:FindFirstChildWhichIsA("Tool")
	local v2 = tool and indexPath(tool, p2)

	if v2 then
		emit.emit(v2)
	end
end

function v:PlayVfx(p2: string)
	emitPath(self.rig, p2) -- equivalent call inferred; original call site unknown
end

function v:ToggleVfx(p2: string, enabled: boolean)
	local part = indexPath(self.rig, p2)

	if part then
		for _, v2 in part:QueryDescendants("ParticleEmitter, Beam, Trail, Light, BillboardGui, Highlight") do
			v2.Enabled = enabled
		end

		if part:IsA("BasePart") and part:HasTag("VfxPart") then
			part.Transparency = enabled and 0 or 1
		end
	end
end

function v:ToggleToolVfx(p2: string, enabled: boolean)
	local tool = self.rig:FindFirstChildWhichIsA("Tool")

	if not tool then
		return
	end

	local part = indexPath(tool, p2)

	if part then
		for _, v2 in part:QueryDescendants("ParticleEmitter, Beam, Trail, Light, BillboardGui, Highlight") do
			v2.Enabled = enabled
		end

		for _, v2 in part:QueryDescendants("BasePart.VfxPart") do
			v2.Transparency = enabled and 0 or 1
		end

		if part:IsA("BasePart") and part:HasTag("VfxPart") then
			part.Transparency = enabled and 0 or 1
		end
	end
end

function v:FadeModel(value: string)
	local parts = value:split(";;")
	local localTransparencyModifier = tonumber(parts[1])
	local v3 = tonumber(parts[2])
	local part = parts[3]

	if not (localTransparencyModifier and v3 and part) then
		warn((`Invalid FadeModel event format: "{value}"`))
		return
	end

	local v4 = indexPath(self.rig, part)

	if v4 then
		for _, v5 in v4:QueryDescendants("BasePart, Decal, ParticleEmitter, Trail, Beam, Fire, Smoke, Sparkles, Explosion") do
			TweenService:Create(v5, TweenInfo.new(v3, Enum.EasingStyle.Linear), {
				LocalTransparencyModifier = localTransparencyModifier
			}):Play()
		end
	end
end

function v:FadeToolModel(value: string)
	local parts = value:split(";;")
	local localTransparencyModifier = tonumber(parts[1])
	local v3 = tonumber(parts[2])
	local part = parts[3]

	if not (localTransparencyModifier and v3 and part) then
		warn((`Invalid FadeModel event format: "{value}"`))
		return
	end

	local tool = self.rig:FindFirstChildWhichIsA("Tool")

	if not tool then
		return
	end

	local v4 = indexPath(tool, part)

	if v4 then
		for _, v5 in v4:QueryDescendants("BasePart, Decal, ParticleEmitter, Trail, Beam, Fire, Smoke, Sparkles, Explosion") do
			TweenService:Create(v5, TweenInfo.new(v3, Enum.EasingStyle.Linear), {
				LocalTransparencyModifier = localTransparencyModifier
			}):Play()
		end
	end
end

function v:Start()
	self.rig = self.Instance.Parent and self.Instance.Parent.Parent

	if not self.rig then
		warn((`Could not get character from VfxAnimator {self.Instance:GetFullName()}`))
		return
	end

	local v2 = {}
	self.trove:Add(function()
		table.clear(v2)
	end)
	self.trove:Add(self.Instance.AnimationPlayed:Connect(function(object2)
		if v2[object2] then
			return
		end

		local maid = self.trove:Extend()
		v2[object2] = true
		maid:Add(function()
			v2[object2] = nil
		end)
		maid:Add(object2:GetMarkerReachedSignal("PlayVfx"):Connect(function(p)
			self:PlayVfx(p)
		end))
		maid:Add(object2:GetMarkerReachedSignal("EnableVfx"):Connect(function(p)
			self:ToggleVfx(p, true)
		end))
		maid:Add(object2:GetMarkerReachedSignal("DisableVfx"):Connect(function(p)
			self:ToggleVfx(p, false)
		end))
		maid:Add(object2:GetMarkerReachedSignal("PlayToolVfx"):Connect(function(p)
			self:PlayToolVfx(p)
		end))
		maid:Add(object2:GetMarkerReachedSignal("EnableToolVfx"):Connect(function(p)
			self:ToggleToolVfx(p, true)
		end))
		maid:Add(object2:GetMarkerReachedSignal("DisableToolVfx"):Connect(function(p)
			self:ToggleToolVfx(p, false)
		end))
		maid:Add(object2:GetMarkerReachedSignal("FadeModel"):Connect(function(p)
			self:FadeModel(p)
		end))
		maid:Add(object2:GetMarkerReachedSignal("FadeToolModel"):Connect(function(p)
			self:FadeToolModel(p)
		end))
		maid:Add(object2.Ended:Once(function()
			self.trove:Remove(maid)
		end))
	end))
end

function v:Stop()
	self.trove:Clean()
	self.rig = nil
end

return v