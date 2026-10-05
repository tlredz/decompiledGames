local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Trove = require(ReplicatedStorage.Packages.Trove)
local Gradients = require(ReplicatedStorage.Packages.Gradients)
local Spring = require(ReplicatedStorage.Packages.Spring)
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Animals = require(ReplicatedStorage.Datas.Animals)
local Mutations = require(ReplicatedStorage.Datas.Mutations)
local Index = require(ReplicatedStorage.Datas.Index)
local Traits = require(ReplicatedStorage.Datas.Traits)
local Rarities = require(ReplicatedStorage.Datas.Rarities)
local Animals2 = require(ReplicatedStorage.Shared.Animals)
local Index2 = require(ReplicatedStorage.Shared.Index)
local BrainrotAssets = require(ReplicatedStorage.Shared.BrainrotAssets)
local MutationText = require(ReplicatedStorage.Shared.MutationText)
local BrainrotCard = require(ReplicatedStorage.Shared.BrainrotCard)
local ExistCountsFlags = require(ReplicatedStorage.Shared.Flags.ExistCountsFlags)
local Net = require(ReplicatedStorage.Packages.Net)
local remoteEvent = Net:RemoteEvent("SingletonBrainrotMutations/RequestPair")
local AnimationSyncController = require(ReplicatedStorage.Controllers.AnimationSyncController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local HoverInfoController = require(ReplicatedStorage.Controllers.HoverInfoController)
local FastOverheadController = require(ReplicatedStorage.Controllers.FastOverheadController)
local AnimalOverheadController = require(ReplicatedStorage.Controllers.AnimalOverheadController)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local animals = ReplicatedStorage:WaitForChild("Animations").Animals
local localPlayer = Players.LocalPlayer
local cframe = CFrame.new(20000, 10000, 0)
local color = Color3.fromRGB(0, 200, 65)
local color2 = Color3.fromRGB(0, 255, 80)
local GlossaryController = {}
local v = nil
local mutation = nil
local v3 = {}
local flag = false
local flag2 = false
local glossary = nil
local list = nil
local template = nil
local searchBox = nil
local close = nil
local unselectAll = nil
local mutations = nil
local template2 = nil
local mutations2 = nil
local template3 = nil
local v4 = nil
local v5 = nil
local selectMutation
local toggleTrait
local v6 = nil
local v7 = nil
local v8 = nil
local v9 = nil
local v10 = nil
local identity = CFrame.identity
local count = 0
local displayName = nil
local generation = nil
local v11 = nil
local v12 = nil
local v13 = nil
local vector2 = createVector(0, 0, 0)
local zero = Vector2.zero
local target = 16
local v15 = 4
local v16 = 50
local v17 = nil
local v18 = Spring.new(Vector2.zero)
local v19 = Spring.new(16)
local v20 = Spring.new(createVector(0, 0, 0))
v18.Speed = 20
v18.Damper = 0.85
v19.Speed = 16
v19.Damper = 1
v20.Speed = 14
v20.Damper = 1
local flag3 = false
local zero2 = Vector2.zero
local v21 = 0.024
local v22 = 1
local zero3 = Vector2.zero
local v23 = 0
local v24 = 0
local v25 = 0
local v26 = nil
local v27 = nil
local clones = {}
local v28 = {}
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.IgnoreWater = true
local flag4 = true
local v29 = {}
local v30 = {}
local text = ""
local layerCollectors = {}
local v31 = nil

local function ensureFade()
	if v31 then
		return
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GlossaryFade"
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 6000
	screenGui.ResetOnSpawn = false
	screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 1
	frame.Parent = screenGui
	v31 = frame
end

local function fade(flag5: boolean)
	ensureFade()
	local tween = TweenService:Create(v31, TweenInfo.new(0.35), {
		BackgroundTransparency = flag5 and 0 or 1
	})
	tween:Play()
	tween.Completed:Wait()
end

local v32 = {
	Glossary = true,
	GlossaryFade = true,
	Index = true,
	TopNotification = true
}

local function hideHud()
	table.clear(layerCollectors)

	for _, layerCollector in localPlayer.PlayerGui:GetChildren() do
		if not layerCollector:IsA("LayerCollector") or not layerCollector.Enabled or v32[layerCollector.Name] or not string.match(
			layerCollector.Name,
			"^[%w _]+$"
		) then
			continue
		end

		layerCollector.Enabled = false
		table.insert(layerCollectors, layerCollector)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreHud()
	for _, v33 in layerCollectors do
		if v33 and v33.Parent then
			v33.Enabled = true
		end
	end

	table.clear(layerCollectors)
end

local function reapplyTraits()
	if v8 then
		v8:Destroy()
		v8 = nil
	end

	local v33 = v9
	local v34 = v10

	if not (v33 and v34) then
		return
	end

	local v35 = {}

	for k in v3 do
		table.insert(v35, k)
	end

	if #v35 == 0 then
		return
	end

	local maid = Trove.new()
	v8 = maid
	maid:Add(Animals2:ApplyTraits(v33, v34, v35))
end

local color3 = Color3.fromRGB(166, 166, 166)
local publicExistCounts = ReplicatorClient.get("PublicExistCounts")

-- equivalent calls inferred from this helper; original call sites unknown
local function isRealMutation(p: string?)
	return p ~= nil and p ~= "Default" and p ~= "All" and Mutations[p] ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getExistCount(p: string, p2: string?)
	local v33 = publicExistCounts:TryIndex({ "data", p })

	if not v33 then
		return nil
	end

	local v34

	if p2 == nil or p2 == "Default" or p2 == "All" then
		v34 = false
	else
		v34 = Mutations[p2] ~= nil
	end

	return v33.mutations[not v34 and "None" or p2] or 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function requestSingletonPairForSelection()
	if v then
		remoteEvent:FireServer(v, mutation or "Normal")
	else
		remoteEvent:FireServer("", "")
	end
end

local count2 = 0
local thread = nil
local v33 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelPendingTraitSet()
	count2 += 1

	if thread and coroutine.status(thread) == "suspended" then
		task.cancel(thread)
	end

	thread = nil
	v33 = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function traitSetKey(p: string, p2: string, p3)
	local clone = table.clone(p3)
	table.sort(clone)
	return (("%*\0%*\0%*"):format(p, p2, (table.concat(clone, "\0"))))
end

local function applyOverheadExists(count3: number, p: string, p2: string?, p3: number?)
	if count3 ~= count2 or not v11 then
		return
	end

	if not p3 then
		local v34 = publicExistCounts:TryIndex({ "data", p })

		if v34 then
			local v35

			if p2 == nil or p2 == "Default" or p2 == "All" then
				v35 = false
			else
				v35 = Mutations[p2] ~= nil
			end

			p3 = v34.mutations[not v35 and "None" or p2] or 0
		else
			p3 = nil
		end
	end

	if not p3 then
		v11.Visible = false
		return
	end

	local v34

	if p3 > 999999 then
		v34 = NumberUtils:ToString(p3)
	else
		v34 = NumberUtils:Comma(p3)
	end

	v11.Text = `{v34} Exist`
	v11.Visible = true
end

local fetchTraitSet

fetchTraitSet = function(p: number, p2: string, p3: string, p4: string?, p5, p6: number)
	task.spawn(function()
		local success, result = pcall(function()
			return Net:Invoke("TraitSetExistCounts/Get", p2, p3, p5)
		end)

		if p ~= count2 then
			return
		end

		if success and result == false and p6 < 6 then
			task.delay(0.6, function()
				if p == count2 then
					fetchTraitSet(p, p2, p3, p4, p5, p6 + 1)
				end
			end)
			return
		end

		v33 = nil

		if not success or type(result) ~= "number" then
			result = nil
		end

		applyOverheadExists(p, p2, p4, result)
	end)
end

local function requestTraitSetExists(p: string, p2: string?, p3)
	if ExistCountsFlags.GlossaryTraitMatchCountsEnabled:Get() then
		local v35 = not isRealMutation(p2) and "Normal" or p2
		local v36 = traitSetKey(p, v35, p3) -- equivalent call inferred; original call site unknown

		if v36 == v33 then
			return
		end

		cancelPendingTraitSet() -- equivalent call inferred; original call site unknown
		v33 = v36
		local v37 = count2
		thread = task.delay(0.5, function()
			thread = nil

			if v37 ~= count2 then
				return
			end

			local v38 = v37
			local v39 = p
			local v40 = v35
			local v41 = p2
			local v42 = p3
			local v43 = 1
			task.spawn(function()
				local success, result = pcall(function()
					return Net:Invoke("TraitSetExistCounts/Get", v39, v40, v42)
				end)

				if v38 ~= count2 then
					return
				end

				if success and result == false and v43 < 6 then
					task.delay(0.6, function()
						if v38 == count2 then
							fetchTraitSet(v38, v39, v40, v41, v42, v43 + 1)
						end
					end)
					return
				end

				v33 = nil

				if not success or type(result) ~= "number" then
					result = nil
				end

				applyOverheadExists(v38, v39, v41, result)
			end)
		end)
	else
		cancelPendingTraitSet() -- equivalent call inferred; original call site unknown
		applyOverheadExists(count2, p, p2, nil)
	end
end

local function updateOverhead()
	local v34 = displayName
	local v35 = v10

	if not (v34 and v34.Parent and v35) then
		return
	end

	local animal = Animals[v35]
	local v36 = {}

	for k in v3 do
		table.insert(v36, k)
	end

	v34.Text = AnimalOverheadController:ResolveDisplayName(v35, v36)

	if v12 and v13 and v12:FindFirstChild("Traits") then
		v13:Clean()
		local v38 = v12
		local v39

		if #v36 > 0 then
			v39 = v36
		end

		AnimalOverheadController:PopulateTraits(v38, v39, v13)
	end

	if generation then
		local generation2 = Animals2:GetGeneration(v35, mutation, v36, nil)
		generation.Text = `${NumberUtils:ToString(generation2)}/s`
		generation.Visible = not (animal and animal.HideGeneration)
	end

	if v11 then
		if #v36 > 0 then
			if ExistCountsFlags.GlossaryTraitMatchCountsEnabled:Get() then
				local existCount = getExistCount(v35, mutation) -- equivalent call inferred; original call site unknown

				if existCount == nil then
					cancelPendingTraitSet() -- equivalent call inferred; original call site unknown
					v11.Visible = false
				else
					v11.Text = "Loading..."
					v11.Visible = true
					requestTraitSetExists(v35, mutation, v36)
				end
			else
				cancelPendingTraitSet() -- equivalent call inferred; original call site unknown
				applyOverheadExists(count2, v35, mutation, nil)
			end
		else
			cancelPendingTraitSet() -- equivalent call inferred; original call site unknown
			local existCount = getExistCount(v35, mutation) -- equivalent call inferred; original call site unknown

			if existCount then
				local v38

				if existCount > 999999 then
					v38 = NumberUtils:ToString(existCount)
				else
					v38 = NumberUtils:Comma(existCount)
				end

				v11.Text = `{v38} Exist`
				v11.Visible = true
			else
				v11.Visible = false
			end
		end
	end
end

local v34 = nil

local function unbindExistsListener()
	if v34 then
		v34()
		v34 = nil
	end
end

local function bindExistsListener(p: string)
	if v34 then
		v34()
		v34 = nil
	end

	v34 = publicExistCounts:Listen({ "data", p }, function()
		updateOverhead()
	end)
end

local function createOverhead(maid, clone, p: string)
	local primaryPart = clone.PrimaryPart

	if not primaryPart then
		return
	end

	local animal = Animals[p]
	local extentsSize = clone:GetExtentsSize()
	local adornee = clone:FindFirstChild("OVERHEAD_ATTACHMENT", true)

	if not (adornee and adornee:IsA("Attachment")) then
		adornee = Instance.new("Attachment")
		adornee.Parent = primaryPart
		adornee.WorldCFrame = clone:GetPivot() * CFrame.new(
			0,
			extentsSize.Y * 0.75 * (animal and animal.OverheadYOffsetModifier or 1),
			0
		)
	end

	local fastOverhead, v36 = FastOverheadController.createFastOverhead({
		adornee = adornee,
		guiTemplate = FastOverheadController.GuiTemplates.AnimalOverhead
	})
	maid:Add(v36)
	fastOverhead.MaxDistance = 1e999
	fastOverhead.Price.Visible = false
	fastOverhead.Rarity.Visible = false
	fastOverhead.Mutation.Visible = false

	if fastOverhead:FindFirstChild("Stolen") then
		fastOverhead.Stolen.Visible = false
	end

	if fastOverhead:FindFirstChild("Traits") then
		fastOverhead.Traits.Visible = false
	end

	local _1OF1Banner = fastOverhead:FindFirstChild("1OF1Banner")

	if _1OF1Banner and _1OF1Banner:IsA("GuiObject") then
		_1OF1Banner.Visible = false
		maid:Add(BrainrotCard.ObserveOneOfOne({
			Index = p,
			Mutation = mutation
		}, function(visible: boolean)
			_1OF1Banner.Visible = visible
		end))
	end

	local clone2 = fastOverhead.Generation:Clone()
	clone2.Name = "Exists"
	clone2.LayoutOrder = (fastOverhead.Generation.LayoutOrder or 3) + 2
	clone2.TextColor3 = color3
	clone2.Visible = false
	clone2.Parent = fastOverhead
	local apply = MutationText.apply
	local v37 = mutation
	local v38

	if v37 == nil or v37 == "Default" or v37 == "All" then
		v38 = false
	else
		v38 = Mutations[v37] ~= nil
	end

	local v39

	if v38 then
		v39 = mutation
	end

	local v40 = apply(clone2, v39)

	if v40 then
		maid:Add(v40)
	end

	displayName = fastOverhead.DisplayName
	generation = fastOverhead.Generation
	v11 = clone2
	v12 = fastOverhead
	local extended = maid:Extend()
	v13 = extended
	maid:Add(function()
		if v11 == clone2 then
			displayName = nil
			generation = nil
			v11 = nil
			v12 = nil

			if v13 == extended then
				v13 = nil
			end
		end
	end)
	updateOverhead()
end

local function buildModel()
	count += 1
	local v35 = count

	if v8 then
		v8:Destroy()
		v8 = nil
	end

	if v7 then
		v7:Destroy()
		v7 = nil
	end

	v9 = nil
	v10 = nil

	if v34 then
		v34()
		v34 = nil
	end

	local v36 = v

	if not v36 then
		return
	end

	task.spawn(function()
		local model = BrainrotAssets.getModel(v36)

		if v35 ~= count or not (flag and model) then
			return
		end

		local maid = Trove.new()
		v7 = maid
		local clone = maid:Clone(model)

		if not clone.PrimaryPart then
			clone:Destroy()
			return
		end

		for _, part in clone:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Massless = true
			part.CastShadow = false
		end

		clone.PrimaryPart.Anchored = true
		clone.Parent = workspace.CurrentCamera

		if mutation then
			maid:Add(Animals2:ApplyMutation(clone, v36, mutation))
		end

		clone:PivotTo(identity)

		if v35 ~= count or not flag then
			return
		end

		local pivot = clone:GetPivot()
		local boundingBox, v37 = Animals2:GetBoundingBox(v36, clone)
		local v38 = boundingBox.Position.Y - v37.Y * 0.5
		local v39 = boundingBox.Position.Y + v37.Y * 0.5

		for _, bone in clone:GetDescendants() do
			if not bone:IsA("Bone") then
				continue
			end

			local Y = bone.WorldPosition.Y
			v38 = math.min(v38, Y)
			v39 = math.max(v39, Y)
		end

		local v40 = v39 - v38
		local currentCamera = workspace.CurrentCamera
		local v41 = not currentCamera and 1.7777777777777777 or currentCamera.ViewportSize.X / math.max(
			currentCamera.ViewportSize.Y,
			1
		)
		local v42 = math.max(
			math.max(math.max(v37.X, v37.Z) / math.max(v41, 0.0001), v40) * 0.5 / 0.34432761328966527 * 2.1,
			6
		)
		local v43 = math.max((v38 + v39) * 0.5, identity.Position.Y + 3)
		vector2 = Vector3.new(pivot.Position.X, v43, pivot.Position.Z)
		v15 = math.max(math.max(v37.X, v40, v37.Z) * 0.5, 8)
		v16 = math.max(v42 * 3.5, v15 * 3)

		if v17 ~= v36 then
			v17 = v36
			target = math.clamp(v42, v15, v16)
		end

		v9 = clone
		v10 = v36
		bindExistsListener(v36)
		reapplyTraits()
		local animationController = clone:FindFirstChild("AnimationController")
		local animator = animationController and animationController:FindFirstChildOfClass("Animator")
		local child = animals:FindFirstChild(v36)
		local idle = child and child:FindFirstChild("Idle")

		if idle and animator then
			local track = animator:LoadAnimation(idle)
			track.Looped = true
			track:Play()
			local v44 = AnimationSyncController:Add(track)
			maid:Add(function()
				v44()
				track:Stop(0)
				track:Destroy()
			end)
		end

		createOverhead(maid, clone, v36)
	end)
end

local function getBrainrotList()
	local result = {}

	for k in Animals do
		if Index2:CanShowInIndex(k) then
			table.insert(result, k)
		end
	end

	table.sort(result, function(a, b)
		local generation2 = Animals[a].Generation or 0
		local generation3 = Animals[b].Generation or 0

		if generation2 == generation3 then
			return a < b
		end

		return generation3 < generation2
	end)
	return result
end

local function matchesQuery(displayName2: string)
	if text == "" then
		return true
	end

	local animal = Animals[displayName2]

	if animal then
		displayName2 = animal.DisplayName or displayName2
	end

	return string.find(string.lower(displayName2), text, 1, true) ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyCardColor(p: string)
	local v35 = v30[p]

	if not v35 then
		return
	end

	local v36 = p == v
	local card = v35.Card
	local backgroundColor

	if v36 then
		backgroundColor = color
	else
		backgroundColor = v35.BaseColor
	end

	card.BackgroundColor3 = backgroundColor
	local uIStroke = v35.Card:FindFirstChildWhichIsA("UIStroke")

	if uIStroke then
		local color4

		if v36 then
			color4 = color2
		else
			color4 = v35.BaseStroke
		end

		uIStroke.Color = color4
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function selectBrainrot(p: string)
	if v == p then
		return
	end

	local v35 = v
	v = p
	requestSingletonPairForSelection() -- equivalent call inferred; original call site unknown
	local v36 = v35 and v30[v35]

	if v36 then
		local v37 = v35 == v
		local card = v36.Card
		local backgroundColor

		if v37 then
			backgroundColor = color
		else
			backgroundColor = v36.BaseColor
		end

		card.BackgroundColor3 = backgroundColor
		local uIStroke = v36.Card:FindFirstChildWhichIsA("UIStroke")

		if uIStroke then
			local color4

			if v37 then
				color4 = color2
			else
				color4 = v36.BaseStroke
			end

			uIStroke.Color = color4
		end
	end

	applyCardColor(p) -- equivalent call inferred; original call site unknown
	buildModel()
end

local function buildBrainrotList()
	for _, child in list:GetChildren() do
		if child.Name == "Template" then
			child.Visible = false
		end
	end

	list.AutomaticCanvasSize = Enum.AutomaticSize.Y

	for _, name in getBrainrotList() do
		local animal = Animals[name]
		local clone = template:Clone()
		clone.Name = name
		local visible

		if text == "" then
			visible = true
		else
			local animal2 = Animals[name]
			local v37

			if animal2 then
				v37 = animal2.DisplayName or name
			else
				v37 = name
			end

			visible = string.find(string.lower(v37), text, 1, true) ~= nil
		end

		clone.Visible = visible
		local nameLabel = clone.NameLabel
		local text2

		if animal then
			text2 = animal.DisplayName or name
		else
			text2 = name
		end

		nameLabel.Text = text2
		clone.RarityLabel.Text = not animal and "" or animal.Rarity or ""

		if clone:FindFirstChild("MutationLabel") then
			clone.MutationLabel.Text = ""
		end

		local v38 = animal and Rarities[animal.Rarity]

		if v38 then
			if v38.GradientPreset then
				clone.RarityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				Gradients.apply(clone.RarityLabel, v38.GradientPreset)
			elseif v38.Color then
				clone.RarityLabel.TextColor3 = v38.Color
			end

			local uIStroke = clone.RarityLabel:FindFirstChildWhichIsA("UIStroke")

			if uIStroke and v38.StrokeColor then
				uIStroke.Color = v38.StrokeColor
			end
		end

		local viewportFrame = clone.ViewportFrame
		local uIStroke = clone:FindFirstChildWhichIsA("UIStroke")
		v30[name] = {
			Card = clone,
			Viewport = viewportFrame,
			Attached = nil,
			State = false,
			BaseColor = clone.BackgroundColor3,
			BaseStroke = uIStroke and uIStroke.Color or Color3.new(0, 0, 0)
		}
		applyCardColor(name) -- equivalent call inferred; original call site unknown
		local v39 = name
		clone.Activated:Connect(function()
			SoundController:PlaySound("Sounds.Sfx.Activated")
			selectBrainrot(v39) -- equivalent call inferred; original call site unknown
		end)
		local v40 = name
		HoverInfoController:Add(clone, function()
			return v40, mutation or "Default"
		end)
		clone.Parent = list
		v30[name].Attached = Animals2:AttachOnViewportWithOptimizations(name, viewportFrame, nil, nil)
		viewportFrame.Parent = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setCardActive(state, visible: boolean)
	if state.State == visible then
		return
	end

	state.State = visible
	local viewport = state.Viewport
	local parent

	if visible then
		parent = state.Card
	end

	viewport.Parent = parent
end

-- equivalent calls inferred from this helper; original call sites unknown
local function detachAllViewports()
	for _, v35 in v30 do
		if v35.State == false then
			continue
		end

		v35.State = false
		v35.Viewport.Parent = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startCuller()
	RunService.Heartbeat:Connect(function()
		if not flag then
			return
		end

		local Y = list.AbsolutePosition.Y
		local v35 = Y + list.AbsoluteSize.Y
		local v36 = list.AbsoluteSize.Y * 0.5

		for _, v37 in v30 do
			local card = v37.Card
			local visible = card.Visible

			if visible then
				if card.AbsoluteSize.Y > 0 then
					local v38 = card.AbsolutePosition.Y + card.AbsoluteSize.Y

					if Y - v36 <= v38 then
						visible = card.AbsolutePosition.Y <= v35 + v36
					else
						visible = false
					end
				else
					visible = false
				end
			end

			if v37.State == visible then
				continue
			end

			setCardActive(v37, visible) -- equivalent call inferred; original call site unknown
		end
	end)
end

local function addSelectionStroke(parent, enabled: boolean)
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Name = "SelectionStroke"
	uIStroke.Thickness = 2.5
	uIStroke.Color = color2
	uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uIStroke.Enabled = enabled
	uIStroke.Parent = parent
	return uIStroke
end

local function buildMutationsPanel()
	if v4 then
		v4:Destroy()
	end

	local maid = Trove.new()
	v4 = maid
	template2.Visible = false
	mutations.AutomaticCanvasSize = Enum.AutomaticSize.Y

	local function addEntry(name: string, layoutOrder: number, fn, fn2)
		local clone = maid:Clone(template2)
		clone.Name = name
		clone.LayoutOrder = layoutOrder
		clone.Visible = true
		local button = clone.Button

		if button:FindFirstChild("Timer") then
			button.Timer.Visible = false
		end

		fn(button)
		local enabled = name == (mutation or "Default")
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Name = "SelectionStroke"
		uIStroke.Thickness = 2.5
		uIStroke.Color = color2
		uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uIStroke.Enabled = enabled
		uIStroke.Parent = button
		maid:Add(button.Activated:Connect(function()
			SoundController:PlaySound("Sounds.Sfx.Activated")
			fn2()
		end))
		clone.Parent = mutations
	end

	addEntry("Default", -1, function(instance)
		MutationText.clear(instance.TextLabel)
		instance.TextLabel.RichText = false
		instance.TextLabel.Text = "Normal"
		instance.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

		if instance:FindFirstChild("ImageLabel") then
			instance.ImageLabel.Image = "rbxassetid://139326264265904"
		end
	end, function()
		selectMutation(nil)
	end)

	for k, v35 in Index do
		if not Mutations[k] or not Index2:CanProgressIndex(k) or not (not v35.DisableIndex or k == "Bloodrot") or v35.HideButton then
			continue
		end

		local indexLimitedTime = Index2:GetIndexLimitedTime(k) or v35.LimitedMutation
		local order

		if indexLimitedTime then
			order = 2000000000 - indexLimitedTime
		else
			order = v35.Order or 1
		end

		local v36 = k
		local v37 = k
		addEntry(k, order, function(instance)
			MutationText.apply(instance.TextLabel, v36, "Auto")

			if instance:FindFirstChild("ImageLabel") then
				instance.ImageLabel.Image = Mutations[v36].Icon or "rbxassetid://139326264265904"
			end
		end, function()
			selectMutation(v37)
		end)
	end
end

local function buildTraitsPanel()
	if v5 then
		v5:Destroy()
	end

	local maid = Trove.new()
	v5 = maid
	template3.Visible = false
	mutations2.AutomaticCanvasSize = Enum.AutomaticSize.Y
	local v35 = {}

	for k in Traits do
		table.insert(v35, k)
	end

	table.sort(v35, function(a, b)
		local isCountry = Traits[a].IsCountry == true
		local isCountry2 = Traits[b].IsCountry == true

		if isCountry == isCountry2 then
			return a < b
		end

		return isCountry2
	end)

	for k, name in v35 do
		local trait = Traits[name]
		local clone = maid:Clone(template3)
		clone.Name = name
		clone.LayoutOrder = k
		clone.Visible = true
		local button = clone.Button
		MutationText.clear(button.TextLabel)
		button.TextLabel.RichText = false
		button.TextLabel.Text = trait.Display or name
		button.TextLabel.TextColor3 = trait.Color or Color3.fromRGB(255, 255, 255)

		if button:FindFirstChild("ImageLabel") then
			button.ImageLabel.Image = trait.Icon
		end

		if button:FindFirstChild("Timer") then
			button.Timer.Visible = false
		end

		local enabled = v3[name] == true
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Name = "SelectionStroke"
		uIStroke.Thickness = 2.5
		uIStroke.Color = color2
		uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uIStroke.Enabled = enabled
		uIStroke.Parent = button
		local v38 = name
		maid:Add(button.Activated:Connect(function()
			SoundController:PlaySound("Sounds.Sfx.Activated")
			toggleTrait(v38)
		end))
		clone.Parent = mutations2
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateUnselectAllVisible()
	if unselectAll then
		unselectAll.Visible = next(v3) ~= nil
	end
end

toggleTrait = function(childName: string)
	if v3[childName] then
		v3[childName] = nil
	else
		v3[childName] = true
	end

	local child = mutations2:FindFirstChild(childName)
	local button = child and child:FindFirstChild("Button")
	local selectionStroke = button and button:FindFirstChild("SelectionStroke")

	if selectionStroke then
		selectionStroke.Enabled = v3[childName] == true
	end

	updateUnselectAllVisible() -- equivalent call inferred; original call site unknown
	reapplyTraits()
	updateOverhead()
end

local function updateMutationStrokes()
	if not mutations then
		return
	end

	local v35 = mutation or "Default"

	for _, guiObject in mutations:GetChildren() do
		local button = guiObject:IsA("GuiObject") and guiObject:FindFirstChild("Button")
		local selectionStroke = button and button:FindFirstChild("SelectionStroke")

		if selectionStroke and selectionStroke:IsA("UIStroke") then
			selectionStroke.Enabled = guiObject.Name == v35
		end
	end
end

selectMutation = function(p: string?)
	if mutation ~= p then
		mutation = p
		requestSingletonPairForSelection() -- equivalent call inferred; original call site unknown
		buildModel()
	end

	updateMutationStrokes()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ensureInit()
	if flag2 then
		return
	end

	flag2 = true
	buildBrainrotList()
	startCuller() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function thumbstick(p: number)
	if math.abs(p) < 0.16 then
		return 0
	end

	local v35 = p < 0 and -1 or 1
	local v36 = (math.abs(p) - 0.16) / 0.84
	return v35 * v36 * v36
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rotateBy(p: number, p2: number)
	zero = Vector2.new(zero.X - p, (math.clamp(zero.Y - p2, -1.35, 1.35)))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function zoomBy(p: number)
	target = math.clamp(target * (1 - p), v15, v16)
end

local function computeCameraCFrame()
	local position = v18.Position
	local position2 = v19.Position
	local position3 = v20.Position
	local v35 = math.cos(position.Y)
	local v36 = Vector3.new(math.sin(position.X) * v35, math.sin(position.Y), math.cos(position.X) * v35) * position2
	return CFrame.lookAt(position3 + v36, position3)
end

local function updateOcclusion(currentCamera)
	local position = v20.Position
	local position2 = currentCamera.CFrame.Position
	local v35 = position - position2
	local magnitude = v35.Magnitude
	local v36 = v29
	table.clear(v36)

	if magnitude > 0.1 and #clones > 0 then
		local unit = v35.Unit

		if flag4 then
			raycastParams.FilterDescendantsInstances = clones
			flag4 = false
		end

		local total = 0

		for _ = 1, 10 do
			local v37 = magnitude - total

			if v37 <= 0.1 then
				break
			end

			local cframe2 = CFrame.lookAt(position2 + unit * total, position)
			local blockcast = workspace:Blockcast(cframe2, createVector(5, 5, 1), unit * v37, raycastParams)

			if not blockcast then
				break
			end

			if blockcast.Instance and blockcast.Instance:IsA("BasePart") then
				blockcast.Instance.LocalTransparencyModifier = 0.75
				v36[blockcast.Instance] = true
			end

			total += blockcast.Distance + 0.2
		end
	end

	for k in v28 do
		if v36[k] or not k.Parent then
			continue
		end

		k.LocalTransparencyModifier = 0
	end

	v29 = v28
	v28 = v36
end

local function setupOrbitInput(maid)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function startDrag(flag5: boolean)
		flag3 = true
		zero2 = UserInputService:GetMouseLocation()
		v21 = flag5 and 0.012 or 0.024 * UserGameSettings.MouseSensitivity
		v22 = flag5 and 0.55 or 1
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isMouseButton(p)
		return p == Enum.UserInputType.MouseButton1 or p == Enum.UserInputType.MouseButton2
	end

	maid:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if isMouseButton(input.UserInputType) then
			startDrag(false) -- equivalent call inferred; original call site unknown
		elseif input.UserInputType == Enum.UserInputType.Touch and v26 == nil then
			startDrag(true) -- equivalent call inferred; original call site unknown
		elseif input.KeyCode == Enum.KeyCode.ButtonR1 then
			v23 = 1
		elseif input.KeyCode == Enum.KeyCode.ButtonL1 then
			v23 = -1
		elseif input.KeyCode == Enum.KeyCode.E then
			v24 = 1
		elseif input.KeyCode == Enum.KeyCode.Q then
			v24 = -1
		end
	end))
	maid:Add(UserInputService.InputEnded:Connect(function(input)
		if isMouseButton(input.UserInputType) or input.UserInputType == Enum.UserInputType.Touch then
			flag3 = false
		elseif input.KeyCode == Enum.KeyCode.ButtonR1 and v23 == 1 then
			v23 = 0
		elseif input.KeyCode == Enum.KeyCode.ButtonL1 and v23 == -1 then
			v23 = 0
		elseif input.KeyCode == Enum.KeyCode.E and v24 == 1 then
			v24 = 0
		elseif input.KeyCode == Enum.KeyCode.Q and v24 == -1 then
			v24 = 0
		end
	end))
	maid:Add(UserInputService.InputChanged:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			if not gameProcessed then
				zoomBy(input.Position.Z * 0.12) -- equivalent call inferred; original call site unknown
			end
		elseif input.KeyCode == Enum.KeyCode.Thumbstick2 then
			local zero4

			if gameProcessed then
				zero4 = Vector2.zero
			else
				local v35 = thumbstick(input.Position.X) -- equivalent call inferred; original call site unknown
				local v36 = thumbstick(input.Position.Y) -- equivalent call inferred; original call site unknown
				zero4 = Vector2.new(v35, v36)
			end

			zero3 = zero4
		end
	end))
	maid:Add(UserInputService.TouchPinch:Connect(function(_, p, _, p2)
		flag3 = false

		if p2 == Enum.UserInputState.End or p2 == Enum.UserInputState.Cancel then
			v26 = nil
			return
		end

		if v26 and v26 > 0 and p > 0 then
			zoomBy((1 - v26 / p) * 1) -- equivalent call inferred; original call site unknown
		end

		v26 = p
	end))
