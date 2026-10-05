local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
require(ReplicatedStorage.Packages.CreateTween)
local Gradients = require(ReplicatedStorage.Packages.Gradients)
local Observers = require(ReplicatedStorage.Packages.Observers)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local NotificationController = require(ReplicatedStorage.Controllers.NotificationController)
local InterfaceController = require(ReplicatedStorage.Controllers.InterfaceController)
require(ReplicatedStorage.Controllers.AnimalController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local ShopController = require(ReplicatedStorage.Controllers.ShopController)
local AnimatedButton = require(ReplicatedStorage.Classes.AnimatedButton)
local FuseMachineData = require(ReplicatedStorage.Datas.FuseMachineData)
local Mutations = require(ReplicatedStorage.Shared.Mutations)
local Animals = require(ReplicatedStorage.Shared.Animals)
local Mutations2 = require(ReplicatedStorage.Datas.Mutations)
local MutationText = require(ReplicatedStorage.Shared.MutationText)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
require(ReplicatedStorage.Shared.Index)
local Rarities = require(ReplicatedStorage.Datas.Rarities)
local Animals2 = require(ReplicatedStorage.Datas.Animals)
local TimeUtils = require(ReplicatedStorage.Utils.TimeUtils)
require(ReplicatedStorage.Utils.MathUtils)
local Traits = require(ReplicatedStorage.Datas.Traits)
require(ReplicatedStorage.Shared.Updates)
require(ReplicatedStorage.Shared.Animals)
local Timer = require(ReplicatedStorage.Packages.Timer)
require(ReplicatedStorage.Packages.Spr)
local VFX = require(ReplicatedStorage.Shared.VFX)
local remoteEvent = Net:RemoteEvent("ShopService/Purchase")
local localPlayer = Players.LocalPlayer
local fuseMachine = localPlayer.PlayerGui:WaitForChild("FuseMachine").FuseMachine
local brainrots = fuseMachine.Brainrots
local fusions = fuseMachine.Fusions
local fusionsOld = fuseMachine.FusionsOld
local time = fuseMachine.Time
local buy = fuseMachine.Buy
local close = fuseMachine.Header.Close
local maid = Trove.new()
local v = Trove.new()
local v2 = nil
local v3 = {}

local function playHauntedTrack(p: string)
	for _, v4 in v3 do
		v4.Idle:Stop(0.2)
		v4[p]:Play(0.1)
	end
end

local v4 = {
	"Bone.003",
	"Bone.004",
	"Bone.005",
	"Bone.006"
}

local function rotationBetween(upVector: Vector3, unit: Vector3)
	local cross = upVector:Cross(unit)
	local v5 = math.clamp(upVector:Dot(unit), -1, 1)

	if not (cross.Magnitude < 0.00001) then
		return CFrame.fromAxisAngle(cross.Unit, (math.acos(v5)))
	end

	if v5 > 0 then
		return CFrame.identity
	end

	local cross2 = upVector:Cross(createVector(1, 0, 0))

	if cross2.Magnitude < 0.001 then
		cross2 = upVector:Cross(createVector(0, 0, 1))
	end

	return CFrame.fromAxisAngle(cross2.Unit, 3.141592653589793)
end

local function quadraticBezier(vector2: Vector3, vector3: Vector3, vector4: Vector3, p: number)
	local v5 = 1 - p
	return vector2 * (v5 * v5) + vector3 * (v5 * 2 * p) + vector4 * (p * p)
end

local function getHauntedRootPart()
	for k in v3 do
		local parent = k.Parent

		if not parent or parent:GetAttribute("Hidden") then
			continue
		end

		local rootPart = k:FindFirstChild("RootPart")

		if rootPart and rootPart:IsA("BasePart") then
			return rootPart
		end
	end

	return nil
end

local function findCarriedBrainrot()
	for _, part in CollectionService:GetTagged((`Held_{localPlayer.UserId}`)) do
		if not part:IsA("BasePart") then
			continue
		end

		for _, weld in part:GetJoints() do
			if not weld:IsA("Weld") then
				continue
			end

			local part0 = weld.Part0
			local part0Model = part0 and part0:FindFirstAncestorOfClass("Model")

			if part0Model then
				return part0Model
			end
		end
	end

	return nil
end

local function snapshotBrainrot(instance)
	local clone = instance:Clone()

	if not clone then
		return nil
	end

	for _, v5 in clone:QueryDescendants("BillboardGui") do
		v5:Destroy()
	end

	for _, v5 in clone:QueryDescendants("JointInstance"), nil, nil do
		local part1 = v5.Part1

		if not part1 or part1:IsDescendantOf(clone) then
			continue
		end

		v5:Destroy()
	end

	local primaryPart = clone.PrimaryPart

	for _, v5 in clone:QueryDescendants("BasePart"), nil, nil do
		v5.Anchored = primaryPart == nil or v5 == primaryPart
		v5.CanCollide = false
		v5.CanQuery = false
		v5.CanTouch = false
	end

	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getBrainrotAnimator(instance)
	local animationController = instance:FindFirstChild("AnimationController")
	return animationController and animationController:FindFirstChildOfClass("Animator")
end

local function getIdleTimePosition(instance)
	local brainrotAnimator = getBrainrotAnimator(instance) -- equivalent call inferred; original call site unknown
	local child = ReplicatedStorage.Animations.Animals:FindFirstChild(instance.Name)
	local idle = child and child:FindFirstChild("Idle")

	if not (brainrotAnimator and idle) then
		return nil
	end

	for _, v5 in brainrotAnimator:GetPlayingAnimationTracks() do
		if v5.Animation == idle then
			return v5.TimePosition
		end
	end

	return nil
end

local function playSnapshotIdle(instance, p: number?)
	local brainrotAnimator = getBrainrotAnimator(instance) -- equivalent call inferred; original call site unknown
	local child = ReplicatedStorage.Animations.Animals:FindFirstChild(instance.Name)
	local idle = child and child:FindFirstChild("Idle")

	if not (brainrotAnimator and idle and idle:IsA("Animation")) then
		return
	end

	local track = brainrotAnimator:LoadAnimation(idle)
	track.Looped = true
	track:Play(0)

	if p and track.Length > 0 then
		track.TimePosition = p % track.Length
	end
end

local function grabWithHauntedTongue(instance)
	local hauntedRootPart = getHauntedRootPart()
	local bones = {}

	if hauntedRootPart then
		for _, childName in v4 do
			local bone = hauntedRootPart:FindFirstChild(childName, true)

			if bone and bone:IsA("Bone") then
				table.insert(bones, bone)
			end
		end
	end

	if not hauntedRootPart or #bones ~= #v4 then
		instance:Destroy()
		return
	end

	local cFrames = table.create(#bones)
	local cFrame = hauntedRootPart.CFrame

	for _, v5 in bones do
		cFrame *= v5.CFrame
		table.insert(cFrames, cFrame)
	end

	local v5 = table.create(#bones, 0)
	local total = 0

	for i = 2, #bones do
		total += (cFrames[i].Position - cFrames[i - 1].Position).Magnitude
		v5[i] = total
	end

	for k, v6 in v5 do
		v5[k] = v6 / total
	end

	local position = cFrames[1].Position
	local unit = (cFrames[2].Position - position).Unit
	local rightVector = hauntedRootPart.CFrame.RightVector
	local v6 = position + unit * (total * 0.5)
	local boundingBox, v7 = instance:GetBoundingBox()
	local position2 = boundingBox.Position
	local v8 = math.clamp(math.min(v7.X, v7.Z) * 0.4, 1, 3)
	local unit2 = (position2 - position).Unit
	local unit3 = (rightVector - unit2 * rightVector:Dot(unit2)).Unit
	local vector2 = unit3:Cross(unit2)

	if vector2.Y < 0 then
		vector2 = -vector2
	end

	local v9 = position2 + unit3 * v8
	local pivot = instance:GetPivot()
	local v10 = pivot.Position - position2
	local scale = instance:GetScale()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function wrapPoint(vector3: Vector3, p: number, p2: number)
		return vector3 + (unit3 * math.cos(p2) + unit2 * math.sin(p2)) * p
	end

	local v11 = table.create(#bones)
	local lastTime = os.clock()
	local preSimulationConnection = nil
	preSimulationConnection = RunService.PreSimulation:Connect(function()
		local v12 = os.clock() - lastTime

		if v12 >= 0.6799999999999999 or not hauntedRootPart.Parent then
			preSimulationConnection:Disconnect()
			instance:Destroy()
		else
			local v13 = v9
			local value = 1
			local v14 = position2
			local v15 = 1

			if v12 < 0.18 then
				v13 = v6:Lerp(v9, (TweenService:GetValue(v12 / 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)))
				value = 0
			elseif v12 < 0.3 then
				value = TweenService:GetValue((v12 - 0.18) / 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			elseif v12 >= 0.36 then
				local v16 = (v12 - 0.36) / 0.32
				v14 = position2:Lerp(v6, (TweenService:GetValue(v16, Enum.EasingStyle.Quad, Enum.EasingDirection.In)))
				v15 = 1 + -0.75 * v16
			end

			if v12 >= 0.36 then
				instance:ScaleTo(scale * v15)
				instance:PivotTo(CFrame.new(v14 + v10 * v15) * pivot.Rotation)
			end

			local v16 = v8 * v15
			local v17 = value * 3.839724354387525
			local magnitude = (v13 - position).Magnitude
			local v18 = position + unit * (magnitude * 0.5) + rightVector * (magnitude * 0.2)

			for k, v19 in v5 do
				local v21 = 1 - v19
				local v22 = position * (v21 * v21) + v18 * (v21 * 2 * v19) + v13 * (v19 * v19)

				if k == 1 or value == 0 then
					v11[k] = v22
				else
					local point = wrapPoint(v14, v16, v17 * (k - 2) / (#bones - 2)) -- equivalent call inferred; original call site unknown
					local v25 = v11

					if k ~= #bones then
						point = v22:Lerp(point, value)
					end

					v25[k] = point
				end
			end

			local unit4 = (v13 - v18).Unit
			local v19 = unit2 * math.cos(v17) - unit3 * math.sin(v17)
			local v20 = math.clamp(math.min(v12, 0.6799999999999999 - v12) / 0.08, 0, 1)
			local cFrame2 = hauntedRootPart.CFrame

			for k, v21 in bones do
				local upVector

				if k < #bones then
					upVector = v11[k + 1] - v11[k]
				else
					upVector = unit4:Lerp(v19, value)
				end

				if upVector.Magnitude < 0.0001 then
					upVector = cFrames[k].UpVector
				end

				local unit5 = upVector.Unit
				local v22 = rotationBetween(cFrames[k].UpVector, unit5) * cFrames[k].Rotation
				local total2 = -1.0995574287564276
				local v23 = vector2 - unit5 * vector2:Dot(unit5)

				if value > 0 and v23.Magnitude > 0.001 then
					local rightVector2 = v22.RightVector
					total2 += (math.atan2(rightVector2:Cross(v23.Unit):Dot(unit5), (rightVector2:Dot(v23.Unit))) - total2) * value
				end

				local v24 = CFrame.new(v11[k]) * CFrame.fromAxisAngle(unit5, total2) * v22
				local cframe = cFrame2 * v21.CFrame
				v21.Transform = v21.Transform:Lerp(cframe:Inverse() * v24, v20)
				cFrame2 = cframe * v21.Transform
			end
		end
	end)
end

local FuseMachineController = {}

local function getBrainrotsInMachine(animalPodiums)
	local clones = {}

	for k, item in animalPodiums do
		if not (item.Machine and item.Machine.Type == "Fuse") then
			continue
		end

		local clone = table.clone(item)
		clone.IndexOnPlot = k
		table.insert(clones, clone)
	end

	return clones
end

local fn
local maid2 = Trove.new()

local function SetupBrainrots()
	local v5 = Synchronizer:Get(localPlayer)

	if not v5 then
		return
	end

	maid2:Clean()
	local brainrotsInMachine = getBrainrotsInMachine(v5:Get("AnimalPodiums"))

	if not brainrotsInMachine then
		return
	end

	for i = 1, FuseMachineData.FuseSlots do
		local v6 = brainrotsInMachine[i]

		if v6 and v6 ~= "Empty" then
			local animal = Animals2[v6.Index]
			local rarity = Rarities[animal.Rarity]
			local clone = maid2:Clone(brainrots.Template)
			clone.Name = `{animal.DisplayName}.{i}`
			clone.LayoutOrder = i
			clone.BrainrotName.Text = Animals:GetDisplayName(v6.Index)

			if v6.Mutation then
				MutationText.apply(clone.Mutation, v6.Mutation, "Auto")
			end

			clone.Rarity.Text = animal.Rarity

			if rarity.GradientPreset then
				clone.Rarity.TextColor3 = Color3.fromRGB(255, 255, 255)
				Gradients.apply(clone.Rarity, rarity.GradientPreset)
			else
				clone.Rarity.TextColor3 = rarity.Color
			end

			clone.Visible = true
			clone.Parent = brainrots
			local v7 = AnimatedButton.new(clone.Return)
			maid2:Add(v7)
			v7:Animate()
			local v8 = v6
			maid2:Add(v7.OnActivated:Connect(function()
				local v9, v10 = FuseMachineData.Remotes.RemoveBrainrot:InvokeServer(v8.IndexOnPlot)

				if v9 then
					return
				end

				NotificationController:Error(v10 or "Something went wrong!")
			end))
			local v9 = Animals:AttachOnViewport(v6.Index, clone.ViewportFrame, true, v6.Mutation and v6.Mutation or nil)

			if v9 then
				maid2:Add(v9)
			end
		else
			local clone = maid2:Clone(brainrots.Template)
			clone.Name = `Empty.{i}`
			clone.LayoutOrder = i
			clone.Visible = true
			clone.BrainrotName.Text = "Empty"
			clone.BrainrotName.TextColor3 = Color3.fromRGB(255, 112, 112)
			clone.Return:Destroy()
			clone.Rarity:Destroy()
			clone.Mutation:Destroy()
			clone.ViewportFrame:Destroy()
			clone.Parent = brainrots
		end
	end
end

local function UpdateOdds()
	local v5 = Synchronizer:Get(localPlayer)

	if not v5 then
		return
	end

	fusions.Visible = false
	fusionsOld.Visible = false
	fuseMachine.PossibleFusions.Visible = false

	for _, frame in fusions:GetChildren() do
		if frame:IsA("Frame") and frame.Name ~= "Template" then
			frame:Destroy()
		end
	end

	for _, label in fusionsOld:GetChildren() do
		if label:IsA("TextLabel") and label.Name ~= "Template" then
			label:Destroy()
		end
	end

	for _, frame in fuseMachine.Lists.Mutations.ScrollingFrame:GetChildren() do
		if frame:IsA("Frame") and frame.Name ~= "Template" then
			frame:Destroy()
		end
	end

	for _, frame in fuseMachine.Lists.Traits.ScrollingFrame:GetChildren() do
		if frame:IsA("Frame") and frame.Name ~= "Template" then
			frame:Destroy()
		end
	end

	local v6 = v5:Get("FuseMachine.OutputRarityOdds")
	local v7 = v5:Get("FuseMachine.OutputTraitsOdds") or {}
	local v8 = v5:Get("FuseMachine.OutputMutationOdds") or {}

	if not v6 then
		return
	end

	local visible = false

	for k, v10 in v8 do
		local mutation = Mutations2[k]

		if not mutation then
			continue
		end

		local clone = fuseMachine.Lists.Mutations.ScrollingFrame.Template:Clone()
		clone.Name = k
		clone.LayoutOrder = -v10
		clone.Vector.Image = mutation.Icon or ""
		MutationText.apply(clone.Title, k, "Auto")
		local _, v11 = math.modf(v10)
		clone.Chance.Text = `{string.format(v11 == 0 and "%d" or "%.2f", v10)}%`
		clone.Visible = true
		clone.Parent = fuseMachine.Lists.Mutations.ScrollingFrame
		visible = true
	end

	fuseMachine.Lists.Mutations.Visible = visible
	local visible2 = false

	for k, v11 in v7 do
		local trait = Traits[k]

		if not trait then
			continue
		end

		local clone = fuseMachine.Lists.Traits.ScrollingFrame.Template:Clone()
		clone.Name = k
		clone.LayoutOrder = -v11
		clone.Vector.Image = trait.Icon or ""
		clone.Title.Text = trait.DisplayWithRichText
		clone.Title.TextColor3 = trait.Color
		clone.Title.RichText = true
		local _, v12 = math.modf(v11)
		clone.Chance.Text = `{string.format(v12 == 0 and "%d" or "%.2f", v11)}%`
		clone.Visible = true
		clone.Parent = fuseMachine.Lists.Traits.ScrollingFrame
		visible2 = true
	end

	fuseMachine.Lists.Traits.Visible = visible2
	local clone = table.clone(v6)
	local visible3 = false

	for k, v12 in clone do
		if v12 == 0 then
			continue
		end

		if Rarities[k] then
			visible3 = true
			local rarity = Rarities[k]
			local clone2 = fusionsOld.Template:Clone()
			clone2.Name = k
			local _, v13 = math.modf(v12)
			clone2.Text = `{k} ({string.format(v13 == 0 and "%d" or "%.2f", v12)}%)`

			if rarity.GradientPreset then
				clone2.TextColor3 = Color3.fromRGB(255, 255, 255)
				Gradients.apply(clone2, rarity.GradientPreset)
			else
				clone2.TextColor3 = rarity.Color
			end

			clone2.LayoutOrder = -v12
			clone2.Visible = true
			clone2.Parent = fusionsOld
		elseif Animals2[k] then
			local animal = Animals2[k]
			local rarity = Rarities[animal.Rarity]
			local clone2 = fusions.Template:Clone()
			clone2.Name = `{k}.{animal.Rarity}`
			clone2.BrainrotName.Text = Animals:GetDisplayName(k)
			local _, v13 = math.modf(v12)
			clone2.Weight.Text = `{string.format(v13 == 0 and "%d" or "%.2f", v12)}%`

			if rarity.GradientPreset then
				clone2.Weight.TextColor3 = Color3.fromRGB(255, 255, 255)
				Gradients.apply(clone2.Weight, rarity.GradientPreset)
			else
				clone2.Weight.TextColor3 = rarity.Color
			end

			clone2.LayoutOrder = -v12
			clone2.Visible = true
			clone2.Parent = fusions
			Animals:AttachOnViewport(k, clone2.ViewportFrame, true, nil)
		end
	end

	fusions.Visible = not visible3
	fusionsOld.Visible = visible3
	fuseMachine.PossibleFusions.Visible = true
end

local v5 = AnimatedButton.new(buy)
v5:Animate()

local function UpdateBuyButton()
	local v6 = Synchronizer:Get(localPlayer)

	if not v6 then
		return
	end

	local v7 = v6:Get("FuseMachine.Cost")
	maid:Clean()
	buy.Visible = false

	if not v7 then
		return
	end

	local v8 = v6:Get("FuseMachine.StartTime")

	if v8 and v8 ~= 0 then
		return
	end

	buy.Price.Text = `${NumberUtils:ToString(v7)}`
	buy.Visible = true
	maid:Add(v5.OnActivated:Connect(function()
		local v9, v10 = FuseMachineData.Remotes.ConfirmFusion:InvokeServer()

		if v9 then
			maid:Clean()
		else
			NotificationController:Error(v10 or "Something went wrong!")
		end
	end))
end

local function UpdateTimer()
	v:Clean()
	local v6 = Synchronizer:Get(localPlayer)

	if not v6 then
		return
	end

	time.Visible = false
	local v7 = v6:Get("FuseMachine.FinishTime")

	if v7 then
		time.Visible = true

		if v7 - workspace:GetServerTimeNow() < 0 then
			time.Text = "Fusion Time (<font color=\"#ffff00\">0s</font>)"

			for _, v8 in CollectionService:GetTagged("FuseMachineCountdown") do
				v8.Text = "READY"
			end
		else
			local text = TimeUtils:E(v7 - workspace:GetServerTimeNow())
			time.Text = `Fusion Time (<font color="#ffff00">{text}</font>)`

			for _, v9 in CollectionService:GetTagged("FuseMachineCountdown") do
				v9.Text = text
			end
		end
	else
		local v8 = v6:Get("FuseMachine.OutputRarityOdds")

		if v8 then
			local rarity = "Common"

			for k, v9 in v8 do
				if v9 <= 0 then
					continue
				end

				if Rarities[k] then
					if Rarities[k].Weight > Rarities[rarity].Weight then
						rarity = k
					end
				else
					local animal = Animals2[k]

					if animal and animal.Price then
						if Rarities[animal.Rarity].Weight > Rarities[rarity].Weight then
							rarity = animal.Rarity
						end
					else
						warn((`Failed to find AnimalsData for {k}`))
					end
				end
			end

			time.Text = `Fusion Time (<font color="#ffff00">{TimeUtils:E(FuseMachineData.FuseTime[rarity])}</font>)`
			time.Visible = true
		else
			time.Text = "Fusion Time (<font color=\"#ffff00\">0s</font>)"
		end

		local v9 = #getBrainrotsInMachine(v6:Get("AnimalPodiums"))

		for _, v10 in CollectionService:GetTagged("FuseMachineCountdown") do
			v10.Text = `{v9}/{FuseMachineData.FuseSlots}`
		end
	end
end

local function UpdateLuckVisibility()
	local v6 = Synchronizer:Get(localPlayer)

	if not v6 then
		return
	end

	local fuseMachine2 = v6:Get("FuseMachine")
	local v7

	if fuseMachine2.StartTime and fuseMachine2.StartTime ~= 0 then
		v7 = fuseMachine2.FuseLuckMultiplier > 1
	else
		v7 = FuseMachineController:GetLuck() > 1
	end

	fuseMachine.LuckyIcon.Visible = v7
	fuseMachine.LuckBlur.Visible = v7
	fuseMachine.Fusions.LuckUIStroke.Enabled = v7
end

function FuseMachineController:GetLuck()
	return ReplicatedStorage:GetAttribute("FuseMachineLuck") or 1
end

function FuseMachineController:OnLuckChanged(callback)
	return (ReplicatedStorage:GetAttributeChangedSignal("FuseMachineLuck"):Connect(function()
		callback(self:GetLuck())
	end))
end

function FuseMachineController:Start()
	task.spawn(pcall, function()
		ContentProvider:PreloadAsync(script:GetChildren())
	end)
	v2 = InterfaceController:Register("FuseMachine", fuseMachine, "TopQuint")
	v2:AttachCloseButton(close)
	v2:Close()
	ShopController:BindLabelToProductPrice(
		fuseMachine.FuseLuck.Buy.Price,
		FuseMachineData.FuseLuckProductId,
		"Product",
		100
	)
	local v6 = AnimatedButton.new(fuseMachine.FuseLuck.Buy)
	v6:Animate()
	v6.OnActivated:Connect(function()
		remoteEvent:FireServer(FuseMachineData.FuseLuckProductId)
	end)

	local function updateFuseLuckVisibility()
		fuseMachine.FuseLuck.Visible = FFlags:GetInstant("FuseMachineService/ShowFuseMachineLuck", true) and FFlags:GetInstant(
			"FuseMachineService/FuseMachineLuckEnabled",
			true
		)
	end

	FFlags:OnUpdate(updateFuseLuckVisibility)
	task.spawn(updateFuseLuckVisibility)

	fn = function()
		task.spawn(SetupBrainrots)
		task.spawn(UpdateBuyButton)
		task.spawn(UpdateOdds)
		task.spawn(UpdateTimer)
		task.spawn(UpdateLuckVisibility)
	end

	self:OnLuckChanged(UpdateLuckVisibility)
	Mutations.watch(UpdateOdds)
	Synchronizer:WaitAndCall(localPlayer, function(object2)
		object2:OnChanged("FuseMachine", fn)
		object2:OnChanged("FuseMachine.Cost", fn)
		object2:OnChanged("FuseMachine.OutputRarityOdds", fn)
		object2:OnChanged("FuseMachine.OutputTraitsOdds", fn)
		object2:OnChanged("FuseMachine.OutputMutationOdds", fn)
		object2:OnChanged("FuseMachine.FuseLuckMultiplier", fn)
		task.spawn(fn)
	end)
	Timer.Simple(1, function()
		UpdateTimer()
		UpdateBuyButton()
	end)
	Observers.observeTag("FuseMachinePrompt", function(p)
		local maid3 = Trove.new()

		local function UpdatePrompt()
			local v7 = Synchronizer:Wait(localPlayer)

			if not v7 then
				return
			end

			local v8 = v7:Get("FuseMachine.StartTime")
			local v9 = v7:Get("FuseMachine.FinishTime")

			if v9 and v9 ~= 0 and v9 <= workspace:GetServerTimeNow() then
				p.ActionText = "Claim"
			elseif not v8 or v8 == 0 then
				p.ActionText = "Fuse Machine"
			elseif (v7:Get("FuseMachine.InstantReveals") or 0) >= 1 then
				p.ActionText = "Reveal Now (FREE)"
			else
				p.ActionText = "Reveal Now"
			end
		end

		maid3:Add(task.spawn(function()
			local v7 = Synchronizer:Wait(localPlayer)

			if not v7 then
				return
			end

			v7:OnChanged("FuseMachine", UpdatePrompt)
			v7:OnChanged("FuseMachine.Cost", UpdatePrompt)
			v7:OnChanged("FuseMachine.OutputRarityOdds", UpdatePrompt)
			maid3:Add(Timer.Simple(1, UpdatePrompt))
			task.spawn(UpdatePrompt)
		end))
		maid3:Add(p.Triggered:Connect(function()
			local v7 = Synchronizer:Get(localPlayer)

			if not v7 then
				return
			end

			local v8 = v7:Get("FuseMachine.StartTime")
			local v9 = v7:Get("FuseMachine.FinishTime")

			if v9 and v9 ~= 0 and v9 <= workspace:GetServerTimeNow() then
				local v10, v11 = FuseMachineData.Remotes.ClaimBrainrot:InvokeServer()

				if not v10 then
					NotificationController:Error(v11 or "Something went wrong!")
				elseif fn then
					fn()
				end
			elseif v8 and v8 ~= 0 then
				if (v7:Get("FuseMachine.InstantReveals") or 0) >= 1 then
					FuseMachineData.Remotes.RevealNow:FireServer()
				else
					remoteEvent:FireServer(FuseMachineData.RevealNowProductId)
				end
			else
				InterfaceController:Toggle("FuseMachine")
			end
		end))
		return function()
			maid3:Destroy()
		end
	end)
	Observers.observeTag("FuseMachine", function(p)
		local maid3 = Trove.new()

		for _, child in p.Hitboxes:GetChildren() do
			local v7 = child
			maid3:Add(child.Touched:Connect(function(otherPart)
				if otherPart.Name ~= "HumanoidRootPart" then
					return
				end

				local playerFromCharacter = Players:GetPlayerFromCharacter(otherPart.Parent)

				if not playerFromCharacter or playerFromCharacter ~= localPlayer then
					return
				end

				if playerFromCharacter:GetAttribute("StealingIndex") then
					local v8

					if getHauntedRootPart() then
						v8 = findCarriedBrainrot()
					end

					local v9

					if v8 then
						v9 = snapshotBrainrot(v8)
					end

					local v10

					if v8 then
						v10 = getIdleTimePosition(v8)
					end

					local now = os.clock()

					if FuseMachineData.Remotes.Delivery:InvokeServer(v7) then
						task.spawn(function()
							SoundController:PlaySound(ReplicatedStorage.Sounds.Sfx["Fuse Machine"].Deposit)
						end)
						VFX.emit(p.Vfx.emitfuse)
						playHauntedTrack("Insert")

						if v9 then
							v9.Parent = workspace
							local v12

							if v10 then
								v12 = v10 + os.clock() - now
							end

							playSnapshotIdle(v9, v12)
							task.delay(0.1, grabWithHauntedTongue, v9)
						end

						fn()
					elseif v9 then
						v9:Destroy()
					end
				end
			end))
		end

		return function()
			maid3:Destroy()
		end
	end)
	Observers.observeTag("FuseMachineLuckGui", function(p)
		p.Enabled = self:GetLuck() > 1
		local connection = self:OnLuckChanged(function(p2)
			p.Enabled = p2 > 1
		end)
		return function()
			connection:Disconnect()
		end
	end)
	Observers.observeTag("HauntedFuseRig", function(instance)
		local brainrotAnimator = getBrainrotAnimator(instance) -- equivalent call inferred; original call site unknown

		if not brainrotAnimator then
			return function() end
		end

		local v7 = {
			Idle = brainrotAnimator:LoadAnimation(ReplicatedStorage.Animations.FuseMachine.HauntedIdle),
			Insert = brainrotAnimator:LoadAnimation(ReplicatedStorage.Animations.FuseMachine.HauntedInsert),
			Fuse = brainrotAnimator:LoadAnimation(ReplicatedStorage.Animations.FuseMachine.HauntedFuse)
		}
		v7.Idle.Looped = true
		v7.Insert.Looped = false
		v7.Fuse.Looped = false

		local function resumeIdle()
			if not (v7.Insert.IsPlaying or v7.Fuse.IsPlaying) then
				v7.Idle:Play(0.2)
			end
		end

		local stoppedConnection = v7.Insert.Stopped:Connect(resumeIdle)
		local stoppedConnection2 = v7.Fuse.Stopped:Connect(resumeIdle)
		v7.Idle:Play()
		v3[instance] = v7
		return function()
			v3[instance] = nil
			stoppedConnection:Disconnect()
			stoppedConnection2:Disconnect()

			for _, v8 in v7 do
				v8:Stop(0)
				v8:Destroy()
			end
		end
	end)
	FuseMachineData.Remotes.FuseAnimation.OnClientEvent:Connect(function(p: string, _: string, _: number)
		local fuseMachine2 = workspace:FindFirstChild("FuseMachine")

		if not fuseMachine2 then
			return
		end

		local maid3 = Trove.new()
		local tracks = {}
		local tracks2 = {}
		local tracks3 = {}

		for _, v7 in fuseMachine2:QueryDescendants(".DoorRig") do
			local animationController = v7:FindFirstChild("AnimationController")

			if not animationController then
				continue
			end

			local animator = animationController:FindFirstChild("Animator")

			if not animator then
				continue
			end

			table.insert(tracks, animator:LoadAnimation(ReplicatedStorage.Animations.FuseMachine.DoorOpen))
			table.insert(tracks2, animator:LoadAnimation(ReplicatedStorage.Animations.FuseMachine.DoorClose))
			table.insert(tracks3, animator:LoadAnimation(ReplicatedStorage.Animations.FuseMachine.LeverMove))
		end

		maid3:Add(function()
			for _, v7 in tracks do
				v7:Stop()
				v7:Destroy()
			end

			for _, v7 in tracks2 do
				v7:Stop()
				v7:Destroy()
			end

			for _, v7 in tracks3 do
				v7:Stop()
				v7:Destroy()
			end
		end)
		local animal = Animals2[p]
		local _ = Rarities[animal.Rarity]
		playHauntedTrack("Fuse")

		for _, v7 in tracks3 do
			v7:Play()
		end

		maid3:Add(task.delay(1, function()
			for _, v7 in tracks3 do
				v7:AdjustSpeed(0)
			end
		end))
		task.spawn(function()
			local child = ReplicatedStorage.Sounds.Sfx["Fuse Machine"]:FindFirstChild(animal.Rarity)

			if child then
				SoundController:PlaySound(child, fuseMachine2:GetPivot().Position)
			end
		end)

		for _, v7 in tracks do
			v7:Play()
			local v8 = v7
			maid3:Add(v7:GetMarkerReachedSignal("Freeze"):Once(function()
				v8:AdjustSpeed(0)
			end))
		end

		local child = fuseMachine2.Vfx:FindFirstChild(animal.Rarity)

		if child then
			VFX.enable(child)
		end

		task.wait(3)
		VFX.disable(child)
		task.wait(1)

		for _, v7 in tracks3 do
			v7:AdjustSpeed(-1)
		end

		for _, v7 in tracks2 do
			v7:Play()
		end

		local v7 = 2

		while v7 > 0 do
			local flag = false

			for _, v9 in tracks2 do
				if v9.Length == 0 then
					continue
				end

				flag = true
				break
			end

			if flag then
				break
			else
				v7 -= task.wait()
			end
		end

		for _, v8 in tracks do
			v8:Stop(0)
		end

		task.wait(2)
		maid3:Destroy()
	end)
	FuseMachineData.Remotes.ForceUpdate.OnClientEvent:Connect(function()
		fn()
	end)
end

return FuseMachineController