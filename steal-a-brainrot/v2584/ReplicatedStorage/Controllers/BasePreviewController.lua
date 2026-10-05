local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Bases = require(ReplicatedStorage.Datas.Bases)
local Animals = require(ReplicatedStorage.Datas.Animals)
local TradePlazaPreview = require(ReplicatedStorage.Shared.TradePlazaPreview)
local Animals2 = require(ReplicatedStorage.Shared.Animals)
local BrainrotAssets = require(ReplicatedStorage.Shared.BrainrotAssets)
local AnimationSyncController = require(ReplicatedStorage.Controllers.AnimationSyncController)
local FastOverheadController = require(ReplicatedStorage.Controllers.FastOverheadController)
local AnimalOverheadController = require(ReplicatedStorage.Controllers.AnimalOverheadController)
local NotificationController = require(ReplicatedStorage.Controllers.NotificationController)
local TradeController = require(ReplicatedStorage.Controllers.TradeController)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local animals = ReplicatedStorage:WaitForChild("Animations").Animals
local remoteFunction = Net:RemoteFunction("TradePlazaPreview/Start")
local remoteEvent = Net:RemoteEvent("TradePlazaPreview/Confirm")
local remoteEvent2 = Net:RemoteEvent("TradePlazaPreview/Stop")
local remoteFunction2 = Net:RemoteFunction("TradePlazaPreview/Template")
local remoteEvent3 = Net:RemoteEvent("PlotService/ClaimBase")
local localPlayer = Players.LocalPlayer
local color = Color3.fromRGB(60, 255, 96)
local BasePreviewController = {}
local v = nil
local v2 = nil

local function ensureFade()
	if v2 then
		return
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BasePreviewFade"
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 5000
	screenGui.ResetOnSpawn = false
	screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 1
	frame.ZIndex = 10
	frame.Parent = screenGui
	v2 = frame
end

local function fade(flag: boolean)
	ensureFade()
	local tween = TweenService:Create(v2, TweenInfo.new(0.4), {
		BackgroundTransparency = flag and 0 or 1
	})
	tween:Play()
	tween.Completed:Wait()
end

local v3 = nil
local v4 = false
local position = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function isMobileInput()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function getReturnButton()
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local tradePlaza = playerGui:FindFirstChild("TradePlaza")
	local button = tradePlaza and tradePlaza:FindFirstChild("Return", true)

	if button and button:IsA("GuiButton") then
		return button
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BasePreviewReturn"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 5001
	screenGui.Parent = playerGui
	local textButton = Instance.new("TextButton")
	textButton.Name = "Return"
	textButton.AnchorPoint = Vector2.new(0.5, 1)
	textButton.Position = UDim2.fromScale(0.5, 0.95)
	textButton.Size = UDim2.fromOffset(160, 48)
	textButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	textButton.TextColor3 = Color3.new(1, 1, 1)
	textButton.TextScaled = true
	textButton.Font = Enum.Font.GothamBold
	textButton.Text = "BACK"
	textButton.Visible = false
	textButton.Parent = screenGui
	return textButton
end

-- equivalent calls inferred from this helper; original call sites unknown
local function showReturn(visible: boolean)
	if not v3 then
		v3 = getReturnButton()
	end

	if not v3 then
		return
	end

	if not v4 then
		v4 = true
		v3.Activated:Connect(function()
			BasePreviewController:Stop()
		end)
	end

	if visible and isMobileInput() then
		if position == nil then
			position = v3.Position
		end

		local position2 = v3.Position
		v3.Position = UDim2.new(position2.X.Scale, position2.X.Offset, 0.78, 0)
	elseif not visible and position ~= nil then
		v3.Position = position
		position = nil
	end

	if visible then
		local Y = v3.AbsoluteSize.Y
		NotificationController:SetBottomOffset((Y <= 0 and 96 or Y) + 24)
	else
		NotificationController:SetBottomOffset(0)
	end

	v3.Visible = visible
