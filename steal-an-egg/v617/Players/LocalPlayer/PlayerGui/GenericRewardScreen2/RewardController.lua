game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local parent = script.Parent
local quint = Enum.EasingStyle.Quint
local quad = Enum.EasingStyle.Quad
local rewardScreen = parent:WaitForChild("RewardScreen")
local contentHolder = rewardScreen:WaitForChild("ContentHolder")
local topBar = rewardScreen:WaitForChild("TopBar")
local bottomBar = rewardScreen:WaitForChild("BottomBar")
local topBarAccent = rewardScreen:WaitForChild("TopBarAccent")
local topBarAccent2 = rewardScreen:WaitForChild("TopBarAccent2")
local bottombarAccent = rewardScreen:WaitForChild("BottombarAccent")
local title = contentHolder:WaitForChild("Title")
local itemName = contentHolder:WaitForChild("ItemName")
local rarityLabel = contentHolder:WaitForChild("RarityLabel")
local tapAnywhereToSkip = contentHolder:WaitForChild("TapAnywhereToSkip")
local pet = contentHolder:WaitForChild("Pet")
local glow = contentHolder:WaitForChild("Glow")
local glow2 = contentHolder:WaitForChild("Glow2")
local RewardSFX = require(parent:WaitForChild("RewardSFX"))
RewardSFX.preload()
local burst = nil
local fade = nil
task.spawn(function()
	local confettiCannon = parent:FindFirstChild("ConfettiCannon")

	if confettiCannon then
		burst = confettiCannon:WaitForChild("Burst", 10)
		fade = confettiCannon:WaitForChild("Fade", 10)
	end
end)

local function transparencyProperty(instance)
	if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
		return "ImageTransparency"
	end

	if instance:IsA("TextLabel") or instance:IsA("TextButton") then
		return "TextTransparency"
	end

	if instance:IsA("UIStroke") then
		return "Transparency"
	end

	return "BackgroundTransparency"
end

local v = {}
local v2 = {}

