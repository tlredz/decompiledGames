local InventoryUI = {}
local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local Client = require(localPlayer.PlayerScripts.Client)
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
local GamepadService = game:GetService("GamepadService")
local mouse = localPlayer:GetMouse()
local hotbarIcons = Client.Databases.HotbarIcons
local hotbar = Client.Interface.Hotbar
local buttonTemplate = hotbar.ButtonTemplate
local backpack = Client.Interface.Backpack
local frame = Client.Interface.TopBarFrame.StackedElements.BackpackButton.Frame
local v = {}
local v2 = {}
local v3 = nil
local v4 = nil
local v5 = {}
local v6 = {}
local v7 = nil
local v8 = nil
local v9 = 0
local StarterGui = game:GetService("StarterGui")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
frame.ClickZone.MouseButton1Click:Connect(function()
	ToggleBackpack()
end)
local v10 = {
	Tools = function(instance)
		if instance:GetAttribute("RestoreHunger") or (instance.Name == "MedKit" or instance.Name == "Bandage") or instance:GetAttribute("StructureName") then
			return false
		end

		if instance:GetAttribute("Interaction") == "Tool" or instance:GetAttribute("ToolName") then
			return true
		end
	end,
	Food = function(instance)
		if instance:GetAttribute("RestoreHunger") then
			return true
		end
	end,
	Heals = function(p)
		if p.Name == "MedKit" or p.Name == "Bandage" then
			return true
		end
	end,
	Blueprints = function(instance)
		if instance:GetAttribute("StructureName") then
			return true
		end
	end
}

function OpenBackpack()
	backpack.Visible = true

	if IsGamepadConnected() then
		local button = nil

		if v[1] then
			button = v[1].Button
		elseif v2[1] then
			button = v2[1].Button
		end

		GamepadService:EnableGamepadCursor(button)
	end

	frame.IconOpen.Visible = true
	frame.IconClosed.Visible = false
end

function CloseBackpack()
	backpack.Visible = false

	if IsGamepadConnected() then
		GamepadService:DisableGamepadCursor()
		StopDraggingButton(true)
	end

	frame.IconOpen.Visible = false
	frame.IconClosed.Visible = true
end

function ToggleBackpack()
	if IsBackpackOpen() then
		CloseBackpack()
	else
		OpenBackpack()
	end
end

function IsBackpackOpen()
	return backpack.Visible
end

ContextActionService:BindActionAtPriority("ToggleBackpack", function(_, p, _)
	if p ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end

	ToggleBackpack()
	return Enum.ContextActionResult.Sink
end, false, Enum.ContextActionPriority.High.Value + 1, Enum.KeyCode.Backquote)
ContextActionService:BindActionAtPriority("CloseBackpack", function(_, p, _)
	if p ~= Enum.UserInputState.Begin or not IsBackpackOpen() then
		return Enum.ContextActionResult.Pass
	end

	CloseBackpack()
	return Enum.ContextActionResult.Sink
end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonB)

function IsGamepadConnected()
	return UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
end

ContextActionService:BindActionAtPriority("GamepadHotbarRight", function(_, p, _)
	if p == Enum.UserInputState.Begin and not IsBackpackOpen() then
		MoveGamepadSelection("right")
		UpdateGamepadHotbarSelection()
	end
end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonR1)
ContextActionService:BindActionAtPriority("GamepadHotbarLeft", function(_, p, _)
	if p == Enum.UserInputState.Begin and not IsBackpackOpen() then
		MoveGamepadSelection("left")
		UpdateGamepadHotbarSelection()
	end
end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonL1)

function MoveGamepadSelection(p)
	local v11 = v4
	local v12 = nil

	if p == "left" then
		v12 = (v11 and table.find(v, v11) or #v + 1) - 1
	elseif p == "right" then
		v12 = (v11 and table.find(v, v11) or 0) + 1
	end

	if v12 and v12 > 0 and v12 <= #v then
		v4 = v[v12]
	else
		v4 = nil
	end
end

function InventoryUI.ClearGamepadSelection()
	v4 = nil
end

function UpdateGamepadHotbarSelection()
	if v4 then
		local item = v4.Items[1]

		if Client.InventoryHandler.GetCurrentlyEquipped() ~= item then
			Client.InventoryHandler.RequestEquipItem(item)
		end
	elseif Client.InventoryHandler.GetCurrentlyEquipped() then
		Client.InventoryHandler.UnequipCurrentItem()
	end
end

function LoadBackpackButtons()
	local buttons = {}

	for _, button in pairs(backpack.Categories:GetChildren()) do
		if not button:IsA("ImageButton") then
			continue
		end

		table.insert(buttons, button)
		local v12 = string.sub(button.Name, 9)
		local v13 = button
		button.MouseButton1Click:Connect(function()
			v3 = v12

			for k, v14 in pairs(buttons) do
				local enabled = v14 == v13
				v14.EquippedStroke.Enabled = enabled
				v14.BackgroundColor3 = enabled and Color3.fromRGB(160, 160, 160) or Color3.fromRGB(54, 54, 54)
			end

			UpdateAllButtons()
		end)
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not Client.PlayerHandler.Alive then
		return
	end

	if not gameProcessed then
		local v11 = input.KeyCode.Value - 48

		if v11 >= 1 and v11 <= 9 then
			local v12 = v[v11]
			local v13 = v12 and v12.Items[1]

			if v13 then
				if Client.InventoryHandler.GetCurrentlyEquipped() == v13 then
					Client.InventoryHandler.UnequipCurrentItem()
				else
					Client.InventoryHandler.RequestEquipItem(v13)
				end
			end
		end
	end
end)

