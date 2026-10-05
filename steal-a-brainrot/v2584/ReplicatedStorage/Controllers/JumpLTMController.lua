local createVector = vector.create
local ProximityPromptService = game:GetService("ProximityPromptService")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local NotificationController = require(ReplicatedStorage.Controllers.NotificationController)
local ConfirmationController = require(ReplicatedStorage.Controllers.ConfirmationController)
local FastOverheadController = require(ReplicatedStorage.Controllers.FastOverheadController)
local AnimalOverheadController = require(ReplicatedStorage.Controllers.AnimalOverheadController)
local WorldBrainrotController = require(ReplicatedStorage.Controllers.WorldBrainrotController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local CloudVisuals = require(ReplicatedStorage.Controllers.EventController.Events["Eggrot Hunt"].CloudVisuals)
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Animals = require(ReplicatedStorage.Datas.Animals)
local JumpLTMData = require(ReplicatedStorage.Shared.JumpLTMData)
local Animals2 = require(ReplicatedStorage.Shared.Animals)
local BrainrotAssets = require(ReplicatedStorage.Shared.BrainrotAssets)
local VFX = require(ReplicatedStorage.Shared.VFX)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local remoteEvent = Net:RemoteEvent("JumpLTMService/EggHatchAnimation")
local remoteEvent2 = Net:RemoteEvent("JumpLTMService/RequestEggPlace")
local remoteEvent3 = Net:RemoteEvent("JumpLTMService/RequestBrainrotPlace")
local remoteEvent4 = Net:RemoteEvent("JumpLTMService/RequestTrampolineUpgrade")
local remoteEvent5 = Net:RemoteEvent("JumpPadService/Launched")
local remoteEvent6 = Net:RemoteEvent("JumpLTMService/Teleport")
local localPlayer = Players.LocalPlayer
local random = Random.new()
local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local JumpLTMController = {
	RenderedEggs = {},
	OnEggRendered = Signal.new()
}

local function setupBaseArrows()
	local plots = workspace:WaitForChild("Plots", 60)

	if not plots then
		return
	end

	local function watchPlot(model)
		if not model:IsA("Model") then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refreshArrows()
			local visible = model:GetAttribute("OwnerUserId") == localPlayer.UserId

			for _, v2 in model:QueryDescendants("BillboardGui#YourBase > ImageLabel#Arrow"), nil, nil do
				v2.Visible = visible
			end
		end

		model:GetAttributeChangedSignal("OwnerUserId"):Connect(refreshArrows)
		model.DescendantAdded:Connect(function(image)
			if image.Name ~= "Arrow" or not image:IsA("ImageLabel") then
				return
			end

			local parent = image.Parent

			if parent and parent.Name == "YourBase" and parent:IsA("BillboardGui") then
				image.Visible = model:GetAttribute("OwnerUserId") == localPlayer.UserId
			end
		end)
		refreshArrows() -- equivalent call inferred; original call site unknown
	end

	plots.ChildAdded:Connect(watchPlot)

	for _, child in plots:GetChildren() do
		watchPlot(child)
	end
end

local function stripFragment(folder)
	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("DataModelMesh") or descendant:IsA("Decal") or descendant:IsA("Texture") or descendant:IsA("SurfaceAppearance") then
			continue
		end

		descendant:Destroy()
	end
end

local function onEggHatchAnimation(model, vector2: Vector3)
	if typeof(model) ~= "Instance" or not model:IsA("Model") then
		return
	end

	local primaryPart = model.PrimaryPart

	if not primaryPart then
		return
	end

	local boundingBox, v = model:GetBoundingBox()
	local v2 = boundingBox.Position.Y - v.Y / 2
	local v3 = {
		{},
		{},
		{}
	}

	for _, v4 in model:QueryDescendants("BasePart"), nil, nil do
		if v4.Transparency >= 1 then
			continue
		end

		local clone = v4:Clone()
		stripFragment(clone)
		clone.CFrame = v4.CFrame
		table.insert(v3[math.clamp(math.floor((v4.Position.Y - v2) / math.max(v.Y, 0.05) * 3) + 1, 1, 3)], clone)
	end

	SoundController:PlaySound("Sounds.Sfx.EggHatchStart", vector2 + createVector(0, 2, 0), false)
	local baseEggHatchShakeDuration = JumpLTMData.BaseEggHatchShakeDuration
	local cFrame = primaryPart.CFrame
	local boundingBox2, v4 = model:GetBoundingBox()
	local pointToObjectSpace = cFrame:PointToObjectSpace(boundingBox2.Position - Vector3.new(0, v4.Y / 2, 0))
	local cframe = CFrame.new(pointToObjectSpace)
	local cframe2 = CFrame.new(-pointToObjectSpace)
	local lastTime = os.clock()
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local v5 = os.clock() - lastTime

		if baseEggHatchShakeDuration <= v5 or not primaryPart.Parent then
			heartbeatConnection:Disconnect()

			if primaryPart.Parent then
				primaryPart.CFrame = cFrame
			end
		else
			local v6 = math.clamp(v5 / baseEggHatchShakeDuration, 0, 1)
			local v7 = v5 * math.lerp(8, 12, v6)
			local v8 = v6 * 0.3141592653589793
			local cframe3 = CFrame.Angles(math.noise(v7, v7, 0) * v8 * 0.5, 0, math.noise(0, v7, v7) * v8)
			primaryPart.CFrame = cFrame * cframe * cframe3 * cframe2
		end
	end)
	task.wait(baseEggHatchShakeDuration)

	if heartbeatConnection.Connected then
		heartbeatConnection:Disconnect()
	end

	if primaryPart.Parent then
		primaryPart.CFrame = cFrame
	end

	local baseEggExplosionDebrisSeconds = JumpLTMData.BaseEggExplosionDebrisSeconds

	for _, v5 in v3 do
		if #v5 == 0 then
			continue
		end

		local v6 = v5[1]
		local v7 = 0

		for _, v8 in v5 do
			local v9 = v8.Size.X * v8.Size.Y * v8.Size.Z

			if not (v7 < v9) then
				continue
			end

			v6 = v8
			v7 = v9
		end

		for _, v8 in v5 do
			v8.Anchored = false
			v8.CanCollide = true
			v8.CollisionGroup = "BombardiroEventCollisionGroup"
			v8.CanQuery = false
			v8.CanTouch = false
			v8.Massless = false
			v8.Parent = workspace.CurrentCamera
		end

		for _, part in v5 do
			if part ~= v6 then
				local weldConstraint = Instance.new("WeldConstraint")
				weldConstraint.Part0 = v6
				weldConstraint.Part1 = part
				weldConstraint.Parent = v6
			end

			local v9 = part
			task.delay(baseEggExplosionDebrisSeconds, function()
				if not v9.Parent then
					return
				end

				local tween = TweenService:Create(v9, tweenInfo, {
					Transparency = 1
				})
				tween.Completed:Once(function()
					v9:Destroy()
				end)
				tween:Play()
			end)
		end

		local vector3 = Vector3.new(v6.Position.X - vector2.X, 0, v6.Position.Z - vector2.Z)
		local v8

		if vector3.Magnitude > 0.05 then
			v8 = vector3.Unit
		else
			v8 = Vector3.new(random:NextNumber(-1, 1), 0, random:NextNumber(-1, 1)).Unit
		end

		v6.AssemblyLinearVelocity = v8 * random:NextNumber(10, 18) + Vector3.new(0, random:NextNumber(18, 28), 0)
		v6.AssemblyAngularVelocity = Vector3.new(
			random:NextNumber(-8, 8),
			random:NextNumber(-8, 8),
			random:NextNumber(-8, 8)
		)
	end

	local copy = VFX.copy(VFX.Library.Misc.Smoke, CFrame.new(vector2 + createVector(0, 1.5, 0)))
	VFX.rescale(copy, 2)
	VFX.emit(copy)
	task.delay(5, function()
		copy:Destroy()
	end)
	SoundController:PlaySound("Sounds.Sfx.Lucky Blocks.SpinEnd", vector2 + createVector(0, 2, 0), false)
