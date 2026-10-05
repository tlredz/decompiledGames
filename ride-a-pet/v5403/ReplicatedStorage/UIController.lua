local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitohiUI = require(ReplicatedStorage:WaitForChild("BitohiUI"))
local spring = BitohiUI.Spring
local fade = BitohiUI.Fade
local nav = BitohiUI.Nav
local store = BitohiUI.Store
local spr = spring.spr
local UIController = {
	Settings = {
		ScaleName = "UIOpenScale",
		OpenFrom = 0.72,
		Rise = 0.035,
		Open = { 0.62, 4.4 },
		OpenMove = { 0.8, 4.6 },
		OpenFade = { 1, 8 },
		CloseTo = 0.88,
		Sink = 0.02,
		Close = { 1, 3.2 },
		CloseFade = { 1, 3.6 },
		Settle = 0.45,
		TextSafeAt = 20
	}
}
local settings = UIController.Settings
local v = store.new()

local function stateOf(instance)
	local v2 = v[instance]

	if v2 then
		return v2
	end

	local v3 = {
		frame = instance,
		home = instance.Position,
		scale = nil,
		fade = nil,
		token = 0,
		closing = false,
		watch = nil,
		group = "Window",
		parent = nil,
		navName = nil,
		deco = nil
	}
	local uIGroup = instance:GetAttribute("UIGroup")

	if uIGroup == "None" then
		v3.group = false
	elseif type(uIGroup) == "string" and uIGroup ~= "" then
		v3.group = uIGroup
	end

	v[instance] = v3
	return v3
end

local class = {}
class.__index = class
local v2 = {
	Sparkles = true,
	UIShimmer = true
}

-- equivalent calls inferred from this helper; original call sites unknown
local function fadeable(uIStroke)
	return uIStroke:IsA("UIStroke") or uIStroke.ClassName == "UIShadow"
end

local function ownFx(instance)
	if v2[instance.Name] then
		return true
	end

	local parent = instance.Parent

	if parent == nil then
		return false
	elseif v2[parent.Name] == true then
		return true
	elseif parent.Parent == nil then
		return false
	else
		return v2[parent.Parent.Name] == true
	end
end

local function newFade(state)
	local numberValue = Instance.new("NumberValue")
	numberValue.Name = "UIFade"
	numberValue.Value = 0
	local object = setmetatable({
		st = state,
		driver = numberValue,
		hidden = 0,
		dirty = true,
		insts = {},
		props = {},
		bases = {},
		n = 0,
		known = {},
		hiddenNodes = {}
	}, class)
	numberValue.Changed:Connect(function(p)
		local hidden = object.hidden

		if p ~= hidden and (p <= 0 or p >= 1 or math.abs(p - hidden) >= 0.0009765625) then
			object:_write(p)
		end
	end)
	state.frame.DescendantAdded:Connect(function(descendant)
		if not object.dirty and (descendant:IsA("GuiObject") or fadeable(descendant)) then
			local v3

			if v2[descendant.Name] then
				v3 = true
			else
				local parent = descendant.Parent

				if parent == nil then
					v3 = false
				elseif v2[parent.Name] == true then
					v3 = true
				elseif parent.Parent == nil then
					v3 = false
				else
					v3 = v2[parent.Parent.Name] == true
				end
			end

			if not v3 then
				object.dirty = true
			end
		end
	end)
	state.frame.DescendantRemoving:Connect(function(descendant)
		if not object.dirty and (descendant:IsA("GuiObject") or fadeable(descendant)) then
			local v3

			if v2[descendant.Name] then
				v3 = true
			else
				local parent = descendant.Parent

				if parent == nil then
					v3 = false
				elseif v2[parent.Name] == true then
					v3 = true
				elseif parent.Parent == nil then
					v3 = false
				else
					v3 = v2[parent.Parent.Name] == true
				end
			end

			if not v3 then
				object.dirty = true
			end
		end
	end)
	numberValue.Parent = state.frame
	return object
end

