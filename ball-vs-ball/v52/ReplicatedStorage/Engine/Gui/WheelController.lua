local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local WheelController = {}
WheelController.__index = WheelController
local v = {
	0,
	0.063,
	0.125,
	0.188,
	0.25,
	0.313,
	0.375,
	0.438,
	0.5,
	0.563,
	0.625,
	0.688,
	0.75,
	0.813,
	0.875,
	0.938,
	1,
	1.063,
	1.125,
	1.188,
	1.25,
	1.313,
	1.351,
	1.375,
	1.483,
	1.62,
	1.701,
	1.786,
	1.872,
	2.003,
	2.154,
	2.313,
	2.466,
	2.615,
	2.773,
	2.941,
	3.104,
	3.339,
	3.63,
	3.953,
	4.385,
	5.004
}

local function cubicBezier(p: number, p2: number, p3: number)
	local v2 = 1 - p3
	return v2 * 3 * v2 * p3 * p + v2 * 3 * p3 * p3 * p2 + p3 * p3 * p3
end

local function easeCsgo(p: number)
	local v2 = 0
	local v3 = 1

	for _ = 1, 24 do
		local midpoint = (v2 + v3) / 2
		local v5 = 1 - midpoint

		if v5 * 3 * v5 * midpoint * 0.075 + v5 * 3 * midpoint * midpoint * 0.165 + midpoint * midpoint * midpoint < p then
			v2 = midpoint
		else
			v3 = midpoint
		end
	end

	local midpoint2 = (v2 + v3) / 2
	local v5 = 1 - midpoint2
	return v5 * 3 * v5 * midpoint2 * 0.82 + v5 * 3 * midpoint2 * midpoint2 * 1 + midpoint2 * midpoint2 * midpoint2
end

local function applyAsset(sprite, src: string?, assets)
	if sprite:GetAttribute("src") == src then
		return
	end

	sprite:SetAttribute("src", src)
	local v2

	if src then
		v2 = assets[src]
	end

	local imageLabel = sprite:FindFirstChild("ImageLabel")

	if imageLabel then
		imageLabel.Image = not v2 and "" or v2.image
	end

	local firstChild = sprite:FindFirstChild("名称")
	local v3 = firstChild and firstChild:FindFirstChild("文字")

	if v3 then
		v3.Text = not v2 and "" or v2.name
	end

	if v2 and v2.strokeColorHex then
		local color = Color3.fromHex(v2.strokeColorHex)
		local uIStroke = sprite:FindFirstChild("UIStroke")

		if uIStroke then
			uIStroke.Color = color
		end

		local firstChild2 = sprite:FindFirstChild("品质颜色")

		if firstChild2 then
			firstChild2.BackgroundColor3 = color
		end

		local uIStroke2 = firstChild and firstChild:FindFirstChild("UIStroke")

		if uIStroke2 then
			uIStroke2.Color = color
		end

		local uIShadow = sprite:FindFirstChild("UIShadow")

		if uIShadow then
			uIShadow.Color = color
		end
	end
end

function WheelController.new(data)
	assert(data and data.ScrollFrame, "[WheelController] 缺少 ScrollFrame")
	local children = {}

	for _, child in data.ScrollFrame:GetChildren() do
		if child.Name == "物品" then
			table.insert(children, child)
		end
	end

	local v2 = children[1]
	assert(v2, "[WheelController] 滚动条下缺少「物品」模板")
	local object = setmetatable({}, WheelController)
	object.scrollFrame = data.ScrollFrame
	object.assets = data.AssetsMap or {}
	object.weights = data.Weights or {}
	object.sprites = {}
	object.pool = {}
	object.pointer = 0
	object.running = false
	object.skipped = true
	local firstChild = data.ScrollFrame:FindFirstChild("高光条")
	object.flashStart = not firstChild and 0.25 or firstChild.BackgroundTransparency

	if firstChild then
		firstChild.Visible = false
	end

	for i = 1, 50 do
		local clone = v2:Clone()
		clone.Name = "物品" .. i
		clone.Size = UDim2.fromScale(0, 0)
		clone.Parent = data.ScrollFrame
		object.sprites[i] = clone
	end

	for _, v3 in children do
		v3:Destroy()
	end

	return object
