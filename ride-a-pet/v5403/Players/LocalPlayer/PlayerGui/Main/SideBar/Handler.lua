local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local GamepadUI = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("GamepadUI"))
local GameSettings = require(ReplicatedStorage:WaitForChild("GameSettings"))
local BitohiUI = require(ReplicatedStorage:WaitForChild("BitohiUI"))
local spring = BitohiUI.Spring
local spr = spring.spr
local SHOWBASKETTRACKER = GameSettings.SHOWBASKETTRACKER == true
local _ = Players.LocalPlayer
local parent = script.Parent
local parent2 = parent.Parent
local dropEgg = parent2:WaitForChild("DropEgg")
local v = {
	Pets = parent2:WaitForChild("PetsTracker"),
	Eggs = parent2:WaitForChild("PlotEggsTracker"),
	Basket = parent2:WaitForChild("BasketTracker")
}
local basketToggle = parent2:FindFirstChild("BasketToggle")
local v2 = { parent, dropEgg }
local positions = {}

for _, v3 in v do
	table.insert(v2, v3)
end

if basketToggle then
	table.insert(v2, basketToggle)
end

for _, v3 in v2 do
	positions[v3] = v3.Position
	v3.SelectionGroup = false
end

local v3 = nil
local v4 = nil
local count = 0
local v5 = {}
local v6 = false
local v7 = 0
local v8 = { 1, 7 }
local v9 = { 0.68, 4.2 }

