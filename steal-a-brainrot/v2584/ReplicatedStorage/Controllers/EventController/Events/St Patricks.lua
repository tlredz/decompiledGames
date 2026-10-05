local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
local Players = game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local StPatricks = {}
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
require(ReplicatedStorage.Controllers.AnimalController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
require(ReplicatedStorage.Shared.ShakePresets)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local MathUtils = require(ReplicatedStorage.Utils.MathUtils)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local VFX = require(ReplicatedStorage.Shared.VFX)
local name = script.Name
local remoteEvent = Net:RemoteEvent("EventService/St Patricks/DestroyGoldCoin")
local remoteEvent2 = Net:RemoteEvent("EventService/St Patricks/SpawnGoldCoin")
local remoteEvent3 = Net:RemoteEvent("EventService/St Patricks/ClaimGoldCoin")
local remoteEvent4 = Net:RemoteEvent("EventService/St Patricks/Hit")
local maid = Trove.new()
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }

function StPatricks.OnStart(_)
	assert((EventController:GetActiveEventData(name)))
	ReplicatedStorage:SetAttribute("StPatricksEvent", true)
	maid:Add(function()
		ReplicatedStorage:SetAttribute("StPatricksEvent", nil)
	end)
	local clone

	if ServerData.IsTsunamiServer() then
		clone = maid:Clone(script.MapTsunami)
	elseif ServerData.IsBiggerServer() then
		clone = maid:Clone(script.MapBigger)
	else
		clone = maid:Clone(script.Map)
	end

	clone.Parent = workspace
	EffectController:Activate("Blink")
	maid:Add(function()
		EffectController:Activate("Blink")
	end)
	maid:Add(Observers.observeTag("HideInStPatricks", function(p)
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
	SoundController:UpdateAmbience()
	EffectController:Run("StPatricksEvent", "GrassRecolor")
	maid:Add(function()
		EffectController:Stop("StPatricksEvent", "GrassRecolor")
	end)
	EffectController:Run("StPatricksEvent", "WallRecolor")
	maid:Add(function()
		EffectController:Stop("StPatricksEvent", "WallRecolor")
	end)
	EffectController:Run("StPatricksEvent", "WallBottomRecolor")
	maid:Add(function()
		EffectController:Stop("StPatricksEvent", "WallBottomRecolor")
	end)
	local stPatricksPot = workspace.StPatricksPot
	maid:Add(task.spawn(function()
		VFX.emit(stPatricksPot.RainbowEmit)
	end))
	maid:Add(task.spawn(function()
		SoundController:PlaySound(
			"Sounds.Sfx.RainbowActivatedEffect",
			stPatricksPot.Rainbow.SoundParts.RainbowActivatedEffect.Position
		)
	end))
	maid:Add(task.spawn(function()
		SoundController:PlaySound(
			"Sounds.Sfx.RainbowMachineEnabled",
			stPatricksPot.Rainbow.SoundParts.RainbowMachineEnabled.Position
		)
	end))
	maid:Add(Observers.observeTag("StPatricksRainbowEventAttachment", function(instance)
		local numberSequence = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(
				1,
				1
			) })
		local children = instance:GetChildren()

		for _, v in children do
			v.Transparency = numberSequence
			v.Enabled = true
		end

		local serverTimeNow = workspace:GetServerTimeNow()

		while instance:IsDescendantOf(workspace) do
			local serverTimeNow2 = workspace:GetServerTimeNow()
			local v = (serverTimeNow2 - serverTimeNow) % 3.5 / 3.5
			local numberSequence2 = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1 - v, 1),
				NumberSequenceKeypoint.new(1, 0)
			})

			if serverTimeNow2 - serverTimeNow >= 3.5 then
				for _, v2 in children do
					v2.Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 0)
					})
				end

				break
			else
				for _, v2 in children do
					v2.Transparency = numberSequence2
				end

				task.wait()
			end
		end

		return nil
	end, { workspace }))
	maid:Add(Observers.observeChildren(stPatricksPot.Rainbow.Enabled, function(p)
		VFX.enable(p)
		return function()
			VFX.disable(p)
		end
	end))