end

function WheelController:Start(p: string, callback)
	if self.running then
		self:Skip()

		repeat
			task.wait()
		until not self.running
	end

	self.pool = self:_buildPool(p)

	for k, sprite in self.sprites do
		applyAsset(sprite, self.pool[k], self.assets)
	end

	self.pointer = 10
	self.running = true
	self.skipped = false
	self:OnStart()
	self:_roll()
	local _playReveal = self:_playReveal()
	self:OnCompleted(p)

	if _playReveal then
		_playReveal.Completed:Wait()
		local firstChild = self.scrollFrame:FindFirstChild("高光条")

		if firstChild then
			firstChild.Visible = false
		end
	end

	self.running = false
	self.skipped = true
	self:OnExit()

	if callback then
		callback()
	end
end

function WheelController:_playReveal()
	local firstChild = self.scrollFrame:FindFirstChild("高光条")

	if not firstChild then
		return nil
	end

	local sprite = self.sprites[42]
	firstChild.AnchorPoint = Vector2.new(0.5, 0.5)
	firstChild.Position = sprite.Position
	firstChild.BackgroundTransparency = self.flashStart
	firstChild.Visible = true
	local tween = TweenService:Create(firstChild, tweenInfo, {
		BackgroundTransparency = 1
	})
	tween:Play()
	return tween
end

function WheelController:Skip()
	if self.running then
		self.skipped = true
	end
end

function WheelController:_buildPool(p2: string)
	local total = 0
	local v2 = {}
	local v3 = {}

	for k in self.assets do
		local weight = self.weights[k]
		total += (type(weight) ~= "number" or not (weight > 0)) and 1 or weight
		table.insert(v2, k)
		table.insert(v3, total)
	end

	local result = table.create(50, p2)

	if total > 0 then
		for i = 1, 50 do
			local v4 = math.random() * total

			for k, v6 in v3 do
				if not (v4 <= v6) then
					continue
				end

				result[i] = v2[k]
				break
			end
		end
	end

	result[42] = p2
	return result
end

function WheelController:_getStopPointer(p2: number)
	local v2 = self.scrollFrame.AbsoluteSize.X * 0.15
	local X = self.sprites[42].AbsoluteSize.X

	if v2 <= 0 then
		return 42
	end

	return 42 + (p2 - 0.5) * X / v2
end

function WheelController:_roll()
	self:_render(10)
	local v2 = math.random(10, 90) / 100
	local lastTime = os.clock()
	self:_render(10)
	local v3 = 1
	local v4 = 0

	while not self.skipped do
		while v3 <= #v and v[v3] <= v4 do
			v3 += 1
			self:OnTicked(self.pool[math.clamp(math.floor(self.pointer + 0.5), 1, 50)])
		end

		if v4 >= 6 then
			break
		end

		task.wait()
		v4 = os.clock() - lastTime
		self:_render(10 + (self:_getStopPointer(v2) - 10) * easeCsgo(math.min(v4 / 6, 1)))
	end

	self:_render(self:_getStopPointer(v2))
end

function WheelController:_render(pointer: number)
	for k, sprite in self.sprites do
		local v2 = (k - pointer) * 0.15
		sprite.Position = UDim2.fromScale(0.5 + v2, 0.5)
		sprite.Size = UDim2.fromScale(1, 1)
	end

	self.pointer = pointer
end

function WheelController:OnStart() end

function WheelController:OnTicked(_: string?) end

function WheelController:OnCompleted(_: string) end

function WheelController:OnExit() end

return WheelController