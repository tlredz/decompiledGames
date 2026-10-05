local createVector = vector.create
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local NorthPole = {}
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
local northPole = ReplicatorClient.get("NorthPole")
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
require(ReplicatedStorage.Controllers.AnimalController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
require(ReplicatedStorage.Shared.SharedEventUtils)
require(ReplicatedStorage.Shared.Snapshot)
local VFX = require(ReplicatedStorage.Shared.VFX)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local MathUtils = require(ReplicatedStorage.Utils.MathUtils)
local Animals = require(ReplicatedStorage.Shared.Animals)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
local Observers = require(ReplicatedStorage.Packages.Observers)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local Spr = require(ReplicatedStorage.Packages.Spr)
local name = script.Name
local remoteEvent = Net:RemoteEvent("EventService/North Pole/StartTransition")
local remoteEvent2 = Net:RemoteEvent("EventService/North Pole/StopTransition")
local remoteEvent3 = Net:RemoteEvent("EventService/North Pole/PointArrow")
local remoteEvent4 = Net:RemoteEvent("EventService/North Pole/Delivery")
local remoteEvent5 = Net:RemoteEvent("EventService/North Pole/Burst")
local remoteEvent6 = Net:RemoteEvent("EventService/North Pole/Grab")
local remoteEvent7 = Net:RemoteEvent("EventService/North Pole/CandyCaneAnimation")
local remoteEvent8 = Net:RemoteEvent("EventService/North Pole/SpawnBrainrot")
local remoteEvent9 = Net:RemoteEvent("EventService/North Pole/DestroyGift")
local remoteEvent10 = Net:RemoteEvent("EventService/North Pole/GiftBurst")
local remoteEvent11 = Net:RemoteEvent("EventService/North Pole/SpawnGift")
local remoteEvent12 = Net:RemoteEvent("EventService/North Pole/OpenGift")
local maid = Trove.new()
local flag = false
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local cframe = CFrame.new(0, 1000, 100000)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }
local maid2 = Trove.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function loadAnimation(animator, animation, maid3)
	local track = animator:LoadAnimation(animation);
	(maid3 or maid2):Add(function()
		track:Stop(0)
		track:Destroy()
	end)
	return track
end

