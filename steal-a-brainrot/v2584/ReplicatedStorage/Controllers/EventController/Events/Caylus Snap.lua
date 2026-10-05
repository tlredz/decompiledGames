local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Shared.EventTypes)
local SkullEmojiEffectController = require(ReplicatedStorage.Controllers.SkullEmojiEffectController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local ShakePresets = require(ReplicatedStorage.Shared.ShakePresets)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local name = script.Name
local maid = Trove.new()
local CaylusSnap = {}

function CaylusSnap.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function calculateTimeLeftFor(p: number)
		return activeEventData.startedAt + p - workspace:GetServerTimeNow()
	end

	local clone = ShakePresets.BumpS:Clone()
	clone.Amplitude = 0.5
	clone.Sustain = true
	local v = maid:Add(ShakePresets.BindShakeToCamera(clone, workspace.CurrentCamera))
	maid:Add(task.delay(1, function()
		clone:Start()
	end))
	local clone_2 = maid:Clone(script.Part)
	clone_2.Parent = workspace
	local clone2 = maid:Clone(script.Caylus)
	clone2.Parent = workspace
	local clone3 = maid:Clone(script.Sound)
	clone3.Parent = clone2.HumanoidRootPart
	clone3:Play()
	local cFrame = script.StartCFrame.CFrame
	local cFrame2 = script.EndCFrame.CFrame
	clone2:PivotTo(cFrame)
	clone2:ScaleTo(1)
	local animator = clone2.Humanoid.Animator
	local track = animator:LoadAnimation(script.WalkAnimation)
	track.Looped = true
	maid:Add(track, "Stop")
	maid:Add(track)
	track:Play()
	local track2 = animator:LoadAnimation(script.SnapAnimation)
	track2.Looped = false
	maid:Add(track2, "Stop")
	maid:Add(track2)
	local rootPart = clone2.HumanoidRootPart.RootPart
	local model = clone2.Model
	local v2 = {
		model.Cylinder,
		model["Cylinder.001"],
		model["Cylinder.002"],
		model["Cylinder.003"]
	}
	local sizes = {}

	for _, v3 in v2 do
		sizes[v3] = v3.Size
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function rescaleBottle(p: number)
		for _, v3 in v2 do
			v3.Size = sizes[v3] * p
		end
	end

	local v3 = nil
	local v4 = 0
	v3 = maid:Add(RunService.PostSimulation:Connect(function()
		local serverTimeNow = workspace:GetServerTimeNow()
		local v5 = math.clamp((serverTimeNow - activeEventData.startedAt) / 5, 0, 1)
		local v6 = math.clamp((serverTimeNow - (activeEventData.startedAt + 5)) / 1.5833333333333333, 0, 1)

		if v4 < 1 then
			v4 = v5
			clone2:PivotTo(cFrame:Lerp(cFrame2, v5))
			clone2:ScaleTo((math.lerp(1, 6.95, v5)))
		end

		clone.Amplitude = math.lerp(0.5, 3, v5)

		if v6 >= 0.4 then
			local v7 = math.map(v6, 0.4, 0.8, 0, 1)
			rootPart.C1 = CFrame.identity:Lerp(CFrame.new(0, 3.8225000000000002, 0), v7)
			rescaleBottle(6.95 + v7 * 2) -- equivalent call inferred; original call site unknown
		end

		if v6 >= 1 and v3 then
			maid:Remove(v3)
			v3 = nil
		end
	end))
	maid:Add(task.delay(calculateTimeLeftFor(5), function()
		track:Stop()
		track2:Play()
	end))
	local v5 = maid:Add(Observers.observeTag("HideInCaylusSnap", function(p)
		local parent = p.Parent
		p.Parent = script
		return function()
			pcall(function()
				p.Parent = parent
			end)
		end
	end, { workspace, script }))
	maid:Add(Observers.observeTag("HideInSteakSnap", function(p)
		local parent = p.Parent
		p.Parent = script
		return function()
			pcall(function()
				p.Parent = parent
			end)
		end
	end, { workspace, script }))
	maid:Add(task.delay(calculateTimeLeftFor(6.483333333333333), function()
		maid:Remove(v)
	end))
	maid:Add(task.delay(calculateTimeLeftFor(6.833333333333333), function()
		SkullEmojiEffectController:Play(1, "Lower")
	end))
	maid:Add(task.delay(calculateTimeLeftFor(7.5), function()
		EffectController:Activate("Blink")
		maid:Add(task.delay(0.35, function()
			maid:Remove(clone2)
			maid:Remove(v5)
		end))
	end))
end

function CaylusSnap.OnStop(_)
	maid:Destroy()
end

function CaylusSnap.OnLoad(_) end

return CaylusSnap