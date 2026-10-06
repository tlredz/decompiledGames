local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local client = PlayerData.client
local ExperienceService = require(ReplicatedStorage.Engine.Service.ExperienceService)
local LevelUpEffects = require(ReplicatedStorage.Engine.Service.LevelUpEffects)
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local scale = 0.8
local uDim = UDim2.new()
local uDim2 = UDim2.new()
local uIStroke = nil
local transparency = 0
local v7 = {}
local numberValue = Instance.new("NumberValue")
local levelBaseTotal = 0
local v8 = 1
local v9 = 0
local v10 = 0
local level = 1
local v11 = nil
local count = 0
local v12 = "hidden"
local tweens = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function play(p, tweenInfo, p2)
	local tween = TweenService:Create(p, tweenInfo, p2)
	table.insert(tweens, tween)
	tween:Play()
	return tween
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelTweens()
	for _, v13 in tweens do
		v13:Cancel()
	end

	table.clear(tweens)
end

local function collectFade(guiObject)
	local props = {}

	if guiObject:IsA("TextLabel") then
		props.TextTransparency = guiObject.TextTransparency
		props.BackgroundTransparency = guiObject.BackgroundTransparency
	elseif guiObject:IsA("GuiObject") then
		props.BackgroundTransparency = guiObject.BackgroundTransparency
	end

	if next(props) ~= nil then
		table.insert(v7, {
			inst = guiObject,
			props = props
		})
	end

	for _, uIStroke2 in guiObject:GetChildren() do
		if uIStroke2:IsA("UIStroke") then
			table.insert(v7, {
				inst = uIStroke2,
				props = {
					Transparency = uIStroke2.Transparency
				}
			})
		end
	end
end

local function fadeGoal(p, p2: number)
	local result = {}

	for k, v13 in p.props do
		result[k] = v13 + (1 - v13) * (1 - p2)
	end

	return result
end

local function applyFade(p: number)
	for _, v13 in v7 do
		for k, v14 in fadeGoal(v13, p) do
			v13.inst[k] = v14
		end
	end
end

local function tweenFade(p: number, duration: number)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for _, v13 in v7 do
		local tween = TweenService:Create(v13.inst, tweenInfo, (fadeGoal(v13, p)))
		table.insert(tweens, tween)
		tween:Play()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function renderDisplay()
	local value = numberValue.Value
	v9 = levelBaseTotal + value
	v2.Size = UDim2.fromScale(math.clamp(value / v8, 0, 1) * 0.99, scale)
	v5.Text = string.format("%d / %d", math.floor(value + 0.5), v8)
end

local function buildSegments(p: number, p2: number)
	local result = {}

	for i = 1, 50 do
		if i == 50 then
			p = math.max(p, p2 - ExperienceService.getLevelInfo(p2).currentExp)
		end

		local levelInfo = ExperienceService.getLevelInfo(p)
		local levelBaseTotal2 = p - levelInfo.currentExp
		p = levelBaseTotal2 + levelInfo.requiredExp

		if p2 < p then
			table.insert(result, {
				level = levelInfo.level,
				levelBaseTotal = levelBaseTotal2,
				required = levelInfo.requiredExp,
				fromExp = levelInfo.currentExp,
				toExp = p2 - levelBaseTotal2,
				levelUp = false
			})
			return result
		else
			table.insert(result, {
				level = levelInfo.level,
				levelBaseTotal = levelBaseTotal2,
				required = levelInfo.requiredExp,
				fromExp = levelInfo.currentExp,
				toExp = levelInfo.requiredExp,
				levelUp = true
			})
		end
	end

	return result
end

local function playLevelUpBounce(p: number)
	play(v3, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(uDim2.X.Scale * 1.3, uDim2.X.Offset * 1.3, uDim2.Y.Scale * 1.3, uDim2.Y.Offset * 1.3)
	}) -- equivalent call inferred; original call site unknown

	if uIStroke then
		local tween = TweenService:Create(uIStroke, TweenInfo.new(0.1), {
			Transparency = 0
		})
		table.insert(tweens, tween)
		tween:Play()
	end

	task.delay(0.1, function()
		if count ~= p then
			return
		end

		play(v3, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = uDim2
		}) -- equivalent call inferred; original call site unknown

		if uIStroke then
			local tween = TweenService:Create(uIStroke, TweenInfo.new(0.1), {
				Transparency = transparency
			})
			table.insert(tweens, tween)
			tween:Play()
		end
	end)
end