function MoveButtonToPosition(p, p2, p3)
	local index = table.find(v, p)
	local index2 = table.find(v2, p)

	if p2 == "Hotbar" then
		if index then
			if index < p3 then
				p3 -= 1
			end

			if index == p3 then
				return
			else
				table.remove(v, index)
			end
		elseif index2 then
			table.remove(v2, index2)
		end

		table.insert(v, p3, p)
	elseif p2 == "Backpack" then
		if index2 then
			return
		end

		if index then
			table.remove(v, index)
		end

		table.insert(v2, p)

		if Client.InventoryHandler.GetCurrentlyEquipped() == p.Items[1] then
			Client.InventoryHandler.UnequipCurrentItem()
		end
	end

	UpdateAllButtons()
end

function AttemptStartDraggingButton(p, p2)
	if v8 then
		v8:Destroy()
		v8 = nil
	end

	local button = p.Button
	local absolutePosition = button.AbsolutePosition
	local absoluteSize = button.AbsoluteSize
	local v11 = absolutePosition + absoluteSize / 2
	v7 = p
	local GuiService = game:GetService("GuiService")
	local guiInset = GuiService:GetGuiInset()
	task.spawn(function()
		while v7 == p do
			local vector = Vector2.new(mouse.X, mouse.Y)

			if v8 then
				v8.Position = UDim2.new(0, vector.X, 0, vector.Y + guiInset.Y)
			elseif (v11 - vector).Magnitude > 50 or p2 then
				local clone = button:Clone()
				clone.Size = UDim2.new(0, absoluteSize.X / 2, 0, absoluteSize.Y / 2)
				clone.Parent = localPlayer.PlayerGui.Interface
				clone.AnchorPoint = Vector2.new(0.5, 0.5)
				clone.Position = UDim2.new(0, vector.X, 0, vector.Y + guiInset.Y)
				clone.EquippedStroke.Enabled = false
				clone.Active = false
				clone.Interactable = false
				clone.Selectable = false
				v8 = clone
			end

			RunService.RenderStepped:Wait()
		end
	end)
end

function IsOverlappingBackpack(p)
	local guiObjectsAtPosition = playerGui:GetGuiObjectsAtPosition(p.AbsolutePosition.X, p.AbsolutePosition.Y)

	if table.find(guiObjectsAtPosition, backpack) then
		return true
	end
end

function StopDraggingButton(p)
	if not p and v7 and v7.Button.Parent and v8 then
		local vector = Vector2.new(mouse.X, mouse.Y)
		local v11 = {}

		if IsOverlappingBackpack(v8) then
			if v7.Items[1]:GetAttribute("LockedHotbarSlot") == nil then
				MoveButtonToPosition(v7, "Backpack")
			end
		else
			for k, v12 in pairs(v) do
				local button = v12.Button
				local absoluteSize = button.AbsoluteSize
				local magnitude = (vector - (button.AbsolutePosition + Vector2.new(0, absoluteSize.Y / 2))).Magnitude

				if magnitude <= 120 then
					table.insert(v11, {
						Distance = magnitude,
						Button = button,
						Position = k
					})
				end

				if k ~= #v then
					continue
				end

				local magnitude2 = (vector - (button.AbsolutePosition + Vector2.new(absoluteSize.X, absoluteSize.Y / 2))).Magnitude

				if magnitude2 <= 120 then
					table.insert(v11, {
						Distance = magnitude2,
						Button = button,
						Position = k + 1
					})
				end
			end

			if #v11 > 0 then
				table.sort(v11, function(a, b)
					return a.Distance < b.Distance
				end)
				local v12 = v11[1]
				MoveButtonToPosition(v7, "Hotbar", v12.Position)
			end
		end
	end

	v7 = nil

	if v8 then
		v8:Destroy()
		v8 = nil
	end
