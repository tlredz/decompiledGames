local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Config = require(ReplicatedStorage.Engine.Service.Config)
local GachaPool = require(ReplicatedStorage.Engine.Service.GachaPool)
local TimeService = require(ReplicatedStorage.Engine.Service.TimeService)
local ButtonActions = require(ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local PoolDisplay = {}
local random = Random.new()

function PoolDisplay.entries(p)
	local chances, v = GachaPool.getChances(p)
	local result = {}

	for _, chance in chances do
		local definition = chance.definition
		table.insert(result, {
			info = {
				image = definition.image,
				name = definition.displayName or definition.name,
				rating = definition.rating
			},
			weight = chance.weight,
			tradable = chance.tradable,
			key = chance.key,
			unlockAt = chance.unlockAt,
			previewDate = chance.row.unlockAt,
			lockReason = chance.lockReason
		})
	end

	return result, v
end

function PoolDisplay.color(p)
	for _, v in Config.rating.list do
		if v.lvl == p then
			return Color3.fromHex(v.colorHex)
		end
	end

	return Color3.new(1, 1, 1)
end

function PoolDisplay:paint(data, p)
	self.Visible = true
	local imageLabel = self:FindFirstChild("ImageLabel")

	if imageLabel then
		imageLabel.Image = data.info.image
	end

	local firstChild = self:FindFirstChild("名称")

	if firstChild and firstChild:FindFirstChild("文字") then
		firstChild["文字"].Text = data.info.name
		firstChild["文字"].TextScaled = true
	end

	for _, v in { self, firstChild } do
		if not v then
			continue
		end

		local uIStroke = v:FindFirstChildWhichIsA("UIStroke")

		if uIStroke then
			uIStroke.Color = PoolDisplay.color(data.info.rating)
		end
	end

	local firstChild2 = self:FindFirstChild("概率")

	if firstChild2 then
		firstChild2.Text = string.format("%.2f%%", not (p > 0) and 0 or data.weight / p * 100)
	end

	PoolDisplay.paintLock(self, data)
	self:SetAttribute("PoolItemKey", data.key)
end

function PoolDisplay.paintLock(instance, p)
	local v = not p.unlockAt and 0 or p.unlockAt - TimeService.now()
	local lockReason = p.lockReason
	local visible = v > 0 or lockReason == "等级奖励获得" or lockReason == "购买新手礼包"
	local firstChild = instance:FindFirstChild("解锁提示")

	if not firstChild then
		return visible
	end

	firstChild.Visible = visible
	firstChild.AutoLocalize = true

	if v > 0 then
		firstChild.Text = string.gsub("Unlocks in {a}", "{a}", function()
			return TimeService.formatCountdown(v)
		end)
		return visible
	end

	if lockReason == "等级奖励获得" then
		firstChild.Text = "Unlock via Level Rewards"
		return visible
	end

	if lockReason == "购买新手礼包" then
		firstChild.Text = "Unlock via Starter Pack"
	end

	return visible
end

function PoolDisplay.probability(instance, items, p)
	local v = {}

	for _, item in items do
		v[item.info.rating] = (v[item.info.rating] or 0) + item.weight
	end

	for _, v2 in Config.rating.list do
		local label = instance:FindFirstChild((tostring(v2.lvl)))

		if not (label and label:IsA("TextLabel")) then
			continue
		end

		local v3 = v[v2.lvl] or 0
		label.Visible = v3 > 0
		label.Text = v2.name .. ":"
		label.TextScaled = true
		label.TextColor3 = PoolDisplay.color(v2.lvl)
		local firstChild = label:FindFirstChild("概率")

		if firstChild then
			firstChild.Text = string.format("%.2f%%", not (p > 0) and 0 or v3 / p * 100)
		end
	end
end

function PoolDisplay.tradeText(list)
	local count = 0

	for _, v in list do
		if v.tradable then
			count += 1
		end
	end

	if count == 0 then
		return "Not Tradable"
	end

	if count == #list then
		return "Tradable"
	end

	return "Some Tradable"
end

function PoolDisplay.template(instance)
	local v = instance:FindFirstChild("物品") or instance:FindFirstChild("物品1")
	assert(v, "奖池缺少物品模板: " .. instance:GetFullName())
	local clone = v:Clone()
	clone.Parent = nil

	for _, button in instance:GetChildren() do
		if button:IsA("GuiButton") then
			button:Destroy()
		end
	end

	return clone
end

local object = setmetatable({}, {
	__mode = "k"
})

function PoolDisplay:grid(instance, items, p, callback)
	local v = {}

	for k, item in items do
		v[item] = k
	end

	local clone = table.clone(items)
	table.sort(clone, function(a, b)
		local rating = a.info.rating or 0
		local rating2 = b.info.rating or 0

		if rating ~= rating2 then
			return rating2 < rating
		end

		if a.weight == b.weight then
			return v[a] < v[b]
		end

		return a.weight < b.weight
	end)

	for _, button in self:GetChildren() do
		if button:IsA("GuiButton") then
			button:Destroy()
		end
	end

	local v2 = {}

	for k, entry in clone do
		local clone2 = instance:Clone()
		clone2.Name = "奖品" .. k
		clone2.LayoutOrder = k
		PoolDisplay.paint(clone2, entry, p)
		clone2.Parent = self

		if entry.unlockAt then
			table.insert(v2, {
				card = clone2,
				entry = entry
			})
		end
	end

	local v3 = (object[self] or 0) + 1
	object[self] = v3

	if #v2 > 0 then
		task.spawn(function()
			while true do
				task.wait(1)

				if object[self] ~= v3 or not self.Parent then
					break
				end

				local flag = false

				for _, v4 in v2 do
					PoolDisplay.paintLock(v4.card, v4.entry)

					if TimeService.now() >= v4.entry.unlockAt then
						flag = true
					end
				end

				if not flag then
					continue
				end

				if callback then
					callback()
				end

				break
			end
		end)
	end

	self.CanvasPosition = Vector2.zero
	local uIGridLayout = self:FindFirstChildWhichIsA("UIGridLayout")

	if uIGridLayout then
		local function resize()
			local X = self.AbsoluteSize.X
			local v4 = math.max(1, (math.floor(X * 0.189)))
			local v5 = math.floor(v4 * 1.22)
			uIGridLayout.CellSize = UDim2.fromOffset(v4, v5)
			uIGridLayout.CellPadding = UDim2.fromOffset(math.floor(X * 0.01), (math.floor(X * 0.01)))
			self.CanvasSize = UDim2.fromOffset(0, uIGridLayout.AbsoluteContentSize.Y)
		end

		if not self:GetAttribute("PoolGridBound") then
			self:SetAttribute("PoolGridBound", true)
			self:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
			uIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				self.CanvasSize = UDim2.fromOffset(0, uIGridLayout.AbsoluteContentSize.Y)
			end)
		end

		resize()
	end
