game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local GamepadService = game:GetService("GamepadService")
local Players = game:GetService("Players")
local _ = Players.LocalPlayer
local legacyUiLoader = require(ReplicatedStorage.client.legacy.legacyUiLoader)
require(ReplicatedStorage.client.modules.ui.Backpack.objectHelper)
local backpack = legacyUiLoader.PlayerGui.backpack
local frame = Instance.new("Frame")
frame.BackgroundTransparency = 1
frame.Size = UDim2.fromOffset(64, 64)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Parent = backpack
local v = {}
local DragHelper = {}
local v2 = {}

function DragHelper.setInventory(p)
	v2 = p
end

function DragHelper.onDragStart(_: string, _) end

function DragHelper.onDragEnd(_: string, _: string) end

function DragHelper.onDragHoveredTarget(_: string, _: string) end

local v3 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function invokeHovered(p, dragEndTarget)
	if v3 == dragEndTarget then
		return
	end

	v3 = dragEndTarget
	DragHelper.onDragHoveredTarget(p, dragEndTarget)
end

function DragHelper.setupDragTarget(p, p2)
	v[p] = p2
end

local v4 = nil
local heartbeatConnection = nil
local mouseLocation = nil
local inputBeganConnection = nil

function DragHelper.startDrag(p: string, instance)
	DragHelper.endDrag(true)
	DragHelper.onDragStart(p, frame)
	v4 = p

	if instance == "pressRelease" then
		local flag = false
		inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.ButtonX then
				flag = true
			end
		end)
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if flag then
				DragHelper.endDrag()
				return
			end

			frame.Visible = true
			mouseLocation = UserInputService:GetMouseLocation()
			frame.Position = UDim2.fromOffset(mouseLocation.X + 48, mouseLocation.Y)
			mouseLocation -= GuiService:GetGuiInset()
			invokeHovered(p, DragHelper.getDragEndTarget()) -- equivalent call inferred; original call site unknown
		end)
	else
		if not instance or typeof(instance) ~= "Instance" then
			heartbeatConnection = RunService.Heartbeat:Connect(function()
				if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
					DragHelper.endDrag()
					return
				end

				frame.Visible = true
				mouseLocation = UserInputService:GetMouseLocation()
				frame.Position = UDim2.fromOffset(mouseLocation.X, mouseLocation.Y)
				mouseLocation -= GuiService:GetGuiInset()
				invokeHovered(p, DragHelper.getDragEndTarget()) -- equivalent call inferred; original call site unknown
			end)
			return
		end

		local function update()
			if instance.UserInputState == Enum.UserInputState.End then
				DragHelper.endDrag()
				return
			end

			frame.Visible = true
			mouseLocation = instance.Position
			frame.Position = UDim2.fromOffset(mouseLocation.X, mouseLocation.Y)
			invokeHovered(p, DragHelper.getDragEndTarget()) -- equivalent call inferred; original call site unknown
		end

		update()
		heartbeatConnection = instance.Changed:Connect(update)
	end
end

function DragHelper.getDragEndTarget()
	if not mouseLocation then
		return
	end

	for _, v5 in legacyUiLoader.PlayerGui:GetGuiObjectsAtPosition(mouseLocation.X, mouseLocation.Y) do
		local v6 = v[v5]

		if v6 then
			return v6, v5
		end
	end

	return nil
end

function DragHelper.endDrag(flag: boolean?)
	if v4 == nil then
		return
	end

	if inputBeganConnection then
		inputBeganConnection:Disconnect()
		inputBeganConnection = nil
	end

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	frame.Visible = false

	if flag then
		DragHelper.onDragEnd(v4, nil)
		v4 = nil
	else
		local dragEndTarget = DragHelper.getDragEndTarget()

		if dragEndTarget then
			DragHelper.onDragEnd(v4, dragEndTarget)
		else
			DragHelper.onDragEnd(nil)
		end

		v4 = nil
	end