end

function StPatricks.OnStop(_)
	maid:Destroy()
end

function StPatricks.OnLoad(_)
	remoteEvent4.OnClientEvent:Connect(function(p)
		ClientEventUtils.playBurst(script.Burst, p, { ReplicatedStorage.Sounds.Events["St Patricks"].Hit })
	end)
	local v = {}

	local function playCharacterAnimation(player, p)
		local character = player.Character

		if not character then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local clone = script.Reward:Clone()
		clone.CurrencyGoldCoins.Text = `+{p}`
		clone.Parent = humanoidRootPart
		TweenService:Create(clone, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			StudsOffset = createVector(0, 2.5, 2.2)
		}):Play()
		TweenService:Create(
			clone.ImageLabel.ImageLabel,
			TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 1.5),
			{
				ImageTransparency = 1
			}
		):Play()
		TweenService:Create(
			clone.CurrencyGoldCoins,
			TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 1.5),
			{
				TextTransparency = 1
			}
		):Play()
		TweenService:Create(
			clone.CurrencyGoldCoins.UIStroke,
			TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 1.5),
			{
				Transparency = 1
			}
		):Play()
		task.delay(5, function()
			clone:Destroy()
		end)
	end

	local function playScreenGoldAnimation(p)
		local random = Random.new()

		for _ = 1, math.min(p, 30) do
			local clone = script.Image:Clone()
			clone.Position = UDim2.fromScale(random:NextNumber(-0.25, 1.25), -(0.25 - random:NextNumber(0, 0.125)))
			clone.Rotation = random:NextNumber(-120, 120)
			local number = random:NextNumber(0.15, 0.2)
			clone.Size = UDim2.fromScale(number, number)
			clone.Parent = Players.LocalPlayer.PlayerGui:FindFirstChild("Effects")
			CreateTween(
				clone,
				TweenInfo.new(random:NextNumber(0.75, 1.3), Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					Position = clone.Position + UDim2.fromScale(0, 1.5),
					Rotation = clone.Rotation + random:NextInteger(-3, 3) * 10
				},
				true
			).Completed:Once(function()
				task.wait(1)
				clone:Destroy()
			end)
		end
	end

	remoteEvent3.OnClientEvent:Connect(function(p: string, player, p2: number)
		local v2 = v[p]

		if not v2 then
			return
		end

		local clone = v2:Clone()
		v2:Destroy()
		clone.Parent = workspace
		local position = clone:GetPivot().Position
		local total = 0
		local size = clone.Size
		local postSimulationConnection = nil
		postSimulationConnection = RunService.PostSimulation:Connect(function(dt: number)
			debug.profilebegin("St Patricks:UpdateCandyAnimation")
			total += dt
			local position2 = player.Character and player.Character:GetPivot().Position or createVector(0, 0, 0)
			local v3 = position + (position2 - position) * 0.25 + createVector(0, 10, 0)
			local value = TweenService:GetValue(total / 0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
			clone:PivotTo(CFrame.new(MathUtils.quadBezier(value, position, v3, position2)) * clone:GetPivot().Rotation)
			clone.Size = size * 0.5 + size * 0.5 * (1 - value)

			if value >= 1 and postSimulationConnection then
				postSimulationConnection:Disconnect()
				postSimulationConnection = nil
				clone:Destroy()
				task.spawn(function()
					SoundController:PlaySound(ReplicatedStorage.Sounds.Events["St Patricks"].CoinPickup, position2)
				end)

				if player == Players.LocalPlayer then
					playScreenGoldAnimation(p2)
				end

				playCharacterAnimation(player, p2)
			end

			debug.profileend()
		end)
	end)
	remoteEvent2.OnClientEvent:Connect(function(name2: string, vector2: Vector3, position: Vector3, p: number, p2: number)
		local clone = script.Drop:Clone()
		clone.Name = name2
		v[name2] = clone
		local proximityPrompt = Instance.new("ProximityPrompt")
		proximityPrompt.Name = "ProximityPrompt"
		proximityPrompt.ActionText = ""
		proximityPrompt.RequiresLineOfSight = false
		proximityPrompt.Enabled = false
		proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
		proximityPrompt:SetAttribute("CustomStyleDisabled", true)
		proximityPrompt.Parent = clone
		local raycastResult = workspace:Raycast(
			position + createVector(0, 10, 0),
			createVector(-0, -30, -0),
			raycastParams
		)

		if raycastResult then
			position = raycastResult.Position or position
		end

		local stPatricksPot = workspace:FindFirstChild("StPatricksPot")
		local pot = stPatricksPot and stPatricksPot:FindFirstChild("Pot")
		local rootPart = pot and pot:FindFirstChild("RootPart")
		local animationController = pot and pot:FindFirstChild("AnimationController")
		local animator = animationController and animationController:FindFirstChild("Animator")
		local animation = pot:FindFirstChild("Animation")
		local bone = rootPart and rootPart.Bone
		local track

		if animator then
			track = animator:LoadAnimation(animation)
			track.Looped = false
			track:Play()
		else
			track = nil
		end

		task.wait(0.25)

		if bone then
			vector2 = bone.WorldPosition + createVector(0, 2, 0)
		end

		local v2 = vector2 + createVector(0, 10, 0)
		local v3 = v2 + (position - v2) * 0.5

		if bone then
			v3 += Vector3.new(0, math.clamp((position - vector2).Magnitude, 25, 1000), 0)
		end

		task.spawn(function()
			SoundController:PlaySound(ReplicatedStorage.Sounds.Events["St Patricks"].CoinSpawn, vector2, false)
			VFX.emit(bone.emit)
		end)
		local v4 = math.random(0, 10000)
		local v5 = vector2
		local total = 0
		local v6 = { 0 }
		local v7 = false
		local v8 = 0

		for i = 1, 20 do
			local cubicBezier = MathUtils.cubicBezier(i / 20, vector2, v2, v3, position)
			total += vector.magnitude(cubicBezier - v5)
			v6[i + 1] = total
			v5 = cubicBezier
		end

		local v9 = false
		local v10 = (position - vector2) * createVector(1, 0, 1)
		local postSimulationConnection = RunService.PostSimulation:Connect(function(_: number)
			local v11 = workspace:GetServerTimeNow() - (p + 0.25)
			local value = TweenService:GetValue(
				p2 == 0 and 1 or math.clamp(v11 / p2, 0, 1),
				Enum.EasingStyle.Quint,
				Enum.EasingDirection.Out
			)
			local v13 = value * total
			local v14 = position

			for i = 1, #v6 do
				local v15 = v6[i]

				if not (v13 <= v15) then
					continue
				end

				local v16 = v6[i - 1]
				local v17 = (v13 - v16) / (v15 - v16)
				local v18 = (i - 2 + v17) / 20
				v14 = MathUtils.cubicBezier(v18, vector2, v2, v3, position)
				break
			end

			local v15 = os.clock() + v4

			if not v9 then
				v9 = true
				clone.Parent = workspace
			end

			local v16 = value * value * (3 - 2 * value)
			local v17 = v14 + Vector3.new(0, math.sin(v15 * 4) * 0.5 + 4, 0)
			clone:PivotTo(CFrame.lookAlong(v17, v10) * CFrame.Angles(
				-v16 * 4 * 3.141592653589793,
				math.max(v11 - p2 + 2, 0) * 0.7853981633974483,
				0
			))

			if value >= 1 then
				proximityPrompt.Enabled = true
				local now = os.clock()

				if v7 and now - v8 > 0.05 then
					v8 = now
					remoteEvent3:FireServer(name2)
				end
			end
		end)
		clone.Destroying:Connect(function()
			postSimulationConnection:Disconnect()

			if track then
				track:Stop()
				track:Destroy()
			end
		end)
		proximityPrompt.PromptShown:Connect(function()
			v7 = true
		end)
		proximityPrompt.PromptHidden:Connect(function()
			v7 = false
		end)
	end)
	remoteEvent.OnClientEvent:Connect(function(p: string)
		local v2 = v[p]

		if not v2 then
			return
		end

		v2:Destroy()
		v[p] = nil
	end)
end

return StPatricks