local function playGrowth(p: number, p2: number, p3: number)
	local segments = buildSegments(p2, p3)

	if #segments == 0 then
		return true
	end

	local count2 = 0

	for _, segment in segments do
		if segment.levelUp then
			count2 += 1
		end
	end

	local v13 = #segments * 0.4 + count2 * 0.15
	local v14 = not (v13 > 1.2) and 1 or 1.2 / v13
	local v15 = math.max(0.05, v14 * 0.4)
	local v16 = v14 * 0.15

	for k, segment in segments do
		if count ~= p then
			return false
		end

		levelBaseTotal = segment.levelBaseTotal
		v8 = math.max(1, segment.required)
		local level2 = segment.level
		local v17 = level < level2
		level = segment.level
		v3.Text = "Lv " .. tostring(segment.level)
		v4.Text = "Lv " .. tostring(segment.level + 1)
		numberValue.Value = segment.fromExp
		renderDisplay() -- equivalent call inferred; original call site unknown

		if v17 then
			playLevelUpBounce(p)

			if v11 then
				local v18 = v11
				v11 = nil
				LevelUpEffects.play(v18)
			end
		end

		if segment.toExp > segment.fromExp then
			play(numberValue, TweenInfo.new(v15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Value = segment.toExp
			}) -- equivalent call inferred; original call site unknown
			task.wait(v15)

			if count ~= p then
				return false
			end

			numberValue.Value = segment.toExp
			renderDisplay() -- equivalent call inferred; original call site unknown
		end

		if not (segment.levelUp and k < #segments) then
			continue
		end

		task.wait(v16)

		if count ~= p then
			return false
		end
	end

	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hiddenPosition()
	local Y = v.AbsoluteSize.Y
	local v13 = Y <= 0 and 60 or Y
	return UDim2.new(uDim.X.Scale, uDim.X.Offset, uDim.Y.Scale, -(v13 + 24))
end

local function show(p: number)
	if v12 == "shown" then
		return true
	end

	if v12 == "hidden" then
		v.Position = hiddenPosition()
		applyFade(0)
		v.Visible = true
	end

	v12 = "showing"
	play(v, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = uDim
	}) -- equivalent call inferred; original call site unknown
	tweenFade(1, 0.3)
	task.wait(0.3)

	if count ~= p then
		return false
	end

	v.Position = uDim
	applyFade(1)
	v12 = "shown"
	return true
end

local function hide(p: number)
	v12 = "hiding"
	play(v, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = hiddenPosition()
	}) -- equivalent call inferred; original call site unknown
	tweenFade(0, 0.3)
	task.wait(0.3)

	if count ~= p then
		return
	end

	v.Visible = false
	v12 = "hidden"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function trigger(value: number)
	count += 1
	local v13 = count
	cancelTweens() -- equivalent call inferred; original call site unknown
	task.spawn(function()
		if not (show(v13) and playGrowth(v13, v9, value)) then
			return
		end

		task.wait(5)

		if count ~= v13 then
			return
		end

		hide(v13)
	end)
end

return {
	Init = function()
		LevelUpEffects.init()
		v = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("经验条"):WaitForChild("经验条框")
		local inst = v:WaitForChild("经验条背景")
		v2 = inst:WaitForChild("经验条进度")
		v3 = v:WaitForChild("当前等级")
		v4 = v:WaitForChild("下一等级")
		v5 = v:WaitForChild("经验数值")
		scale = v2.Size.Y.Scale
		uDim = v.Position
		uDim2 = v3.Size
		uIStroke = v3:FindFirstChildOfClass("UIStroke")
		transparency = not uIStroke and 0 or uIStroke.Transparency
		collectFade(inst)
		collectFade(v2)
		collectFade(v3)
		collectFade(v4)
		collectFade(v5)
		v.Visible = false
		numberValue.Value = 0
		numberValue.Changed:Connect(renderDisplay)
		v10 = client.exp.total()
		v9 = v10
		level = ExperienceService.getLevelInfo(v10).level
		client.exp.total.Changed(function(value)
			if typeof(value) ~= "number" then
				return
			end

			if value <= v10 then
				if value < v10 then
					count += 1
					cancelTweens() -- equivalent call inferred; original call site unknown
					v11 = nil
					level = ExperienceService.getLevelInfo(value).level
					v.Visible = false
					v12 = "hidden"
				end

				v10 = value
				v9 = value
			else
				if ExperienceService.getLevelInfo(value).level > ExperienceService.getLevelInfo(v10).level then
					v11 = value
				end

				v10 = value
				trigger(value) -- equivalent call inferred; original call site unknown
			end
		end)
	end
}