end

local function buildPetOverhead(instance, maid, object)
	local primaryPart = instance.PrimaryPart

	while not primaryPart and instance.Parent do
		task.wait(0.1)
		primaryPart = instance.PrimaryPart
	end

	if not primaryPart then
		return
	end

	local brainrotIndex = instance:GetAttribute("BrainrotIndex")

	if type(brainrotIndex) ~= "string" then
		return
	end

	local animal = Animals[brainrotIndex]

	if not animal then
		return
	end

	local mutation = instance:GetAttribute("Mutation")

	if type(mutation) ~= "string" then
		mutation = nil
	end

	local UID = instance:GetAttribute("UID")
	local adornee = instance:FindFirstChild("OVERHEAD_ATTACHMENT", true)

	if not (adornee and adornee:IsA("Attachment")) then
		local model = BrainrotAssets.getModel(brainrotIndex)

		if not (instance.Parent and primaryPart.Parent) then
			return
		end

		local extentsSize

		if model then
			extentsSize = model:GetExtentsSize() * (instance:GetScale() / model:GetScale())
		else
			extentsSize = instance:GetExtentsSize()
		end

		adornee = Instance.new("Attachment")
		adornee.Parent = primaryPart
		adornee.WorldCFrame = instance:GetPivot() * CFrame.new(
			0,
			extentsSize.Y * 0.75 * (animal.OverheadYOffsetModifier or 1),
			0
		)
		maid:Add(adornee)
	end

	local fastOverhead, v2 = FastOverheadController.createFastOverhead({
		adornee = adornee,
		guiTemplate = FastOverheadController.GuiTemplates.AnimalOverhead
	})
	maid:Add(v2)
	AnimalOverheadController:Populate({
		Overhead = fastOverhead,
		Index = brainrotIndex,
		Mutation = mutation,
		Trove = maid
	})
	local extended = maid:Extend()

	local function updateTraits()
		extended:Clean()
		local v3

		if type(UID) == "string" then
			v3 = object:TryIndex({ "traits", UID })
		end

		if type(v3) ~= "table" then
			v3 = nil
		end

		AnimalOverheadController:PopulateTraits(fastOverhead, v3, extended)
		fastOverhead.DisplayName.Text = AnimalOverheadController:ResolveDisplayName(brainrotIndex, v3)
		fastOverhead.Generation.Text = `${NumberUtils:ToString(Animals2:GetGeneration(brainrotIndex, mutation, v3))}/s`
		fastOverhead.Generation.Visible = not animal.HideGeneration
	end

	if type(UID) == "string" then
		maid:Add(object:Observe({ "traits", UID }, updateTraits))
	else
		updateTraits()
	end