end

function GlossaryController:Open()
	if flag then
		return
	end

	flag = true
	task.spawn(function()
		if ServerData.IsTsunamiServer() or ServerData.IsDuelsServer() then
			return
		end

		Net:RemoteEvent("ExistCounts/RequestPublic"):FireServer("4833d1a5-7006-4219-a006-18550cb9f1c6")
	end)
	ensureInit() -- equivalent call inferred; original call site unknown
	fade(true)
	hideHud()
	glossary.Enabled = true
	text = ""

	if searchBox then
		searchBox.Text = ""
	end

	v = "Noobini Pizzanini"
	mutation = nil
	requestSingletonPairForSelection() -- equivalent call inferred; original call site unknown
	table.clear(v3)
	updateUnselectAllVisible() -- equivalent call inferred; original call site unknown

	for displayName2, v35 in v30 do
		applyCardColor(displayName2) -- equivalent call inferred; original call site unknown
		local card = v35.Card
		local visible

		if text == "" then
			visible = true
		else
			local animal = Animals[displayName2]

			if animal then
				displayName2 = animal.DisplayName or displayName2
			end

			visible = string.find(string.lower(displayName2), text, 1, true) ~= nil
		end

		card.Visible = visible
	end

	buildMutationsPanel()
	buildTraitsPanel()
	localPlayer:SetAttribute("FreezeLocalMovement", true)
	localPlayer:Move(createVector(0, 0, 0))
	local currentCamera = workspace.CurrentCamera
	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.FieldOfView = 38
	local maid = Trove.new()
	v6 = maid
	table.clear(clones)
	table.clear(v28)
	table.clear(v29)
	flag4 = true
	identity = cframe
	local glossaryBackground = ReplicatedStorage:FindFirstChild("GlossaryBackground")

	if glossaryBackground then
		local clone = maid:Clone(glossaryBackground)

		for _, part in clone:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = true
			part.CanTouch = false
		end

		if clone:IsA("Model") then
			clone:PivotTo(cframe)
		end

		clone.Parent = workspace
		table.insert(clones, clone)
	end

	local lookVector = identity.LookVector
	zero = Vector2.new(math.atan2(lookVector.X, lookVector.Z), 0.12)
	target = 16
	vector2 = identity.Position + createVector(0, 3, 0)
	v17 = nil
	flag3 = false
	zero3 = Vector2.zero
	v23 = 0
	v24 = 0
	v25 = 0
	v26 = nil
	v18:SetTarget(zero, true)
	v19:SetTarget(target, true)
	v20:SetTarget(vector2, true)
	local position = v18.Position
	local position2 = v19.Position
	local position3 = v20.Position
	local v35 = math.cos(position.Y)
	local v36 = Vector3.new(math.sin(position.X) * v35, math.sin(position.Y), math.cos(position.X) * v35) * position2
	currentCamera.CFrame = CFrame.lookAt(position3 + v36, position3)

	if v27 then
		v27.Enabled = false
	end

	setupOrbitInput(maid)
	maid:Add(RunService.PreRender:Connect(function(dt)
		if flag3 then
			local mouseLocation = UserInputService:GetMouseLocation()
			local v37 = mouseLocation - zero2
			zero2 = mouseLocation
			local cameraYInvertValue = UserGameSettings:GetCameraYInvertValue()
			rotateBy(v37.X * v21, v37.Y * v21 * v22 * cameraYInvertValue) -- equivalent call inferred; original call site unknown
		end

		if zero3.X ~= 0 or zero3.Y ~= 0 then
			local v37 = 4 * UserGameSettings.GamepadCameraSensitivity * dt
			rotateBy(zero3.X * v37, -zero3.Y * v37) -- equivalent call inferred; original call site unknown
		end

		if v23 ~= 0 then
			zoomBy(v23 * 1.4 * dt) -- equivalent call inferred; original call site unknown
		end

		if v24 ~= 0 then
			v25 = math.clamp(v25 + v24 * 16 * dt, -5, 5)
		end

		v18.Target = zero
		v19.Target = target
		v20.Target = vector2 + Vector3.new(0, v25, 0)
		local currentCamera2 = workspace.CurrentCamera

		if currentCamera2 then
			local position4 = v18.Position
			local position5 = v19.Position
			local position6 = v20.Position
			local v37 = math.cos(position4.Y)
			local v38 = Vector3.new(math.sin(position4.X) * v37, math.sin(position4.Y), math.cos(position4.X) * v37) * position5
			currentCamera2.CFrame = CFrame.lookAt(position6 + v38, position6)
			updateOcclusion(currentCamera2)
		end
	end))
	buildModel()
	task.wait(0.1)
	fade(false)
