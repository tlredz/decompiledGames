local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local parentModule = require(script.Parent)
local ButtonActions = require(script.Parent.ButtonActions)
local ButtonActivation = require(script.Parent.ButtonActivation)
local zero = Vector2.zero
local v = {}
local v2 = {}
local count = 0
local v3 = nil
local v4 = 0
local v5 = {}
local v6 = 0
local flag = false
local selectedObject = nil
local GamepadPages = {}
local v7 = 0

for _, v8 in {
	"A",
	"B",
	"X",
	"Y",
	"L1",
	"R1",
	"L2",
	"R2",
	"L3",
	"R3"
} do
	v["手柄" .. v8] = Enum.KeyCode["Button" .. v8]
end

for k, v8 in {
	["上"] = "DPadUp",
	["下"] = "DPadDown",
	["左"] = "DPadLeft",
	["右"] = "DPadRight"
} do
	v["手柄" .. k] = Enum.KeyCode[v8]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function visible(instance)
	return instance:IsDescendantOf(Players.LocalPlayer.PlayerGui) and parentModule.IsVisible(instance)
end

local function owner(instance)
	local v8 = nil

	for k, v9 in v2 do
		if not ((instance == k or instance:IsDescendantOf(k)) and (not v8 or k:IsDescendantOf(v8.root))) then
			continue
		end

		v8 = v9
	end

	return v8
end

