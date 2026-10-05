local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local GingerbreadTown = {}
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
require(ReplicatedStorage.Controllers.AnimalController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.Utils.MathUtils)
require(ReplicatedStorage.Packages.Signal)
require(ReplicatedStorage.Packages.FFlags)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Net = require(ReplicatedStorage.Packages.Net)
require(ReplicatedStorage.Packages.Spr)
local VFX = require(ReplicatedStorage.Shared.VFX)
local name = script.Name
local localPlayer = Players.LocalPlayer
local remoteEvent = Net:RemoteEvent("EventService/Gingerbread Town/CollectCandy")
local remoteEvent2 = Net:RemoteEvent("EventService/Gingerbread Town/DestroyRings")
local remoteEvent3 = Net:RemoteEvent("EventService/Gingerbread Town/CreateRings")
local remoteEvent4 = Net:RemoteEvent("EventService/Gingerbread Town/UpdateRide")
local remoteEvent5 = Net:RemoteEvent("EventService/Gingerbread Town/Burst")
local maid = Trove.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function loadAnimation(animator, animation, maid2)
	local track = animator:LoadAnimation(animation);
	(maid2 or maid):Add(function()
		track:Stop(0)
		track:Destroy()
	end)
	return track
end

function GingerbreadTown.OnStart(_)
	assert((EventController:GetActiveEventData(name)))
	local cartoon = Lighting:FindFirstChild("Cartoon")

	if cartoon then
		cartoon.Parent = script
		maid:Add(function()
			cartoon.Parent = Lighting
		end)
	end

	local clone_2 = maid:Clone(script.NightSky)
	clone_2.Parent = Lighting
	local clone = maid:Clone(script.GingerbreadTown)
	maid:Extend()
	local v = nil
	local v2 = nil

	local function calculateRideAlpha(p: number, p2: number, p3: number)
		return math.clamp((p - p2) / p3, 0, 1), p < p2 or p2 + p3 < p
	end

	maid:Add(remoteEvent4.OnClientEvent:Connect(function(p: number, p2: number)
		v = p
		v2 = p2
	end))
	local extended = maid:Extend()
	local v3 = {}
	maid:Add(remoteEvent3.OnClientEvent:Connect(function(items)
		if not localPlayer:GetAttribute("SleighSeated") then
			return
		end

		for k, item in items do
			local extended2 = extended:Extend()
			local candycane = clone.Rings:GetChildren()[item.ring].Candycane
			local clone2 = extended2:Clone(script.Drop)
			clone2:PivotTo(candycane:GetPivot())
			clone2.BillboardGui.CurrencyCandyCane.Text = `+{item.amount}`
			clone2.Parent = workspace
			local clone3 = extended2:Clone(script.ActivatedCandyCaneVFX.Attachment)
			clone3.Parent = candycane
			table.insert(v3, {
				ringTrove = extended2,
				vfx = clone3,
				ring = item.ring,
				amount = item.amount,
				uuid = k,
				drop = clone2
			})
		end
	end))
	maid:Add(remoteEvent2.OnClientEvent:Connect(function()
		extended:Clean()
		table.clear(v3)
	end))

	local function createSyncedAnimator(animator, animation, callback)
		local maid2 = Trove.new()
		local track = loadAnimation(animator, animation, maid2) -- equivalent call inferred; original call site unknown
		maid2:Add(RunService.PreRender:Connect(function()
			if not (v and v2) then
				return
			end

			local serverTimeNow = workspace:GetServerTimeNow()
			local v5 = v
			local v6 = v2
			local v7 = math.clamp((serverTimeNow - v5) / v6, 0, 1)
			local v8 = serverTimeNow < v5 or v5 + v6 < serverTimeNow
			local timePosition2 = v7 * v2
			local timePosition = track.TimePosition
			local v10 = true

			if v8 then
				if track.IsPlaying then
					track.TimePosition = 0
					track:Stop(0)
				end

				v10 = false
			elseif math.abs(timePosition2 - timePosition) > 0.1 then
				if not track.IsPlaying then
					track:Play()
				end

				track.TimePosition = timePosition2
			end

			if callback then
				callback(v10, timePosition2)
			end
		end))
		return maid2:WrapClean()
	end

	local function playCharacterAnimation(localPlayer2, p)
		local character = localPlayer2.Character

		if not character then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local clone2 = script.Reward:Clone()
		clone2.CurrencyCandyCane.Text = `+{p}`
		clone2.Parent = humanoidRootPart
		TweenService:Create(clone2, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			StudsOffset = createVector(0, 2.5, 2.2)
		}):Play()
		TweenService:Create(
			clone2.ImageLabel.ImageLabel,
			TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 1.5),
			{
				ImageTransparency = 1
			}
		):Play()
		TweenService:Create(
			clone2.CurrencyCandyCane,
			TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 1.5),
			{
				TextTransparency = 1
			}
		):Play()
		TweenService:Create(
			clone2.CurrencyCandyCane.UIStroke,
			TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 1.5),
			{
				Transparency = 1
			}
		):Play()
		task.delay(5, function()
			clone2:Destroy()
		end)
	end

	local function playScreenCandyCaneAnimation(p)
		local random = Random.new()

		for _ = 1, math.min(p, 30) do
			local clone2 = script.Image:Clone()
			clone2.Position = UDim2.fromScale(random:NextNumber(-0.25, 1.25), -(0.25 - random:NextNumber(0, 0.125)))
			clone2.Rotation = random:NextNumber(-120, 120)
			local number = random:NextNumber(0.15, 0.2)
			clone2.Size = UDim2.fromScale(number, number)
			clone2.Parent = Players.LocalPlayer.PlayerGui:FindFirstChild("Effects")
			CreateTween(
				clone2,
				TweenInfo.new(random:NextNumber(0.75, 1.3), Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					Position = clone2.Position + UDim2.fromScale(0, 1.5),
					Rotation = clone2.Rotation + random:NextInteger(-3, 3) * 10
				},
				true
			).Completed:Once(function()
				task.wait(1)
				clone2:Destroy()
			end)
		end
	end

	EffectController:Run("GingerbreadTownEvent", "GrassRecolor")
	maid:Add(function()
		EffectController:Stop("GingerbreadTownEvent", "GrassRecolor")
	end)
	EffectController:Run("GingerbreadTownEvent", "WallRecolor")
	maid:Add(function()
		EffectController:Stop("GingerbreadTownEvent", "WallRecolor")
	end)
	EffectController:Run("GingerbreadTownEvent", "WallBottomRecolor")
	maid:Add(function()
		EffectController:Stop("GingerbreadTownEvent", "WallBottomRecolor")
	end)
	clone.Parent = workspace
	maid:Add(remoteEvent.OnClientEvent:Connect(function(p: string, p2: number)
		playCharacterAnimation(localPlayer, p2)
		playScreenCandyCaneAnimation(p2)
		task.spawn(function()
			SoundController:PlaySound(ReplicatedStorage.Sounds.Events["Gingerbread Town"].CandyCane)
		end)

		for k, v4 in v3 do
			if v4.uuid ~= p then
				continue
			end

			v4.ringTrove:Clean()
			local clone2 = script.BurstVFX:Clone()
			clone2:PivotTo(v4.drop:GetPivot() * CFrame.Angles(0, 1.5707963267948966, 0))
			clone2.Parent = workspace
			VFX.emit(clone2)
			task.delay(5, function()
				clone2:Destroy()
			end)
			table.remove(v3, k)
			break
		end
	end))
	maid:Add(Timer.Simple(0.05, function()
		if #v3 == 0 then
			return
		end

		local character = localPlayer.Character

		if not character then
			return
		end

		for _, v4 in v3 do
			if not ((v4.drop:GetPivot().Position - character:GetPivot().Position).Magnitude <= 30) then
				continue
			end

			remoteEvent:FireServer(v4.uuid)
		end
	end))
	maid:Add(Observers.observeTag("GingerbreadTownReindeer", function(animator)
		local maid2 = Trove.new();
		(loadAnimation(animator, script.ReindeerIdle, maid2)):Play(0)
		maid2:Add(createSyncedAnimator(animator, script.ReindeerTravel))
		return maid2:WrapClean()
	end))
	maid:Add(Observers.observeTag("GingerbreadTownSleigh", function(p)
		local maid2 = Trove.new()
		local clone2 = maid2:Clone(ReplicatedStorage.Sounds.Events["Gingerbread Town"].Fly)
		maid:Add(Observers.observeChildren(p.Parent.Parent, function(parent)
			if parent.Name == "SleighMain" then
				clone2.Parent = parent
			end

			return nil
		end))
		local v4 = {}
		local v5 = nil
		maid2:Add(Observers.observeTag("GingerbreadTownSleighMainWeld", function(p2)
			table.insert(v4, p2)

			if v5 then
				p2.C1 = CFrame.Angles(1.5707963267948966, 0, 0)
			end

			return function()
				local index = table.find(v4, p2)

				if index then
					table.remove(v4, index)
				end
			end
		end))
		maid2:Add(createSyncedAnimator(p, script.SleighTravel, function(p2)
			if v5 == p2 then
				return
			end

			if p2 then
				if not clone2.IsPlaying then
					clone2:Play()
				end
			elseif clone2.IsPlaying then
				clone2:Stop()
			end

			v5 = p2

			for _, v6 in v4 do
				local v7 = v6
				task.defer(function()
					local v8 = v7
					local C1

					if p2 then
						C1 = CFrame.Angles(1.5707963267948966, 0, 0)
					else
						C1 = CFrame.identity
					end

					v8.C1 = C1
				end)
			end
		end))
		return maid2:WrapClean()
	end))
	maid:Add(Observers.observeTag("GingerbreadTownEventReindeer", function(part)
		local maid2 = Trove.new()
		local clone2 = maid2:Clone(script.BabyReindeer)
		clone2.Parent = workspace
		local weld = Instance.new("Weld")
		weld.Part0 = clone2.PrimaryPart
		weld.Part1 = part
		weld.C0 = clone2.PrimaryPart.PivotOffset
		weld.Parent = clone2.PrimaryPart
		local track = clone2.AnimationController.Animator:LoadAnimation(script.BabyReindeerIdle)
		maid:Add(function()
			track:Stop(0)
			track:Destroy()
		end)
		track.Priority = Enum.AnimationPriority.Idle
		track.Looped = true
		track:Play()
		local track2 = clone2.AnimationController.Animator:LoadAnimation(script.BabyReindeerMove)
		maid:Add(function()
			track2:Stop(0)
			track2:Destroy()
		end)
		track2.Priority = Enum.AnimationPriority.Action
		track2.Looped = true
		maid2:Add(Observers.observeAttribute(part, "Moving", function(p)
			if p then
				track2:Play()
			else
				track2:Stop()
			end

			return nil
		end))
		return maid2:WrapClean()
	end, { workspace }))
	maid:Add(function()
		EffectController:Activate("Blink")
	end)
	maid:Add(Observers.observeTag("HideInGingerbreadTown", function(p)
		local parent = p.Parent
		p.Parent = script
		return function()
			pcall(function()
				p.Parent = parent
			end)
		end
	end, { workspace, script }))
	CycleController:Update()
	SoundController:UpdateOST()
	EffectController:Activate("Blink")
	maid:Add(function()
		CycleController:Update()
		SoundController:UpdateOST()
	end)
end

function GingerbreadTown.OnStop(_)
	maid:Destroy()
end

function GingerbreadTown.OnLoad(_)
	remoteEvent5.OnClientEvent:Connect(function(p: string)
		ClientEventUtils.playBurst(script.ReindeerBurst, p, { ReplicatedStorage.Sounds.Events["Gingerbread Town"].Hit })
	end)
end

return GingerbreadTown