local function startTrainTravel(p: number)
	if flag then
		return
	end

	flag = true
	ReplicatedStorage:SetAttribute("InTrainTravelCutscene", true)
	local v = false
	local maid3 = Trove.new()
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Parent = currentCamera
	ProximityPromptService.Enabled = false
	maid:Add(function()
		ProximityPromptService.Enabled = true
	end)
	local clone = maid3:Clone(script.SnowyAtmosphere)

	local function fade(p2: string, callback)
		local tweenInfo = TweenInfo.new(1)
		local tintColor

		if p2 == "Out" then
			tintColor = Color3.new(0, 0, 0)
		else
			tintColor = Color3.new(1, 1, 1)
		end

		local v6 = TweenService:Create(colorCorrectionEffect, tweenInfo, {
			TintColor = tintColor
		})
		v6:Play()

		if callback ~= nil then
			local completedConnection = v6.Completed:Connect(function(p3)
				if p3 ~= Enum.PlaybackState.Cancelled then
					callback(p3)
				end
			end)

			if not v then
				maid:Add(completedConnection)
			end
		end

		if not v then
			maid:Add(function()
				v6:Cancel()
				v6:Destroy()
			end)
		end
	end

	local v2 = false
	local v3 = false

	local function resetCamera()
		if v2 or not v3 then
			return
		end

		v2 = true
		currentCamera.CameraType = Enum.CameraType.Custom
		local character = Players.LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if humanoid ~= nil then
			currentCamera.CameraSubject = humanoid
		end
	end

	maid:Add(function()
		flag = false
		v = true
		fade("Out", function()
			maid3:Clean()

			if not v2 and v3 then
				v2 = true
				currentCamera.CameraType = Enum.CameraType.Custom
				local character = Players.LocalPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				if humanoid ~= nil then
					currentCamera.CameraSubject = humanoid
				end
			end

			ReplicatedStorage:SetAttribute("InTrainTravelCutscene", nil)
			fade("In", function()
				colorCorrectionEffect:Destroy()
			end)
		end)
	end)
	local road = script.Road
	local clone2 = maid3:Clone(script.BrainrotExpress)
	clone2.Parent = currentCamera
	local v4 = road.End.Position.Z - road.Start.Position.Z
	local v5 = p * 260

	for i = 1, math.max(math.ceil(v5 / (v4 - 100)), 1) + 2 do
		local clone3 = maid3:Clone(road)
		clone3:PivotTo(cframe * CFrame.new(0, 0, -(v4 * (i - 1))))
		clone3.Parent = currentCamera
	end

	fade("Out", function()
		v3 = true
		clone.Parent = Lighting
		currentCamera.CameraType = Enum.CameraType.Scriptable
		maid3:Add(resetCamera)
		local lastTime = os.clock()
		local v6 = lastTime + p
		maid3:Add(RunService.PreRender:Connect(function()
			local v7 = math.clamp((os.clock() - lastTime) / (v6 - lastTime), 0, 1)
			clone2:PivotTo(cframe * CFrame.new(0, 0, -50) * CFrame.new(0, 0, -((v5 - 50) * v7)))
			currentCamera.CFrame = clone2.Camera.CFrame
		end))
		maid3:Add(task.delay(p - 1, function()
			maid:Clean()
		end))
		ReplicatedStorage.Sounds.Events["North Pole"].TrainLoop:Play()
		maid3:Add(function()
			ReplicatedStorage.Sounds.Events["North Pole"].TrainLoop:Stop()
		end)
		fade("In")
	end)
end

local function stopTrainTravel()
	if not flag then
		return
	end

	maid:Clean()
end

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
	clone.CurrencyCandyCane.Text = `+{p}`
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
		clone.CurrencyCandyCane,
		TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 1.5),
		{
			TextTransparency = 1
		}
	):Play()
	TweenService:Create(
		clone.CurrencyCandyCane.UIStroke,
		TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 1.5),
		{
			Transparency = 1
		}
	):Play()
	task.delay(5, function()
		clone:Destroy()
	end)
end

local function playScreenCandyCaneAnimation()
	local random = Random.new()

	for _ = 1, 10 do
		local clone = script.Image:Clone()
		clone.Position = UDim2.fromScale(random:NextNumber(-0.25, 1.25), -0.25)
		clone.Rotation = random:NextNumber(-120, 120)
		local number = random:NextNumber(0.15, 0.2)
		clone.Size = UDim2.fromScale(number, number)
		clone.Parent = localPlayer.PlayerGui:FindFirstChild("Effects")
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

