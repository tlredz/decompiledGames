local createVector = vector.create
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local State = require(packages.State)
local Trove = require(packages.Trove)
local modules = ReplicatedStorage.shared.modules
local SharedTimeFlowPuzzle = require(modules.SharedTimeFlowPuzzle)
require("../Types")
local completionStateObjects = {
	Rough = State.new(false),
	Cut = State.new(false),
	Radiant = State.new(false)
}

local function observerCallback(data)
	local maid = Trove.new()
	local rough = data.Rough
	local cut = data.Cut
	local radiant = data.Radiant
	local door = data.Door
	local beam = data.Beam
	local beamOfSunshineAndDeath = beam.BeamOfSunshineAndDeath

	-- equivalent calls inferred from this helper; original call sites unknown
	local function areAllFinished()
		if completionStateObjects.Rough:get() and completionStateObjects.Radiant:get() and completionStateObjects.Cut:get() then
			return true
		end

		return false
	end

	local thread = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function check()
		if areAllFinished() and thread then
			coroutine.resume(thread)
		end
	end

	maid:Add(completionStateObjects.Rough:observe(function(flag: boolean)
		if flag then
			local proximityPrompt = rough:FindFirstChildWhichIsA("ProximityPrompt", true)
			proximityPrompt.Enabled = false
			check() -- equivalent call inferred; original call site unknown
			local v2 = maid:Add(script.Parent.Parent.Assets.Rough:Clone())
			v2:AddTag("FloatingObject")
			v2:PivotTo(rough:GetPivot() * CFrame.new(0, v2:GetExtentsSize().Y / 2, 0))
			v2.Parent = Workspace
		end
	end, true))
	maid:Add(completionStateObjects.Cut:observe(function(flag: boolean)
		if flag then
			local proximityPrompt = cut:FindFirstChildWhichIsA("ProximityPrompt", true)
			proximityPrompt.Enabled = false
			check() -- equivalent call inferred; original call site unknown
			local v2 = maid:Add(script.Parent.Parent.Assets.Cut:Clone())
			v2:AddTag("FloatingObject")
			v2:PivotTo(cut:GetPivot() * CFrame.new(0, v2:GetExtentsSize().Y / 2, 0))
			v2.Parent = Workspace
		end
	end, true))
	maid:Add(completionStateObjects.Radiant:observe(function(flag: boolean)
		if flag then
			local proximityPrompt = radiant:FindFirstChildWhichIsA("ProximityPrompt", true)
			proximityPrompt.Enabled = false
			check() -- equivalent call inferred; original call site unknown
			local v2 = maid:Add(script.Parent.Parent.Assets.Radiant:Clone())
			v2:PivotTo(radiant:GetPivot() * CFrame.new(0, v2:GetExtentsSize().Y / 2, 0))
			v2:AddTag("FloatingObject")
			v2.Parent = Workspace
		end
	end, true))
	local v2 = false

	local function handleWall()
		for _, part in door:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.CanCollide = false
			part.Transparency = 1
		end
	end

	local function toggleBeam(enabled: boolean)
		v2 = enabled

		for _, effect in beamOfSunshineAndDeath:GetDescendants() do
			if effect:IsA("Beam") then
				effect.Enabled = enabled
			elseif effect:IsA("ParticleEmitter") then
				effect.Enabled = enabled
			end
		end
	end

	local emitCountsByEffect = {}

	for _, effect in beamOfSunshineAndDeath:GetDescendants() do
		if not (effect:IsA("Beam") or effect:IsA("ParticleEmitter")) then
			continue
		end

		effect:AddTag("IgnorePerformance")

		if effect:IsA("ParticleEmitter") then
			emitCountsByEffect[effect] = effect:GetAttribute("EmitCount") or 1
		end
	end

	maid:Add(task.spawn(function()
		while true do
			if v2 then
				for k, v3 in emitCountsByEffect do
					k:Emit(v3)
				end
			end

			task.wait(0.15)
		end
	end))
	maid:Add(function()
		toggleBeam(false)
	end)

	if areAllFinished() then
		handleWall()
	else
		thread = coroutine.create(function()
			coroutine.yield()
			local A = beamOfSunshineAndDeath.A
			local B = beamOfSunshineAndDeath.B
			A.Position = createVector(0, 0, 0)
			B.Position = createVector(0, 0, 0)
			A.Parent = door
			B.Parent = beam.Part
			toggleBeam(true)
			task.wait(5)
			handleWall()
			toggleBeam(false)
		end)

		if thread then
			coroutine.resume(thread)
		end
	end

	if thread then
		maid:Add(thread)
	end

	return function()
		maid:Destroy()
	end
end

return {
	ObserverCallback = observerCallback,
	CompletionStateObjects = completionStateObjects,
	Tag = SharedTimeFlowPuzzle.CollectionServiceTags.GemPlacements
}