end

local function pick(list, p, key)
	local total = 0

	if key then
		for _, v in list do
			if v.key == key then
				total += v.weight
			end
		end

		if p <= total then
			total = 0
			key = nil
		end
	end

	local v = random:NextNumber() * (p - total)
	local total2 = 0

	for _, v2 in list do
		if v2.key == key then
			continue
		end

		total2 += v2.weight

		if v2.weight > 0 and v < total2 then
			return v2
		end
	end

	for i = #list, 1, -1 do
		if list[i].weight > 0 then
			return list[i]
		end
	end

	return list[#list]
end

local function isVisible(parent)
	while parent do
		if parent:IsA("GuiObject") and not parent.Visible then
			return false
		end

		if parent:IsA("ScreenGui") and not parent.Enabled then
			return false
		else
			parent = parent.Parent
		end
	end

	return true
end

function PoolDisplay.newEntries(items, items2)
	local unlockAts = {}

	for _, item in items2 do
		if item.unlockAt then
			unlockAts[item.key] = item.unlockAt
		end
	end

	local result = {}
	local v = {}

	for k, item in items do
		if not (item.weight > 0 and unlockAts[item.key]) then
			continue
		end

		table.insert(result, item)
		v[item] = k
	end

	local v2 = #result > 0

	if not v2 then
		local previewDate = nil

		for _, item in items do
			if item.weight > 0 and item.previewDate and (not previewDate or previewDate < item.previewDate) then
				previewDate = item.previewDate
			end
		end

		if previewDate then
			for k, item in items do
				if not (item.weight > 0 and item.previewDate == previewDate) then
					continue
				end

				table.insert(result, item)
				v[item] = k
			end
		end
	end

	table.sort(result, function(a, b)
		local rating = a.info.rating or 0
		local rating2 = b.info.rating or 0

		if rating ~= rating2 then
			return rating2 < rating
		end

		if not v2 then
			return v[a] < v[b]
		end

		local v3 = unlockAts[a.key]
		local v4 = unlockAts[b.key]

		if v3 ~= v4 then
			return v4 < v3
		end

		return v[a] < v[b]
	end)
	return result
end

function PoolDisplay:preview(list, p, options, callback)
	local template = PoolDisplay.template(self)
	local uIListLayout = self:FindFirstChildWhichIsA("UIListLayout")

	if uIListLayout then
		uIListLayout:Destroy()
	end

	self.ClipsDescendants = true
	self.ScrollingEnabled = false
	self.ScrollBarThickness = 0
	self.AutomaticCanvasSize = Enum.AutomaticSize.None
	self.CanvasSize = UDim2.new()
	self.CanvasPosition = Vector2.zero

	if #list == 0 then
		template:Destroy()
		return function() end
	end

	local v = {}
	local v2 = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function lastKey()
		local v3 = v[#v]

		if v3 then
			return (v3:GetAttribute("PoolItemKey"))
		end

		return nil
	end

	local function position()
		local absoluteSize = self.AbsoluteSize

		if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
			return
		end

		local v3 = absoluteSize.Y * 1.04
		local v4 = math.ceil(absoluteSize.X / v3) + 2

		while #v < v4 do
			local clone = template:Clone()
			clone.Name = "预览奖品" .. #v + 1
			clone.AnchorPoint = Vector2.zero
			clone.SizeConstraint = Enum.SizeConstraint.RelativeYY
			clone.Size = UDim2.fromScale(1, 1)
			local paint = PoolDisplay.paint
			local v6 = list
			local v7 = p
			local v8 = lastKey() -- equivalent call inferred; original call site unknown
			paint(clone, pick(v6, v7, v8), p)
			clone.Parent = self

			if callback and clone:IsA("GuiButton") then
				clone.Active = true
				clone.Interactable = true
				ButtonActions.Bind(clone, function()
					if isVisible(self) then
						callback()
					end
				end)
			end

			table.insert(v, clone)
		end

		while v4 < #v do
			table.remove(v):Destroy()
		end

		for k, v5 in v do
			v5.Position = UDim2.fromScale((k - 1 - v2) * v3 / absoluteSize.X, 0)
		end
	end

	local v3 = options or {}
	local v4 = 0

	local function restart()
		v2 = 0
		position()
		local absoluteSize = self.AbsoluteSize
		local v5 = not (absoluteSize.X > 0 and absoluteSize.Y > 0) and 0 or math.floor(absoluteSize.X / (absoluteSize.Y * 1.04))
		local key = nil

		for k, v6 in v do
			local v7

			if k <= v5 then
				v7 = v3[k]
			end

			local v8 = v7 or pick(list, p, key)
			PoolDisplay.paint(v6, v8, p)
			key = v8.key
		end

		position()
		v4 = os.clock() + 2
	end

	position()
	local flag = false
	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		if not self.Parent then
			renderSteppedConnection:Disconnect()
		elseif not isVisible(self) then
			flag = false
		elseif flag then
			if os.clock() < v4 then
				position()
				return
			end

			v2 += math.min(dt, 0.1) * 0.25

			while v2 >= 1 do
				v2 -= 1

				if not (#v > 0) then
					continue
				end

				local v5 = table.remove(v, 1)
				local paint = PoolDisplay.paint
				local v7 = list
				local v8 = p
				local v9 = lastKey() -- equivalent call inferred; original call site unknown
				paint(v5, pick(v7, v8, v9), p)
				table.insert(v, v5)
			end

			position()
		else
			flag = true
			restart()
		end
	end)
	self.Destroying:Connect(function()
		renderSteppedConnection:Disconnect()
		template:Destroy()
	end)
	return function(p2, p3, options2)
		list = p2
		p = p3
		v3 = options2 or {}
		restart()
	end
end

return PoolDisplay