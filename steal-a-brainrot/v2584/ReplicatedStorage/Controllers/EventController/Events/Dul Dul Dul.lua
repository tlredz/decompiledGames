game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local DulDulDul = {}
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
require(ReplicatedStorage.Controllers.AnimalController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.Utils.MathUtils)
require(ReplicatedStorage.Shared.Snapshot)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local VFX = require(ReplicatedStorage.Shared.VFX)
local name = script.Name
local v = ServerData.IsBiggerServer() and -251 or 0
local remoteEvent = Net:RemoteEvent("EventService/Dul Dul Dul/Burst")
local maid = Trove.new()

local function grow(folder, p: number, fn)
	local function growPart(state, size: Vector3, p2: number, flag: boolean?)
		local cFrame = state.CFrame
		local vector = Vector3.new(flag and 0 or size.X, 0, flag and 0 or size.Z)
		local cFrame2 = cFrame * CFrame.new(0, -(size.Y - vector.Y) / 2, 0)
		state.Size = vector
		state.CFrame = cFrame2
		local transparency = state.Transparency
		state.Transparency = 1
		state.CanCollide = false
		maid:Add(function()
			state.Transparency = transparency
			state.CanCollide = true
			state.Size = size
			state.CFrame = cFrame
		end)
		local maid2 = maid
		local v3

		if fn then
			v3 = fn(p2)
		else
			v3 = p2
		end

		maid2:Add(task.delay(v3, function()
			state.Transparency = transparency
			state.CanCollide = true
			local v4 = not fn and 1 or fn(p2 + 1)
			local tweenInfo = TweenInfo.new(v4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			CreateTween(state, tweenInfo, {
				Size = size
			})
			CreateTween(state, tweenInfo, {
				CFrame = cFrame
			})
		end))
	end

	local parts = {}
	local v2 = 1e999
	local v3 = -1e999

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and part.Transparency < 1) then
			continue
		end

		table.insert(parts, part)
		v2 = math.min(v2, part.Position.Y)
		v3 = math.max(v3, part.Position.Y)
	end

	table.sort(parts, function(a, b)
		return a.Position.Y < b.Position.Y
	end)
	local v4 = v3 - v2

	for _, v5 in parts do
		local v6 = (v5.Position.Y - v2) / v4 * p + 0.25
		growPart(v5, v5.Size, v6)
	end
end

local function initActivationVisual()
	local maid2 = maid:Extend()
	local v2 = table.create(4)
	maid2:Add(function()
		table.clear(v2)
	end)
	local total = 0
	maid2:Add(RunService.PreRender:Connect(function(dt: number)
		debug.profilebegin("Dul Dul Dul Event")
		total += dt

		for k, v3 in v2 do
			if not (v3.target and v3.targetAttachment) then
				continue
			end

			v3.beam.First.Enabled = true
			v3.beam.Second.Enabled = true
			local v4 = math.clamp(total - k + 1, 0, 1)
			local worldPosition = v3.beam.WorldPosition
			v3.targetAttachment.Position = worldPosition + (v3.target:GetPivot().Position - worldPosition) * v4
		end

		debug.profileend()
	end))
	maid2:Add(Observers.observeTag("DulDulDulPlayerVFX", function(parent)
		local clone = script.PlayerVFX.Beam:Clone()
		clone.Parent = parent
		local clone2 = script.PlayerVFX.Torso:Clone()
		clone2.Parent = parent
		local dulDulDulIndex = parent:GetAttribute("DulDulDulIndex")
		v2[dulDulDulIndex] = {
			beam = clone,
			target = nil
		}
		local v3 = Observers.observeTag("DulDulDulPlayerVFX", function(target)
			if not (target ~= parent and target:GetAttribute("DulDulDulIndex") == parent:GetAttribute("DulDulDulIndex") % 4 + 1) then
				return nil
			end

			local attachment = Instance.new("Attachment")
			attachment.Position = clone.WorldPosition
			attachment.Parent = workspace.Terrain
			local v4 = v2[parent:GetAttribute("DulDulDulIndex")]
			v4.target = target
			v4.beam.First.Attachment0 = attachment
			v4.beam.Second.Attachment0 = attachment
			v4.targetAttachment = attachment
			return function()
				attachment:Destroy()
			end
		end)
		return function()
			clone2:Destroy()
			clone:Destroy()
			v3()
			v2[dulDulDulIndex] = nil
		end
	end))