end

local v = {
	{
		From = 5,
		To = 0,
		Duration = 0.16,
		Direction = Enum.EasingDirection.In
	},
	{
		From = 0,
		To = 1.2,
		Duration = 0.09,
		Direction = Enum.EasingDirection.Out
	},
	{
		From = 1.2,
		To = 0,
		Duration = 0.09,
		Direction = Enum.EasingDirection.In
	}
}

local function bounceEggIn(instance)
	local eggPlacedAt = instance:GetAttribute("EggPlacedAt")

	if type(eggPlacedAt) ~= "number" or workspace:GetServerTimeNow() - eggPlacedAt > 3 then
		return
	end

	local pivot = instance:GetPivot()
	local v2 = 1
	local lastTime = os.clock()
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if not (instance.Parent and instance.PrimaryPart) then
			heartbeatConnection:Disconnect()
			return
		end

		local v3 = v[v2]
		local v4 = math.clamp((os.clock() - lastTime) / v3.Duration, 0, 1)
		local value = TweenService:GetValue(v4, Enum.EasingStyle.Quad, v3.Direction)
		local v5 = v3.From + (v3.To - v3.From) * value
		instance:PivotTo(pivot + Vector3.new(0, v5, 0))

		if v4 >= 1 then
			v2 += 1
			lastTime = os.clock()

			if not v[v2] then
				instance:PivotTo(pivot)
				heartbeatConnection:Disconnect()
			end
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatHatchRemaining(p: number)
	local v2 = math.max(math.ceil(p), 0)
	return (`{v2 // 60}:{string.format("%02d", v2 % 60)}`)
end

local function buildEggTimerOverhead(instance, maid)
	local primaryPart = instance.PrimaryPart

	while not primaryPart and instance.Parent do
		task.wait(0.1)
		primaryPart = instance.PrimaryPart
	end

	if not primaryPart then
		return
	end

	local _, v2 = instance:GetBoundingBox()
	local attachment = Instance.new("Attachment")
	attachment.Parent = primaryPart
	attachment.WorldCFrame = instance:GetPivot() * CFrame.new(0, v2.Y * 0.75, 0)
	maid:Add(attachment)
	local fastOverhead, v3 = FastOverheadController.createFastOverhead({
		adornee = attachment,
		guiTemplate = FastOverheadController.GuiTemplates.AnimalOverhead
	})
	maid:Add(v3)
	local brainrotIndex = instance:GetAttribute("BrainrotIndex")
	local v4

	if type(brainrotIndex) == "string" then
		v4 = Animals[brainrotIndex]
	end

	if v4 then
		local mutation = instance:GetAttribute("Mutation")

		if type(mutation) ~= "string" then
			mutation = nil
		end

		local traits = instance:GetAttribute("Traits")
		local traits2

		if type(traits) == "string" and traits ~= "" then
			traits2 = string.split(traits, "|")
		end

		local hideRarity = brainrotIndex == "Gold Egg"
		AnimalOverheadController:Populate({
			Overhead = fastOverhead,
			Index = brainrotIndex,
			Traits = traits2,
			Mutation = mutation,
			Trove = maid,
			HidePrice = hideRarity or v4.Egg ~= nil,
			HideRarity = hideRarity
		})
	else
		for _, childName in {
			"DisplayName",
			"Mutation",
			"Price",
			"Rarity"
		} do
			local guiObject = fastOverhead:FindFirstChild(childName)

			if guiObject and guiObject:IsA("GuiObject") then
				guiObject.Visible = false
			end
		end
	end

	local generation = fastOverhead.Generation

	local function update()
		local hatchAt = instance:GetAttribute("HatchAt")

		if type(hatchAt) ~= "number" then
			generation.Visible = false
			return
		end

		local v5 = hatchAt - workspace:GetServerTimeNow()
		generation.Visible = true
		local generation2 = generation
		local text

		if v5 <= 0 then
			text = "READY!"
		else
			text = formatHatchRemaining(v5)
		end

		generation2.Text = text
	end

	maid:Add(instance:GetAttributeChangedSignal("HatchAt"):Connect(update))
	maid:Add(Timer.Simple(1, update))
	local hatchAt = instance:GetAttribute("HatchAt")

	if type(hatchAt) ~= "number" then
		generation.Visible = false
		return
	end

	local v5 = hatchAt - workspace:GetServerTimeNow()
	generation.Visible = true
	local text2

	if v5 <= 0 then
		text2 = "READY!"
	else
		text2 = formatHatchRemaining(v5)
	end

	generation.Text = text2
