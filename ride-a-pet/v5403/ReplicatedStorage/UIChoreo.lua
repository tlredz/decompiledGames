local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local BitohiUI = require(ReplicatedStorage:WaitForChild("BitohiUI"))
local enthusiasticArrive = BitohiUI.EnthusiasticArrive
local fade = BitohiUI.Fade
local spring = BitohiUI.Spring
local store = BitohiUI.Store
local UIIdle = require(ReplicatedStorage:WaitForChild("UIIdle"))
local UIQuality = require(ReplicatedStorage:WaitForChild("UIQuality"))
local spr = spring.spr
local UIChoreo = {}
local v = { 0.5, 3.6 }
UIChoreo.SWING = v
UIChoreo.POSE = {
	Header = {
		S = 0.45,
		R = 18,
		Y = -0.14,
		Tune = "Card",
		PoseTune = v
	},
	Close = {
		S = 0,
		R = -220,
		Tune = "Card",
		PoseTune = { 0.55, 4.2 }
	},
	Pop = {
		S = 0,
		R = -14,
		Tune = "Card",
		PoseTune = v
	},
	Spin = {
		S = 0,
		R = -40,
		Tune = "Card",
		PoseTune = { 0.55, 4 }
	},
	Rise = {
		S = 0.55,
		R = -6,
		Y = 0.08,
		Tune = "Card",
		PoseTune = v
	},
	Panel = {
		S = 0.88,
		Y = 0.05,
		Tune = "Card",
		PoseTune = { 0.7, 4 }
	},
	FromLeft = {
		S = 0.85,
		R = 4,
		X = -0.1,
		Tune = "Card",
		PoseTune = v
	}
}
local v2 = { 0.72, 4.4 }
local v3 = { 1, 11 }
local v4 = {
	Step = 0.008,
	MaxTotal = 0.05,
	ScaleTo = 0.4,
	Spin = 8,
	Pull = 0.12,
	Wind = 0.03,
	OutTuning = { 1, 11 }
}
local v5 = {
	Step = v4.Step,
	MaxTotal = v4.MaxTotal,
	ScaleTo = 1,
	WindScale = 1,
	Spin = v4.Spin,
	Pull = 0,
	Wind = v4.Wind,
	OutTuning = v4.OutTuning
}

local function inLayout(p)
	local parent = p.Parent
	return parent ~= nil and parent:FindFirstChildWhichIsA("UIGridStyleLayout") ~= nil
end

local function child(child2, value)
	for childName in value:gmatch("[^%.]+") do
		child2 = child2 and child2:FindFirstChild(childName)
	end

	return child2
end

local function resolve(guiObject, get)
	if type(get) == "function" then
		return get(guiObject) or {}
	end

	local guiObjects = {}
	local match, _ = get:match("^(.-)/%*$")

	if match then
		if match ~= "" or not guiObject then
			for childName in match:gmatch("[^%.]+") do
				guiObject = guiObject and guiObject:FindFirstChild(childName)
			end
		end

		if guiObject then
			for _, guiObject2 in ipairs(guiObject:GetChildren()) do
				if guiObject2:IsA("GuiObject") and guiObject2.Visible then
					table.insert(guiObjects, guiObject2)
				end
			end

			return guiObjects
		end
	else
		for childName in get:gmatch("[^%.]+") do
			guiObject = guiObject and guiObject:FindFirstChild(childName)
		end

		if guiObject and guiObject:IsA("GuiObject") and guiObject.Visible then
			guiObjects[1] = guiObject
		end
	end

	return guiObjects
end