local function addMover(inst, p2: number)
	local property = transparencyProperty(inst)
	local position = inst.Position
	local alpha = inst[property]
	local v5 = {
		inst = inst,
		property = property,
		rest = position,
		hidden = UDim2.new(position.X.Scale + p2 * 1.15, position.X.Offset, position.Y.Scale, position.Y.Offset),
		alpha = alpha,
		content = false,
		goal = {
			Position = position,
			[property] = alpha
		},
		outGoal = nil
	}
	v5.outGoal = {
		Position = v5.hidden,
		[property] = 1
	}
	v[#v + 1] = v5
end

local function addFader(inst)
	local property = transparencyProperty(inst)
	local alpha = inst[property]
	v2[#v2 + 1] = {
		inst = inst,
		property = property,
		alpha = alpha,
		content = false,
		goal = {
			[property] = alpha
		},
		outGoal = {
			[property] = 1
		}
	}
end

addMover(topBar, 1)
addMover(topBarAccent, 1)
addMover(topBarAccent2, 1)
addMover(bottomBar, -1)
addMover(bottombarAccent, -1)
local count = #v
addMover(title, -1)
addMover(itemName, 1)
addMover(rarityLabel, -1)
addFader(tapAnywhereToSkip)
addFader(glow)
addFader(glow2)

local function addDescendantFaders(folder)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("UIStroke") or descendant:IsA("TextLabel") then
			addFader(descendant)
		end
	end
end

addDescendantFaders(title)
addDescendantFaders(itemName)
addDescendantFaders(rarityLabel)
addDescendantFaders(tapAnywhereToSkip)
local size = pet.Size
local position = pet.Position
local imageTransparency = pet.ImageTransparency
local uDim = UDim2.fromScale(size.X.Scale * 0.9, size.Y.Scale * 0.9)
local rotation = glow.Rotation
local rotation2 = glow2.Rotation
rewardScreen.BackgroundColor3 = Color3.new(0, 0, 0)
local tweenInfos = table.create(count)
local v3 = {
	Size = size
}
local v4 = {
	BackgroundTransparency = 0.45
}
local v5 = {
	ImageTransparency = imageTransparency
}
local v6 = {
	BackgroundTransparency = 1
}
local v7 = {
	Size = uDim,
	ImageTransparency = 1
}

for i = 1, count do
	tweenInfos[i] = TweenInfo.new(0.42, quint, Enum.EasingDirection.Out, 0, false, (i - 1) * 0.03)
end

local tweenInfos2 = table.create(#v - count)

for i = 1, #v - count do
	tweenInfos2[i] = TweenInfo.new(0.42, quint, Enum.EasingDirection.Out, 0, false, (i - 1) * 0.045 + 0.06)
end

local tweenInfo = TweenInfo.new(0.34, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.06)
local tweenInfo2 = TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0.06)
local tweenInfo3 = TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.06)
local tweenInfo4 = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo5 = TweenInfo.new(0.2, quad, Enum.EasingDirection.In)
local tweenInfo6 = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local tweenInfo7 = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo8 = TweenInfo.new(0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local v8 = table.create(32)
local count2 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function play(p, p2, p3)
	local tween = TweenService:Create(p, p2, p3)
	count2 += 1
	v8[count2] = tween
	tween:Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelAll()
	for i = 1, count2 do
		v8[i]:Cancel()
		v8[i] = nil
	end

	count2 = 0
end

local count3 = 0
local idleMotion = parent:GetAttribute("IdleMotion") ~= false
local renderSteppedConnection = nil
local inputBeganConnection = nil
local v9 = 0

local function onRender(p: number)
	v9 += p

	if v9 > 3600 then
		v9 -= 3600
	end

	if not idleMotion then
		return
	end

	glow.Rotation = rotation + v9 * -26
	glow2.Rotation = rotation2 + v9 * 8
	pet.Position = UDim2.new(
		position.X.Scale,
		position.X.Offset,
		position.Y.Scale + math.sin(v9 * 1.9634954084936207) * 0.006,
		position.Y.Offset
	)
end

local hide
local requestNext

-- equivalent calls inferred from this helper; original call sites unknown
local function startIdle()
	if not renderSteppedConnection then
		v9 = 0
		renderSteppedConnection = RunService.RenderStepped:Connect(onRender)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopIdle()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	glow.Rotation = rotation
	glow2.Rotation = rotation2
	pet.Position = position
end

parent:GetAttributeChangedSignal("IdleMotion"):Connect(function()
	idleMotion = parent:GetAttribute("IdleMotion") ~= false

	if not idleMotion then
		glow.Rotation = rotation
		glow2.Rotation = rotation2
		pet.Position = position
	end
end)

local function startSkipListener()
	if inputBeganConnection then
		return
	end

	inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		local userInputType = input.UserInputType

		if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch then
			requestNext()
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopSkipListener()
	if inputBeganConnection then
		inputBeganConnection:Disconnect()
		inputBeganConnection = nil
	end
end

local v10 = false
local count4 = 0
local count5 = 0
local flag = false
local v11 = table.create(8)
local v12 = 1
local count6 = 0

local function queued()
	return count6 - v12 + 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function enqueue(p)
	if count6 - v12 + 1 >= 8 then
		return false
	end

	count6 += 1
	v11[count6] = p or false
	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function dequeue()
	if count6 < v12 then
		return nil
	end

	local v13 = v11[v12]
	v11[v12] = nil
	v12 += 1

	if count6 < v12 then
		v12 = 1
		count6 = 0
	end

	return v13
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearQueue()
	for i = v12, count6 do
		v11[i] = nil
	end

	v12 = 1
	count6 = 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sanitize(p)
	local v13 = tostring(p)
	local v14 = string.gsub(v13, "&", "&amp;")
	local v15 = string.gsub(v14, "<", "&lt;")
	return (string.gsub(v15, ">", "&gt;"))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyContent(data)
	if not data then
		return
	end

	if data.title then
		title.Text = sanitize(data.title)
	end

	if data.item then
		itemName.Text = sanitize(data.item)
	end

	if data.rarity then
		rarityLabel.Text = sanitize(data.rarity)
	end

	if data.image then
		pet.Image = data.image
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function celebrate()
	if burst then
		burst:Fire()
	end

	RewardSFX.play("Reward")
end

local v13 = {}
local v14 = {}

local function registerSwap(inst, p2: string, p3: number)
	local v15 = #v13 + 1
	v13[v15] = {
		inst = inst,
		goal = {
			[p2] = p3
		}
	}
	v14[v15] = {
		inst = inst,
		goal = {
			[p2] = 1
		}
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isContent(instance)
	return instance == title or instance == itemName or instance == rarityLabel or (instance:IsDescendantOf(title) or instance:IsDescendantOf(itemName) or instance:IsDescendantOf(rarityLabel))
end

for i = 1, #v do
	local v15 = v[i]
	v15.content = isContent(v15.inst)

	if v15.content then
		registerSwap(v15.inst, v15.property, v15.alpha)
	end
end

for i = 1, #v2 do
	local v15 = v2[i]
	v15.content = isContent(v15.inst)

	if v15.content then
		registerSwap(v15.inst, v15.property, v15.alpha)
	end
end

registerSwap(pet, "ImageTransparency", imageTransparency)

local function resetToHidden()
	rewardScreen.BackgroundTransparency = 1

	for i = 1, #v do
		local v15 = v[i]
		local inst = v15.inst
		inst.Position = v15.hidden
		inst[v15.property] = 1
	end

	for i = 1, #v2 do
		local v15 = v2[i]
		v15.inst[v15.property] = 1
	end

	pet.Size = uDim
	pet.Position = position
	pet.ImageTransparency = 1
	glow.Rotation = rotation
	glow2.Rotation = rotation2
end

local advance

-- equivalent calls inferred from this helper; original call sites unknown
local function armAutoClose(p)
	count4 += 1
	local autoClose = p and p.autoClose or 4

	if autoClose <= 0 then
		return
	end

	local v15 = count4
	task.delay(autoClose, function()
		if v15 == count4 and v10 then
			hide()
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function armDwell()
	count5 += 1
	flag = false
	local v15 = count5
	task.delay(1.2, function()
		if v15 ~= count5 or not v10 then
			return
		end

		flag = true

		if count6 - v12 + 1 > 0 then
			advance()
		end
	end)
end

local function settleEntrance()
	for i = 1, #v do
		local v15 = v[i]
		local inst = v15.inst
		inst.Position = v15.rest

		if not v15.content then
			inst[v15.property] = v15.alpha
		end
	end

	for i = 1, #v2 do
		local v15 = v2[i]

		if not v15.content then
			v15.inst[v15.property] = v15.alpha
		end
	end

	rewardScreen.BackgroundTransparency = 0.45
end

advance = function()
	local v15 = dequeue() -- equivalent call inferred; original call site unknown

	if v15 == nil then
		return
	end

	count3 += 1
	local v16 = count3
	cancelAll() -- equivalent call inferred; original call site unknown
	settleEntrance()

	for i = 1, #v14 do
		play(v14[i].inst, tweenInfo6, v14[i].goal) -- equivalent call inferred; original call site unknown
	end

	task.delay(0.18, function()
		if count3 ~= v16 or not v10 then
			return
		end

		cancelAll() -- equivalent call inferred; original call site unknown
		applyContent(v15 or nil) -- equivalent call inferred; original call site unknown
		pet.Size = uDim

		for i = 1, #v13 do
			play(v13[i].inst, tweenInfo7, v13[i].goal) -- equivalent call inferred; original call site unknown
		end

		play(pet, tweenInfo8, v3) -- equivalent call inferred; original call site unknown
		celebrate() -- equivalent call inferred; original call site unknown
		armAutoClose(v15 or nil) -- equivalent call inferred; original call site unknown
		armDwell() -- equivalent call inferred; original call site unknown
	end)
end

requestNext = function()
	if not v10 then
		return
	end

	if count6 - v12 + 1 > 0 then
		advance()
	else
		hide()
	end
end

local function present(data)
	count3 += 1
	local v15 = count3
	cancelAll()
	applyContent(data) -- equivalent call inferred; original call site unknown
	resetToHidden()
	parent.Enabled = true
	v10 = true
	play(rewardScreen, tweenInfo4, v4) -- equivalent call inferred; original call site unknown

	for i = 1, #v do
		local v16 = v[i]
		local v17

		if i <= count then
			v17 = tweenInfos[i]
		else
			v17 = tweenInfos2[i - count]
		end

		play(v16.inst, v17, v16.goal) -- equivalent call inferred; original call site unknown
	end

	for i = 1, #v2 do
		play(v2[i].inst, tweenInfo, v2[i].goal) -- equivalent call inferred; original call site unknown
	end

	play(pet, tweenInfo2, v3) -- equivalent call inferred; original call site unknown
	play(pet, tweenInfo3, v5) -- equivalent call inferred; original call site unknown
	startIdle() -- equivalent call inferred; original call site unknown
	task.delay(0.25, function()
		if count3 == v15 and v10 then
			if inputBeganConnection then
				return
			else
				inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
					if gameProcessed then
						return
					end

					local userInputType = input.UserInputType

					if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch then
						requestNext()
					end
				end)
			end
		end
	end)
	task.delay(0.12, function()
		if count3 == v15 and v10 then
			celebrate() -- equivalent call inferred; original call site unknown
		end
	end)
	armAutoClose(data) -- equivalent call inferred; original call site unknown
	armDwell() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function show(p)
	if not v10 then
		present(p)
		return
	end

	-- equivalent call inferred; original call site unknown
	if not enqueue(p) then
		return
	end

	if flag then
		advance()
	end
end

hide = function()
	if not v10 then
		return
	end

	count3 += 1
	local v15 = count3
	count4 += 1
	count5 += 1
	flag = false
	v10 = false
	clearQueue() -- equivalent call inferred; original call site unknown
	cancelAll() -- equivalent call inferred; original call site unknown
	stopIdle() -- equivalent call inferred; original call site unknown
	stopSkipListener() -- equivalent call inferred; original call site unknown

	if fade then
		fade:Fire()
	end

	play(rewardScreen, tweenInfo5, v6) -- equivalent call inferred; original call site unknown

	for i = 1, #v do
		local v16 = v[i]
		play(v16.inst, tweenInfo5, v16.outGoal) -- equivalent call inferred; original call site unknown
	end

	for i = 1, #v2 do
		play(v2[i].inst, tweenInfo5, v2[i].outGoal) -- equivalent call inferred; original call site unknown
	end

	play(pet, tweenInfo5, v7) -- equivalent call inferred; original call site unknown
	task.delay(0.22, function()
		if count3 == v15 then
			parent.Enabled = false
			resetToHidden()
		end
	end)
end

local bindableEvent = Instance.new("BindableEvent")
bindableEvent.Name = "ShowReward"
bindableEvent.Parent = parent
bindableEvent.Event:Connect(show)
local bindableEvent2 = Instance.new("BindableEvent")
bindableEvent2.Name = "HideReward"
bindableEvent2.Parent = parent
bindableEvent2.Event:Connect(function()
	hide()
end)
local bindableEvent3 = Instance.new("BindableEvent")
bindableEvent3.Name = "NextReward"
bindableEvent3.Parent = parent
bindableEvent3.Event:Connect(function()
	requestNext()
end)
local onClientEventConnection = nil
task.spawn(function()
	local Remotes = require(ReplicatedStorage.Shared.Remotes)
	onClientEventConnection = Remotes.RewardScreen.Show.OnClientEvent:Connect(function(p)
		if typeof(p) == "table" or p == nil then
			show(p) -- equivalent call inferred; original call site unknown
		end
	end)
end)
parent.Enabled = false
resetToHidden()
script.Destroying:Once(function()
	count3 += 1
	count4 += 1
	count5 += 1
	cancelAll() -- equivalent call inferred; original call site unknown
	stopIdle() -- equivalent call inferred; original call site unknown
	stopSkipListener() -- equivalent call inferred; original call site unknown

	if onClientEventConnection then
		onClientEventConnection:Disconnect()
	end

	bindableEvent:Destroy()
	bindableEvent2:Destroy()
	bindableEvent3:Destroy()
end)