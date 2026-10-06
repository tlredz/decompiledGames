local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = ReplicatedStorage:WaitForChild("音效素材")
local tickSFXV4 = v:WaitForChild("TickSFX V4")
local v2 = {
	["选项卡1"] = v:WaitForChild("Jet Set Radio - Spray 1"),
	["选项卡2"] = v:WaitForChild("Jet Set Radio - Spray 2"),
	["选项卡3"] = v:WaitForChild("Jet Set Radio - Spray 3")
}
local v3 = v:WaitForChild("卡片弹出")
local tweenInfo = TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.08, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
local SlotMachineCard = {}
local v4 = {}
local v5 = {}
local v6 = 0
local renderSteppedConnection = nil
local v7 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function stopTicking()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	v7 = 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startTicking()
	if renderSteppedConnection then
		return
	end

	v7 = 0
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
		v7 += dt

		while v7 >= 0.07142857142857142 do
			v7 -= 0.07142857142857142
			tickSFXV4:Play()
		end
	end)
end

local function addActiveSpin()
	v6 += 1

	if v6 == 1 then
		startTicking() -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeActiveSpin()
	v6 = math.max(0, v6 - 1)

	if v6 == 0 then
		stopTicking() -- equivalent call inferred; original call site unknown
	end
end

local function scaleSize(udim: UDim2, p: number)
	return UDim2.new(udim.X.Scale * p, math.floor(udim.X.Offset * p), udim.Y.Scale * p, (math.floor(udim.Y.Offset * p)))
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function stripOffsetY(p: number, offset: number)
	return 0.5 - (p - 0.5) * 1.5 + offset * 1.5
end