-- equivalent calls inferred from this helper; original call sites unknown
local function ClosedPosition(p)
	local v10 = positions[p]
	return UDim2.new(
		1 + p.AnchorPoint.X * p.Size.X.Scale + 0.15,
		math.max(0, p.AnchorPoint.X * p.Size.X.Offset) + 32,
		v10.Y.Scale,
		v10.Y.Offset
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Rest()
	return dropEgg:GetAttribute("DropAvailable") == true and dropEgg or parent
end

local function Sync()
	for k, v10 in v do
		v10:SetAttribute("Open", v3 == k)
	end

	parent:SetAttribute("Open", v4 == parent)

	if basketToggle then
		basketToggle:SetAttribute("Open", v4 == basketToggle)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CancelAnimations()
	for k in v5 do
		spr.stop(k, "Position")
	end

	table.clear(v5)
end

local function Slide(button, position, p, fn, p2)
	local flag = false

	local function finish()
		if flag then
			return
		end

		flag = true
		v5[button] = nil

		if p ~= count or not button.Parent then
			return
		end

		if not p2 then
			spr.stop(button, "Position")
			button.Position = position
		end

		fn()
	end

	v5[button] = true
	spring.to(button, p2 and v9 or v8, {
		Position = position
	})
	task.delay(p2 and 0.3 or 0.18, function()
		if p == count then
			if flag then
				return
			end

			flag = true
			v5[button] = nil

			if p == count then
				if not button.Parent then
					return
				end

				if not p2 then
					spr.stop(button, "Position")
					button.Position = position
				end

				fn()
			end
		end
	end)
end

local function Transition(button)
	count += 1
	local v10 = count
	CancelAnimations() -- equivalent call inferred; original call site unknown
	v4 = button
	Sync()
	local selectedObject = GuiService.SelectedObject
	local v11 = false

	if selectedObject then
		for _, ancestor in v2 do
			if not (selectedObject == ancestor or selectedObject:IsDescendantOf(ancestor)) then
				continue
			end

			v11 = true
			break
		end
	end

	if not v3 and v11 then
		GuiService.SelectedObject = nil
	end

	local function bringIn()
		if not button or v10 ~= count or not button.Parent then
			return
		end

		if not button.Visible then
			spr.stop(button, "Position")
			button.Position = ClosedPosition(button)
		end

		button.Visible = true
		Slide(button, positions[button], v10, function()
			local top = GamepadUI.Top()

			if v3 and button == v[v3] and top and top.Owner == button then
				GamepadUI.Focus(button:FindFirstChild("Toggle"))
			elseif v3 and v11 and UserInputService:GetLastInputType().Name:match("^Gamepad") then
				local button2 = button:IsA("GuiButton") and button or button:FindFirstChild("Toggle") or button:FindFirstChild("Egg")

				if button2 and button2:IsA("GuiButton") and button2.Visible and button2.Selectable then
					GuiService.SelectedObject = button2
				end
			end
		end, true)
	end

	local v12 = {}

	for _, v13 in v2 do
		if v13 == button then
			continue
		end

		if v13.Visible then
			table.insert(v12, v13)
		else
			spr.stop(v13, "Position")
			v13.Position = ClosedPosition(v13)
		end
	end

	if #v12 == 0 then
		bringIn()
		return
	end

	local count2 = #v12

	for _, v13 in v12 do
		local v15 = v13
		Slide(v13, ClosedPosition(v13), v10, function()
			v15.Visible = false
			count2 -= 1

			if count2 == 0 then
				bringIn()
			end
		end)
	end
end

local function OpenPanel(p, p2)
	if not v[p] or dropEgg:GetAttribute("DropAvailable") == true or p == "Basket" and not SHOWBASKETTRACKER then
		return
	end

	if p2 then
		v6 = false
		v7 = os.clock() + 0.5
	elseif os.clock() < v7 then
		return
	end

	if v3 == p and v4 == v[p] then
		return
	end

	v3 = p
	Transition(v[p])
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClosePanel(p, p2)
	if v3 ~= p then
		return
	end

	if p2 then
		v6 = true
		v7 = os.clock() + 0.5
	end

	v3 = nil
	Transition(Rest())
end

local function Bindable(parent3, name)
	local v10 = parent3:FindFirstChild(name)

	if v10 and not v10:IsA("BindableEvent") then
		warn("[SideBar] Replacing invalid request object: " .. v10:GetFullName())
		v10:Destroy()
		v10 = nil
	end

	if not v10 then
		v10 = Instance.new("BindableEvent")
		v10.Name = name
		v10.Parent = parent3
	end

	return v10
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HookButton(button, onActivated)
	if not (button and button:IsA("GuiButton")) then
		warn("[SideBar] Missing GuiButton for a tracker toggle")
		return
	end

	button.Active = true
	button.Interactable = true
	button.Selectable = true
	button.ZIndex = math.max(button.ZIndex, 20)
	button.Activated:Connect(onActivated)
end

for k, v10 in v do
	local v11 = k
	Bindable(v10, "OpenRequest").Event:Connect(function()
		local v12 = v11

		if not v[v12] or dropEgg:GetAttribute("DropAvailable") == true or v12 == "Basket" and not SHOWBASKETTRACKER or os.clock() < v7 then
			return
		end

		if v3 == v12 and v4 == v[v12] then
			return
		end

		v3 = v12
		Transition(v[v12])
	end)
	local v12 = k
	Bindable(v10, "CloseRequest").Event:Connect(function()
		if v3 ~= v12 then
			return
		end

		v3 = nil
		Transition(Rest())
	end)
	local toggle = v10:FindFirstChild("Toggle") or v10:FindFirstChild("Close")
	local v13 = k

	local function fn()
		if v3 ~= v13 then
			return
		end

		v6 = true
		v7 = os.clock() + 0.5
		v3 = nil
		Transition(Rest())
	end

	HookButton(toggle, fn) -- equivalent call inferred; original call site unknown
end

local pets = parent:FindFirstChild("Pets")

local function fn()
	if not (v.Pets and dropEgg:GetAttribute("DropAvailable") ~= true) then
		return
	end

	v6 = false
	v7 = os.clock() + 0.5

	if v3 == "Pets" and v4 == v.Pets then
		return
	end

	v3 = "Pets"
	Transition(v.Pets)
end

HookButton(pets, fn) -- equivalent call inferred; original call site unknown
local egg = parent:FindFirstChild("Egg")

local function fn2()
	if not (v.Eggs and dropEgg:GetAttribute("DropAvailable") ~= true) then
		return
	end

	v6 = false
	v7 = os.clock() + 0.5

	if v3 == "Eggs" and v4 == v.Eggs then
		return
	end

	v3 = "Eggs"
	Transition(v.Eggs)
end

HookButton(egg, fn2) -- equivalent call inferred; original call site unknown

if basketToggle then
	local function fn3()
		if not (v.Basket and dropEgg:GetAttribute("DropAvailable") ~= true and SHOWBASKETTRACKER) then
			return
		end

		v6 = false
		v7 = os.clock() + 0.5

		if v3 == "Basket" and v4 == v.Basket then
			return
		end

		v3 = "Basket"
		Transition(v.Basket)
	end

	HookButton(basketToggle, fn3) -- equivalent call inferred; original call site unknown
end

for _, v10 in v2 do
	v10.Visible = v10 == Rest()
	spr.stop(v10, "Position")
	local position = v10 == Rest() and positions[v10]

	if not position then
		position = ClosedPosition(v10)
	end

	v10.Position = position
end

if dropEgg:GetAttribute("DropAvailable") == true then
	v4 = dropEgg

	if not v4 then
		v4 = parent
	end
else
	v4 = parent
end

Sync()

for _, v10 in {
	{ "Egg", "Eggs", Enum.KeyCode.DPadRight },
	{ "Pets", "Pets", Enum.KeyCode.ButtonL2 }
} do
	local child = parent:FindFirstChild(v10[1])
	local v11 = v10[2]
	local v12 = v10[3]
	local v13 = v[v11]
	local v15 = v11
	GamepadUI.BindMenuShortcut(child, v13, v12, function()
		if v3 == v11 then
			ClosePanel(v11, true) -- equivalent call inferred; original call site unknown
		else
			local v16 = v11

			if not v[v16] or dropEgg:GetAttribute("DropAvailable") == true or v16 == "Basket" and not SHOWBASKETTRACKER then
				return
			end

			v6 = false
			v7 = os.clock() + 0.5

			if v3 == v16 and v4 == v[v16] then
				return
			end

			v3 = v16
			Transition(v[v16])
		end
	end, {
		Group = parent,
		CloseCursor = true,
		BadgeLeft = false,
		OpenAttribute = "Open",
		CloseButton = v13:FindFirstChild("Toggle"),
		Close = function()
			if v3 ~= v15 then
				return
			end

			v6 = true
			v7 = os.clock() + 0.5
			v3 = nil
			Transition(Rest())
		end,
		CanActivate = function()
			return dropEgg:GetAttribute("DropAvailable") ~= true
		end
	})
end

local expander = parent2:FindFirstChild("Expander")

if expander then
	expander.Visible = false
end

script.Destroying:Connect(function()
	count += 1
	CancelAnimations() -- equivalent call inferred; original call site unknown
end)
dropEgg:GetAttributeChangedSignal("DropAvailable"):Connect(function()
	if dropEgg:GetAttribute("DropAvailable") == true then
		v3 = nil
		Transition(Rest())
	elseif not v3 then
		Transition(Rest())
	end
end)