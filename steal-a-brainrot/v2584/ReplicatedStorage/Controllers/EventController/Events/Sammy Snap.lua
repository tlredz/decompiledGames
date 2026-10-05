local createVector = vector.create
game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
game:GetService("HttpService")
game:GetService("StarterGui")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
game:GetService("Players")
game:GetService("Debris")
require(ReplicatedStorage.Shared.EventTypes)
local SammySnap = {}
local SkullEmojiEffectController = require(ReplicatedStorage.Controllers.SkullEmojiEffectController)
require(ReplicatedStorage.Controllers.CharacterController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
require(ReplicatedStorage.Controllers.AnimalController)
require(ReplicatedStorage.Controllers.SoundController)
require(ReplicatedStorage.Controllers.CycleController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
require(ReplicatedStorage.Shared.SharedEventUtils)
require(ReplicatedStorage.Packages.Serialization)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
require(ReplicatedStorage.Shared.ShakePresets)
require(ReplicatedStorage.Packages.TopbarPlus)
require(ReplicatedStorage.Packages.Observers)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local MapInformation = require(ReplicatedStorage.Shared.MapInformation)
require(ReplicatedStorage.Packages.Moonlite)
require(ReplicatedStorage.Utils.MathUtils)
require(ReplicatedStorage.Packages.Squash)
require(ReplicatedStorage.Packages.Shake)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Packages.Net)
require(ReplicatedStorage.Packages.Spr)
local VFX = require(ReplicatedStorage.Shared.VFX)
local _ = workspace.RenderedMovingAnimals
local name = script.Name
local maid = Trove.new()

local function waitForTrackLength(p)
	local lastTime = os.clock()

	while p.Length <= 0 do
		if os.clock() - lastTime >= 5 then
			warn((`[Sammy Snap] Animation '{not p.Animation and "?" or p.Animation.Name or "?"}' length never resolved`))
			break
		else
			task.wait()
		end
	end

	return p.Length
end

function SammySnap.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)
	local v

	if activeEventData.arguments == nil then
		v = false
	else
		v = table.find(activeEventData.arguments, "Coffin") ~= nil
	end

	local v2 = v and 5.5 or 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function calculateTimeLeftFor(p: number)
		return activeEventData.startedAt + v2 + p - workspace:GetServerTimeNow()
	end

	local function loadAnimationsOnRig(clone, items)
		local tracksByChildName = {}

		for childName, animation in items do
			local child = clone:FindFirstChild(childName)

			if child then
				local animator = child:FindFirstChildWhichIsA("Animator", true)

				if animator then
					local track = animator:LoadAnimation(animation)
					maid:Add(track, "Stop")
					maid:Add(track)
					tracksByChildName[childName] = track
				else
					warn((`[Sammy Snap] No Animator under part: {childName}`))
				end
			else
				warn((`[Sammy Snap] Coffin rig missing part: {childName}`))
			end
		end

		return tracksByChildName
	end

	local clone = nil
	local pivot = nil
	local v3, sammy5

	if v then
		local clone2 = maid:Clone(script.Coffin)

		for _, v4 in clone2:QueryDescendants("BasePart"), nil, nil do
			v4.CollisionGroup = "BombardiroEventCollisionGroup"
		end

		clone2.Parent = workspace
		v3 = clone2
		local pivot2 = clone2:GetPivot()
		local coffin = clone2:FindFirstChild("Coffin")

		if coffin and coffin:IsA("Model") then
			coffin = coffin.PrimaryPart
		elseif not (coffin and coffin:IsA("BasePart")) then
			coffin = clone2.PrimaryPart
		end

		local v4

		if coffin then
			v4 = maid:Add(Instance.new("Sound"))
			v4.RollOffMode = Enum.RollOffMode.InverseTapered
			v4.RollOffMinDistance = 50
			v4.RollOffMaxDistance = 1500
			v4.Looped = true
			v4.SoundId = "rbxassetid://113669291729126"
			v4.Volume = 0.5
			v4.SoundGroup = SoundService.Cutscene.WorkspaceSounds.EventMusic
			v4.Parent = coffin
			v4:Play()
			v4.TimePosition = 15.2
		else
			v4 = nil
		end

		local coffinSequence = coffin and ReplicatedStorage.Sounds.Events["Sammy Snap"]:FindFirstChild("CoffinSequence")

		if coffinSequence then
			local clone3 = maid:Clone(coffinSequence)
			clone3.Parent = coffin
			clone3:Play()
		end

		local v5 = loadAnimationsOnRig(clone2, {
			Coffin = script.CoffinWalkCoffin1,
			Sammy1 = script.CoffinWalkSammy1,
			Sammy2 = script.CoffinWalkSammy2,
			Sammy3 = script.CoffinWalkSammy3,
			Sammy4 = script.CoffinWalkSammy4,
			Sammy5 = script.CoffinWalkSammy5
		})

		for _, v6 in v5 do
			v6.Looped = true
			v6:Play()
		end

		local startedAt = activeEventData.startedAt
		local postSimulationConnection = nil
		postSimulationConnection = RunService.PostSimulation:Connect(function()
			local v6 = math.clamp((workspace:GetServerTimeNow() - startedAt) / 2.5, 0, 1)
			clone2:PivotTo(pivot2:Lerp(pivot2 + createVector(0, 0, 23), v6))

			if v6 >= 1 then
				postSimulationConnection:Disconnect()
			end
		end)
		maid:Add(postSimulationConnection)
		local v6 = true
		maid:Add(function()
			v6 = false
		end)
		local v7 = activeEventData.startedAt + 2.5 - workspace:GetServerTimeNow()

		if v7 > 0 then
			task.wait(v7)
		end

		if not v6 then
			return
		end

		for _, v8 in v5 do
			v8:Stop()
		end

		if v4 then
			maid:Add(task.delay(2.5, function()
				CreateTween(v4, TweenInfo.new(2.5), {
					Volume = 0
				})
			end))
		end

		local v8 = loadAnimationsOnRig(clone2, {
			Coffin = script.CoffinCoffin1,
			Sammy1 = script.CoffinSammy1,
			Sammy2 = script.CoffinSammy2,
			Sammy3 = script.CoffinSammy3,
			Sammy4 = script.CoffinSammy4,
			Sammy5 = script.CoffinSammy5
		})
		sammy5 = v8.Sammy5

		for _, v9 in v8 do
			v9.Looped = false
			waitForTrackLength(v9)
		end

		local v9 = activeEventData.startedAt + 2.5
		local timePosition = math.max(workspace:GetServerTimeNow() - v9, 0)

		for _, v11 in v8 do
			v11:Play()

			if timePosition > 0 and timePosition < v11.Length then
				v11.TimePosition = timePosition
			end

			local v12 = math.max(v11.Length - 0.05 - timePosition, 0)
			local v13 = v11
			maid:Add(task.delay(v12, function()
				v13:AdjustSpeed(0)
			end))
		end

		local v11 = activeEventData.startedAt + 5.5 - workspace:GetServerTimeNow()

		if v11 > 0 then
			task.wait(v11)
		end

		local sammy52 = clone2:FindFirstChild("Sammy5")

		if sammy52 then
			pivot = sammy52:GetPivot()
			clone = sammy52
		end
	else
		v3 = nil
	end

	if clone then
		if sammy5 then
			sammy5:Stop()
		end

		clone.Parent = workspace
		maid:Add(clone)

		for _, child in script.SammyEffects:GetChildren() do
			local clone_2 = child:Clone()
			clone_2.Parent = clone.UpperTorso
		end

		local highlight = Instance.new("Highlight")
		highlight.Name = "Highlight"

		if ServerData.IsTsunamiServer() then
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		else
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		end

		highlight.FillTransparency = 1
		highlight.OutlineColor = Color3.fromRGB(255, 12, 12)
		highlight.Parent = clone
		maid:Add(highlight)
	else
		clone = maid:Clone(script.Sammy)
		clone.Parent = workspace
	end

	for _, v4 in clone:QueryDescendants("BasePart"), nil, nil do
		v4.CollisionGroup = "BombardiroEventCollisionGroup"
	end

	local clone2 = maid:Clone(ReplicatedStorage.Sounds.Events["Sammy Snap"].Fire)
	clone2.Parent = clone.HumanoidRootPart
	clone2:Play()
	local clone3 = maid:Clone(ReplicatedStorage.Sounds.Events["Sammy Snap"].Walk)
	clone3.Parent = clone.HumanoidRootPart
	clone3:Play()
	local _ = activeEventData.startedAt + 11.17 - workspace:GetServerTimeNow()
	local track = clone.AnimationController.Animator:LoadAnimation(script.WalkAnimation)
	track.Looped = true
	maid:Add(track, "Stop")
	maid:Add(track)
	local track2 = clone.AnimationController.Animator:LoadAnimation(script.SnapAnimation)
	track2.Looped = false
	maid:Add(track2, "Stop")
	maid:Add(track2)
	maid:Add(track2:GetMarkerReachedSignal("Freeze"):Connect(function()
		track2:AdjustSpeed(0)
	end))
	track:Play()
	local v4 = (v and 1 or 0) + 9
	local v5

	if ServerData.IsJumpLTMServer() then
		v5 = 260
	elseif ServerData.IsTsunamiServer() then
		v5 = 350
	elseif ServerData.IsBiggerServer() then
		v5 = 250
	else
		v5 = 150
	end

	local startTsunami = script:FindFirstChild("StartTsunami")
	local position = MapInformation.MapCenter.Position
	local cFrame

	if ServerData.IsJumpLTMServer() then
		cFrame = CFrame.new(position.X, 1, position.Z - v5) * CFrame.Angles(0, 3.141592653589793, 0)
	elseif ServerData.IsTsunamiServer() and startTsunami then
		cFrame = startTsunami.CFrame
	else
		cFrame = workspace.Road.StartGround.CFrame
	end

	local v6 = pivot or cFrame
	local v7 = ServerData.IsTsunamiServer() and 10 or 1
	local v8 = ServerData.IsTsunamiServer() and 50 or 13.9
	maid:Add(RunService.PostSimulation:Connect(function(_: number)
		debug.profilebegin("Sammy Snap:Update")
		local timeLeftFor = calculateTimeLeftFor(v4) -- equivalent call inferred; original call site unknown
		local v10 = math.clamp((v4 - timeLeftFor) / v4, 0, 1)
		clone:PivotTo(v6:Lerp(v6 + Vector3.new(0, 0, v5), v10))
		clone:ScaleTo((math.lerp(v7, v8, v10 * v10)))
		debug.profileend()
	end))
	maid:Add(task.delay(calculateTimeLeftFor(v4), function()
		track2:Play()
	end))
	local maid2 = maid
	maid2:Add(task.delay(calculateTimeLeftFor(v4 + 0.5), function()
		SkullEmojiEffectController:Play(2.5, "Lower")
	end))
	local maid3 = maid
	maid3:Add(task.delay(calculateTimeLeftFor(v4 + 0.5), function()
		ReplicatedStorage.Sounds.Events["Sammy Snap"].Snap:Play()
		local leftHand = clone.LeftHand
		local clone4 = maid:Clone(script.Snap)
		clone4.CFrame = leftHand.CFrame
		clone4.Parent = workspace
		local weld = Instance.new("Weld")
		weld.Part0 = clone4
		weld.Part1 = leftHand
		weld.Parent = clone4
		VFX.emit(clone4)
	end))
	local maid4 = maid
	maid4:Add(task.delay(calculateTimeLeftFor(v4 + 1 + 2), function()
		SkullEmojiEffectController:Stop()
		EffectController:Activate("Blink")
		maid:Remove(clone)

		if v3 then
			maid:Remove(v3)
		end
	end))
end

function SammySnap.OnStop(_)
	maid:Destroy()
end

function SammySnap.OnLoad(_)
	task.spawn(pcall, function()
		ContentProvider:PreloadAsync(script:GetChildren())
	end)
	task.spawn(pcall, function()
		ContentProvider:PreloadAsync(ReplicatedStorage.Models.Events["Sammy Snap"])
	end)
end

return SammySnap