end

UserInputService.InputEnded:Connect(function(input, _)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.Gamepad1 then
		if GamepadService.GamepadCursorEnabled and IsBackpackOpen() then
			return
		else
			StopDraggingButton()
		end
	end
end)
UserInputService.InputBegan:Connect(function(input, _)
	if input.UserInputType == Enum.UserInputType.Gamepad1 and GamepadService.GamepadCursorEnabled and IsBackpackOpen() and v7 then
		local v11 = time()

		if v9 < v11 then
			v9 = time() + 0.2
			StopDraggingButton()
		end
	end
end)

function CanStack(_)
	return true
end

function SetEquippedButton(p)
	for _, v11 in pairs(v) do
		local button = v11.Button
		local item = v11.Items[1]
		button.EquippedStroke.Enabled = item == p

		if item == p then
			local _ = button.Name
		end
	end

	if p == nil then
		InventoryUI.ClearGamepadSelection()
	end
end

InventoryUI.SetEquippedButton = SetEquippedButton

function ActivateButton(p)
	p.Button.MouseButton1Click:Connect(function()
		if not Client.PlayerHandler.Alive or Client.PingClient.PingActive then
			return
		end

		if GamepadService.GamepadCursorEnabled then
			if v7 == nil then
				local v11 = time()

				if v9 < v11 then
					v9 = time() + 0.2
					AttemptStartDraggingButton(p, true)
				end
			end
		else
			if table.find(v2, p) then
				return
			end

			local item = p.Items[1]

			if Client.InventoryHandler.GetCurrentlyEquipped() == item then
				Client.InventoryHandler.UnequipCurrentItem()
			else
				Client.InventoryHandler.RequestEquipItem(item)
			end
		end
	end)
	p.Button.MouseButton1Down:Connect(function()
		if GamepadService.GamepadCursorEnabled and IsBackpackOpen() or Client.PingClient.PingActive then
			return
		end

		AttemptStartDraggingButton(p)
	end)
	p.Button.MouseButton1Up:Connect(function()
		if GamepadService.GamepadCursorEnabled and IsBackpackOpen() then
			return
		end

		if Client.PingClient.PingActive then
		end
	end)
end

local v11 = {
	[2] = "rbxassetid://131281415467162",
	[3] = "rbxassetid://119675587390744"
}

function CheckBlueprint(instance)
	if not instance:GetAttribute("StructureName") or not instance:GetAttribute("ToolName") or instance:GetAttribute("ToolName") ~= "Blueprint" then
		return
	end

	local structureName = instance:GetAttribute("StructureName")
	local v12 = nil

	for _, possibleBlueprint in pairs(Client.Databases.CraftingDatabase.PossibleBlueprints) do
		for _, v14 in pairs(possibleBlueprint) do
			if v14.Name ~= structureName then
				continue
			end

			v12 = v14
			break
		end
	end

	if v12 then
		return v12.Image
	end
end

function UpdateIconQuantity(instance, text)
	if instance:HasTag("BlueprintHotbar") then
		instance.Amount.Text = string.gsub(instance.TextLabel.Text, "[Bb][Ll][Uu][Ee][Pp][Rr][Ii][Nn][Tt]", "")
		instance.Amount.Visible = true

		if not (text > 1) then
			instance.StackVisual.Visible = false
			return
		end

		instance.Amount.Text = instance.Amount.Text .. " ( " .. text .. " )"
		instance.StackVisual.Image = v11[math.min(text, 3)]
		instance.StackVisual.Visible = true
	elseif text > 1 then
		instance.Amount.Text = text
		instance.Amount.Visible = true
		instance.StackVisual.Image = v11[math.min(text, 3)]
		instance.StackVisual.Visible = true
	else
		instance.Amount.Visible = false
		instance.StackVisual.Visible = false
	end
end