end

local function growPetIn(instance)
	local petGrowInAt = instance:GetAttribute("PetGrowInAt")

	if type(petGrowInAt) ~= "number" or workspace:GetServerTimeNow() - petGrowInAt > 3 then
		return
	end

	local scale = instance:GetScale()
	local lastTime = os.clock()
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if not instance.Parent then
			heartbeatConnection:Disconnect()
			return
		end

		local v2 = math.clamp((os.clock() - lastTime) / 0.6, 0, 1)
		local value = TweenService:GetValue(v2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

		if not pcall(instance.ScaleTo, instance, scale * math.max(value, 0.05)) or v2 >= 1 then
			heartbeatConnection:Disconnect()
		end
	end)
end

local v2 = nil
local v3 = nil
local thread = nil

local function playJumpAnimation()
	local character = localPlayer.Character

	if not character then
		return
	end

	if character ~= v3 then
		v3 = character
		v2 = nil
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
		local animate = character:FindFirstChild("Animate")
		local jump = animate and animate:FindFirstChild("jump")
		local animation = jump and jump:FindFirstChildOfClass("Animation")

		if animator and animation then
			local track = animator:LoadAnimation(animation)
			track.Priority = Enum.AnimationPriority.Movement
			track.Looped = false
			v2 = track
		end
	end

	local v4 = v2

	if v4 then
		if thread then
			task.cancel(thread)
		end

		v4:Play(0.05)
		thread = task.delay(0.3, function()
			thread = nil

			if v4.IsPlaying then
				v4:Stop(0.2)
			end
		end)
	end
end

local remoteEvent7 = Net:RemoteEvent("JumpPadService/LaunchRequest")
local remoteEvent8 = Net:RemoteEvent("JumpPadService/LaunchedBroadcast")

local function isOverPad(instance, pointToObjectSpace: Vector3, p: number, p2: number)
	local halfSize = instance.Size / 2

	if pointToObjectSpace.Y < -halfSize.Y or pointToObjectSpace.Y > halfSize.Y + p2 then
		return false
	end

	if instance:GetAttribute("JumpPadCircular") == true then
		local v5 = math.min(halfSize.X, halfSize.Z) + p
		return pointToObjectSpace.X * pointToObjectSpace.X + pointToObjectSpace.Z * pointToObjectSpace.Z <= v5 * v5
	end

	return math.abs(pointToObjectSpace.X) <= halfSize.X + p and math.abs(pointToObjectSpace.Z) <= halfSize.Z + p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playPadFeedback(instance)
	local v4 = SoundController:PlaySound("Sounds.Events.Easter.Trampoline", instance.Position, false)

	if v4 and instance:FindFirstAncestor("BaseTrampolines") then
		v4.Volume = 0.4
	end

	VFX.emit(instance:FindFirstAncestorWhichIsA("Model") or instance)
end

local function launchFromPad(instance, humanoidRootPart)
	local jumpForce = instance:GetAttribute("JumpForce") or 150
	local upVector = instance.CFrame.UpVector
	local floatVelocity = humanoidRootPart:FindFirstChild("FloatVelocity")

	if floatVelocity then
		floatVelocity:Destroy()
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "FloatAttachment"
	attachment.Parent = humanoidRootPart
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Name = "FloatVelocity"
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
	linearVelocity.LineDirection = upVector
	linearVelocity.LineVelocity = jumpForce
	linearVelocity.MaxForce = 1e999
	linearVelocity.Attachment0 = attachment
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	linearVelocity.Parent = humanoidRootPart
	task.delay(0.15, function()
		linearVelocity:Destroy()
		attachment:Destroy()
	end)
end

local flag = false

