local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local Maid = require(game.ReplicatedStorage.Util.Maid)
local Signal2 = require(game.ReplicatedStorage.Util.Signal2)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
require(game.ReplicatedStorage.Util)
local Modification = require(game.ReplicatedStorage.Util.Modification)
local MobileUIController = require(game.ReplicatedStorage.Controllers.UI.MobileUIController)
local TableAttribute = require(game.ReplicatedStorage.Modules.Util.TableAttribute)
local IsTransformed = require(game.ReplicatedStorage.Util.IsTransformed)
local ImageUtil = require(game.ReplicatedStorage.Modules.Asset.ImageUtil)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("UI"):tag("Backpack"):traceback():display():build()
local v2 = {
	[Enum.KeyCode.One] = "1",
	[Enum.KeyCode.Two] = "2",
	[Enum.KeyCode.Three] = "3",
	[Enum.KeyCode.Four] = "4",
	[Enum.KeyCode.Five] = "5",
	[Enum.KeyCode.Six] = "6",
	[Enum.KeyCode.Seven] = "7",
	[Enum.KeyCode.Eight] = "8",
	[Enum.KeyCode.Nine] = "9",
	[Enum.KeyCode.Zero] = "0"
}
local v3 = {
	[Enum.KeyCode.One] = "",
	[Enum.KeyCode.Two] = "",
	[Enum.KeyCode.Three] = "",
	[Enum.KeyCode.Four] = "",
	[Enum.KeyCode.Five] = "",
	[Enum.KeyCode.Six] = "",
	[Enum.KeyCode.Seven] = "",
	[Enum.KeyCode.Eight] = "",
	[Enum.KeyCode.Nine] = "",
	[Enum.KeyCode.Zero] = ""
}
local v4 = {
	Hotkeys = {
		Enum.KeyCode.One,
		Enum.KeyCode.Two,
		Enum.KeyCode.Three,
		Enum.KeyCode.Four,
		Enum.KeyCode.Five,
		Enum.KeyCode.Six,
		Enum.KeyCode.Seven,
		Enum.KeyCode.Eight,
		Enum.KeyCode.Nine,
		Enum.KeyCode.Zero
	},
	MaxHotbar = 9
}
local v5 = Signal2.new()
local clone = table.clone(v2)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
task.wait(0.15)
local clone2 = script.Parent.Template:Clone()
clone2.TextButton:Destroy()
clone2.Number.Visible = false
clone2.BackgroundTransparency = 0.7
local v6 = {}
local flag = false
local flag2 = false
local v7 = {}
local v8 = {}
local v9 = nil
local v10 = {}
local v11 = {}