end

local function createBrainrot(instance, parent, childName: string, mutation: string?, traits, cframe: CFrame, callback)
	local model = BrainrotAssets.getModel(childName)

	if not model or callback and not callback() then
		return
	end

	local clone = instance:Clone(model)

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
	end

	clone.PrimaryPart.Anchored = true
	clone.Parent = parent

	if mutation then
		instance:Add(Animals2:ApplyMutation(clone, childName, mutation))
	end

	if traits then
		instance:Add(Animals2:ApplyTraits(clone, childName, traits))
	end

	if callback and not callback() then
		return
	end

	clone:PivotTo(cframe)
	local animationController = clone:FindFirstChild("AnimationController")
	local animator = animationController and animationController:FindFirstChild("Animator")
	local child = animals:FindFirstChild(childName)
	local idle = child and child:FindFirstChild("Idle")

	if idle and animator then
		local track = animator:LoadAnimation(idle)
		track.Looped = true
		track:Play()
		local v5 = AnimationSyncController:Add(track)
		instance:Add(function()
			v5()
			track:Stop(0)
			track:Destroy()
		end)
	end

	local animal = Animals[childName]
	local extentsSize = clone:GetExtentsSize()
	local adornee = clone:FindFirstChild("OVERHEAD_ATTACHMENT", true)

	if not (adornee and adornee:IsA("Attachment")) then
		adornee = Instance.new("Attachment")
		adornee.Parent = clone.PrimaryPart
		adornee.WorldCFrame = clone:GetPivot() * CFrame.new(
			0,
			extentsSize.Y * 0.75 * (not animal and 1 or animal.OverheadYOffsetModifier or 1),
			0
		)
	end

	local fastOverhead, v6 = FastOverheadController.createFastOverhead({
		adornee = adornee,
		guiTemplate = FastOverheadController.GuiTemplates.AnimalOverhead
	})
	instance:Add(v6)
	local formatted = `${NumberUtils:ToString(Animals2:GetGeneration(childName, mutation, traits, nil))}/s`
	fastOverhead.Generation.Text = formatted
	fastOverhead.Generation.Visible = not (animal and animal.HideGeneration)
	AnimalOverheadController:Populate({
		Overhead = fastOverhead,
		Index = childName,
		Traits = traits,
		Mutation = mutation,
		Player = nil,
		Trove = instance
	})
end

local v5 = {
	"Laser",
	"LaserHitbox",
	"InvisibleWalls",
	"Unlock",
	"Purchases",
	"FriendPanel",
	"CashPad",
	"DeliveryHitbox",
	"StealHitbox"
}

local function stripBaseExtras(folder)
	for _, childName in v5 do
		local child = folder:FindFirstChild(childName)

		if child then
			child:Destroy()
		end
	end

	for _, billboardGui in folder:GetDescendants() do
		if billboardGui:IsA("BillboardGui") then
			billboardGui:Destroy()
		end
	end
end

local function buildPreviewBase(instance, instance2, cframe: CFrame, p, text: string)
	local pivotsByName = {}
	local tier = instance2:GetAttribute("Tier") or 0
	local v6 = Bases[tier] or Bases[0]

	if not v6 then
		return nil, pivotsByName
	end

	local clone = instance:Clone(p or v6.Model)
	clone.Name = "PreviewBase"
	stripBaseExtras(clone)
	local root = clone:FindFirstChild("Root", true)

	if root and root:IsA("BasePart") then
		clone.PrimaryPart = root
	end

	clone:PivotTo(cframe)
	clone.Parent = workspace
	local plotSign = clone:FindFirstChild("PlotSign")

	if plotSign then
		for _, label in plotSign:GetDescendants() do
			if label:IsA("TextLabel") then
				label.Text = text
			end
		end
	end

	local animalPodiums = clone:FindFirstChild("AnimalPodiums")

	if not animalPodiums then
		return clone, pivotsByName
	end

	for _, child in animalPodiums:GetChildren() do
		local name = tonumber(child.Name)

		if name and v6.MaxAnimals < name then
			child:Destroy()
		end
	end

	for _, child in animalPodiums:GetChildren() do
		local name = tonumber(child.Name)
		local spawn = child:FindFirstChild("Base") and child.Base:FindFirstChild("Spawn")

		if name and spawn then
			pivotsByName[name] = spawn:GetPivot()
		end
	end

	return clone, pivotsByName