local function buildReel(p, list)
	local v8 = list and #list > 0 and #list or 1
	local v9 = math.ceil(6 / v8) * v8
	local frame = Instance.new("Frame")
	frame.Name = "滚轮胶卷"
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Size = UDim2.fromScale(1, v9 * 1.5)
	frame.Position = UDim2.fromScale(0.5, 0.5 - (v9 - 0.5) * 1.5 + 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ZIndex = 2

	for i = 1, v9 do
		local clone = p.imageLabel:Clone()
		clone.Name = "滚轮图标" .. i
		clone:ClearAllChildren()
		clone.Visible = true
		clone.ImageTransparency = 0
		clone.ImageColor3 = Color3.new(0, 0, 0)
		clone.BackgroundTransparency = 1
		clone.AnchorPoint = Vector2.new(0.5, 0.5)

		if list and #list > 0 then
			clone.Image = list[(i - 1) % v8 + 1]
		end

		clone.Size = UDim2.fromScale(1, 1.2 / (v9 * 1.5))
		clone.Position = UDim2.fromScale(0.5, (i - 0.5) / v9)
		clone.ZIndex = 2
		clone.Parent = frame
	end

	frame.Parent = p.reelWindow
	return frame, v9, v8
end

local function restoreStatic(data)
	data.cardButton.BackgroundTransparency = data.baseBackgroundTransparency
	data.cardButton.Size = data.baseSize
	data.imageLabel.Visible = true

	for _, fadeRecord in ipairs(data.fadeRecords) do
		fadeRecord.instance[fadeRecord.prop] = fadeRecord.original
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideEffectNodes(data)
	data.reelWindow.Visible = false
	data.beam1.Visible = false
	data.beam2.Visible = false
	data.question.Visible = false
	local firstChild = data.reelWindow:FindFirstChild("滚轮胶卷")

	if firstChild then
		firstChild:Destroy()
	end
end

function SlotMachineCard.register(instance, fadeRecords, baseBackgroundTransparency: number, udim: UDim2)
	local imageFrame = instance:WaitForChild("图片框")
	local v9 = {
		cardButton = instance,
		baseSize = udim,
		baseBackgroundTransparency = baseBackgroundTransparency,
		fadeRecords = fadeRecords,
		spinHidden = {},
		imageFrame = imageFrame,
		imageLabel = imageFrame:WaitForChild("默认图片"),
		reelWindow = imageFrame:WaitForChild("滚轮容器"),
		question = imageFrame:WaitForChild("问号遮罩"),
		beam1 = imageFrame:WaitForChild("高光条1"),
		beam2 = instance:WaitForChild("高光条2"),
		beam2FlashStart = instance:WaitForChild("高光条2").BackgroundTransparency,
		tweens = {},
		dirty = false
	}

	for _, v10 in ipairs(fadeRecords) do
		if v10.instance == imageFrame or v10.instance:IsDescendantOf(imageFrame) then
			continue
		end

		table.insert(v9.spinHidden, v10)
	end

	v4[instance] = v9
	hideEffectNodes(v9) -- equivalent call inferred; original call site unknown
end

function SlotMachineCard.reset(p)
	local v8 = v4[p]

	if not v8 then
		return
	end

	for _, tween in ipairs(v8.tweens) do
		tween:Cancel()
	end

	table.clear(v8.tweens)
	local v9 = v5[p]
	v5[p] = nil

	if v9 then
		if v9.spinning then
			v9.spinning = false
			removeActiveSpin() -- equivalent call inferred; original call site unknown
		end

		v9.cancelled = true

		if v9.connection then
			v9.connection:Disconnect()
			v9.connection = nil
		end

		if v9.strip then
			v9.strip:Destroy()
			v9.strip = nil
		end
	end

	if v8.dirty then
		v8.dirty = false
		restoreStatic(v8)
	end

	hideEffectNodes(v8) -- equivalent call inferred; original call site unknown
end

local function playPopBeat(state, p, callback, object)
	local cardButton = state.cardButton

	if object then
		object:Play()
	end

	local baseSize = state.baseSize
	local v11 = TweenService:Create(cardButton, tweenInfo2, {
		Size = UDim2.new(
			baseSize.X.Scale * 1.08,
			math.floor(baseSize.X.Offset * 1.08),
			baseSize.Y.Scale * 1.08,
			(math.floor(baseSize.Y.Offset * 1.08))
		)
	})
	table.insert(state.tweens, v11)
	v11.Completed:Once(function()
		if v5[cardButton] ~= p then
			return
		end

		local tween = TweenService:Create(cardButton, tweenInfo3, {
			Size = state.baseSize
		})
		table.insert(state.tweens, tween)
		tween.Completed:Once(function()
			if v5[cardButton] ~= p then
				return
			end

			v5[cardButton] = nil
			state.dirty = false
			callback()
		end)
		tween:Play()
	end)
	v11:Play()
end

local function playRevealBeat(data, state, callback)
	local v8 = v2[data.cardButton.Name]

	if v8 then
		v8:Play()
	end

	data.beam2.BackgroundTransparency = data.beam2FlashStart
	data.beam2.Visible = true
	local tween = TweenService:Create(data.beam2, tweenInfo, {
		BackgroundTransparency = 1
	})
	table.insert(data.tweens, tween)
	tween.Completed:Once(function()
		data.beam2.Visible = false
	end)
	tween:Play()
	playPopBeat(data, state, callback)
end

local function reveal(data, state, callback, callback2)
	if state.spinning then
		state.spinning = false
		removeActiveSpin() -- equivalent call inferred; original call site unknown
	end

	if state.connection then
		state.connection:Disconnect()
		state.connection = nil
	end

	if state.strip then
		state.strip:Destroy()
		state.strip = nil
	end

	data.reelWindow.Visible = false
	data.beam1.Visible = false
	data.question.Visible = false
	callback()
	restoreStatic(data)
	playRevealBeat(data, state, callback2)
end

function SlotMachineCard:play(duration: number, p2, callback, callback2)
	local v8 = v4[self]

	if v8 then
		SlotMachineCard.reset(self)
		local v9 = {
			connection = nil,
			strip = nil,
			offset = 0,
			cancelled = false,
			spinning = true
		}
		v5[self] = v9
		v8.dirty = true
		v6 += 1

		if v6 == 1 and not renderSteppedConnection then
			v7 = 0
			renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
				v7 += dt

				while v7 >= 0.07142857142857142 do
					v7 -= 0.07142857142857142
					tickSFXV4:Play()
				end
			end)
		end

		restoreStatic(v8)

		for _, v10 in ipairs(v8.spinHidden) do
			v10.instance[v10.prop] = 1
		end

		self.BackgroundTransparency = 1
		v8.imageLabel.Visible = false
		local reel, v10, v11 = buildReel(v8, p2)
		v9.strip = reel
		v8.reelWindow.Visible = true
		v8.beam1.Visible = true
		v8.question.Visible = true
		v9.connection = RunService.RenderStepped:Connect(function(dt: number)
			v9.offset = (v9.offset + dt * 14) % v11
			reel.Position = UDim2.fromScale(0.5, stripOffsetY(v10, v9.offset))
		end)
		task.delay(duration, function()
			if v5[self] ~= v9 or v9.cancelled then
				return
			end

			reveal(v8, v9, callback, callback2)
		end)
	else
		callback()
		callback2()
	end
end

function SlotMachineCard.reopen(p, callback, callback2, flag: boolean?)
	local v8 = v4[p]

	if v8 then
		SlotMachineCard.reset(p)
		restoreStatic(v8)
		hideEffectNodes(v8) -- equivalent call inferred; original call site unknown
		callback()

		if flag then
			v3:Play()
		end
	else
		callback()
	end

	callback2()
end

return SlotMachineCard