local function setupFirstCarryGuide()
	local v4 = nil
	task.spawn(function()
		local v5 = Synchronizer:Wait(localPlayer)

		if v5 and v5:Get({ "JumpLTMEvent", "CarryGuideSeen" }) then
			flag = true
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function endGuide()
		if v4 then
			v4:Destroy()
			v4 = nil
		end

		NotificationController:Notify("", nil, nil, nil, nil, "JumpLTMEggGuide", true)
	end

	local function startGuide()
		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local plots = workspace:FindFirstChild("Plots")

		if not plots then
			return
		end

		local v5 = nil

		for _, child in plots:GetChildren() do
			if child:GetAttribute("OwnerUserId") ~= localPlayer.UserId then
				continue
			end

			v5 = child
			break
		end

		if not v5 then
			return
		end

		local collectZone = v5:FindFirstChild("CollectZone")
		local v7

		if collectZone then
			v7 = collectZone:QueryDescendants("BasePart")[1]
		end

		if not v7 then
			return
		end

		local tutorialArrow = ReplicatedStorage.Controllers:FindFirstChild("FTUEController") and ReplicatedStorage.Controllers.FTUEController:FindFirstChild("TutorialArrow")

		if not (tutorialArrow and tutorialArrow:IsA("Model")) then
			return
		end

		local maid = Trove.new()
		v4 = maid
		local v8 = maid:Add(tutorialArrow:Clone())
		local start = v8:FindFirstChild("Start")
		local firstChild = v8:FindFirstChild("End")
		start.CFrame = humanoidRootPart.CFrame
		firstChild.CFrame = v7.CFrame + Vector3.new(0, v7.Size.Y / 2 + 2, 0)
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = humanoidRootPart
		weldConstraint.Part1 = start
		weldConstraint.Parent = start
		v8.Parent = workspace
		NotificationController:Notify("Place the egg in your base!", 9999, nil, nil, nil, "JumpLTMEggGuide")
	end

	localPlayer:GetAttributeChangedSignal("CarryingJumpEgg"):Connect(function()
		if localPlayer:GetAttribute("CarryingJumpEgg") == true then
			if flag then
				return
			end

			flag = true
			startGuide()
		else
			endGuide() -- equivalent call inferred; original call site unknown
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setupForeignPromptHiding()
	local function getOwnPlotOrder()
		local plots = workspace:FindFirstChild("Plots")

		if not plots then
			return nil
		end

		for _, child in plots:GetChildren() do
			if child:GetAttribute("OwnerUserId") == localPlayer.UserId then
				return (child:GetAttribute("Order"))
			end
		end

		return nil
	end

	ProximityPromptService.PromptShown:Connect(function(p)
		local parent = p.Parent

		while parent and parent ~= workspace do
			local ownerUserId = parent:GetAttribute("OwnerUserId")

			if ownerUserId == nil then
				local basePlotOrder = parent:GetAttribute("BasePlotOrder")

				if basePlotOrder == nil then
					parent = parent.Parent
				else
					if basePlotOrder ~= getOwnPlotOrder() then
						p.Enabled = false
					end

					break
				end
			else
				if ownerUserId ~= localPlayer.UserId then
					p.Enabled = false
				end

				break
			end
		end
	end)
end

local function setupForeignTrampolineArrowHiding()
	local plots = workspace:WaitForChild("Plots", 60)

	if not plots then
		return
	end

	local order = nil

	while not order do
		for _, child in plots:GetChildren() do
			if child:GetAttribute("OwnerUserId") ~= localPlayer.UserId then
				continue
			end

			order = child:GetAttribute("Order")
			break
		end

		if not order then
			task.wait(0.5)
		end
	end

	local map = workspace:WaitForChild("Map", 60)
	local baseTrampolines = map and map:WaitForChild("BaseTrampolines", 60)

	if not baseTrampolines then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applyToArrow(instance)
		local model = instance:FindFirstAncestorWhichIsA("Model")
		local basePlotOrder = model and model:GetAttribute("BasePlotOrder")

		if basePlotOrder ~= nil and basePlotOrder ~= order then
			instance.Enabled = false
		end
	end

	baseTrampolines.DescendantAdded:Connect(function(beam)
		if beam.Name == "Arrow" and beam:IsA("Beam") then
			applyToArrow(beam) -- equivalent call inferred; original call site unknown
		end
	end)

	for _, v4 in baseTrampolines:QueryDescendants("Beam#Arrow"), nil, nil do
		applyToArrow(v4) -- equivalent call inferred; original call site unknown
	end
end

local function setupForeignTrampolineHiding()
	local plots = workspace:WaitForChild("Plots", 60)

	if not plots then
		return
	end

	local order = nil

	while not order do
		for _, child in plots:GetChildren() do
			if child:GetAttribute("OwnerUserId") ~= localPlayer.UserId then
				continue
			end

			order = child:GetAttribute("Order")
			break
		end

		if not order then
			task.wait(0.5)
		end
	end

	local map = workspace:WaitForChild("Map", 60)
	local baseTrampolines = map and map:WaitForChild("BaseTrampolines", 60)

	if not baseTrampolines then
		return
	end

	local v4 = {}

	local function register(model)
		if not model:IsA("Model") then
			return
		end

		local basePlotOrder = model:GetAttribute("BasePlotOrder")

		if type(basePlotOrder) ~= "number" or basePlotOrder == order then
			return
		end

		if model.Name:match("^TrampolineSign") then
			model:PivotTo(model:GetPivot() + createVector(0, -5000, 0))
		else
			v4[model] = {
				Pad = model,
				OriginalPivot = model:GetPivot(),
				TriggerCFrame = nil,
				TriggerSize = nil,
				Hidden = false,
				LastOccupiedAt = os.clock()
			}
		end
	end

	baseTrampolines.ChildAdded:Connect(register)
	baseTrampolines.ChildRemoved:Connect(function(child)
		v4[child] = nil
	end)

	for _, child in baseTrampolines:GetChildren() do
		register(child)
	end

	local function resolveTrigger(state)
		local v5 = state.Pad:QueryDescendants(".JumpPad")[1]

		if v5 then
			state.TriggerCFrame = state.OriginalPivot * state.Pad:GetPivot():ToObjectSpace(v5.CFrame)
			state.TriggerSize = v5.Size
		end
	end

	local function isPadOccupied(p)
		local triggerCFrame = p.TriggerCFrame
		local triggerSize = p.TriggerSize

		if not (triggerCFrame and triggerSize) then
			return false
		end

		local halfTriggerSize = triggerSize / 2

		for _, v6 in Players:GetPlayers() do
			local character = v6.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				continue
			end

			local pointToObjectSpace = triggerCFrame:PointToObjectSpace(humanoidRootPart.Position)

			if math.abs(pointToObjectSpace.X) <= halfTriggerSize.X + 2 and math.abs(pointToObjectSpace.Z) <= halfTriggerSize.Z + 2 and pointToObjectSpace.Y >= -halfTriggerSize.Y and pointToObjectSpace.Y <= halfTriggerSize.Y + 30 then
				return true
			end
		end

		return false
	end

	while true do
		task.wait(0.15)
		local now = os.clock()

		for _, v5 in v4 do
			local v6 = not v5.TriggerCFrame and v5.Pad:QueryDescendants(".JumpPad")[1]

			if v6 then
				v5.TriggerCFrame = v5.OriginalPivot * v5.Pad:GetPivot():ToObjectSpace(v6.CFrame)
				v5.TriggerSize = v6.Size
			end

			if isPadOccupied(v5) then
				v5.LastOccupiedAt = now

				if v5.Hidden then
					v5.Hidden = false
					v5.Pad:PivotTo(v5.OriginalPivot)
				end
			elseif not v5.Hidden and now - v5.LastOccupiedAt > 1 then
				v5.Hidden = true
				v5.Pad:PivotTo(v5.OriginalPivot + createVector(0, -5000, 0))
			end
		end
	end
end

local function setupClientJumpPads()
	local parts = {}
	Observers.observeTag("JumpPad", function(part)
		if not part:IsA("BasePart") then
			return nil
		end

		table.insert(parts, part)
		return function()
			local index = table.find(parts, part)

			if index then
				table.remove(parts, index)
			end
		end
	end, { workspace })
	remoteEvent8.OnClientEvent:Connect(function(p, instance)
		if p == localPlayer or typeof(instance) ~= "Instance" then
			return
		end

		playPadFeedback(instance) -- equivalent call inferred; original call site unknown
	end)
	local v4 = 0
	RunService.PostSimulation:Connect(function()
		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if not character or not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
			return
		end

		local now = os.clock()

		if now - v4 < 0.3 then
			return
		end

		local Y = humanoidRootPart.AssemblyLinearVelocity.Y

		if Y > 10 then
			return
		end

		local v5 = humanoid.FloorMaterial ~= Enum.Material.Air

		if not v5 and Y > -10 then
			return
		end

		local v6 = math.max(4, humanoid.HipHeight + humanoidRootPart.Size.Y)
		local v7 = v5 and 0 or 1

		for _, v8 in parts do
			if not isOverPad(v8, v8.CFrame:PointToObjectSpace(humanoidRootPart.Position), v7, v6) then
				continue
			end

			v4 = now
			launchFromPad(v8, humanoidRootPart)
			playJumpAnimation()
			playPadFeedback(v8) -- equivalent call inferred; original call site unknown
			remoteEvent7:FireServer(v8)
			break
		end
	end)
end

function JumpLTMController:StartNormalServer()
	Observers.observeTag("JumpLTMMachine", function(instance)
		local maid = Trove.new()
		local prompt = instance:FindFirstChild("Prompt")
		local proximityPrompt = prompt and prompt:FindFirstChildOfClass("ProximityPrompt")

		if proximityPrompt then
			maid:Add(proximityPrompt.Triggered:Connect(function()
				if ConfirmationController:IsInPrompt() or not ConfirmationController:Show(
					"Are you sure you want to join the <font color=\"rgb(255, 48, 51)\">Jump for Eggs LTM</font>?",
					300,
					"JoinCancel"
				) then
					return
				end

				remoteEvent6:FireServer()
			end))
		end

		local arcadopus = ReplicatedStorage.Animations.Animals:FindFirstChild("Arcadopus")
		local arcadopus2 = instance:FindFirstChild("Arcadopus")
		local animator = arcadopus2 and arcadopus2:FindFirstChildWhichIsA("Animator", true)

		if arcadopus and animator then
			local track = animator:LoadAnimation(arcadopus.Idle)
			track.Looped = true
			track:Play()
			maid:Add(function()
				track:Stop()
			end)
		end

		return maid:WrapClean()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isCarryingEgg()
	return localPlayer:GetAttribute("CarryingJumpEgg") == true
end

local function findPlotOwnerUserId(parent)
	while parent and parent ~= workspace do
		if parent:IsA("Model") then
			local ownerUserId = parent:GetAttribute("OwnerUserId")

			if type(ownerUserId) == "number" then
				return ownerUserId
			end
		end

		parent = parent.Parent
	end

	return nil
end

local v4 = 0

local function tryPlaceFromScreenPoint(X: number, Y: number)
	if localPlayer:GetAttribute("CarryingJumpEgg") ~= true then
		return
	end

	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local screenPointToRay = currentCamera:ScreenPointToRay(X, Y)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { localPlayer.Character }
	raycastParams.RespectCanCollide = true
	local raycastResult = workspace:Raycast(screenPointToRay.Origin, screenPointToRay.Direction * 250, raycastParams)

	if not raycastResult then
		return
	end

	local plotOwnerUserId = findPlotOwnerUserId(raycastResult.Instance)

	if plotOwnerUserId == localPlayer.UserId then
		remoteEvent2:FireServer(raycastResult.Position)
	elseif plotOwnerUserId ~= nil then
		local now = os.clock()

		if now - v4 > 1 then
			v4 = now
			NotificationController:Error("This is not your plot!")
		end
	end
end

local function setupEggPlaceInput()
	UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			tryPlaceFromScreenPoint(input.Position.X, input.Position.Y)
		end
	end)
	UserInputService.TouchTapInWorld:Connect(function(point: Vector2, flag2: boolean)
		if flag2 then
			return
		end

		tryPlaceFromScreenPoint(point.X, point.Y)
	end)
	localPlayer:GetAttributeChangedSignal("CarryingJumpEgg"):Connect(function()
		if isCarryingEgg() then
			ContextActionService:BindAction("JumpLTMPlaceEgg", function(_, p)
				if p == Enum.UserInputState.Begin then
					remoteEvent2:FireServer()
				end

				return Enum.ContextActionResult.Pass
			end, false, Enum.KeyCode.ButtonX)
		else
			ContextActionService:UnbindAction("JumpLTMPlaceEgg")
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isCarryingBaseBrainrot()
	return localPlayer:GetAttribute("CarryingBaseBrainrot") == true
end

local function isStandingOnOwnPlot()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return false
	end

	local plots = workspace:FindFirstChild("Plots")

	if not plots then
		return false
	end

	for _, model in plots:GetChildren() do
		if not (model:IsA("Model") and model:GetAttribute("OwnerUserId") == localPlayer.UserId) then
			continue
		end

		local floor = model:FindFirstChild("Floor")

		if not (floor and floor:IsA("BasePart")) then
			return false
		end

		local pointToObjectSpace = floor.CFrame:PointToObjectSpace(humanoidRootPart.Position)
		return math.abs(pointToObjectSpace.X) <= floor.Size.X / 2 and math.abs(pointToObjectSpace.Z) <= floor.Size.Z / 2
	end

	return false
end

local function setupPlaceButton()
	local jumpLTMPlaceButton = localPlayer:WaitForChild("PlayerGui"):WaitForChild("JumpLTMPlaceButton")
	jumpLTMPlaceButton:WaitForChild("Activate").Activated:Connect(function()
		if isCarryingBaseBrainrot() then
			remoteEvent3:FireServer()
		end
	end)
	local heartbeatConnection = nil

	local function updateCarryState()
		if isCarryingBaseBrainrot() then
			if not heartbeatConnection then
				heartbeatConnection = RunService.Heartbeat:Connect(function()
					jumpLTMPlaceButton.Enabled = isStandingOnOwnPlot()
				end)
			end
		else
			if heartbeatConnection then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end

			jumpLTMPlaceButton.Enabled = false
		end
	end

	localPlayer:GetAttributeChangedSignal("CarryingBaseBrainrot"):Connect(updateCarryState)
	updateCarryState()
end

local function setupTrampolineSignGui()
	local v5 = Synchronizer:Wait(localPlayer)

	if not v5 then
		return
	end

	local plots = workspace:WaitForChild("Plots", 60)

	if not plots then
		return
	end

	local order = nil

	while not order do
		for _, child in plots:GetChildren() do
			if child:GetAttribute("OwnerUserId") ~= localPlayer.UserId then
				continue
			end

			order = child:GetAttribute("Order")
			break
		end

		if not order then
			task.wait(0.5)
		end
	end

	local map = workspace:WaitForChild("Map", 60)
	local baseTrampolines = map and map:WaitForChild("BaseTrampolines", 60)

	if not baseTrampolines then
		return
	end

	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local formatted = `TrampolineSign{order}`
	local v6 = nil

	local function update()
		local v7 = v6

		if not v7 then
			return
		end

		local title = v7:FindFirstChild("Title")
		local upgrade = v7:FindFirstChild("Upgrade")
		local lockOverlay = v7:FindFirstChild("LockOverlay")
		local trampolineTiers = JumpLTMData.GetTrampolineTiers()
		local v8 = v5:Get({ "JumpLTMEvent", "TrampolineTier" }) or 1
		local trampolineTier = trampolineTiers[v8 + 1]

		if trampolineTier then
			if title then
				title.Text = `TRAMPOLINE <font size="18">{v8}/{#trampolineTiers}</font>`
			end

			if upgrade then
				upgrade.Visible = true
				local price = upgrade:FindFirstChild("Price")

				if price then
					price.Text = `${NumberUtils:ToString(trampolineTier.Cost, 2)}`
				end
			end

			if lockOverlay then
				lockOverlay.Visible = JumpLTMData.GetLevelInfo(v5:Get({ "JumpLTMEvent", "XP" })) < trampolineTier.RequiredLevel
				local rebirth = lockOverlay:FindFirstChild("Rebirth")

				if rebirth then
					rebirth.Text = `LEVEL {trampolineTier.RequiredLevel}`
				end
			end
		else
			if title then
				title.Text = `TRAMPOLINE <font size="18">{#trampolineTiers}/{#trampolineTiers} MAX</font>`
			end

			if upgrade then
				upgrade.Visible = false
			end

			if lockOverlay then
				lockOverlay.Visible = false
			end
		end
	end

	local v7 = 0

	local function attachSign(instance)
		local sign = instance:WaitForChild("Sign", 10)

		if not (sign and sign:IsA("BasePart")) then
			return
		end

		local clone = v6

		if not clone then
			local surfaceGui = sign:FindFirstChildOfClass("SurfaceGui")

			if not surfaceGui then
				return
			end

			clone = surfaceGui:Clone()
			clone.Name = "TrampolineSignGui"
			clone.Enabled = true
			clone.ResetOnSpawn = false
			v6 = clone
			local upgrade = clone:FindFirstChild("Upgrade")

			if upgrade and upgrade:IsA("GuiButton") then
				upgrade.Activated:Connect(function()
					local now = os.clock()

					if now - v7 < 0.3 then
						return
					end

					v7 = now
					remoteEvent4:FireServer(order)
				end)
			end

			clone.Parent = playerGui
		end

		clone.Adornee = sign
		update()
	end

	baseTrampolines.ChildAdded:Connect(function(child)
		if child.Name == formatted then
			task.spawn(attachSign, child)
		end
	end)
	local child = baseTrampolines:FindFirstChild(formatted)

	if child then
		task.spawn(attachSign, child)
	end

	v5:OnChanged({ "JumpLTMEvent", "TrampolineTier" }, update)
	v5:OnChanged({ "JumpLTMEvent", "XP" }, update)
end

function JumpLTMController:Start()
	remoteEvent5.OnClientEvent:Connect(playJumpAnimation)

	if not ServerData.IsJumpLTMServer() then
		JumpLTMController:StartNormalServer()
		return
	end

	setupEggPlaceInput()
	task.spawn(setupPlaceButton)
	task.spawn(setupTrampolineSignGui)
	local v5 = ReplicatorClient.get("JumpLTM/PetTraits")
	local renderedEggs = JumpLTMController.RenderedEggs
	ReplicatorClient.get("JumpLTM/Eggs")
	WorldBrainrotController:RenderPool({
		PoolId = "JumpLTM/Eggs",
		ReplicatorId = "JumpLTM/Eggs",
		ShowTimer = true,
		HideHatchTimer = true,
		ShowDropButton = true,
		GrabHoldDuration = 1.25,
		GrabMaxDistance = 10,
		RenderedBrainrots = renderedEggs,
		OnRendered = function(p: string)
			JumpLTMController.OnEggRendered:Fire(p)
		end
	})
	CloudVisuals:Start()
	task.spawn(setupBaseArrows)
	setupFirstCarryGuide()
	setupForeignPromptHiding() -- equivalent call inferred; original call site unknown
	task.spawn(setupForeignTrampolineArrowHiding)
	task.spawn(setupForeignTrampolineHiding)
	setupClientJumpPads()
	remoteEvent.OnClientEvent:Connect(onEggHatchAnimation)
	Observers.observeTag("BasePlotPet", function(p)
		local maid = Trove.new()
		maid:Add(task.spawn(buildPetOverhead, p, maid, v5))
		growPetIn(p)
		return function()
			maid:Destroy()
		end
	end)
	Observers.observeTag("BasePlotEggVisual", function(p)
		local maid = Trove.new()
		maid:Add(task.spawn(buildEggTimerOverhead, p, maid))
		bounceEggIn(p)
		return function()
			maid:Destroy()
		end
	end)
end

return JumpLTMController