for _, guiObject in clone2:GetDescendants() do
	if guiObject:IsA("GuiObject") then
		guiObject.ZIndex += 20
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getItemId(instance)
	local itemId = instance:GetAttribute("ItemId")
	assert(type(itemId) == "number", (`no item-id for {instance:GetFullName()}`))
	return itemId
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getToolName(instance)
	if instance:GetAttribute("IsAprilFoolsFruit") then
		return (`Plastic {instance.Name}`)
	end

	return instance.Name
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getFromCache()
	if not v6[1] then
		return (script.Parent.Template:Clone())
	end

	local v12 = v6[#v6][1]
	table.remove(v6, #v6)
	return v12
end

local waitForCharacter

waitForCharacter = function(callback)
	v5:Once(function(p: string, p2)
		local v12

		if p == "Backpack" then
			local v13
			v13, v12 = v5:Wait()
		else
			local _, v13 = v5:Wait()
			v12 = p2
			p2 = v13
		end

		task.spawn(callback, v12, p2)
		waitForCharacter(callback)
	end)
end

local function updateLayouts()
	local frames = {}

	for _, frame in script.Parent.Inventory.Container:GetChildren() do
		if frame:IsA("Frame") and frame.LayoutOrder < 99999 then
			table.insert(frames, frame)
		end
	end

	table.sort(frames, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)

	for k, v12 in frames do
		v12.LayoutOrder = k
	end
end

local function updateHotkeys()
	if flag or flag2 then
		clone = table.clone(v3)
		script.Parent.Hotbar.Container.More.Number.Visible = false
	else
		clone = table.clone(v2)
		script.Parent.Hotbar.Container.More.Number.Visible = true
	end

	for k, v12 in v7 do
		v12._Obj.Number.Text = clone[v4.Hotkeys[k]]
		v12._Obj.Number.TextLabel.Text = clone[v4.Hotkeys[k]]
	end

	script.Parent.Inventory.GamepadHintsFrame.Visible = flag ~= false
	local count = 0

	for _, v12 in v7 do
		if v12.Dummy then
			v12._Obj.Visible = script.Parent.Inventory.Visible
		else
			count += 1
		end
	end

	local count2 = 0

	for _, _ in v8 do
		count2 += 1
	end

	if not flag then
		script.Parent.Hotbar.Container.More.Frame.Visible = false
		script.Parent.Hotbar.Container.More.BackgroundTransparency = 0.5
	end

	if flag and count2 > 0 or script.Parent.Inventory.Visible or count < count2 then
		script.Parent.Hotbar.Container.More.Visible = true
		script.Parent.Hotbar.Container.More.Selectable = true

		if flag then
			script.Parent.Hotbar.Container.More.Frame.Visible = true
			script.Parent.Hotbar.Container.More.BackgroundTransparency = 1
		end
	else
		script.Parent.Hotbar.Container.More.Visible = false
	end
end

local function returnToCache(state)
	state.Parent = nil
	state.LayoutOrder = 0
	state.Stack.Text = ""
	state.Stack.TextLabel.Text = ""
	state.Number.Text = ""
	state.Number.TextLabel.Text = ""
	state.Title.Text = ""
	state.Title.TextLabel.Text = ""
	state.Image.Image = ""
	state.Visible = false
	state.OutterGlow.ImageTransparency = 1
	state.InnerGlow.ImageTransparency = 1
	state.InnerGlow.Visible = true
	state.Border.BackgroundTransparency = 1
	state.TextButton.Visible = true
	table.insert(v6, { state, os.clock() + 300 })
end

local function addDummyButton(layoutOrder: number?)
	local obj = getFromCache() -- equivalent call inferred; original call site unknown

	if layoutOrder then
		obj.LayoutOrder = layoutOrder
		obj.Number.Text = clone[v4.Hotkeys[layoutOrder]]
		obj.Number.TextLabel.Text = clone[v4.Hotkeys[layoutOrder]]
		obj.Parent = script.Parent.Hotbar.Container
		local maid = Maid.new()
		v7[layoutOrder] = {
			_Obj = obj,
			Dummy = true,
			Destroy = function(self)
				returnToCache(obj)
				self._Maid:DoCleaning()
			end,
			_Maid = maid,
			DummySlot = layoutOrder
		}
		maid:GiveTask(obj.TextButton.SelectionGained:Connect(function()
			local maid2 = Maid.new()
			maid2:GiveTask(obj.TextButton.Activated:Connect(function()
				if v9 then
					if typeof(v9) == "number" then
						v7[v9]._Obj.InnerGlow.ImageTransparency = 1
						v9 = nil
					else
						v9._Obj.InnerGlow.ImageTransparency = 1
						v9:Drag(nil, layoutOrder)
					end
				else
					v9 = layoutOrder
					obj.InnerGlow.ImageTransparency = 0
				end
			end))
			maid2:GiveTask(obj.TextButton.SelectionLost:Once(function()
				maid2:DoCleaning()
			end))
			maid2:GiveTask(function()
				if maid._tasks.ConsoleClean == maid2 then
					maid._tasks.ConsoleClean = nil
				end
			end)
			maid.ConsoleClean = maid2
		end))

		if flag and script.Parent.Inventory.Visible then
			obj.TextButton.Selectable = true
		end
	else
		obj.LayoutOrder = 999999
		obj.Visible = true
		obj.Parent = script.Parent.Inventory.Container
		table.insert(v10, obj)
	end
end

local function updateInventory()
	if not (script.Parent and script.Parent:FindFirstChild("Inventory")) then
		return
	end

	local count = 0

	for _, v12 in v7 do
		if v12.Dummy then
			v12._Obj.Visible = script.Parent.Inventory.Visible
		else
			count += 1
		end
	end

	local count2 = 0

	for _, _ in v8 do
		count2 += 1
	end

	local v12 = math.max(math.ceil((count2 - count) / v4.MaxHotbar + 1), 2)
	local v13 = v12 * v4.MaxHotbar - (count2 - count)

	if script.Parent.Inventory.Visible then
		local count3 = #v10

		if v13 < count3 then
			for _ = 1, count3 - v13 do
				returnToCache(v10[1])
				table.remove(v10, 1)
			end
		else
			for _ = 1, v13 - count3 do
				addDummyButton()
			end
		end
	end

	local more = script.Parent.Hotbar.Container.More

	if not flag then
		more.Frame.Visible = false
		more.BackgroundTransparency = 0.5
	end

	if flag and count2 > 0 or script.Parent.Inventory.Visible or count < count2 then
		more.Visible = true
		more.Selectable = true

		if flag then
			more.Frame.Visible = true
			more.BackgroundTransparency = 1
		end
	else
		script.Parent.Hotbar.Container.More.Visible = false
	end

	local offset = script.Parent.Inventory.Container.UIGridLayout.CellSize.X.Offset
	local offset2 = script.Parent.Inventory.Container.UIGridLayout.CellPadding.X.Offset
	local offset3 = script.Parent.Inventory.Container.UIPadding.PaddingLeft.Offset
	script.Parent.Inventory.Size = UDim2.fromOffset(
		offset * v4.MaxHotbar + offset2 * (v4.MaxHotbar - 1) + offset3 * 2 + 5,
		offset * v12 + offset2 * (v12 - 1) + offset3 * 2
	)
end

local function swapButtons(state, instance)
	if not state.Slot and instance and not instance.Dummy then
		instance, state = state, instance
	end

	if state.Slot or instance then
		if state.Slot or not instance or instance.Dummy then
			if state.Slot or not (instance and instance.Dummy) then
				if state.Slot and not instance then
					addDummyButton(state.Slot)
					v7[state.Slot]._Obj.Visible = true
					state._Obj.Number.Text = ""
					state._Obj.Number.TextLabel.Text = ""
					state.Slot = nil
					state._Obj.LayoutOrder = 99888
					state._Obj.Parent = script.Parent.Inventory.Container
					updateInventory()
					updateLayouts()
				elseif state.Slot and instance and instance.Dummy then
					local dummySlot = instance.DummySlot
					instance:Destroy()

					if state.Slot then
						addDummyButton(state.Slot)
					else
						addDummyButton()
					end

					state.Slot = dummySlot
					v7[dummySlot] = state
					state._Obj.LayoutOrder = dummySlot
					state._Obj.Number.Text = clone[v4.Hotkeys[state.Slot]]
					state._Obj.Number.TextLabel.Text = clone[v4.Hotkeys[state.Slot]]
					state._Obj.Parent = script.Parent.Hotbar.Container
					updateInventory()
				elseif state.Slot and instance and not instance.Slot then
					local layoutOrder = instance._Obj.LayoutOrder
					v7[state.Slot] = instance
					instance.Slot = state.Slot
					instance._Obj.LayoutOrder = state.Slot
					instance._Obj.Number.Text = clone[v4.Hotkeys[state.Slot]]
					instance._Obj.Number.TextLabel.Text = clone[v4.Hotkeys[state.Slot]]
					instance._Obj.Parent = script.Parent.Hotbar.Container
					state._Obj.Number.Text = ""
					state._Obj.Number.TextLabel.Text = ""
					state.Slot = nil
					state._Obj.LayoutOrder = layoutOrder
					state._Obj.Parent = script.Parent.Inventory.Container
					updateInventory()
				elseif state.Slot and instance and instance.Slot then
					local slot = instance.Slot
					v7[state.Slot] = instance
					instance.Slot = state.Slot
					instance._Obj.LayoutOrder = state.Slot
					instance._Obj.Number.Text = clone[v4.Hotkeys[state.Slot]]
					instance._Obj.Number.TextLabel.Text = clone[v4.Hotkeys[state.Slot]]
					instance._Obj.Parent = script.Parent.Hotbar.Container
					state.Slot = slot
					v7[state.Slot] = state
					state._Obj.LayoutOrder = state.Slot
					state._Obj.Number.Text = clone[v4.Hotkeys[state.Slot]]
					state._Obj.Number.TextLabel.Text = clone[v4.Hotkeys[state.Slot]]
				end
			else
				state.Slot = instance.DummySlot
				assert(type(state.Slot) == "number", "bad slot")
				instance:Destroy()
				addDummyButton()
				v7[state.Slot] = state
				state._Obj.LayoutOrder = state.Slot
				state._Obj.Number.Text = clone[v4.Hotkeys[state.Slot]]
				state._Obj.Number.TextLabel.Text = clone[v4.Hotkeys[state.Slot]]
				state._Obj.Parent = script.Parent.Hotbar.Container
				updateInventory()
			end
		else
			local layoutOrder = state._Obj.LayoutOrder
			state._Obj.LayoutOrder = instance._Obj.LayoutOrder
			instance._Obj.LayoutOrder = layoutOrder
		end
	else
		state._Obj.LayoutOrder = 99888
		updateLayouts()
	end

	local v12 = {}

	for k, v13 in v7 do
		if not (v13.Tools and typeof(v13.Tools) == "table" and v13.Tools[1]) then
			continue
		end

		local toolTip = v13.Tools[1].ToolTip

		if toolTip == "" then
			local tool = v13.Tools[1]

			if tool:GetAttribute("IsAprilFoolsFruit") then
				toolTip = `Plastic {tool.Name}`
			else
				toolTip = tool.Name
			end
		end

		v12[toolTip] = k
	end

	v11 = v12
end

local class = {}
class.__index = class

function class.new(instance, character, backpack)
	local object = setmetatable({}, class)
	object._Character = character
	object._Backpack = backpack
	object.Tools = {}
	object._Maids = {}
	object._Maid = Maid.new()
	local _Maid = object._Maid
	local slot = v11[instance.ToolTip]

	if not slot then
		local v13 = v11
		local toolName = getToolName(instance) -- equivalent call inferred; original call site unknown
		slot = v13[toolName]
	end

	if slot then
		if v7[slot].Dummy then
			v7[slot]:Destroy()
			object.Slot = slot
		end
	else
		for i = 1, v4.MaxHotbar do
			if not v7[i].Dummy then
				continue
			end

			v7[i]:Destroy()
			object.Slot = i
			break
		end
	end

	local toolName = getToolName(instance) -- equivalent call inferred; original call site unknown
	object._Name = toolName
	local obj = getFromCache() -- equivalent call inferred; original call site unknown
	object._Obj = obj
	local _Obj = object._Obj
	local toolName2 = getToolName(instance) -- equivalent call inferred; original call site unknown
	_Obj:SetAttribute("ItemName", toolName2)
	_Maid:GiveTask(function()
		if not localPlayer.Parent then
			return
		end

		returnToCache(_Obj)
		v8[object._Name] = nil

		if object.Slot then
			addDummyButton(object.Slot)
		end
	end)
	_Obj.LayoutOrder = 0

	if object.Slot then
		_Obj.LayoutOrder = object.Slot
		_Obj.Parent = script.Parent.Hotbar.Container
		_Obj.Number.Text = clone[v4.Hotkeys[object.Slot]]
		_Obj.Number.TextLabel.Text = clone[v4.Hotkeys[object.Slot]]
		v7[object.Slot] = object
	end

	if not _Obj.Parent then
		_Obj.Parent = script.Parent.Inventory.Container
		_Obj.LayoutOrder = 99955
		updateLayouts()
	end

	object:AddTool(instance)
	_Obj.Visible = true
	_Maid:GiveTask(_Obj.TextButton.MouseEnter:Connect(function()
		_Obj.InnerGlow.ImageTransparency = 0
	end))
	_Maid:GiveTask(_Obj.TextButton.MouseLeave:Connect(function()
		_Obj.InnerGlow.ImageTransparency = 1
	end))
	_Maid:GiveTask(_Obj.TextButton.MouseButton1Down:Connect(function()
		if flag or not script.Parent.Inventory.Visible then
			return
		end

		local mouseLocation = UserInputService:GetMouseLocation()
		local X = mouseLocation.X
		local Y = mouseLocation.Y
		object:Drag(Vector2.new(X, Y))
	end))
	_Maid:GiveTask(_Obj.TextButton.Activated:Connect(function()
		if script.Parent.Inventory.Visible then
			return
		end

		if object.Equipped then
			object:Unequip()
		else
			object:Equip()
		end
	end))
	_Maid:GiveTask(_Obj.TextButton.SelectionGained:Connect(function()
		local maid = Maid.new()
		maid:GiveTask(_Obj.TextButton.Activated:Connect(function()
			if v9 then
				if typeof(v9) == "number" then
					v7[v9]._Obj.InnerGlow.ImageTransparency = 1
					object:Drag(nil, v9, true)
					v9 = nil
				else
					v9._Obj.InnerGlow.ImageTransparency = 1
					v9:Drag(nil, object)
				end
			else
				v9 = object
				_Obj.InnerGlow.ImageTransparency = 0
			end
		end))
		maid:GiveTask(_Obj.TextButton.SelectionLost:Once(function()
			maid:DoCleaning()
		end))
		maid:GiveTask(function()
			_Maid._tasks.consoleCleanup = nil
		end)
		_Maid.consoleCleanup = maid
	end))
	return object
end

function class:Drag(point: Vector2?, value, flag3: boolean?)
	if self.Destroyed then
		return
	end

	if value then
		if typeof(value) == "number" then
			local slot = self.Slot
			local _ = self._Obj.LayoutOrder
			swapButtons(self, v7[value])

			if flag3 then
				if slot then
					GuiService.SelectedObject = v7[slot]._Obj.TextButton
				end
			else
				GuiService.SelectedObject = v7[value]._Obj.TextButton
			end
		else
			swapButtons(self, value)
			GuiService.SelectedObject = self._Obj.TextButton
		end

		v9 = nil
	else
		clone2.Stack.Text = self._Obj.Stack.Text
		clone2.Stack.TextLabel.Text = self._Obj.Stack.Text
		clone2.Title.Text = self._Obj.Title.Text
		clone2.Title.TextLabel.Text = self._Obj.Title.Text
		clone2.Image.Image = self._Obj.Image.Image
		clone2.Image.ImageRectOffset = self._Obj.Image.ImageRectOffset
		clone2.Image.ImageRectSize = self._Obj.Image.ImageRectSize
		clone2.OutterGlow.ImageTransparency = self._Obj.OutterGlow.ImageTransparency
		clone2.Parent = script.Parent
		clone2.Position = UDim2.fromOffset(self._Obj.AbsolutePosition.X, self._Obj.AbsolutePosition.Y)
		self._Obj.Title.Visible = false
		self._Obj.Stack.Visible = false
		self._Obj.Image.Visible = false
		self._Obj.OutterGlow.Visible = false
		local visible = self._Obj.InnerGlow.Visible
		self._Obj.InnerGlow.Visible = false
		clone2.Visible = true
		local v12 = false
		local touchEndedConnection

		if flag2 then
			touchEndedConnection = UserInputService.TouchEnded:Connect(function()
				v12 = true
			end)
		end

		while true do
			task.wait()
			assert(point, "bad start")
			local v13 = point - UserInputService:GetMouseLocation()
			clone2.Position = UDim2.fromOffset(
				self._Obj.AbsolutePosition.X - v13.X,
				self._Obj.AbsolutePosition.Y - v13.Y
			)
			local v14

			if flag2 then
				v14 = v12 == true
			else
				v14 = not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
			end

			if not (v14 or not script.Parent.Inventory.Visible) then
				continue
			end

			if touchEndedConnection then
				touchEndedConnection:Disconnect()
			end

			local v15 = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()

			if script.Parent.Inventory.Visible then
				local flag4

				if self._Obj.AbsolutePosition.X <= v15.X and self._Obj.AbsolutePosition.X + self._Obj.AbsoluteSize.X >= v15.X and self._Obj.AbsolutePosition.Y <= v15.Y and self._Obj.AbsolutePosition.Y + self._Obj.AbsoluteSize.Y >= v15.Y then
					if self.Equipped then
						self:Unequip()
					else
						self:Equip()
					end

					flag4 = false
				else
					flag4 = true
				end

				if flag4 then
					local v16 = v15

					local function Loop(p: number?, p2)
						if p2._Obj.AbsolutePosition.X <= v16.X and p2._Obj.AbsolutePosition.X + p2._Obj.AbsoluteSize.X >= v16.X and p2._Obj.AbsolutePosition.Y <= v16.Y and p2._Obj.AbsolutePosition.Y + p2._Obj.AbsoluteSize.Y >= v16.Y then
							swapButtons(self, p2)
							flag4 = false
							return false
						end
					end

					for _, v17 in v8 do
						if Loop(v17.Slot, v17) == false then
							break
						end
					end

					if flag4 then
						for k, v18 in v7 do
							if Loop(k, v18) == false then
								break
							end
						end
					end
				end

				if flag4 then
					local v16 = {
						_Obj = script.Parent.Inventory
					}

					if v16._Obj.AbsolutePosition.X <= v15.X and v16._Obj.AbsolutePosition.X + v16._Obj.AbsoluteSize.X >= v15.X and v16._Obj.AbsolutePosition.Y <= v15.Y and v16._Obj.AbsolutePosition.Y + v16._Obj.AbsoluteSize.Y >= v15.Y then
						swapButtons(self, nil)
					end
				end
			end

			self._Obj.Title.Visible = true
			self._Obj.Stack.Visible = true
			self._Obj.Image.Visible = true
			self._Obj.OutterGlow.Visible = true
			self._Obj.InnerGlow.Visible = visible
			clone2.Visible = false
			return
		end
	end
end

function class:Equip()
	if self.Destroyed or self.Disabled then
		return
	end

	for _, tool in self.Tools do
		if tool.Parent == self._Character then
			return
		end
	end

	if self.Tools[#self.Tools]:GetAttribute("WaitForHandle") and not self.Tools[#self.Tools]:FindFirstChild("Handle") then
		return
	end

	local humanoid = self._Character:FindFirstChild("Humanoid")
	assert(humanoid, "bad humanoid")
	humanoid:EquipTool(self.Tools[#self.Tools])
	self:_UpdateEquipped()
end

function class:Unequip()
	if self.Destroyed then
		return
	end

	for _, tool in self.Tools do
		if tool.Parent ~= self._Character then
			continue
		end

		local humanoid = self._Character:FindFirstChild("Humanoid")
		assert(humanoid, "bad humanoid")
		humanoid:UnequipTools()
		self:_UpdateEquipped()
		break
	end
end

function class:AddTool(instance)
	if self.Destroyed or table.find(self.Tools, instance) then
		return
	end

	table.insert(self.Tools, instance)
	local parent = instance.Parent

	if self._Maids[instance] then
		self._Maids[instance]:DoCleaning()
	end

	self._Maids[instance] = Maid.new()
	self._Maids[instance]:GiveTask(instance:GetPropertyChangedSignal("Parent"):Connect(function()
		local parent2 = instance.Parent

		if parent2 == parent then
			return
		end

		if parent2 == self._Character then
			self:_UpdateEquipped()
		elseif parent2 == self._Backpack then
			self:_UpdateEquipped()
		else
			self:RemoveTool(instance, parent == self._Character)
		end

		parent = parent2
	end))
	self._Maids[instance]:GiveTask(instance:GetPropertyChangedSignal("Name"):Connect(function()
		local toolName = getToolName(instance) -- equivalent call inferred; original call site unknown

		if v8[toolName] then
			local toolName2 = getToolName(instance) -- equivalent call inferred; original call site unknown

			if table.find(v8[toolName2].Tools, instance) then
				local toolName3 = getToolName(instance) -- equivalent call inferred; original call site unknown
				v8[toolName3]:_UpdateEquipped()
			else
				local toolName3 = getToolName(instance) -- equivalent call inferred; original call site unknown
				v8[toolName3]:AddTool(instance)
			end
		else
			local v14 = v8
			local toolName2 = getToolName(instance) -- equivalent call inferred; original call site unknown
			v14[toolName2] = class.new(instance, self._Character, self._Backpack)
			updateInventory()
		end

		self:RemoveTool(instance)
	end))
	self._Maids[instance]:GiveTask(instance:GetAttributeChangedSignal("ItemId"):Connect(function()
		self:_UpdateIcon(instance)
	end))
	self._Maids[instance]:GiveTask(instance:GetAttributeChangedSignal("IconSpriteKey"):Connect(function()
		self:_UpdateIcon(instance)
	end))
	self._Maids[instance]:GiveTask(instance:GetAttributeChangedSignal("OutlineSpriteKey"):Connect(function()
		self:_UpdateIcon(instance)
	end))
	self._Maids[instance]:GiveTask(instance:GetAttributeChangedSignal("DragonType"):Connect(function()
		self:_UpdateIcon(instance)
	end))
	self._Maids[instance]:GiveTask(instance:GetAttributeChangedSignal("IsAprilFoolsFruit"):Connect(function()
		self:_UpdateIcon(instance)
	end))
	self._Maids[instance]:GiveTask(instance:GetAttributeChangedSignal("ImageColor3"):Connect(function()
		self:_UpdateIcon(instance)
	end))
	self._Maids[instance]:GiveTask(instance:GetAttributeChangedSignal("Name"):Connect(function()
		self:_UpdateIcon(instance)
	end))
	self._Maids[instance]:GiveTask(instance:GetAttributeChangedSignal("Locks"):Connect(function()
		self:_UpdateDisabled(instance)
	end))
	local itemId = getItemId(instance) -- equivalent call inferred; original call site unknown
	self._Maids[instance]:GiveTask(Modification.connectOnModificationPreferredForAdornee(
		localPlayer,
		itemId,
		function(p: number?)
			self:_UpdateIcon(instance, p)
		end,
		nil,
		"Skin"
	))
	local count = #self.Tools

	if count == 1 then
		self._Obj.Stack.Text = ""
		self._Obj.Stack.TextLabel.Text = ""
	else
		self._Obj.Stack.Text = "x" .. count
		self._Obj.Stack.TextLabel.Text = "x" .. count
	end

	self:_UpdateDisabled(instance)
	self:_UpdateIcon(instance)
	self:_UpdateEquipped()
end

function class:RemoveTool(p, _: boolean?)
	if self.Destroyed then
		return
	end

	local count = 0
	local v12 = nil

	for i = 1, #self.Tools do
		local tool = self.Tools[i - count]

		if tool == p then
			table.remove(self.Tools, i - count)
			count += 1
		else
			v12 = tool
		end
	end

	if self._Maids[p] then
		self._Maids[p]:DoCleaning()
		self._Maids[p] = nil
	end

	if not v12 then
		self:Destroy()
		return
	end

	local count2 = #self.Tools

	if count2 == 1 then
		self._Obj.Stack.Text = ""
		self._Obj.Stack.TextLabel.Text = ""
	else
		self._Obj.Stack.Text = "x" .. count2
		self._Obj.Stack.TextLabel.Text = "x" .. count2
	end

	self:_UpdateEquipped()
	return true
end

function class:_UpdateEquipped()
	if self.Destroyed then
		return
	end

	for _, tool in self.Tools do
		if tool.Parent ~= self._Character then
			continue
		end

		self._Obj.OutterGlow.ImageTransparency = 0
		self._Obj.InnerGlow.Visible = false
		self.Equipped = true
		return
	end

	self._Obj.OutterGlow.ImageTransparency = 1
	self._Obj.InnerGlow.Visible = true
	self.Equipped = false
end

function class:_UpdateIcon(instance, p2: number?)
	local extended = v.extend("Button:_UpdateIcon", true, nil)
	extended.info((`called fn: (tool={instance:GetFullName()})`))

	if self.Destroyed then
		extended.trace("returning early, button is destroyed")
		return
	end

	local itemId = getItemId(instance) -- equivalent call inferred; original call site unknown
	extended.trace((`itemId: {ItemConfig.match(itemId):unwrap().Index.DebugLabel} {Modification.getIfAdornee(itemId) and "adornee" or "not adornee"}`))

	if not p2 then
		if Modification.getIfAdornee(itemId) then
			p2 = Modification.getPreferredModification(
				itemId,
				"Skin",
				Modification.Data.Modification.fromItemReplication(localPlayer),
				Modification.Data.Modification.fromItemReplication(localPlayer)
			)
		else
			p2 = nil
		end
	end

	local trace = extended.trace
	local v13

	if p2 then
		v13 = ItemConfig.match(p2):unwrap().Index.DebugLabel or nil
	end

	trace((`skinId: {v13}`))
	local imageForToolInstance = ImageUtil.getImageForToolInstance(instance, p2)

	if imageForToolInstance then
		extended.trace("applying tool image")
		local _Obj = self._Obj
		_Obj.Image.Image = imageForToolInstance.Icon.Image
		_Obj.Image.ImageColor3 = imageForToolInstance.Icon.ImageColor3
		_Obj.Image.ImageRectOffset = imageForToolInstance.Icon.ImageRectOffset
		_Obj.Image.ImageRectSize = imageForToolInstance.Icon.ImageRectSize
		_Obj.Title.Visible = false
	else
		extended.trace("no tool image")
		self._Obj.Title.Visible = true
		local title = self._Obj.Title
		local toolName = getToolName(instance) -- equivalent call inferred; original call site unknown
		title.Text = toolName
		local textLabel = self._Obj.Title.TextLabel
		local toolName2 = getToolName(instance) -- equivalent call inferred; original call site unknown
		textLabel.Text = toolName2
	end
end

function class:_UpdateDisabled(p2)
	local locks = TableAttribute:Get(p2, "Locks")

	if next(locks) then
		self.Disabled = true
		self._Obj.Border.BackgroundTransparency = 0.5
		self._Obj.TextButton.Visible = false
	else
		self.Disabled = false
		self._Obj.Border.BackgroundTransparency = 1
		self._Obj.TextButton.Visible = true
	end
end

function class:Destroy()
	self.Destroyed = true

	if self.Slot and v7[self.Slot] == self then
		v7[self.Slot] = nil
	end

	for _, _Maid in self._Maids do
		_Maid:DoCleaning()
	end

	self._Maids = {}
	self._Maid:DoCleaning()
	updateInventory()
end

local newCooldownFrame = MobileUIController:GetNewCooldownFrame()
newCooldownFrame.ZIndex = 999
newCooldownFrame.Frame1.Frame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
newCooldownFrame.Frame2.Frame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
newCooldownFrame.Parent = script.Parent.Template

if UserInputService.TouchEnabled and (not UserInputService.MouseEnabled or RunService:IsStudio()) then
	v4.MaxHotbar = 4
	flag2 = true
end

if UserInputService.GamepadEnabled or GuiService:IsTenFootInterface() then
	flag = true

	if GuiService:IsTenFootInterface() then
		script.Parent.UIScale.Scale = 1.6666666666666667
	end
end

while not pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.Backpack, false) do
	task.wait(1)
end

if not GuiService:IsTenFootInterface() then
	UserInputService.InputBegan:Connect(function(input)
		local v12 = flag

		if input.UserInputType == Enum.UserInputType.Gamepad1 then
			flag = true
		else
			flag = false
		end

		if flag ~= v12 then
			updateHotkeys()
		end
	end)
	UserInputService.GamepadConnected:Connect(function()
		flag = false

		if UserInputService.GamepadEnabled or GuiService:IsTenFootInterface() then
			flag = true
		end

		updateHotkeys()
	end)
	UserInputService.GamepadDisconnected:Connect(function()
		flag = false

		if UserInputService.GamepadEnabled or GuiService:IsTenFootInterface() then
			flag = true
		end

		updateHotkeys()
	end)
end

updateHotkeys()

for i = 1, v4.MaxHotbar do
	addDummyButton(i)
end

local clone3 = table.clone((IsTransformed.isTransformed("rigList")))

for k, v12 in IsTransformed.isTransformed("rigListSpecial"), nil, nil do
	clone3[k] = v12
end

clone3.Buddha = nil
local tool = nil
local v12 = false
local v13 = {}

local function CharacterAdded(instance, parent)
	for _, v14 in v8 do
		v14:Destroy()
	end

	if tool then
		tool:Destroy()
	end

	for _, v14 in v13 do
		v14()
	end

	v13 = {}

	if not v12 then
		v12 = true
		task.spawn(function()
			for _ = 1, flag2 and 10 or 20 do
				table.insert(v6, { script.Parent.Template:Clone(), os.clock() + 300 })
				task.wait(0.03333333333333333)
			end
		end)
	end

	script.Parent.Inventory.Visible = false

	local function lockTransformedTool(tool2, p: string, sourceTool)
		if not tool2:IsA("Tool") or tool2.Name == sourceTool or tool2.ToolTip ~= "Sword" and tool2.ToolTip ~= "Gun" and tool2.ToolTip ~= "Melee" and tool2.ToolTip ~= "JobTool" then
			return
		end

		TableAttribute:SetKey(tool2, "Locks", p, true)
		local humanoid = tool2.Parent == instance and instance:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid:UnequipTools()
		end
	end

	local function childAdded(tool2)
		if tool2:IsA("Tool") then
			if tool2.ToolTip == "Wear" or tool2:GetAttribute("ConsoleTool") then
				return
			end

			if tool2.ToolTip == "Sword" or tool2.ToolTip == "Gun" or tool2.ToolTip == "Melee" or tool2.ToolTip == "JobTool" then
				local v14 = nil

				for childName in clone3 do
					if not instance:FindFirstChild(childName) then
						continue
					end

					v14 = childName
					break
				end

				if v14 then
					local child = instance:FindFirstChild(v14)

					if not child or child:GetAttribute("SourceTool") ~= tool2.Name then
						local v16 = v14 .. "_TransformLock"
						local v18

						if child then
							v18 = child:GetAttribute("SourceTool")
						end

						lockTransformedTool(tool2, v16, v18)
					end
				end
			elseif tool2.ToolTip == "Fish" then
				local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					local buddha = humanoidRootPart:FindFirstChild("Buddha") or humanoidRootPart:FindFirstChild("Buddha2")

					if buddha then
						TableAttribute:SetKey(tool2, "Locks", "Buddha_TransformLock", true)
						buddha.AncestryChanged:Connect(function(_, parent2)
							if not parent2 then
								TableAttribute:SetKey(tool2, "Locks", "Buddha_TransformLock", nil)
							end
						end)
						task.defer(function()
							local humanoid = instance:FindFirstChild("Humanoid")

							if humanoid then
								humanoid:UnequipTools()
							end
						end)
					end
				end
			end

			local toolName = getToolName(tool2) -- equivalent call inferred; original call site unknown

			if v8[toolName] then
				local toolName2 = getToolName(tool2) -- equivalent call inferred; original call site unknown

				if table.find(v8[toolName2].Tools, tool2) then
					local toolName3 = getToolName(tool2) -- equivalent call inferred; original call site unknown
					v8[toolName3]:_UpdateEquipped()
				else
					local toolName3 = getToolName(tool2) -- equivalent call inferred; original call site unknown
					v8[toolName3]:AddTool(tool2)
				end
			else
				local v15 = v8
				local toolName2 = getToolName(tool2) -- equivalent call inferred; original call site unknown
				v15[toolName2] = class.new(tool2, instance, parent)
				updateInventory()
			end
		elseif tool2.Parent == instance then
			local toolName = getToolName(tool2) -- equivalent call inferred; original call site unknown
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
			local buddha

			if humanoidRootPart then
				buddha = humanoidRootPart:FindFirstChild("Buddha") or humanoidRootPart:FindFirstChild("Buddha2")
			else
				buddha = false
			end

			if clone3[toolName] then
				local v14 = toolName .. "_TransformLock"
				local sourceTool = tool2:GetAttribute("SourceTool")

				for _, child in instance:GetChildren() do
					lockTransformedTool(child, v14, sourceTool)
				end

				for _, child in parent:GetChildren() do
					lockTransformedTool(child, v14, sourceTool)
				end

				local parentChangedConnection = nil

				if toolName == "PainTransformed" then
					task.spawn(function()
						while task.wait() and tool2.Parent do

						end

						for _, tool3 in parent:GetChildren() do
							assert(tool3:IsA("Tool"), (`bad child: {tool3}`))

							if tool3.ToolTip == "Sword" or tool3.ToolTip == "Gun" or tool3.ToolTip == "Melee" or tool3.ToolTip == "JobTool" then
								TableAttribute:SetKey(tool3, "Locks", v14, nil)
							end
						end
					end)
				else
					parentChangedConnection = tool2:GetPropertyChangedSignal("Parent"):Connect(function()
						if not tool2.Parent then
							if not instance:FindFirstChild(toolName) then
								for _, tool3 in parent:GetChildren() do
									assert(tool3:IsA("Tool"), (`bad child: {tool3}`))

									if tool3.ToolTip == "Sword" or tool3.ToolTip == "Gun" or tool3.ToolTip == "Melee" or tool3.ToolTip == "JobTool" then
										TableAttribute:SetKey(tool3, "Locks", v14, nil)
									end
								end
							end

							if parentChangedConnection then
								parentChangedConnection:Disconnect()
								parentChangedConnection = nil
							end
						end
					end)
				end

				table.insert(v13, function()
					if parentChangedConnection then
						parentChangedConnection:Disconnect()
						parentChangedConnection = nil
					end
				end)
			elseif buddha then
				local tool3 = instance:FindFirstChildOfClass("Tool")

				if tool3 and tool3.ToolTip == "Fish" then
					local humanoid = instance:FindFirstChild("Humanoid")
					assert(humanoid, "bad humanoid")
					humanoid:UnequipTools()
				end

				for _, tool4 in parent:GetChildren() do
					assert(tool4:IsA("Tool"), (`bad child: {tool4}`))

					if tool4.ToolTip ~= "Fish" then
						continue
					end

					TableAttribute:SetKey(tool4, "Locks", "Buddha_TransformLock", true)
					local v14 = tool4
					buddha.AncestryChanged:Connect(function(p, parent2)
						if not parent2 then
							TableAttribute:SetKey(v14, "Locks", "Buddha_TransformLock", nil)
						end
					end)
				end
			end
		end
	end

	local v14 = {}

	for k in v11 do
		for _, tool2 in localPlayer.Backpack:GetChildren() do
			if tool2:IsA("Tool") then
				local toolName = getToolName(tool2) -- equivalent call inferred; original call site unknown

				if toolName == k or tool2.ToolTip == k then
					continue
				end
			end

			v14[k] = true
		end
	end

	for k in v14 do
		v11[k] = nil
	end

	tool = Instance.new("Tool")
	tool.RequiresHandle = false
	tool:SetAttribute("ConsoleTool", true)
	tool.Activated:Connect(function()
		script.Parent.Inventory.Visible = not script.Parent.Inventory.Visible
	end)
	local outterGlow = script.Parent.Hotbar.Container.More.OutterGlow
	tool.AncestryChanged:Connect(function(_, parent2)
		if parent2 == localPlayer.Character then
			outterGlow.ImageTransparency = 0
		else
			outterGlow.ImageTransparency = 1
		end
	end)
	tool.Parent = parent

	for _, child in parent:GetChildren() do
		if child:IsA("Tool") or child:IsA("Model") then
			childAdded(child)
		end
	end

	for _, child in instance:GetChildren() do
		if child:IsA("Tool") or child:IsA("Model") then
			childAdded(child)
		end
	end

	local childAddedConnection = parent.ChildAdded:Connect(childAdded)
	local childAddedConnection2 = instance.ChildAdded:Connect(childAdded)
	table.insert(v13, function()
		if childAddedConnection then
			childAddedConnection:Disconnect()
			childAddedConnection = nil
		end

		if childAddedConnection2 then
			childAddedConnection2:Disconnect()
			childAddedConnection2 = nil
		end

		if tool and tool.Parent then
			tool:Destroy()
		end
	end)
end

v5:Once(function(p: string, p2)
	local v14

	if p == "Backpack" then
		local v15
		v15, v14 = v5:Wait()
	else
		local _, v15 = v5:Wait()
		v14 = p2
		p2 = v15
	end

	task.spawn(CharacterAdded, v14, p2)
	waitForCharacter(CharacterAdded)
end)

if localPlayer.Character then
	v5:Fire("Character", localPlayer.Character)
end

localPlayer.CharacterAdded:Connect(function(character)
	v5:Fire("Character", character)
end)

if localPlayer:FindFirstChild("Backpack") then
	v5:Fire("Backpack", localPlayer.Backpack)
end

localPlayer.ChildAdded:Connect(function(child)
	if child.Name == "Backpack" then
		v5:Fire("Backpack", child)
	end
end)
local v14 = 0
local v15 = 0
ContextActionService:BindAction("ToolbarMovement", function(_, p, p2)
	if p ~= Enum.UserInputState.Begin or GuiService.SelectedObject then
		return Enum.ContextActionResult.Pass
	end

	local v16 = {}
	local v17 = nil

	for _, v18 in v7 do
		if v18.Dummy or v18.Disabled then
			continue
		end

		table.insert(v16, v18)

		if v18.Equipped then
			v17 = #v16
		end
	end

	local _ = script.Parent.Hotbar.Container.More.Visible

	if p2.KeyCode == Enum.KeyCode.ButtonR1 then
		if not v17 then
			v16[1]:Equip()
		elseif v15 > os.clock() then
			v16[v17]:Unequip()
			v15 = 0
			v14 = 0
		else
			if not v16[v17 + 1] then
				v16[v17]:Unequip()
				return
			end

			v16[v17 + 1]:Equip()
			v14 = os.clock() + 0.1
			v15 = 0
		end
	else
		if not v17 then
			local _ = script.Parent.Hotbar.Container.More.Visible
		end

		if not v17 then
			v16[#v16]:Equip()
		elseif v14 > os.clock() then
			v16[v17]:Unequip()
			v15 = 0
			v14 = 0
		else
			if not v16[v17 - 1] then
				v16[v17]:Unequip()
				return
			end

			v16[v17 - 1]:Equip()
			v14 = 0
			v15 = os.clock() + 0.1
		end
	end
end, false, Enum.KeyCode.ButtonR1, Enum.KeyCode.ButtonL1)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not script.Parent.Enabled then
		return
	end

	local index = table.find(v4.Hotkeys, input.KeyCode)

	if index then
		if v7[index] and not v7[index].Dummy then
			if v7[index].Equipped then
				v7[index]:Unequip()
			else
				v7[index]:Equip()
			end
		end
	elseif input.KeyCode == Enum.KeyCode.Backquote then
		script.Parent.Inventory.Visible = not script.Parent.Inventory.Visible
	end
end)
script.Parent.Hotbar.Container.More.TextButton.Activated:Connect(function()
	task.wait()
	script.Parent.Inventory.Visible = not script.Parent.Inventory.Visible
end)
local selectedObjectChangedConnection = nil
script.Parent.Inventory:GetPropertyChangedSignal("Visible"):Connect(function()
	if script.Parent.Inventory.Visible then
		script.Parent.Hotbar.Container.More.Title.Text = "-"
		script.Parent.Hotbar.Container.More.Title.TextLabel.Text = "-"

		if flag then
			if tool then
				tool.Parent = localPlayer.Backpack
			end

			for _, v16 in v7 do
				v16._Obj.TextButton.Selectable = true
			end

			for _, v16 in v8 do
				v16._Obj.TextButton.Selectable = true
			end

			GuiService.SelectedObject = v7[1]._Obj.TextButton
			local selectedObject = GuiService.SelectedObject
			selectedObjectChangedConnection = GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
				if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(script.Parent) then
					selectedObject = GuiService.SelectedObject
				else
					GuiService.SelectedObject = selectedObject
				end
			end)
			ContextActionService:BindActionAtPriority("BackpackMovement", function(_, p, p2)
				if p ~= Enum.UserInputState.Begin then
					return Enum.ContextActionResult.Pass
				end

				if p2.KeyCode == Enum.KeyCode.ButtonB then
					if not v9 then
						script.Parent.Inventory.Visible = false
						return
					end

					if typeof(v9) == "number" then
						v7[v9]._Obj.InnerGlow.ImageTransparency = 1
					else
						v9._Obj.InnerGlow.ImageTransparency = 1
					end

					v9 = nil
				elseif p2.KeyCode == Enum.KeyCode.ButtonX then
					if v9 then
						return
					end

					for _, v16 in v7 do
						if not (selectedObject and v16._Obj == selectedObject.Parent) then
							continue
						end

						if v16.Dummy then
							return
						end

						local slot = v16.Slot
						swapButtons(v16, nil)
						assert(slot, "bad s")
						GuiService.SelectedObject = v7[slot]._Obj.TextButton
						return
					end
				end
			end, false, 3001, Enum.KeyCode.ButtonB, Enum.KeyCode.ButtonX)
		end
	else
		if v9 then
			if typeof(v9) == "number" then
				v7[v9]._Obj.InnerGlow.ImageTransparency = 1
			else
				v9._Obj.InnerGlow.ImageTransparency = 1
			end

			v9 = nil
		end

		script.Parent.Hotbar.Container.More.Title.Text = "+"
		script.Parent.Hotbar.Container.More.Title.TextLabel.Text = "+"

		if flag then
			for _, v16 in v7 do
				v16._Obj.TextButton.Selectable = false
			end

			for _, v16 in v8 do
				v16._Obj.TextButton.Selectable = false
			end
		end

		if selectedObjectChangedConnection then
			selectedObjectChangedConnection:Disconnect()
			selectedObjectChangedConnection = nil
		end

		pcall(function()
			ContextActionService:UnbindAction("BackpackMovement")
		end)
		GuiService.SelectedObject = nil
	end

	updateInventory()
end)

while true do
	task.wait(60)
	local v16 = 1

	while true do
		local v17 = v6[v16]

		if not v17 then
			break
		end

		if v17[2] < os.clock() then
			v17[1]:Destroy()
			table.remove(v6, v16)
		else
			v16 += 1
		end
	end
end