local function scan(state)
	state.dirty = false

	for _, icon in state.icons do
		if icon.node.Parent then
			icon.node.Visible = false
		end
	end

	state.icons = {}
	state.buttons = {}
	local descendants = state.root:GetDescendants()
	table.insert(descendants, 1, state.root)

	for _, guiObject in descendants do
		if guiObject:IsA("GuiButton") and owner(guiObject) == state then
			table.insert(state.buttons, guiObject)
		end

		local parent = guiObject.Parent

		if not (guiObject:IsA("ImageLabel") and parent and parent:IsA("GuiButton") and owner(parent) == state) then
			continue
		end

		local v8 = v[guiObject.Name]

		if v8 then
			local v9 = {
				node = guiObject,
				button = parent,
				key = v8,
				fallback = guiObject.Image
			}
			table.insert(state.icons, v9)
			local success, imageForKeyCode = pcall(UserInputService.GetImageForKeyCode, UserInputService, v8)

			if success and imageForKeyCode ~= "" then
				guiObject.Image = imageForKeyCode
			end
		elseif guiObject.Name:match("^手柄") and not state.warned[guiObject] then
			state.warned[guiObject] = true
			warn("[GamepadPages] 未识别提示名称: " .. guiObject:GetFullName())
		end
	end

	table.sort(state.buttons, function(a, b)
		if a.AbsolutePosition.Y ~= b.AbsolutePosition.Y then
			return a.AbsolutePosition.Y < b.AbsolutePosition.Y
		end

		if a.AbsolutePosition.X == b.AbsolutePosition.X then
			return a:GetFullName() < b:GetFullName()
		end

		return a.AbsolutePosition.X < b.AbsolutePosition.X
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function usable(button)
	return button and button:IsA("GuiButton") and button.Selectable and parentModule.CanActivate(button) and ButtonActions.Has(button)
end

local function top()
	for _, v8 in v2 do
		if not v8.observed then
			continue
		end

		local open = visible(v8.root) and (not v8.options.available or v8.options.available())

		if open == v8.open then
			continue
		end

		v8.open = open
		count += 1
		v8.sequence = count
	end

	local function higher(data, data2)
		if data.options.base == true ~= (data2.options.base == true) then
			return data.options.base ~= true
		end

		if data.gui.DisplayOrder ~= data2.gui.DisplayOrder then
			return data.gui.DisplayOrder > data2.gui.DisplayOrder
		end

		if data.gui ~= data2.gui then
			return data.sequence > data2.sequence
		end

		if data.root:IsDescendantOf(data2.root) then
			return true
		end

		if data2.root:IsDescendantOf(data.root) then
			return false
		end

		if data.root.ZIndex ~= data2.root.ZIndex then
			return data.root.ZIndex > data2.root.ZIndex
		end

		return data.sequence > data2.sequence
	end

	local v8 = nil

	for _, v9 in v2 do
		if not (v9.open and visible(v9.root) and (not v9.options.available or v9.options.available())) then
			continue
		end

		if not (not v8 or higher(v9, v8)) then
			continue
		end

		v8 = v9
	end

	if v8 and not parentModule.IsBlocked(v8.root) then
		return v8
	end

	return nil
end

local function reveal(data, root)
	local parent = data.Parent

	while parent and parent ~= root do
		if parent:IsA("ScrollingFrame") then
			local v8 = data.AbsolutePosition - parent.AbsolutePosition
			local absoluteSize = data.AbsoluteSize
			local absoluteWindowSize = parent.AbsoluteWindowSize

			local function delta(p, p2, p3)
				if p < 0 then
					return p
				end

				return (math.max(0, p + p2 - p3))
			end

			local v9 = parent.AbsoluteCanvasSize - absoluteWindowSize
			local X = parent.CanvasPosition.X
			local X2 = v8.X
			local X3 = absoluteSize.X
			local X4 = absoluteWindowSize.X

			if not (X2 < 0) then
				X2 = math.max(0, X2 + X3 - X4)
			end

			local v10 = math.clamp(X + X2, 0, (math.max(0, v9.X)))
			local Y = parent.CanvasPosition.Y
			local Y2 = v8.Y
			local Y3 = absoluteSize.Y
			local Y4 = absoluteWindowSize.Y

			if not (Y2 < 0) then
				Y2 = math.max(0, Y2 + Y3 - Y4)
			end

			parent.CanvasPosition = Vector2.new(v10, (math.clamp(Y + Y2, 0, (math.max(0, v9.Y)))))
		end

		parent = parent.Parent
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function focus(p, button)
	if not usable(button) then
		return
	end

	GuiService.SelectedObject = button
	p.memory = button
	reveal(button, p.root)
end

local function refresh()
	local v8 = top()

	if v8 ~= v3 then
		if v3 and GuiService.SelectedObject and owner(GuiService.SelectedObject) == v3 then
			v3.memory = GuiService.SelectedObject
		end

		v3 = v8
		zero = Vector2.zero
		v4 = 0
	end

	for _, v9 in v2 do
		if v9.dirty then
			scan(v9)
		end

		for _, icon in v9.icons do
			if not icon.node.Parent then
				continue
			end

			local node = icon.node
			local open = parentModule.IsGamepad()

			if open then
				local button

				if v3 == v9 then
					button = icon.button
					open = usable(button)
				else
					open = v3 and v3.options.base and v9.options.base and v9.open

					if open then
						open = visible(v9.root) and (not v9.options.available or v9.options.available())

						if open then
							button = icon.button
							open = usable(button)
						end
					end
				end
			end

			node.Visible = open
		end
	end

	if next(v5) or os.clock() < v6 then
		return v3
	end

	if v3 and not v3.options.base and parentModule.IsGamepad() then
		if not flag then
			selectedObject = GuiService.SelectedObject
			flag = true
		end

		local memory, button, v9

		if GuiService.SelectedObject and owner(GuiService.SelectedObject) == v3 then
			if not usable(GuiService.SelectedObject) then
				memory = v3.memory or v3.options.defaultButton

				if not memory or owner(memory) ~= v3 or not usable(memory) then
					memory = nil

					for k, icon in v3.icons do
						if icon.key ~= Enum.KeyCode.ButtonA then
							continue
						end

						button = icon.button

						if not usable(button) then
							continue
						end

						memory = icon.button
						break
					end

					if not memory then
						for k, button2 in v3.buttons do
							if not usable(button2) then
								continue
							end

							memory = button2
							break
						end
					end
				end

				v9 = v3
				focus(v9, memory) -- equivalent call inferred; original call site unknown
			end
		else
			memory = v3.memory or v3.options.defaultButton

			if not memory or owner(memory) ~= v3 or not usable(memory) then
				memory = nil

				for k, icon in v3.icons do
					if icon.key ~= Enum.KeyCode.ButtonA then
						continue
					end

					button = icon.button

					if not usable(button) then
						continue
					end

					memory = icon.button
					break
				end

				if not memory then
					for k, button2 in v3.buttons do
						if not usable(button2) then
							continue
						end

						memory = button2
						break
					end
				end
			end

			v9 = v3
			focus(v9, memory) -- equivalent call inferred; original call site unknown
		end
	elseif flag then
		local selectedObject2 = GuiService.SelectedObject

		if not selectedObject2 or owner(selectedObject2) then
			local v9 = GuiService
			local selectedObject3

			if selectedObject and selectedObject.Parent then
				local button = selectedObject

				if usable(button) then
					selectedObject3 = selectedObject
				end
			end

			v9.SelectedObject = selectedObject3
		end

		flag = false
		selectedObject = nil
	end

	return v3
end

function GamepadPages.IsBlocking()
	local v8 = top()
	return v8 ~= nil and not v8.options.base
end

function GamepadPages.IsRegistered(p)
	return v2[p] ~= nil
end

function GamepadPages.GetActivePage()
	local v8 = top()
	return v8 and v8.root
end

function GamepadPages.IsActive(p)
	return GamepadPages.GetActivePage() == p
end

function GamepadPages.Register(folder, options)
	assert(not v2[folder], "Page already registered")
	local v8 = {
		root = folder,
		gui = folder:FindFirstAncestorOfClass("ScreenGui"),
		options = options or {},
		open = false,
		sequence = 0,
		dirty = true,
		icons = {},
		buttons = {},
		connections = {},
		warned = {}
	}
	assert(v8.gui, "Page requires ScreenGui")
	v2[folder] = v8

	-- equivalent calls inferred from this helper; original call sites unknown
	local function connect(object, fn)
		table.insert(v8.connections, object:Connect(fn))
	end

	local v9 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function watch(image)
		if v9[image] then
			return
		end

		v9[image] = true

		if image:IsA("ImageLabel") then
			local function fn()
				v8.dirty = true
			end

			connect(image:GetPropertyChangedSignal("Name"), fn) -- equivalent call inferred; original call site unknown
		end
	end

	for _, image in folder:GetDescendants() do
		if v9[image] then
			continue
		end

		v9[image] = true

		if not image:IsA("ImageLabel") then
			continue
		end

		local propertyChangedSignal = image:GetPropertyChangedSignal("Name")
		table.insert(v8.connections, propertyChangedSignal:Connect(function()
			v8.dirty = true
		end))
	end

	local descendantAdded = folder.DescendantAdded
	table.insert(v8.connections, descendantAdded:Connect(function(image)
		watch(image) -- equivalent call inferred; original call site unknown
		v8.dirty = true
	end))
	local descendantRemoving = folder.DescendantRemoving
	table.insert(v8.connections, descendantRemoving:Connect(function()
		v8.dirty = true
	end))

	local function fn()
		GamepadPages.Unregister(folder)
	end

	connect(folder.Destroying, fn) -- equivalent call inferred; original call site unknown

	for _, v10 in v2 do
		v10.dirty = true
	end

	scan(v8)
	return v8
end

function GamepadPages.Observe(p, items)
	local v8 = v2[p] or GamepadPages.Register(p, items)

	if items then
		for k, item in items do
			v8.options[k] = item
		end
	end

	v8.observed = true
	refresh()
	return v8
end

function GamepadPages.Refresh()
	return (refresh())
end

function GamepadPages.CanRestoreFocus(p)
	local v8 = GamepadPages.IsActive(p) and parentModule.IsGamepad() and not next(v5)

	if v8 then
		local now = os.clock()
		return v6 <= now
	end

	return v8
end

function GamepadPages.Invalidate(p)
	local v8 = v2[p]

	if v8 then
		v8.dirty = true
	end
end

function GamepadPages.Open(p, p2)
	local v8 = v2[p] or GamepadPages.Register(p, p2)
	count += 1
	v8.sequence = count
	v8.open = true
	refresh()
end

function GamepadPages.Close(p)
	local v8 = v2[p]

	if v8 then
		v8.open = false
		refresh()
	end
end

function GamepadPages.Unregister(p)
	local v8 = v2[p]

	if not v8 then
		return
	end

	for _, connection in v8.connections do
		connection:Disconnect()
	end

	for _, icon in v8.icons do
		if icon.node.Parent then
			icon.node.Visible = false
		end
	end

	v2[p] = nil

	for _, v9 in v2 do
		v9.dirty = true
	end

	refresh()
end

function GamepadPages.RefreshImages()
	for _, v8 in v2 do
		for _, icon in v8.icons do
			local success, imageForKeyCode = pcall(UserInputService.GetImageForKeyCode, UserInputService, icon.key)

			if success and imageForKeyCode ~= "" then
				icon.node.Image = imageForKeyCode
			end
		end
	end
end

local vectors = {
	[Enum.KeyCode.DPadLeft] = Vector2.new(-1, 0),
	[Enum.KeyCode.DPadRight] = Vector2.new(1, 0),
	[Enum.KeyCode.DPadUp] = Vector2.new(0, -1),
	[Enum.KeyCode.DPadDown] = Vector2.new(0, 1)
}

local function move(p, p2)
	local selectedObject2 = GuiService.SelectedObject

	if not selectedObject2 or owner(selectedObject2) ~= p then
		return
	end

	local button = selectedObject2[p2.X < 0 and "NextSelectionLeft" or p2.X > 0 and "NextSelectionRight" or p2.Y < 0 and "NextSelectionUp" or "NextSelectionDown"]

	if button and button ~= selectedObject2 and owner(button) == p and usable(button) then
		if button then
			focus(p, button) -- equivalent call inferred; original call site unknown
		end
	else
		local v8 = selectedObject2.AbsolutePosition + selectedObject2.AbsoluteSize / 2
		local v9 = 1e999
		local v10 = nil

		for _, button2 in p.buttons do
			if not (button2 ~= selectedObject2 and usable(button2)) then
				continue
			end

			local vector = button2.AbsolutePosition + button2.AbsoluteSize / 2 - v8
			local dot = vector:Dot(p2)
			local v11 = dot + math.abs(vector.X * p2.Y - vector.Y * p2.X) * 3

			if not (dot > 1 and v11 < v9) then
				continue
			end

			v10 = button2
			v9 = v11
		end

		if v10 then
			focus(p, v10) -- equivalent call inferred; original call site unknown
		end
	end
end

ButtonActions.SetOnBound(function(p)
	local v8 = owner(p)

	if v8 then
		v8.dirty = true
	end
end)
ButtonActions.SetGamepadPolicy(function(p)
	local v8 = owner(p)
	local v9 = top()
	local open

	if v8 == nil then
		open = false
	elseif v8 == v9 then
		open = true
	else
		open = v9 and v9.options.base and v8.options.base and v8.open

		if open then
			open = visible(v8.root) and (not v8.options.available or v8.options.available())
		end
	end

	return open
end)

function GamepadPages.HandleInput(_, p, p2)
	if p == Enum.UserInputState.Begin then
		ButtonActivation.Begin(p2)
	end

	local keyCode = p2.KeyCode

	if p == Enum.UserInputState.Cancel then
		ButtonActivation.Cancel(p2)
		v5[keyCode] = nil
		zero = Vector2.zero
		v6 = os.clock() + 0.05
		return Enum.ContextActionResult.Pass
	elseif p == Enum.UserInputState.End then
		ButtonActivation.End(p2)
		local v8 = v5[keyCode]
		v5[keyCode] = nil

		if keyCode == Enum.KeyCode.Thumbstick1 then
			zero = Vector2.zero
		end

		if keyCode == Enum.KeyCode.Thumbstick2 then
			v4 = 0
		end

		if v8 then
			v6 = os.clock() + 0.05
		end

		if v8 then
			return Enum.ContextActionResult.Sink
		end

		return Enum.ContextActionResult.Pass
	else
		if v5[keyCode] and keyCode ~= Enum.KeyCode.Thumbstick1 and keyCode ~= Enum.KeyCode.Thumbstick2 then
			return Enum.ContextActionResult.Sink
		end

		local v8 = refresh()

		if not (v8 and parentModule.IsGamepad()) then
			return Enum.ContextActionResult.Pass
		end

		if vectors[keyCode] and not v8.options.base or keyCode == Enum.KeyCode.Thumbstick1 or keyCode == Enum.KeyCode.Thumbstick2 then
			if v8.options.base then
				return Enum.ContextActionResult.Pass
			end

			v5[keyCode] = true

			if keyCode == Enum.KeyCode.Thumbstick2 then
				v4 = not (math.abs(p2.Position.Y) > 0.2) and 0 or p2.Position.Y
			elseif vectors[keyCode] and p == Enum.UserInputState.Begin then
				move(v8, vectors[keyCode])
			elseif keyCode == Enum.KeyCode.Thumbstick1 then
				local position = p2.Position
				local vector

				if math.max(math.abs(position.X), (math.abs(position.Y))) > 0.55 then
					if math.abs(position.X) > math.abs(position.Y) then
						vector = Vector2.new(math.sign(position.X), 0)
					else
						vector = Vector2.new(0, -math.sign(position.Y))
					end
				else
					vector = Vector2.zero
				end

				if vector ~= zero then
					zero = vector

					if vector.Magnitude > 0 then
						move(v8, vector)
						v7 = os.clock() + 0.35
					end
				end
			end

			return Enum.ContextActionResult.Sink
		else
			local selectedObject2 = nil
			local v9 = false
			local buttons = {}
			local v10

			if v8.options.base then
				v10 = {}

				for _, v11 in v2 do
					if not (v11.options.base and v11.open and visible(v11.root) and (not v11.options.available or v11.options.available())) then
						continue
					end

					table.insert(v10, v11)
				end
			else
				v10 = { v8 }
			end

			for _, v11 in v10 do
				for _, icon in v11.icons do
					if icon.key ~= keyCode or not usable(icon.button) or table.find(buttons, icon.button) then
						continue
					end

					table.insert(buttons, icon.button)
				end
			end

			if #buttons > 1 then
				local fullNames = {}
				v9 = true

				for _, v11 in buttons do
					table.insert(fullNames, v11:GetFullName())
				end

				warn("[GamepadPages] 快捷键冲突 " .. keyCode.Name .. ": " .. table.concat(fullNames, ", "))
			elseif #buttons == 1 then
				selectedObject2 = buttons[1]
			end

			if keyCode == Enum.KeyCode.ButtonA and not selectedObject2 and not v9 and GuiService.SelectedObject and usable(GuiService.SelectedObject) and (owner(GuiService.SelectedObject) == v8 or v8.options.base and owner(GuiService.SelectedObject) and owner(GuiService.SelectedObject).options.base) then
				selectedObject2 = GuiService.SelectedObject
			end

			if v8.options.base and not (selectedObject2 or v9) then
				return Enum.ContextActionResult.Pass
			end

			v5[keyCode] = true

			if p == Enum.UserInputState.Begin and selectedObject2 then
				GuiService.SelectedObject = nil
				local sequence = v8.sequence
				task.defer(function()
					local v11 = top()

					if (v11 == v8 or v11 and v11.options.base and v8.options.base) and v8.open and v8.sequence == sequence then
						ButtonActions.Invoke(selectedObject2, p2)
					end
				end)
			end

			return Enum.ContextActionResult.Sink
		end
	end
end

local v8 = {
	Enum.KeyCode.ButtonA,
	Enum.KeyCode.ButtonB,
	Enum.KeyCode.ButtonX,
	Enum.KeyCode.ButtonY,
	Enum.KeyCode.ButtonL1,
	Enum.KeyCode.ButtonR1,
	Enum.KeyCode.ButtonL2,
	Enum.KeyCode.ButtonR2,
	Enum.KeyCode.ButtonL3,
	Enum.KeyCode.ButtonR3,
	Enum.KeyCode.DPadLeft,
	Enum.KeyCode.DPadRight,
	Enum.KeyCode.DPadUp,
	Enum.KeyCode.DPadDown,
	Enum.KeyCode.Thumbstick1,
	Enum.KeyCode.Thumbstick2
}
ContextActionService:BindActionAtPriority(
	"RegisteredGamepadPages",
	GamepadPages.HandleInput,
	false,
	4200,
	table.unpack(v8)
)
local total = 0
RunService.Heartbeat:Connect(function(dt)
	total += dt

	if total >= 0.1 then
		total = 0
		refresh()
	end

	if v3 and top() == v3 and parentModule.IsGamepad() and v4 ~= 0 then
		local selectedObject2 = GuiService.SelectedObject
		local scroll = v3.options.scroll or selectedObject2 and selectedObject2:FindFirstAncestorOfClass("ScrollingFrame")

		if scroll and parentModule.IsVisible(scroll) then
			local v9 = math.max(0, scroll.AbsoluteCanvasSize.Y - scroll.AbsoluteWindowSize.Y)
			scroll.CanvasPosition = Vector2.new(
				scroll.CanvasPosition.X,
				(math.clamp(scroll.CanvasPosition.Y - v4 * math.max(250, scroll.AbsoluteWindowSize.Y) * dt, 0, v9))
			)
		end
	end

	if v3 and top() == v3 and zero.Magnitude > 0 then
		local now = os.clock()

		if v7 <= now then
			v7 = os.clock() + 0.16
			move(v3, zero)
		end
	end
end)
UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
	GamepadPages.RefreshImages()
	refresh()
end)
UserInputService.InputEnded:Connect(function(input)
	task.defer(function()
		if v5[input.KeyCode] then
			v5[input.KeyCode] = nil
			v6 = os.clock() + 0.05

			if input.KeyCode == Enum.KeyCode.Thumbstick1 then
				zero = Vector2.zero
			end
		end
	end)
end)
UserInputService.GamepadConnected:Connect(GamepadPages.RefreshImages)
UserInputService.GamepadDisconnected:Connect(GamepadPages.RefreshImages)
GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
	local selectedObject2 = GuiService.SelectedObject
	local v9 = selectedObject2 and owner(selectedObject2)

	if v9 and v9 == v3 then
		v9.memory = selectedObject2
		reveal(selectedObject2, v9.root)
	end
end)
return GamepadPages