end

function DragHelper.getDragging()
	return v4, heartbeatConnection, mouseLocation
end

local v5 = {}

function DragHelper.setupUserInput(data)
	v5[data.component] = data
	data.component.Destroying:Connect(function()
		v5[data.component] = nil
	end)
	local v6 = 0
	data.component.TouchTap:Connect(function()
		if v4 or not data.getItemId() then
			return
		end

		if time() - v6 < 0.5 and v2[data.getItemId()] then
			data.action(data.getItemId(), "favourite", not v2[data.getItemId()].sub.Favourited)
			v6 = 0
		else
			v6 = time()
		end
	end)
	data.component.TouchPan:Connect(function(_)
		if v4 or not (data.getItemId() and data.canDrag()) then
			return
		end

		data.action(data.getItemId(), "dragStarted")
	end)
	data.component.InputBegan:Connect(function(input, _)
		if v4 or not data.getItemId() then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if data.canDrag() and not GamepadService.GamepadCursorEnabled then
				local changedConnection = nil
				local inputChangedConnection = nil

				-- equivalent calls inferred from this helper; original call sites unknown
				local function process(p)
					changedConnection:Disconnect()
					inputChangedConnection:Disconnect()
					data.action(data.getItemId(), p)
				end

				inputChangedConnection = UserInputService.InputChanged:Connect(function(input2)
					if input2.UserInputType == Enum.UserInputType.MouseMovement then
						process("dragStarted") -- equivalent call inferred; original call site unknown
					end
				end)
				changedConnection = input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						process("equip") -- equivalent call inferred; original call site unknown
					end
				end)
			else
				if GamepadService.GamepadCursorEnabled then
					local absolutePosition = data.component.AbsolutePosition
					local v7 = data.component.AbsoluteSize + absolutePosition
					local position = input.Position

					if position.X < absolutePosition.X or position.X > v7.X or position.Y < absolutePosition.Y or position.Y > v7.Y then
						return
					end
				end

				data.action(data.getItemId(), "equip")
			end
		end
	end)
end

function DragHelper.cancelDrag()
	DragHelper.endDrag(true)
end

UserInputService.InputBegan:Connect(function(input, _)
	local v6 = v5[GuiService.SelectedObject]

	if v6 then
		if input.KeyCode == Enum.KeyCode.ButtonX then
			if v4 or not (v6.getItemId() and v6.canDrag()) then
				return
			end

			v6.action(v6.getItemId(), "dragStarted", "pressRelease")
		elseif input.KeyCode == Enum.KeyCode.ButtonY then
			if not v6.getItemId() then
				return
			end

			v6.action(v6.getItemId(), "favourite", not v2[v6.getItemId()].sub.Favourited)
		end
	end
end)
UserInputService.WindowFocusReleased:Connect(DragHelper.cancelDrag)
GuiService.MenuOpened:Connect(DragHelper.cancelDrag)
backpack.inventory:GetPropertyChangedSignal("Visible"):Connect(DragHelper.cancelDrag)
local v6 = {}
local v7 = nil
local v8 = nil
RunService.Heartbeat:Connect(function()
	local v9 = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()

	if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		if v9 == v8 and v7 ~= nil then
			return
		end

		for _, v10 in legacyUiLoader.PlayerGui:GetGuiObjectsAtPosition(v9.X, v9.Y) do
			if not v5[v10] or v6[v10] then
				continue
			end

			local itemId = v5[v10].getItemId()

			if not (itemId and v2[itemId]) then
				continue
			end

			if v7 == nil then
				v7 = not v2[itemId].sub.Favourited
			end

			if (v2[itemId].sub.Favourited and true or false) == v7 then
				continue
			end

			v6[v10] = true
			v5[v10].action(itemId, "favourite", v7)
		end

		v8 = v9
	else
		table.clear(v6)
		v7 = nil
		v8 = nil
	end
end)
return DragHelper