end

function GlossaryController:Close()
	if not flag then
		return
	end

	flag = false
	remoteEvent:FireServer("", "")
	fade(true)
	glossary.Enabled = false

	if v4 then
		v4:Destroy()
		v4 = nil
	end

	if v5 then
		v5:Destroy()
		v5 = nil
	end

	detachAllViewports() -- equivalent call inferred; original call site unknown

	if v8 then
		v8:Destroy()
		v8 = nil
	end

	if v7 then
		v7:Destroy()
		v7 = nil
	end

	v9 = nil
	v10 = nil

	if v34 then
		v34()
		v34 = nil
	end

	table.clear(clones)
	table.clear(v28)
	table.clear(v29)
	flag4 = true

	if v6 then
		v6:Destroy()
		v6 = nil
	end

	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		currentCamera.CameraType = Enum.CameraType.Custom
		local character = localPlayer.Character

		if character then
			currentCamera.CameraSubject = character:FindFirstChildWhichIsA("Humanoid")
		end

		currentCamera.FieldOfView = 70
	end

	localPlayer:SetAttribute("FreezeLocalMovement", false)

	if v27 then
		v27.Enabled = true
	end

	restoreHud() -- equivalent call inferred; original call site unknown
	task.wait(0.05)
	fade(false)
end