end

function BasePreviewController:Start_Preview(instance)
	if v then
		return
	end

	local name = instance.Name
	local order = instance:GetAttribute("Order")

	if typeof(order) ~= "number" then
		return
	end

	local v6 = Synchronizer:Get(name)
	local animalList = v6 and v6:Get("AnimalList")

	if type(animalList) ~= "table" or next(animalList) == nil then
		return
	end

	fade(true)
	local v7, v8, v9 = remoteFunction:InvokeServer(name)

	if not v7 then
		fade(false)
		return
	end

	if typeof(v8) == "number" then
		order = v8
	end

	local slotCFrame = TradePlazaPreview.getSlotCFrame(order)
	local maid = Trove.new()
	local pivot = slotCFrame
	local tradePlazaPreviewMap = ReplicatedStorage:FindFirstChild("TradePlazaPreviewMap")

	if tradePlazaPreviewMap then
		local clone = maid:Clone(tradePlazaPreviewMap)

		for _, descendant in clone:GetDescendants() do
			if descendant:HasTag("Plot") then
				descendant:RemoveTag("Plot")
			end
		end

		clone:PivotTo(slotCFrame)
		clone.Parent = workspace
		local plots = clone:FindFirstChild("Plots")
		local plotFixed = plots and plots:FindFirstChild("PlotFixed")

		if plotFixed then
			local primaryPart

			if plotFixed:IsA("Model") then
				primaryPart = plotFixed.PrimaryPart or nil
			end

			pivot = primaryPart and primaryPart:GetPivot() or plotFixed:GetPivot()
		end
	end

	local child

	if typeof(v9) == "string" then
		local tradePlazaPreviewBases = ReplicatedStorage:WaitForChild("TradePlazaPreviewBases", 5)
		child = tradePlazaPreviewBases and tradePlazaPreviewBases:WaitForChild(v9, 5)
	end

	local extended = maid:Extend()
	local v10 = nil
	local v11 = {}
	local v12 = {}
	local v13 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function currentSignText()
		local owner = v6 and v6:Get("Owner")

		if typeof(owner) == "Instance" and owner:IsA("Player") then
			return (`{owner.DisplayName}'s Base`)
		end

		return "Empty Base"
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function brainrotKey(data)
		if type(data) ~= "table" or not data.Index then
			return nil
		end

		local v14 = type(data.Traits) ~= "table" and "" or table.concat(data.Traits, ",")
		return (`{data.Index}|{data.Mutation or ""}|{v14}`)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clearSlot(k: number)
		local v14 = v12[k]

		if v14 then
			v12[k] = nil
			v14:Destroy()
		end

		v13[k] = nil
	end

	local function updatePodiums()
		local v14 = v10

		if not v14 then
			return
		end

		local animalList2 = v6 and v6:Get("AnimalList") or animalList or {}

		for k, v15 in v11 do
			local v16 = animalList2[k]
			local v17 = brainrotKey(v16) -- equivalent call inferred; original call site unknown

			if v17 == v13[k] then
				continue
			end

			clearSlot(k) -- equivalent call inferred; original call site unknown

			if not v17 then
				continue
			end

			local extended2 = extended:Extend()
			v12[k] = extended2
			v13[k] = v17
			local v18 = k

			local function isCurrent()
				return v12[v18] == extended2
			end

			task.spawn(createBrainrot, extended2, v14, v16.Index, v16.Mutation, v16.Traits, v15, isCurrent)
		end
	end

	local function buildBase(child2)
		extended:Clean()
		table.clear(v12)
		table.clear(v13)
		table.clear(v11)
		v10, v11 = buildPreviewBase(extended, instance, pivot, child2, currentSignText())
		updatePodiums()
	end

	buildBase(child)
	remoteEvent:FireServer()
	v = {
		trove = maid,
		uid = name
	}
	showReturn(true)
	local flag = false

	local function scheduleRefresh()
		if flag then
			return
		end

		flag = true
		task.spawn(function()
			task.wait(0.1)
			flag = false

			if not v or v.uid ~= name then
				return
			end

			local v14 = nil
			xpcall(function()
				v14 = remoteFunction2:InvokeServer(name)
			end, warn)

			if typeof(v14) ~= "string" or (not v or v.uid ~= name) then
				return
			end

			local tradePlazaPreviewBases = ReplicatedStorage:FindFirstChild("TradePlazaPreviewBases")
			local child2 = tradePlazaPreviewBases and tradePlazaPreviewBases:WaitForChild(v14, 5)

			if child2 and v and v.uid == name then
				buildBase(child2)
			end
		end)
	end

	local flag2 = false

	local function scheduleRerender()
		if flag2 then
			return
		end

		flag2 = true
		task.spawn(function()
			task.wait(0.1)
			flag2 = false

			if not v or v.uid ~= name then
				return
			end

			updatePodiums()
		end)
	end

	maid:Add(instance:GetAttributeChangedSignal("BaseSkinName"):Connect(scheduleRefresh))
	maid:Add(instance:GetAttributeChangedSignal("Tier"):Connect(scheduleRefresh))

	if v6 then
		maid:Add(v6:OnChanged("Owner", scheduleRefresh))
		maid:Add(v6:OnChanged("AnimalList", scheduleRerender))
	end

	task.wait(0.15)
	fade(false)