function UpdateAllButtons()
	local v12 = 1

	for _, v13 in pairs(v) do
		if v13.Button:FindFirstChild("Number") then
			v13.Button.Number.Text = v12
			v13.Button.Number.Visible = true
		end

		v13.Button.Parent = hotbar
		v13.Button.LayoutOrder = v12
		local v14 = #v13.Items
		UpdateIconQuantity(v13.Button, v14)
		v12 += 1
	end

	local layoutOrder = 1
	local count = 0

	for _, v14 in pairs(v2) do
		if v14.Button:FindFirstChild("Number") then
			v14.Button.Number.Visible = false
		end

		v14.Button.Parent = backpack.ScrollingFrame
		v14.Button.LayoutOrder = layoutOrder
		v14.Button.EquippedStroke.Enabled = false
		local v15 = #v14.Items
		UpdateIconQuantity(v14.Button, v15)
		local visible = not v3 or v3 == "All" or not v10[v3] or v10[v3](v14.Items[1])
		v14.Button.Visible = visible

		if visible then
			count += 1
		end

		layoutOrder += 1
	end

	local uIGridLayout = backpack.ScrollingFrame.UIGridLayout
	local v14 = backpack.ScrollingFrame.AbsoluteSize.X * 0.15
	uIGridLayout.CellSize = UDim2.new(0, v14, 0, v14)
	local v15 = backpack.ScrollingFrame.AbsoluteSize.X * 0.011
	local v16 = math.ceil(count / 6)
	local v17 = v14 * v16 + v15 * (v16 - 1)
	backpack.ScrollingFrame.CanvasSize = UDim2.new(1, 0, 0, v17)
	local v18 = backpack.ScrollingFrame.AbsoluteSize.X * 0.011

	if v17 <= backpack.ScrollingFrame.AbsoluteSize.Y then
		v18 = backpack.ScrollingFrame.AbsoluteSize.X * 0.016
	end

	uIGridLayout.CellPadding = UDim2.new(0, v18, 0, v15)
end

function InventoryUI.GetLatestFromItemStack(p)
	local v12 = v5[p]

	if v12 then
		return v12.Items[#v12.Items]
	end
end

function AddHotbarItem(p)
	if v5[p] then
		return
	end

	local v12 = v6[p.Name]

	if v12 and CanStack(p) then
		table.insert(v12.Items, p)
	else
		v12 = CreateNewHotbarButton(p)
	end

	v5[p] = v12
	UpdateAllButtons()
end

function CreateNewHotbarButton(instance)
	local clone = buttonTemplate:Clone()
	clone.Parent = hotbar
	clone.TextLabel.Text = instance.Name
	clone.Name = "Button" .. instance.Name
	local image = CheckBlueprint(instance)
	local icon = hotbarIcons.Icons[instance.Name]

	if image then
		clone.TextLabel.Visible = false
		clone.ImageIcon.Visible = false
		clone.BlueprintImageIcon.ImageLabel.Image = image
		clone.BlueprintImageIcon.Visible = true
		clone:AddTag("BlueprintHotbar")
	elseif icon then
		clone.TextLabel.Visible = false
		clone.ImageIcon.Image = icon
		clone.ImageIcon.Visible = true
	end

	local iconColour = hotbarIcons.GetIconColour(instance)

	if iconColour then
		clone.ImageIcon.ImageColor3 = iconColour
	end

	local v13 = {
		Button = clone,
		Items = { instance }
	}
	v6[instance.Name] = v13
	local lockedHotbarSlot = instance:GetAttribute("LockedHotbarSlot")

	if lockedHotbarSlot then
		table.insert(v, lockedHotbarSlot, v13)
	else
		table.insert(v, v13)
	end

	ActivateButton(v13)
	clone.Visible = true
	return v13
end

local v12 = {
	["Snow Block"] = true
}

function RemoveHotbarItem(p)
	local v13 = v5[p]
	v5[p] = nil
	local items = v13.Items

	if #items == 1 and items[1] == p then
		v13.Button:Destroy()
		v6[p.Name] = nil

		for k, v14 in pairs(v) do
			if v14 ~= v13 then
				continue
			end

			table.remove(v, k)
			break
		end

		for k, v14 in pairs(v2) do
			if v14 ~= v13 then
				continue
			end

			table.remove(v2, k)
			break
		end

		if v4 == p then
			v4 = nil
		end
	else
		local index = table.find(v13.Items, p)

		if index then
			table.remove(v13.Items, index)
		end
	end

	UpdateAllButtons()

	if Client.InventoryHandler.GetCurrentlyEquipped() == p then
		Client.InventoryHandler.UnequipCurrentItem()

		if v12[p.Name] and v6[p.Name] and v6[p.Name].Items then
			local items2 = v6[p.Name].Items
			local item = items2[#items2]

			if item then
				Client.InventoryHandler.RequestEquipItem(item)
			end
		end
	end
end

function InventoryUI.GetStoredItem(p: string)
	if v6[p] and v6[p].Items then
		local items = v6[p].Items
		local item = items[#items]

		if item then
			return item
		end
	end
end

function LoadInventory()
	local inventory = localPlayer:WaitForChild("Inventory")
	inventory.ChildAdded:Connect(function(child)
		AddHotbarItem(child)
	end)
	local children = inventory:GetChildren()

	for _, v13 in pairs(children) do
		AddHotbarItem(v13)
	end

	inventory.ChildRemoved:Connect(function(child)
		RemoveHotbarItem(child)
	end)
end

function InventoryUI.Init()
	task.spawn(function()
		LoadBackpackButtons()
		LoadInventory()
	end)
end

return InventoryUI