function NorthPole.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)

	local function calculateTimeLeft(p: number)
		return (math.max(activeEventData.startedAt + p - workspace:GetServerTimeNow(), 0))
	end

	maid2:Add(remoteEvent.OnClientEvent:Connect(startTrainTravel))
	maid2:Add(remoteEvent2.OnClientEvent:Connect(stopTrainTravel))
	local clone = maid2:Clone(script.EntranceSign)
	clone.Parent = workspace
	maid2:Add(ReplicatedStorage:GetAttributeChangedSignal("NorthPoleEventInMap"):Connect(function()
		if ReplicatedStorage:GetAttribute("NorthPoleEventInMap") and clone then
			maid2:Remove(clone)
			clone = nil
		end
	end))
	local maid3 = maid2:Extend()
	local v = nil
	local v2 = nil
	maid2:Add(remoteEvent3.OnClientEvent:Connect(function(value, flag2: boolean?)
		if value == nil then
			maid3:Clean()
			return
		end

		v = value
		v2 = flag2
		maid3:Add(function()
			v = nil
			v2 = nil
		end)
		local clone2 = maid3:Clone(script.PointingArrow)
		local start = clone2.Start
		local v3 = clone2.End
		clone2.Parent = workspace
		maid3:Add(RunService.PreRender:Connect(function()
			local position

			if typeof(value) == "Instance" then
				position = value:GetPivot().Position
			elseif typeof(value) == "CFrame" then
				position = value.Position
			else
				position = value
			end

			local character = localPlayer.Character

			if character then
				local pivot = character:GetPivot()
				start:PivotTo(pivot)

				if v2 and (position - pivot.Position).Magnitude <= 10 then
					maid3:Clean()
				end
			end

			v3:PivotTo(CFrame.new(position))
		end))
	end))
	maid2:Add(Observers.observeTag("NorthPoleEventGrabItem", function(parent)
		return Observers.observeAttribute(parent, "GrabPrompt", function(p)
			if p == false then
				return
			end

			local name2 = parent.Name
			local proximityPrompt = Instance.new("ProximityPrompt")
			proximityPrompt.Name = "ProximityPrompt"
			proximityPrompt.ActionText = "Grab"
			proximityPrompt.HoldDuration = 0.5
			proximityPrompt.RequiresLineOfSight = false
			proximityPrompt.Enabled = true
			proximityPrompt.Parent = parent
			local triggeredConnection = proximityPrompt.Triggered:Connect(function()
				remoteEvent6:FireServer(name2)
			end)
			return function()
				proximityPrompt:Destroy()
				triggeredConnection:Disconnect()
			end
		end)
	end, { workspace }))
	maid2:Add(Observers.observeTag("NorthPolePlayerCollision", function(p)
		p.CanCollide = true
		return nil
	end, { workspace }))
	maid2:Add(Observers.observeTag("NorthPoleDoor", function(instance)
		local pivot = instance:GetPivot()
		return Observers.observeAttribute(instance, "Open", function(p)
			if p then
				Spr.target(instance, 0.75, 3.5, {
					Pivot = pivot * CFrame.Angles(0, -1.5707963267948966, 0)
				})
				SoundController:PlaySound(script.DoorOpen, pivot.Position, false)
			else
				Spr.target(instance, 0.75, 3.5, {
					Pivot = pivot
				})
				SoundController:PlaySound(script.DoorClose, pivot.Position, false)
			end

			return function()
				if instance:IsDescendantOf(workspace) then
					Spr.target(instance, 0.75, 3.5, {
						Pivot = pivot
					})
					SoundController:PlaySound(script.DoorClose, pivot.Position, false)
				end
			end
		end)
	end, { workspace }))
	local parents = {}
	local v3 = {}
	maid2:Add(Observers.observeTag("NorthPoleSantaSleign", function(parent)
		local name2 = parent.Name
		local clone2 = ReplicatedStorage.Models.Events["North Pole"].Sleigh:Clone()
		clone2.PrimaryPart.Anchored = true

		if FFlags:GetInstant("Optimisation.HumanoidBrainrotModels", ServerData.IsNewPlayersServer()) then
			local animationController = clone2:FindFirstChild("AnimationController")

			if animationController then
				animationController:Destroy()
			end

			local humanoid = Instance.new("Humanoid", clone2)
			Instance.new("Animator", humanoid)
			humanoid.Name = "AnimationController"
			humanoid.EvaluateStateMachine = false
			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			humanoid.PlatformStand = true
			humanoid.Parent = clone2
		end

		clone2.Parent = parent
		local track = clone2.AnimationController.Animator:LoadAnimation(ReplicatedStorage.Models.Events["North Pole"].SleighFly)
		track.Looped = true
		track:Play()

		local function updateGifts()
			local v4 = northPole:TryIndex({ "gifts", parent.Name }) or {}

			for i = 1, 10 do
				local child = clone2.Gifts:FindFirstChild((tostring(i)))

				if not child then
					continue
				end

				child:SetAttribute("GiftTexture", v4[i] or "")
				child:AddTag("NorthPoleEventGiftTexture")

				for _, part in child:GetChildren() do
					if part:IsA("BasePart") then
						part.Transparency = i <= #v4 and 0 or 1
					end
				end
			end
		end

		local v4 = northPole:Listen({ "gifts", parent.Name }, updateGifts)
		updateGifts()
		table.insert(parents, parent)
		v3[name2] = clone2
		return function()
			v3[name2] = nil
			local index = table.find(parents, parent)

			if index then
				table.remove(parents, index)
			end

			v4()
			track:Stop(0)
			track:Destroy()
			clone2:Destroy()
		end
	end))
	maid2:Add(RunService.PreRender:Connect(function(_)
		debug.profilebegin("North Pole:BulkMoveTo")
		local primaryParts = {}
		local cFrames = {}

		for _, v4 in parents do
			local v5 = v3[v4.Name]

			if not v5 then
				continue
			end

			table.insert(primaryParts, v5.PrimaryPart)
			table.insert(cFrames, v4.CFrame)
		end

		workspace:BulkMoveTo(primaryParts, cFrames, Enum.BulkMoveMode.FireCFrameChanged)
		debug.profileend()
	end))
	local filterDescendantsInstances = {}
	local overlapParams = OverlapParams.new()
	maid2:Add(Observers.observeTag("NorthPoleDeliveryHitboxes", function(p)
		table.insert(filterDescendantsInstances, p)
		overlapParams.FilterDescendantsInstances = filterDescendantsInstances
		return function()
			local index = table.find(filterDescendantsInstances, p)

			if index then
				table.remove(filterDescendantsInstances, index)
				overlapParams.FilterDescendantsInstances = filterDescendantsInstances
			end
		end
	end))
	overlapParams.FilterDescendantsInstances = filterDescendantsInstances
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.MaxParts = 1
	local total = 0
	maid2:Add(RunService.PostSimulation:Connect(function(dt: number)
		total += dt

		if total < 0.05 then
			return
		end

		debug.profilebegin("NorthPole:Hitboxes")
		total = 0

		if not localPlayer:GetAttribute("Stealing") then
			return
		end

		local character = localPlayer.Character

		if not character then
			debug.profileend()
			return
		end

		local position = character:GetPivot().Position

		if #workspace:GetPartBoundsInBox(CFrame.new(position), createVector(4, 4, 2), overlapParams) <= 0 then
			return
		end

		remoteEvent4:FireServer()
		debug.profileend()
	end))
	maid2:Add(Observers.observeTag("NorthPoleSantaSpawner", function(adornee)
		local clone2 = script.SpawnerUI:Clone()
		clone2.Adornee = adornee
		clone2.Parent = localPlayer.PlayerGui
		local maid4 = Trove.new()

		local function rebuildBrainrots(items)
			maid4:Clean()

			if items == nil then
				return
			end

			for _, item in items do
				local index = item.Index
				local brainrot = item.Brainrot
				local price = item.Price
				local clone3 = maid4:Clone(clone2.ScrollingFrame.UIListLayout.Template)
				clone3.Spacer.Title.Text = Animals:GetDisplayName(brainrot)
				local v5 = Animals:AttachOnViewport(brainrot, clone3.Spacer.ViewportFrame, true)

				if v5 then
					maid4:Add(v5)
				end

				clone3.Spacer.Buy.Txt.Size = UDim2.fromScale(0.35, 0.8)
				clone3.Spacer.Buy.Txt.Text = price
				clone3.Parent = clone2.ScrollingFrame

				local function updateBuyButton()
					local v8 = northPole:TryIndex({ "stocks", adornee.Name }) or {}

					if index and not ((v8[index] or 0) <= 0) then
						Spr.target(clone3.Spacer.Buy, 1, 5, {
							BackgroundColor3 = Color3.fromRGB(81, 158, 86)
						})
						clone3.Spacer.Amount.Text = `{v8[index] or 0} LEFT`
						clone3.Spacer.Amount.TextColor3 = Color3.fromRGB(255, 213, 0)
					else
						Spr.target(clone3.Spacer.Buy, 1, 5, {
							BackgroundColor3 = Color3.fromRGB(150, 150, 150)
						})
						clone3.Spacer.Amount.Text = "SOLD OUT"
						clone3.Spacer.Amount.TextColor3 = Color3.fromRGB(255, 61, 61)
					end
				end

				maid4:Add(northPole:Listen({ "stocks", adornee.Name }, updateBuyButton))
				updateBuyButton()
				maid4:Add(clone3.Spacer.Buy.Activated:Connect(function()
					remoteEvent8:FireServer(brainrot)
				end))
			end
		end

		local v5 = northPole:Observe({ "brainrots", adornee.Name }, rebuildBrainrots)
		return function()
			v5()
			maid4:Destroy()
			clone2:Destroy()
		end
	end))
	maid2:Add(Observers.observeTag("Elf", function(parent)
		local maid4 = Trove.new()
		local humanoidRootPart = parent:WaitForChild("HumanoidRootPart")
		local clone2 = maid4:Clone(script.Elf)
		local v5 = maid4:Add(Instance.new("Weld"))
		v5.Part0 = clone2.PrimaryPart
		v5.Part1 = humanoidRootPart
		v5.Parent = clone2.PrimaryPart
		clone2.Parent = parent
		local animationController = clone2:FindFirstChild("AnimationController")

		if animationController then
			animationController:Destroy()
		end

		local humanoid = Instance.new("Humanoid", clone2)
		Instance.new("Animator", humanoid)
		humanoid.Name = "AnimationController"
		humanoid.EvaluateStateMachine = false
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.PlatformStand = true
		humanoid.Parent = clone2
		local animator = clone2.AnimationController.Animator
		local track = loadAnimation(animator, script.Idle, maid4) -- equivalent call inferred; original call site unknown
		track.Looped = true
		track.Priority = Enum.AnimationPriority.Idle
		track:Play()
		local track2 = loadAnimation(animator, script.Attack, maid4) -- equivalent call inferred; original call site unknown
		track2.Looped = false
		track2.Priority = Enum.AnimationPriority.Action
		maid4:Add(track2:GetMarkerReachedSignal("CandyDisappear"):Once(function()
			clone2.Candy.Transparency = 1
		end))
		maid4:Add(parent:GetAttributeChangedSignal("AttackAnimation"):Connect(function()
			track2:Play()
		end))
		local track3 = loadAnimation(animator, script.Walk, maid4) -- equivalent call inferred; original call site unknown
		track3.Priority = Enum.AnimationPriority.Action2
		maid4:Add(Observers.observeAttribute(parent, "IsRunning", function(p)
			if p then
				track3:Play()
				track3:AdjustSpeed(1.5)
			else
				track3:Stop()
			end

			return nil
		end))
		return maid4:WrapClean()
	end))
	maid2:Add(ReplicatedStorage:GetAttributeChangedSignal("NorthPoleEventActive"):Connect(function()
		CycleController:Update()
		SoundController:UpdateOST()
	end))
	maid2:Add(function()
		task.spawn(stopTrainTravel)
		EffectController:Activate("Blink")
		CycleController:Update()
		SoundController:UpdateOST()
	end)