function class:_scan()
	local frame = self.st.frame
	local skip = self.st.deco and self.st.deco.Skip
	local insts = self.insts
	local props = self.props
	local bases = self.bases
	local known = self.known
	local known2 = {}
	local count = 0
	local v4 = {}
	local n = self.n
	local v5 = table.move(insts, 1, n, 1, table.create(n))
	local v6 = table.move(props, 1, n, 1, table.create(n))
	local v7 = table.move(bases, 1, n, 1, table.create(n))
	local PROPS = fade.PROPS
	local prunedHidden = false
	local hiddenNodes = self.hiddenNodes
	table.clear(hiddenNodes)
	local visit

	visit = function(canvasGroup)
		if canvasGroup ~= frame and skip and skip(canvasGroup) then
			return
		end

		local v9 = PROPS[canvasGroup.ClassName]

		if v9 then
			local v10 = known[canvasGroup] or {}
			known2[canvasGroup] = v10
			v4[canvasGroup] = true

			for _, v11 in ipairs(v9) do
				local v12 = v10[v11]

				if v12 == nil then
					v12 = canvasGroup[v11]

					if v12 >= 1 then
						v12 = false
					end

					v10[v11] = v12
				end

				count += 1
				insts[count] = canvasGroup
				props[count] = v11
				bases[count] = v12
			end
		end

		local v10

		if canvasGroup == frame then
			v10 = false
		else
			v10 = canvasGroup:IsA("CanvasGroup")
		end

		for _, child in ipairs(canvasGroup:GetChildren()) do
			if fadeable(child) then
				visit(child)
			elseif not v2[child.Name] and not v10 then
				if child:IsA("GuiObject") then
					if child.Visible then
						visit(child)
					else
						prunedHidden = true
						hiddenNodes[#hiddenNodes + 1] = child
					end
				elseif child:IsA("Folder") then
					visit(child)
				end
			end
		end
	end

	visit(frame)
	self.prunedHidden = prunedHidden

	if self.hidden ~= 0 then
		for i = 1, n do
			local v9 = v5[i]
			local v10 = v7[i]

			if not v10 or v4[v9] or not v9.Parent then
				continue
			end

			v9[v6[i]] = v10
		end
	end

	for i = count + 1, self.n do
		insts[i] = nil
		props[i] = nil
		bases[i] = nil
	end

	self.n = count
	self.known = known2
	self.dirty = false
	self.st.textCount = nil
end

function class:Stale()
	if self.dirty then
		return true
	end

	if not self.prunedHidden then
		return false
	end

	local hiddenNodes = self.hiddenNodes

	for i = 1, #hiddenNodes do
		local hiddenNode = hiddenNodes[i]

		if hiddenNode.Visible and hiddenNode.Parent then
			return true
		end
	end

	return false
end

function class:Refresh()
	if self.dirty then
		self:_scan()
	end

	self:_write(self.hidden)
end

function class:Rebase()
	if self.hidden ~= 0 then
		return
	end

	local insts = self.insts
	local props = self.props
	local bases = self.bases
	local known = self.known

	for i = 1, self.n do
		local inst = insts[i]

		if not inst.Parent then
			continue
		end

		local v3 = props[i]
		local v4 = inst[v3]

		if v4 >= 1 then
			v4 = false
		end

		bases[i] = v4
		local v5 = known[inst]

		if v5 then
			v5[v3] = v4
		end
	end
end

function class:_write(hidden)
	self.hidden = hidden
	local insts = self.insts
	local props = self.props
	local bases = self.bases

	for i = 1, self.n do
		local v3 = bases[i]

		if not v3 then
			continue
		end

		local inst = insts[i]

		if inst.Parent then
			inst[props[i]] = v3 + (1 - v3) * hidden
		end
	end
end

function class:Apply(p)
	spr.stop(self.driver)
	self:_write(p)
	self.driver.Value = p
end

function class:Spring(p2, p3)
	spring.to(self.driver, p3, {
		Value = p2
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function countScaledText(frame)
	local count = 0
	local visit

	visit = function(instance)
		for _, child in ipairs(instance:GetChildren()) do
			if child:IsA("GuiObject") then
				if child.Visible and not v2[child.Name] then
					if (child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox")) and child.TextScaled then
						count += 1
					end

					visit(child)
				end
			elseif child:IsA("Folder") then
				visit(child)
			end
		end
	end

	visit(frame)
	return count
end

local function openFrom(state)
	local uIOpenFrom = state.frame:GetAttribute("UIOpenFrom")

	if type(uIOpenFrom) == "number" then
		return uIOpenFrom
	end

	if state.textCount == nil then
		state.textCount = countScaledText(state.frame)
	end

	if state.textCount >= settings.TextSafeAt then
		return 1
	end

	return settings.OpenFrom
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ensureRig(state)
	if state.fade then
		return
	end

	state.scale = state.scale or spring.scale(state.frame, settings.ScaleName)
	state.fade = newFade(state)
end

local function hook(p, p2, ...)
	local v3 = p.deco and p.deco[p2]

	if not v3 then
		return
	end

	local success, result = pcall(v3, ...)

	if not success then
		warn(("[UIController] %s.%s: %s"):format(p.frame:GetFullName(), p2, (tostring(result))))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unwatch(p)
	if p.watch then
		p.watch:Disconnect()
		p.watch = nil
	end
end

local function rest(state)
	local frame = state.frame
	spr.stop(frame, "Position")
	frame.Position = state.home

	if state.scale then
		spr.stop(state.scale)
		state.scale.Scale = 1
		state.fade:Apply(0)
	end

	frame.Interactable = true
	frame:SetAttribute("UIClosing", nil)
	state.closing = false
	hook(state, "Hidden")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function watch(state)
	if state.watch then
		return
	end

	state.watch = state.frame:GetPropertyChangedSignal("Visible"):Connect(function()
		if state.frame.Visible then
			return
		end

		state.token += 1
		unwatch(state) -- equivalent call inferred; original call site unknown
		rest(state)
	end)
end

local function doOpen(state)
	local frame = state.frame
	state.token += 1
	ensureRig(state) -- equivalent call inferred; original call site unknown
	local v3 = not frame.Visible
	state.closing = false
	frame.Interactable = true
	frame:SetAttribute("UIClosing", nil)

	if v3 then
		if state.fade:Stale() then
			state.fade:_scan()
		end

		state.fade:Rebase()
		spr.stop(state.scale)
		spr.stop(frame, "Position")
		state.scale.Scale = openFrom(state)
		state.fade:Apply(1)
		frame.Position = state.home + UDim2.fromScale(0, settings.Rise)
	end

	hook(state, "Open", v3)

	if v3 then
		frame.Visible = true
	end

	watch(state) -- equivalent call inferred; original call site unknown
	spring.to(state.scale, settings.Open, {
		Scale = 1
	})
	spring.to(frame, settings.OpenMove, {
		Position = state.home
	})
	state.fade:Spring(0, settings.OpenFade)
end

local function doClose(state)
	local frame = state.frame
	state.token += 1
	local token = state.token
	ensureRig(state) -- equivalent call inferred; original call site unknown

	if not state.closing and state.fade.hidden == 0 then
		if state.fade:Stale() then
			state.fade:_scan()
		end

		state.fade:Rebase()
	end

	state.closing = true
	frame.Interactable = false
	frame:SetAttribute("UIClosing", true)
	watch(state) -- equivalent call inferred; original call site unknown
	hook(state, "Close")
	spring.to(state.scale, settings.Close, {
		Scale = openFrom(state) == 1 and 1 or settings.CloseTo
	})
	spring.to(frame, settings.Close, {
		Position = state.home + UDim2.fromScale(0, settings.Sink)
	})
	local v3 = not state.deco and 0 or state.deco.CloseLead or 0

	if v3 > 0 then
		task.delay(v3, function()
			if token == state.token and state.closing then
				state.fade:Spring(1, settings.CloseFade)
			end
		end)
	else
		state.fade:Spring(1, settings.CloseFade)
	end

	task.delay(settings.Settle + v3, function()
		if token ~= state.token or not state.closing then
			return
		end

		unwatch(state) -- equivalent call inferred; original call site unknown
		frame.Visible = false
		rest(state)
	end)
end

local navEntry

navEntry = function(state)
	if state.navName then
		return state.navName
	end

	state.navName = state.frame:GetFullName()
	local v3 = {}
	setmetatable(v3, {
		__index = function(_, p)
			if p == "IsOpen" then
				return UIController.isOpen(state.frame)
			end

			return nil
		end
	})

	function v3.Open(_)
		doOpen(state)
	end

	function v3.Close(_)
		doClose(state)
	end

	local register = nav.register
	local navName = state.navName
	local v4 = {
		Group = state.group,
		Parent = 0
	}
	local parent

	if state.parent and stateOf(state.parent) then
		parent = navEntry((stateOf(state.parent))) or nil
	end

	v4.Parent = parent
	register(navName, v3, v4)
	return state.navName
end

function UIController.isOpen(p)
	local v3 = v[p]
	local visible = p.Visible

	if visible then
		local closing = v3 and v3.closing
		visible = not closing
	end

	return visible
end

function UIController.open(frame)
	if UIController.isOpen(frame) then
		return false
	end

	local st = stateOf(frame)

	if st.group then
		return nav.open((navEntry(st)))
	end

	doOpen(st)
	return true
end

function UIController.close(frame)
	if not UIController.isOpen(frame) then
		return false
	end

	local st = stateOf(frame)

	if st.group then
		return nav.close((navEntry(st)))
	end

	doClose(st)
	return true
end

function UIController.toggle(p)
	if not UIController.isOpen(p) then
		return UIController.open(p) == true
	end

	UIController.close(p)
	return false
end

function UIController.configure(frame, p2)
	local v3 = stateOf(frame)

	if p2.Group ~= nil then
		v3.group = p2.Group
	end

	if p2.Parent ~= nil then
		v3.parent = p2.Parent
	end
end

function UIController.decorate(frame, deco)
	local v3 = stateOf(frame)
	v3.deco = deco

	if v3.fade then
		v3.fade.dirty = true
	end
end

function UIController.warm(frame)
	local st = stateOf(frame)
	ensureRig(st) -- equivalent call inferred; original call site unknown

	if st.deco and not frame.Visible then
		if st.fade.dirty then
			st.fade:_scan()
		end

		openFrom(st)
		hook(st, "Warm")
	end
end

function UIController.refreshFade(p)
	local v3 = v[p]

	if not (v3 and v3.fade) then
		return
	end

	v3.fade.dirty = true

	if not p.Visible then
		return
	end

	v3.fade:_scan()

	if v3.fade.hidden == 0 then
		v3.fade:Rebase()
	else
		v3.fade:_write(v3.fade.hidden)
	end
end

return UIController