function GlossaryController.Start(_)
	if not ServerData.IsTradePlaza() then
		return
	end

	glossary = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Glossary", 30)

	if not glossary then
		warn("[GlossaryController] PlayerGui.Glossary not found")
		return
	end

	glossary.Enabled = false
	local main = glossary:WaitForChild("Left"):WaitForChild("Main")
	local header = main:WaitForChild("Header")
	searchBox = header.SearchFrame.SearchBox
	close = header.Close
	list = main.Content.Holder.List
	template = list.Template
	local right = glossary:WaitForChild("Right")
	local mutations3 = right:WaitForChild("Mutations")
	local traits = right:WaitForChild("Traits")
	mutations = mutations3.Content.Holder.Mutations
	template2 = mutations.Template
	mutations2 = traits.Content.Holder.Mutations
	template3 = mutations2.Template
	mutations3.Header.Txt1.Text = "Mutations"
	traits.Header.Txt1.Text = "Traits"
	right.Visible = true
	mutations3.Visible = true
	traits.Visible = true
	unselectAll = right:WaitForChild("UnselectAll")
	unselectAll.Visible = false
	unselectAll.Activated:Connect(function()
		if next(v3) == nil then
			return
		end

		SoundController:PlaySound("Sounds.Sfx.Activated")
		table.clear(v3)

		for _, guiObject in mutations2:GetChildren() do
			local button = guiObject:IsA("GuiObject") and guiObject:FindFirstChild("Button")
			local selectionStroke = button and button:FindFirstChild("SelectionStroke")

			if selectionStroke and selectionStroke:IsA("UIStroke") then
				selectionStroke.Enabled = false
			end
		end

		updateUnselectAllVisible() -- equivalent call inferred; original call site unknown
		reapplyTraits()
		updateOverhead()
	end)
	close.Activated:Connect(function()
		SoundController:PlaySound("Sounds.Sfx.Activated")
		GlossaryController:Close()
	end)
	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		text = string.lower(searchBox.Text)

		for displayName2, v35 in v30 do
			local card = v35.Card
			local visible

			if text == "" then
				visible = true
			else
				local animal = Animals[displayName2]

				if animal then
					displayName2 = animal.DisplayName or displayName2
				end

				visible = string.find(string.lower(displayName2), text, 1, true) ~= nil
			end

			card.Visible = visible
		end
	end)
	ExistCountsFlags.GlossaryTraitMatchCountsEnabled.Changed:Connect(function()
		updateOverhead()
	end)
	task.spawn(function()
		local map = workspace:WaitForChild("Map", 60)
		local glossary2 = map and map:WaitForChild("Glossary", 60)

		if not glossary2 then
			warn("[GlossaryController] workspace.Map.Glossary not found")
			return
		end

		local rootPart = glossary2:FindFirstChild("RootPart", true) or glossary2:FindFirstChildWhichIsA(
			"BasePart",
			true
		)

		if not rootPart then
			warn("[GlossaryController] Glossary has no BasePart to anchor a prompt")
			return
		end

		local proximityPrompt = Instance.new("ProximityPrompt")
		proximityPrompt.ActionText = "Open"
		proximityPrompt.ObjectText = "Brainrot Glossary"
		proximityPrompt.KeyboardKeyCode = Enum.KeyCode.E
		proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
		proximityPrompt.HoldDuration = 0
		proximityPrompt.RequiresLineOfSight = false
		proximityPrompt.MaxActivationDistance = 12
		proximityPrompt.Parent = rootPart
		v27 = proximityPrompt
		proximityPrompt.Triggered:Connect(function()
			if flag then
				return
			end

			GlossaryController:Open()
		end)
	end)
end

return GlossaryController