end

function NorthPole.OnStop(_)
	maid2:Destroy()
end

function NorthPole.OnLoad(_)
	remoteEvent10.OnClientEvent:Connect(function(part)
		if typeof(part) == "Instance" then
			local clone = maid2:Clone(script.GiftBurst)
			clone.Anchored = false
			clone:PivotTo(part:GetPivot())
			clone.Parent = workspace
			local weld = Instance.new("Weld")
			weld.Part0 = clone
			weld.Part1 = part
			weld.Parent = clone
			VFX.emit(clone)
			task.delay(5, function()
				clone:Destroy()
			end)
			task.spawn(function()
				SoundController:PlaySound(
					ReplicatedStorage.Sounds.Events["North Pole"].PresentOpen,
					clone:GetPivot().Position
				)
			end)
		else
			if typeof(part) ~= "Vector3" then
				ClientEventUtils.playBurst(
					script.GiftBurst,
					part,
					{ ReplicatedStorage.Sounds.Events["North Pole"].PresentOpen }
				)
				return
			end

			local clone = maid2:Clone(script.GiftBurst)
			clone.Anchored = true
			clone:PivotTo(CFrame.new(part))
			clone.Parent = workspace
			VFX.emit(clone)
			task.delay(5, function()
				clone:Destroy()
			end)
			task.spawn(function()
				SoundController:PlaySound(
					ReplicatedStorage.Sounds.Events["North Pole"].PresentOpen,
					clone:GetPivot().Position
				)
			end)
		end
	end)
	local v = {
		"rbxassetid://106128825959360",
		"rbxassetid://84670396546354",
		"rbxassetid://131357512835082",
		"rbxassetid://94526507693712"
	}
	Observers.observeTag("NorthPoleEventGiftTexture", function(instance)
		local giftTexture = instance:GetAttribute("GiftTexture") or ""
		local v2 = 0

		for i = 1, #giftTexture do
			local v3 = string.byte(giftTexture, i)
			v2 = (v2 * 31 + v3) % 4294967296
		end

		local textureID2 = v[v2 % #v + 1] or v[1]
		return Observers.observeDescendants(instance, function(part)
			if not part:IsA("MeshPart") then
				return nil
			end

			local textureID = part.TextureID

			if textureID == "" then
				return nil
			end

			part.TextureID = textureID2
			return function()
				part.TextureID = textureID
			end
		end)
	end)
	local v2 = {}
	remoteEvent11.OnClientEvent:Connect(function(name2: string, _: string, vector2: Vector3, position: Vector3, p: number, p2: number)
		local clone = ReplicatedStorage.Models.Events["North Pole"].WrappedGift:Clone()
		clone.Name = name2
		clone:SetAttribute("GiftTexture", name2)
		clone:AddTag("NorthPoleEventGiftTexture")
		v2[name2] = clone
		local primaryPart = clone.PrimaryPart or clone:FindFirstChild("Handle")

		if primaryPart then
			primaryPart.Anchored = true
			local attachment = Instance.new("Attachment")
			attachment.Name = "Attachment0"
			attachment.Position = createVector(0, 1, 0)
			attachment.Parent = primaryPart
			local attachment2 = Instance.new("Attachment")
			attachment2.Name = "Attachment1"
			attachment2.Position = createVector(0, -1, 0)
			attachment2.Parent = primaryPart
			local trail = Instance.new("Trail")
			trail.Name = "Trail"
			trail.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 69, 69)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 69, 69))
			})
			trail.Attachment0 = attachment
			trail.Attachment1 = attachment2
			trail.Lifetime = 0.35
			trail.LightInfluence = 1
			trail.Parent = clone
		end

		clone.Parent = workspace
		local proximityPrompt = Instance.new("ProximityPrompt")
		proximityPrompt.Name = "ProximityPrompt"
		proximityPrompt.ActionText = "Open"
		proximityPrompt.RequiresLineOfSight = false
		proximityPrompt.Enabled = false
		proximityPrompt.HoldDuration = 0.5
		proximityPrompt.Parent = primaryPart
		local scale = clone:GetScale()
		task.spawn(function()
			SoundController:PlaySound(ReplicatedStorage.Sounds.Events["North Pole"].SantaHoHoHo, vector2, false)
			local clone2 = ReplicatedStorage.Sounds.Events["North Pole"].PresentDrop:Clone()
			clone2.Parent = clone.PrimaryPart
			clone2:Play()
			clone2.Ended:Once(function()
				clone2:Destroy()
			end)
		end)
		local raycastResult = workspace:Raycast(
			position + createVector(0, 10, 0),
			createVector(-0, -30, -0),
			raycastParams
		)

		if raycastResult then
			position = raycastResult.Position or position
		end

		local v3 = vector2 + (position - vector2) * 0.5
		math.random(0, 10000)
		local v4 = false
		local postSimulationConnection = RunService.PostSimulation:Connect(function(_: number)
			local v5 = workspace:GetServerTimeNow() - p
			local value = TweenService:GetValue(
				p2 == 0 and 1 or math.clamp(v5 / p2, 0, 1),
				Enum.EasingStyle.Quint,
				Enum.EasingDirection.Out
			)
			local quadBezier = MathUtils.quadBezier(value, vector2, v3, position)
			clone:ScaleTo((math.lerp(scale * 2, scale, value)))
			clone:PivotTo(CFrame.new(quadBezier) * CFrame.Angles(0, math.lerp(12.566370614359172, 0, value), 0))

			if value >= 0.8 and not v4 then
				v4 = true
				local clone2 = script.GiftLanding:Clone()
				clone2:PivotTo(CFrame.new(position))
				clone2.Parent = workspace
				VFX.emit(clone2)
				task.delay(5, function()
					clone2:Destroy()
				end)
			end

			if value >= 1 then
				proximityPrompt.Enabled = true
			end
		end)
		clone.Destroying:Connect(function()
			postSimulationConnection:Disconnect()
		end)
		proximityPrompt.Triggered:Connect(function()
			remoteEvent12:FireServer(name2)
		end)
	end)
	remoteEvent9.OnClientEvent:Connect(function(p: string)
		local v3 = v2[p]

		if not v3 then
			return
		end

		v3:Destroy()
		v2[p] = nil
	end)
	remoteEvent7.OnClientEvent:Connect(function(vector2: Vector3, player, p: string, p2: number)
		local total = 0
		local model = Instance.new("Model")
		local clone = ReplicatedStorage.Models.Events["North Pole"]["Candy Cane Tiers"][p]:Clone()
		clone.Parent = model

		if clone:IsA("Model") then
			model.PrimaryPart = clone.PrimaryPart
		else
			model.PrimaryPart = clone
		end

		model.Parent = workspace
		local scale = model:GetScale()
		local postSimulationConnection = nil
		postSimulationConnection = RunService.PostSimulation:Connect(function(dt: number)
			debug.profilebegin("North Pole:UpdateCandyAnimation")
			total += dt
			local position = player.Character and player.Character:GetPivot().Position or createVector(0, 0, 0)
			local v3 = vector2 + (position - vector2) * 0.25 + createVector(0, 20, 0)
			local value = TweenService:GetValue(total / 0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
			model:PivotTo(CFrame.new(MathUtils.quadBezier(value, vector2, v3, position)))
			model:ScaleTo((math.lerp(scale, 0.05, value)))

			if value >= 1 and postSimulationConnection then
				postSimulationConnection:Disconnect()
				postSimulationConnection = nil

				for _, part in model:GetDescendants() do
					if part:IsA("BasePart") then
						part.Transparency = 1
					end
				end

				task.delay(3, function()
					model:Destroy()
				end)

				if player == localPlayer then
					playScreenCandyCaneAnimation()
				end

				playCharacterAnimation(player, p2)
			end

			debug.profileend()
		end)
	end)
	remoteEvent5.OnClientEvent:Connect(function(p, p2, p3: number?)
		ClientEventUtils.playBurst(script.Burst, p, { ReplicatedStorage.Sounds.Events["North Pole"].CandyCane })

		if p2 and p3 then
			playCharacterAnimation(p2, p3)
		end
	end)
end

return NorthPole