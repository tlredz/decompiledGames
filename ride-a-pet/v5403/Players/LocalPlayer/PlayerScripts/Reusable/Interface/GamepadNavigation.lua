local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadUI = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("GamepadUI"))
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local v = {
	BackpackGui = true,
	Backpack = true
}
local instances = {}

local function IsOnScreen(parent)
	while parent and not parent:IsA("ScreenGui") do
		if parent:IsA("GuiObject") and not parent.Visible then
			return false
		else
			parent = parent.Parent
		end
	end

	return parent ~= nil and parent:IsA("ScreenGui") and parent.Enabled
end

local function FirstButton(folder)
	local v2 = 1e999
	local v3 = nil

	for _, button in folder:GetDescendants() do
		if not (button:IsA("GuiButton") and button.Selectable and button.Active and button.Visible) then
			continue
		end

		if not IsOnScreen(button) then
			continue
		end

		local absolutePosition = button.AbsolutePosition
		local v4 = absolutePosition.Y * 4 + absolutePosition.X

		if not (v4 < v2) then
			continue
		end

		v3 = button
		v2 = v4
	end

	return v3
end

local function CountButtons(folder)
	local count = 0

	for _, button in folder:GetDescendants() do
		if button:IsA("GuiButton") then
			count += 1
		end
	end

	return count
end

local function ApplyFocus()
	if GamepadUI.CursorActive() or not UserInputService.GamepadEnabled then
		return
	end

	local selectedObject = GuiService.SelectedObject

	if selectedObject then
		while selectedObject and not selectedObject:IsA("ScreenGui") do
			selectedObject = selectedObject.Parent
		end

		if selectedObject and v[selectedObject.Name] then
			return
		end
	end

	while #instances > 0 do
		local v2 = instances[#instances]

		if v2.Parent and IsOnScreen(v2) then
			local selectedObject2 = FirstButton(v2)

			if selectedObject2 and selectedObject2.Parent and selectedObject2.Visible and IsOnScreen(selectedObject2) then
				GuiService.SelectedObject = selectedObject2
				return
			end
		end

		table.remove(instances)
	end

	if GuiService.SelectedObject then
		local selectedObject2 = GuiService.SelectedObject

		while selectedObject2 and not selectedObject2:IsA("ScreenGui") do
			selectedObject2 = selectedObject2.Parent
		end

		if not v[selectedObject2 and selectedObject2.Name or ""] then
			GuiService.SelectedObject = nil
		end
	end
end

local function Watch(guiObject, screenGui)
	if screenGui.Name == "Main" and (guiObject.Name == "SideBar" or guiObject.Name == "BasketTracker" or guiObject.Name == "PetsTracker" or guiObject.Name == "PlotEggsTracker" or guiObject.Name == "BasketToggle") or v[screenGui.Name] then
		return
	end

	if CountButtons(guiObject) < 2 or guiObject.Visible then
		return
	end

	if screenGui.Name == "Main" and (guiObject:HasTag("FocusFrame") or guiObject.Name == "Gifting" or guiObject.Name == "Confirmation") then
		GamepadUI.Watch(guiObject)
	end

	local function OnVisibilityChanged()
		if guiObject.Visible then
			for i = #instances, 1, -1 do
				if instances[i] == guiObject then
					table.remove(instances, i)
				end
			end

			table.insert(instances, guiObject)
			guiObject.SelectionGroup = true
		else
			guiObject.SelectionGroup = false

			for i = #instances, 1, -1 do
				if instances[i] == guiObject then
					table.remove(instances, i)
				end
			end
		end

		task.defer(ApplyFocus)
	end

	guiObject:GetPropertyChangedSignal("Visible"):Connect(OnVisibilityChanged)
end

local function WatchScreenGui(screenGui)
	if not screenGui:IsA("ScreenGui") or v[screenGui.Name] then
		return
	end

	for _, guiObject in screenGui:GetChildren() do
		if guiObject:IsA("GuiObject") then
			Watch(guiObject, screenGui)
		end
	end

	screenGui.ChildAdded:Connect(function(guiObject)
		if guiObject:IsA("GuiObject") then
			task.defer(Watch, guiObject, screenGui)
		end
	end)
end

for _, child in playerGui:GetChildren() do
	WatchScreenGui(child)
end

playerGui.ChildAdded:Connect(WatchScreenGui)