end

function BasePreviewController:Stop()
	local v6 = v

	if not v6 then
		return
	end

	v = nil
	fade(true)
	remoteEvent2:FireServer()
	showReturn(false) -- equivalent call inferred; original call site unknown
	v6.trove:Destroy()
	task.wait(0.15)
	fade(false)
end

function BasePreviewController.Start(_)
	if not ServerData.IsTradePlaza() then
		return
	end

	Observers.observeTag("Plot", function(instance)
		local plots = workspace:FindFirstChild("Plots")

		if instance.Parent ~= plots then
			return
		end

		local maid = Trove.new()
		local flag = false
		maid:Add(function()
			flag = true
		end)
		local v6 = nil
		local v7 = nil
		maid:Add(function()
			if v7 then
				v7:Destroy()
				v7 = nil
			end
		end)

		local function rebindPrompts()
			if v7 then
				v7:Destroy()
				v7 = nil
			end

			local spawn = instance:FindFirstChild("Spawn")

			if not (spawn and spawn:IsA("BasePart")) then
				return
			end

			local maid2 = Trove.new()
			v7 = maid2
			local v8 = maid2:Add(Instance.new("ProximityPrompt"))
			v8.ActionText = "View Brainrots"
			v8.ObjectText = "Base"
			v8.KeyboardKeyCode = Enum.KeyCode.E
			v8.Style = Enum.ProximityPromptStyle.Custom
			v8.HoldDuration = 0
			v8.RequiresLineOfSight = false
			v8.MaxActivationDistance = 14
			v8.Parent = spawn
			local v9 = maid2:Add(Instance.new("ProximityPrompt"))
			v9.ActionText = "Claim Base"
			v9.ObjectText = "Empty Base"
			v9.KeyboardKeyCode = Enum.KeyCode.E
			v9.Style = Enum.ProximityPromptStyle.Custom
			v9.HoldDuration = 0
			v9.RequiresLineOfSight = false
			v9.MaxActivationDistance = 14
			v9.Enabled = false
			v9.Parent = spawn
			local v10 = maid2:Add(Instance.new("ProximityPrompt"))
			v10.ActionText = "SEND TRADE"
			v10.ObjectText = ""
			v10.KeyboardKeyCode = Enum.KeyCode.T
			v10.GamepadKeyCode = Enum.KeyCode.ButtonY
			v10.Style = Enum.ProximityPromptStyle.Custom
			v10.HoldDuration = 0
			v10.RequiresLineOfSight = false
			v10.MaxActivationDistance = 14
			v10.UIOffset = Vector2.new(0, -76)
			v10:SetAttribute("ActionColor", color)
			v10.Enabled = false
			v10.Parent = spawn

			local function getOwner()
				local owner = v6 and v6:Get("Owner")

				if typeof(owner) == "Instance" and owner:IsA("Player") then
					return owner
				end

				return nil
			end

			local function hasAnyBrainrot()
				local animalList = v6 and v6:Get("AnimalList")

				if type(animalList) ~= "table" then
					return false
				end

				for _, v11 in animalList do
					if type(v11) == "table" and v11.Index then
						return true
					end
				end

				return false
			end

			local function update()
				local owner = v6 and v6:Get("Owner")

				if typeof(owner) ~= "Instance" or not owner:IsA("Player") then
					owner = nil
				end

				v8.ObjectText = not owner and "Base" or `{owner.DisplayName}'s Base`
				v8.Enabled = owner ~= nil and hasAnyBrainrot()
				v9.Enabled = owner == nil
				v10.Enabled = owner ~= nil and owner ~= localPlayer
			end

			local owner = v6 and v6:Get("Owner")

			if typeof(owner) ~= "Instance" or not owner:IsA("Player") then
				owner = nil
			end

			v8.ObjectText = not owner and "Base" or `{owner.DisplayName}'s Base`
			local enabled

			if owner == nil then
				enabled = false
			else
				enabled = hasAnyBrainrot()
			end

			v8.Enabled = enabled
			v9.Enabled = owner == nil
			local enabled2

			if owner == nil then
				enabled2 = false
			else
				enabled2 = owner ~= localPlayer
			end

			v10.Enabled = enabled2
			maid2:Add(v8.Triggered:Connect(function()
				BasePreviewController:Start_Preview(instance)
			end))
			maid2:Add(v9.Triggered:Connect(function()
				local owner2 = v6 and v6:Get("Owner")

				if typeof(owner2) ~= "Instance" or not owner2:IsA("Player") then
					owner2 = nil
				end

				if owner2 then
					return
				end

				remoteEvent3:FireServer(instance.Name)
			end))
			maid2:Add(v10.Triggered:Connect(function()
				local owner2 = v6 and v6:Get("Owner")

				if typeof(owner2) ~= "Instance" or not owner2:IsA("Player") then
					owner2 = nil
				end

				if not owner2 or owner2 == localPlayer then
					return
				end

				xpcall(function()
					local v13, v14 = TradeController:SendInvite(owner2.UserId, function(flag2: boolean, value: string?)
						if flag2 then
							NotificationController:Success((`Trade Request sent to {owner2.DisplayName}!`))
						elseif typeof(value) == "string" then
							NotificationController:Error(value)
						end
					end)

					if not v13 and typeof(v14) == "string" then
						NotificationController:Error(v14)
					end
				end, warn)
			end))

			if v6 then
				maid2:Add(v6:OnChanged("Owner", update))
				maid2:Add(v6:OnChanged("AnimalList", update))
			end
		end

		maid:Add(instance.ChildAdded:Connect(function(part)
			if part.Name == "Spawn" and part:IsA("BasePart") then
				rebindPrompts()
			end
		end))
		task.spawn(function()
			local v8 = Synchronizer:Wait(instance.Name)

			if flag then
				return
			end

			v6 = v8
			rebindPrompts()
		end)
		return function()
			maid:Destroy()
		end
	end)
end

return BasePreviewController