end

function DulDulDul.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)
	maid:Add(function()
		EffectController:Activate("Blink")
		CycleController:Update()
		SoundController:UpdateOST()
		SoundController:UpdateAmbience()
	end)
	CycleController:Update()
	SoundController:UpdateOST()
	SoundController:UpdateAmbience()
	maid:Add(task.spawn(function()
		initActivationVisual()
	end))
	maid:Add(Observers.observeTag("DulDulDul", function(parent)
		local maid2 = Trove.new()
		local humanoidRootPart = parent:WaitForChild("HumanoidRootPart")
		local clone = maid2:Clone(script["Dul Dul Dul"])
		local v2 = maid2:Add(Instance.new("Weld"))
		v2.Part0 = clone.PrimaryPart
		v2.Part1 = humanoidRootPart
		v2.C0 = CFrame.Angles(0, 0, 0)
		v2.Parent = clone.PrimaryPart
		clone.Parent = parent
		local animator = clone.AnimationController.Animator
		local track = animator:LoadAnimation(script.Idle)
		track.Priority = Enum.AnimationPriority.Idle
		track.Looped = true
		track:Play()
		local track2 = animator:LoadAnimation(script.Walk)
		track2.Priority = Enum.AnimationPriority.Movement
		local index = parent:GetAttribute("Index")
		local track3 = animator:LoadAnimation(script[(index == 1 or index == 4) and "Build2" or "Build1"])
		track3.Priority = Enum.AnimationPriority.Action
		local track4 = animator:LoadAnimation(script.Gesture)
		track4.Priority = Enum.AnimationPriority.Action2
		local track5 = animator:LoadAnimation(script.Attack)
		track5.Priority = Enum.AnimationPriority.Action3
		local v3 = nil
		maid2:Add(track5:GetMarkerReachedSignal("CreateTie"):Connect(function()
			if v3 then
				return
			end

			local clone2 = maid:Clone(script.Tie)
			clone2.RigidConstraint.Attachment1 = clone:FindFirstChild("HandAttachment", true)
			clone2.Parent = clone
			v3 = clone2
		end))
		maid2:Add(track5:GetMarkerReachedSignal("DestroyTie"):Connect(function()
			if v3 then
				maid:Remove(v3)
				v3 = nil
			end
		end))
		maid2:Add(track5:GetMarkerReachedSignal("Freeze"):Connect(function()
			if not parent:GetAttribute("FinishAttackAnimation") then
				track5:AdjustSpeed(0)
			end
		end))
		maid2:Add(task.defer(function()
			if parent:GetAttribute("IsRunning") then
				track2:Play()
			end
		end))
		maid2:Add(Observers.observeAttribute(parent, "IsBuilding", function(p)
			if not p then
				return nil
			end

			local clone2 = script.Hammer:Clone()
			clone2["Cube.010"].RigidConstraint.Attachment1 = clone:FindFirstChild("HandAttachment", true)
			clone2.Parent = clone
			track3:Play()
			return function()
				track3:Stop()
				clone2:Destroy()
			end
		end))
		local v4 = nil
		maid2:Add(Observers.observeAttribute(parent, "Gesture", function(p)
			if not p then
				return nil
			end

			local clone2 = ReplicatedStorage.Sounds.Events["Dul Dul Dul"].Yap:Clone()
			clone2.Parent = clone.PrimaryPart
			clone2:Play()
			v4 = clone2
			track4:Play()
			return function()
				clone2:Destroy()
				clone2:Stop()
				track4:Stop()

				if v4 == clone2 then
					v4 = nil
				end
			end
		end))
		maid2:Add(parent:GetAttributeChangedSignal("AttackAnimation"):Connect(function()
			if v3 then
				maid:Remove(v3)
				v3 = nil
			end

			if v4 then
				v4:Pause()
			end

			track5:Play()
		end))
		maid2:Add(track5.Ended:Connect(function()
			if v4 then
				v4:Resume()
			end
		end))
		maid2:Add(parent:GetAttributeChangedSignal("FinishAttackAnimation"):Connect(function()
			if parent:GetAttribute("FinishAttackAnimation") then
				track5:AdjustSpeed(1)
			end
		end))
		maid2:Add(parent:GetAttributeChangedSignal("IsRunning"):Connect(function()
			if parent:GetAttribute("IsRunning") then
				track2:Play()
			else
				track2:Stop()
			end
		end))
		return maid2:WrapClean()
	end))
	maid:Add(task.delay(activeEventData.startedAt + 4 - workspace:GetServerTimeNow(), function()
		EffectController:Activate("Blink")
		local v2

		if ServerData.IsBiggerServer() then
			v2 = script.SchoolMapBigger
		else
			v2 = script.SchoolMap
		end

		local clone = maid:Clone(v2)
		clone.Parent = workspace
		maid:Add(Observers.observeTag("HideInDulDulDul", function(p)
			local parent = p.Parent
			p.Parent = script
			return function()
				pcall(function()
					p.Parent = parent
				end)
			end
		end, { workspace, script }))
		EffectController:Run("DulDulDulEvent", "GrassRecolor")
		maid:Add(function()
			EffectController:Stop("DulDulDulEvent", "GrassRecolor")
		end)
		EffectController:Run("DulDulDulEvent", "WallRecolor")
		maid:Add(function()
			EffectController:Stop("DulDulDulEvent", "WallRecolor")
		end)
		EffectController:Run("DulDulDulEvent", "WallBottomRecolor")
		maid:Add(function()
			EffectController:Stop("DulDulDulEvent", "WallBottomRecolor")
		end)
	end))
	maid:Add(task.spawn(function()
		while not ReplicatedStorage:GetAttribute("DulDulDulConstructionStart") do
			task.wait()
		end

		local dulDulDulConstructionStart = ReplicatedStorage:GetAttribute("DulDulDulConstructionStart")

		if not dulDulDulConstructionStart then
			return
		end

		local clone = maid:Clone(script.Machine)
		clone:PivotTo(clone:GetPivot() + Vector3.new(0, 0, v))
		clone.Parent = workspace
		SoundController:PlaySound(ReplicatedStorage.Sounds.Events["Dul Dul Dul"].Building, clone.Root.Position, false)
		local clone2 = maid:Clone(script.BuildingVFX)
		clone2:PivotTo(clone2:GetPivot() + Vector3.new(0, 0, v))
		clone2.Parent = workspace
		grow(clone.Animate.AnimateObjects, 6, function(p)
			return dulDulDulConstructionStart + p + 3 - workspace:GetServerTimeNow()
		end)
		maid:Add(task.delay(dulDulDulConstructionStart + 3 - workspace:GetServerTimeNow(), function()
			VFX.enable(clone2)
			maid:Add(task.delay(dulDulDulConstructionStart + 6 + 3 - workspace:GetServerTimeNow(), function()
				VFX.disable(clone2)
			end))
		end))
	end))
end

function DulDulDul.OnStop(_)
	maid:Destroy()
end

function DulDulDul.OnLoad(_)
	task.spawn(pcall, function()
		ContentProvider:PreloadAsync(script:GetChildren())
	end)
	task.spawn(pcall, function()
		ContentProvider:PreloadAsync(ReplicatedStorage.Sounds.Events["Dul Dul Dul"]:GetChildren())
	end)
	remoteEvent.OnClientEvent:Connect(function(p: string)
		ClientEventUtils.playBurst(script.Burst, p, { ReplicatedStorage.Sounds.Events["Dul Dul Dul"].Burst })
	end)
end

return DulDulDul