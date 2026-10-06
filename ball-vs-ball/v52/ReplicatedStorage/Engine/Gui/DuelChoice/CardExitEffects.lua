local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local CardExitEffects = {
	COLLAPSE_TIME = 0.2
}
local v = {}

local function scaleSize(udim: UDim2, p: number)
	return UDim2.new(udim.X.Scale * p, math.floor(udim.X.Offset * p), udim.Y.Scale * p, (math.floor(udim.Y.Offset * p)))
end

function CardExitEffects.register(p, fadeRecords, baseBackgroundTransparency: number, udim: UDim2)
	v[p] = {
		fadeRecords = fadeRecords,
		baseBackgroundTransparency = baseBackgroundTransparency,
		baseSize = udim,
		generation = 0,
		tweens = {}
	}
end

function CardExitEffects:reset()
	local v2 = v[self]

	if not v2 then
		return
	end

	v2.generation += 1

	for _, tween in ipairs(v2.tweens) do
		tween:Cancel()
	end

	table.clear(v2.tweens)
	self.Size = v2.baseSize
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playTween(p, p2, p3, p4)
	local tween = TweenService:Create(p2, p3, p4)
	table.insert(p.tweens, tween)
	tween:Play()
end

local function fadeOut(ancestor, p, tweenInfo3)
	playTween(p, ancestor, tweenInfo3, {
		BackgroundTransparency = 1
	}) -- equivalent call inferred; original call site unknown

	for _, fadeRecord in ipairs(p.fadeRecords) do
		if not fadeRecord.instance:IsDescendantOf(ancestor) then
			continue
		end

		playTween(p, fadeRecord.instance, tweenInfo3, {
			[fadeRecord.prop] = 1
		}) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function finishAfter(p, p2, p3: number, duration: number)
	task.delay(duration, function()
		if p2.generation ~= p3 or not p.Parent then
			return
		end

		p.Visible = false
		CardExitEffects.reset(p)
	end)
end

function CardExitEffects.collapseAll(list)
	for _, v2 in ipairs(list) do
		CardExitEffects.reset(v2)
		local v3 = v[v2]

		if v3 then
			fadeOut(v2, v3, tweenInfo)
			finishAfter(v2, v3, v3.generation, 0.2) -- equivalent call inferred; original call site unknown
		else
			v2.Visible = false
		end
	end
end

function CardExitEffects.collapseWithSelection(list, p)
	for _, v2 in ipairs(list) do
		CardExitEffects.reset(v2)

		if v2 ~= p then
			v2.Visible = false
		end
	end

	local v2 = v[p]

	if not v2 then
		p.Visible = false
		return
	end

	local generation = v2.generation
	task.delay(0.12, function()
		if v2.generation ~= generation or not p.Parent then
			return
		end

		fadeOut(p, v2, tweenInfo2)
		local baseSize = v2.baseSize
		playTween(v2, p, tweenInfo2, {
			Size = UDim2.new(
				baseSize.X.Scale * 0.9,
				math.floor(baseSize.X.Offset * 0.9),
				baseSize.Y.Scale * 0.9,
				(math.floor(baseSize.Y.Offset * 0.9))
			)
		}) -- equivalent call inferred; original call site unknown
		finishAfter(p, v2, generation, 0.15) -- equivalent call inferred; original call site unknown
	end)
end

return CardExitEffects