local positions = store.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function parkKid(p)
	local position = positions[p]

	if not position then
		position = p.Position
		positions[p] = position
	end

	spr.stop(p, "Position")
	p.Position = position + UDim2.fromScale(0.1, 0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playKid(p)
	local position = positions[p]

	if position then
		spring.to(p, v2, {
			Position = position
		})
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resetKid(k)
	local position = positions[k]

	if position then
		spr.stop(k, "Position")
		k.Position = position
	end
end

local function onScreen(p, guiObjects)
	local Y = p.AbsolutePosition.Y
	local v6 = Y + p.AbsoluteSize.Y
	local result = {}

	for _, v7 in ipairs(guiObjects) do
		local Y2 = v7.AbsolutePosition.Y

		if Y2 < v6 and Y < Y2 + v7.AbsoluteSize.Y then
			table.insert(result, v7)
		end
	end

	return result
end

local class = {}
class.__index = class

function UIChoreo.new(root, spec)
	local self = setmetatable({
		root = root,
		spec = spec,
		runs = {},
		parts = {},
		faded = {},
		rowKids = {},
		token = 0
	}, class)

	for _, v6 in ipairs(spec.Parts or {}) do
		if type(v6.Get) ~= "string" then
			continue
		end

		for _, v7 in ipairs((resolve(root, v6.Get))) do
			enthusiasticArrive.mark(v7)
		end
	end

	return self
end

function class:_cancel()
	self.token += 1

	for i = #self.runs, 1, -1 do
		self.runs[i]:Cancel()
		self.runs[i] = nil
	end
end

function class:Skip()
	local v6 = {}

	for _, v7 in ipairs(self.spec.Parts or {}) do
		if not (v7.Fade ~= false and type(v7.Get) == "string") then
			continue
		end

		local match = v7.Get:match("^(.-)/%*$")
		table.insert(v6, {
			path = match or v7.Get,
			star = match ~= nil,
			lowSkip = v7.LowSkip == true
		})
	end

	local root = self.root
	return function(instance)
		local v7 = nil

		for _, v8 in ipairs(v6) do
			if v8.lowSkip and v7 == nil then
				v7 = UIQuality.low()
			end

			local child2

			if not (v8.lowSkip and v7) then
				child2 = v8.path == "" and root

				if not child2 then
					child2 = root

					for childName in v8.path:gmatch("[^%.]+") do
						child2 = child2 and child2:FindFirstChild(childName)
					end

					if not child2 then
						child2 = nil
					end
				end
			end

			if not child2 then
				continue
			end

			if v8.star then
				if instance ~= child2 and instance:IsDescendantOf(child2) then
					return true
				end
			elseif instance == child2 or instance:IsDescendantOf(child2) then
				return true
			end
		end

		return false
	end
end

local function rowChildren(instance)
	local guiObjects = {}

	for _, guiObject in ipairs(instance:GetChildren()) do
		if guiObject:IsA("GuiObject") and guiObject.Visible then
			table.insert(guiObjects, guiObject)
		end
	end

	return guiObjects
end

function class:_idleLater()
	if self.spec.Idle == false then
		return
	end

	local token = self.token
	task.delay(self.spec.IdleAfter or 0.6, function()
		if token == self.token and self.root.Visible then
			UIIdle.start(self.root)
		end
	end)
end

function class:Enter(p)
	self:_cancel()
	UIIdle.stop(self.root, p == false)
	local root = self.root
	local spec = self.spec

	if p == false then
		for k, part in pairs(self.parts) do
			if k.Parent then
				enthusiasticArrive.play(k, part, {
					Reset = false,
					Fade = self.faded[k] == true
				})
			end
		end

		for k in pairs(self.rowKids) do
			if not k.Parent then
				continue
			end

			playKid(k) -- equivalent call inferred; original call site unknown
		end

		self:_idleLater()
	else
		table.clear(self.parts)
		table.clear(self.faded)
		table.clear(self.rowKids)
		local low = UIQuality.low()
		local v6 = {}

		for _, v7 in ipairs(spec.Parts or {}) do
			local items = v7.LowSkip and low and {} or resolve(root, v7.Get)
			local fade2 = v7.Fade ~= false

			for i, v9 in ipairs(items) do
				self.parts[v9] = v7.Pose
				self.faded[v9] = fade2 or nil
				enthusiasticArrive.set(v9, v7.Pose, {
					Flip = i % 2 == 0,
					Fade = fade2
				})
			end

			if #items == 1 then
				table.insert(v6, {
					Obj = items[1],
					Pose = v7.Pose,
					At = v7.At or 0,
					Fade = fade2
				})
			elseif #items > 1 then
				table.insert(v6, {
					Items = items,
					Pose = v7.Pose,
					At = v7.At or 0,
					Step = v7.Step or 0.05,
					MaxTotal = v7.MaxTotal or 0.35,
					Order = v7.Order,
					Fade = fade2
				})
			end
		end

		if #v6 > 0 then
			table.insert(self.runs, enthusiasticArrive.timeline(v6))
		end

		local token = self.token

		for _, v7 in ipairs(spec.Lists or {}) do
			local v8 = resolve(root, v7.Get)[1]

			if not v8 then
				continue
			end

			local guiObjects = {}

			for _, guiObject in ipairs(v8:GetChildren()) do
				if not guiObject:IsA("GuiObject") or not guiObject.Visible or v7.Skip and v7.Skip[guiObject.Name] then
					continue
				end

				table.insert(guiObjects, guiObject)
			end

			local v9 = onScreen(v8, guiObjects)
			table.sort(v9, function(a, b)
				return a.AbsolutePosition.Y < b.AbsolutePosition.Y
			end)

			for _, v10 in ipairs(v9) do
				for _, v11 in ipairs((rowChildren(v10))) do
					self.rowKids[v11] = true
					parkKid(v11) -- equivalent call inferred; original call site unknown
				end
			end

			local step = v7.Step or 0.05

			for i, v10 in ipairs(v9) do
				local v11 = v10
				task.delay((v7.At or 0) + (i - 1) * step, function()
					if token ~= self.token then
						return
					end

					for i2, v12 in ipairs((rowChildren(v11))) do
						playKid(v12) -- equivalent call inferred; original call site unknown
					end
				end)
			end
		end

		self:_idleLater()

		if spec.Opened then
			task.spawn(spec.Opened, root)
		end
	end
end

function class:Leave()
	self:_cancel()
	UIIdle.stop(self.root, true)
	local v6 = {}

	for k in pairs(self.parts) do
		if k.Parent and k.Visible then
			table.insert(v6, k)
		end
	end

	if #v6 > 0 then
		local instances = {}
		local instances2 = {}

		for _, instance in ipairs(v6) do
			if not self.faded[instance] then
				continue
			end

			if CollectionService:HasTag(instance, UIIdle.Tags.Spin) then
				spring.to(spring.scale(instance), v4.OutTuning, {
					Scale = v4.ScaleTo
				})
				fade.group(instance):Spring(1, v4.OutTuning)
			else
				local parent = instance.Parent
				local v7

				if parent == nil then
					v7 = false
				else
					v7 = parent:FindFirstChildWhichIsA("UIGridStyleLayout") ~= nil
				end

				if v7 then
					table.insert(instances, instance)
				else
					table.insert(instances2, instance)
				end
			end
		end

		if #instances2 > 0 then
			table.insert(self.runs, enthusiasticArrive.out(instances2, v4))
		end

		if #instances > 0 then
			table.insert(self.runs, enthusiasticArrive.out(instances, v5))
		end
	end

	for k in pairs(self.rowKids) do
		local v7 = positions[k]

		if k.Parent and v7 then
			spring.to(k, v3, {
				Position = v7 + UDim2.fromScale(0.06, 0)
			})
		end
	end

	if self.spec.Closing then
		task.spawn(self.spec.Closing, self.root)
	end
end

function class:Warm()
	if self.root.Visible then
		return
	end

	local low = UIQuality.low()
	local v6 = {}

	for _, v7 in ipairs(self.spec.Parts or {}) do
		if v7.LowSkip and low then
			continue
		end

		local fade2 = v7.Fade ~= false

		for _, v8 in ipairs((resolve(self.root, v7.Get))) do
			enthusiasticArrive.set(v8, v7.Pose, {
				Fade = fade2
			})
			table.insert(v6, v8)

			if not (#v6 >= 8) then
				continue
			end

			enthusiasticArrive.reset(v6)
			table.clear(v6)
			task.wait()

			if self.root.Visible then
				return
			end
		end
	end

	if #v6 > 0 then
		enthusiasticArrive.reset(v6)
	end
end

function class:Reset()
	self:_cancel()
	UIIdle.stop(self.root)
	local v6 = {}

	for k in pairs(self.parts) do
		table.insert(v6, k)
	end

	enthusiasticArrive.reset(v6)

	for k in pairs(self.rowKids) do
		resetKid(k) -- equivalent call inferred; original call site unknown
	end

	table.clear(self.rowKids)
	local token = self.token
	task.delay(0.1, function()
		if token == self.token and not self.root.Visible then
			enthusiasticArrive.reset(v6)
		end
	end)

	if self.spec.Hidden then
		task.spawn(self.spec.Hidden, self.root)
	end
end

local v6 = nil

function UIChoreo.window(instance, p)
	v6 = v6 or require(ReplicatedStorage:WaitForChild("UIController"))
	local v7 = UIChoreo.new(instance, p)
	local flag = false
	local flag2 = false

	for _, v8 in ipairs(p.Parts or {}) do
		if v8.LowSkip then
			flag2 = true
		end
	end

	if flag2 then
		local v8 = UIQuality.onChanged(function()
			if instance.Visible then
				flag = true
			else
				v6.refreshFade(instance)
			end
		end)
		instance.Destroying:Once(v8)
	end

	v6.decorate(instance, {
		Skip = v7:Skip(),
		CloseLead = p.CloseLead or 0.08,
		Open = function(p2)
			v7:Enter(p2)
		end,
		Close = function()
			v7:Leave()
		end,
		Hidden = function()
			v7:Reset()

			if flag then
				flag = false
				v6.refreshFade(instance)
			end
		end,
		Warm = function()
			v7:Warm()
		end
	})
	return v7
end

return UIChoreo