local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GamepadService = game:GetService("GamepadService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local Signal = require(ReplicatedStorage.Modules.Signal)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules.UILibrary)
local EmoteWheelSlot = require(script:WaitForChild("EmoteWheelSlot"))
local emoteWheel = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("EmoteWheel")
local v = 6.283185307179586 / CONSTANTS.MAX_EQUIPPABLE_EMOTES
local v2 = v * -0.5
local EmoteWheel = {}
EmoteWheel.__index = EmoteWheel

function EmoteWheel.new()
	local self = setmetatable({}, EmoteWheel)
	self.EmoteKeyPicked = Signal.new()
	self.EmoteWheelSlotHighlighted = Signal.new()
	self.Frame = emoteWheel:Clone()
	self._is_enabled = false
	self._connections = {}
	self._input_connections = {}
	self._emote_wheel_slots = {}
	self._finish_picking_bindable = nil
	self._last_highlighted_wheel_slot = nil
	self._generate_hash = 0
	self:_Init()
	return self
end

function EmoteWheel:GetLastHighlightedSlot()
	return self._last_highlighted_wheel_slot
end

function EmoteWheel:GetEmoteWheelSlot(p2)
	return self._emote_wheel_slots[p2]
end

function EmoteWheel:GetEmoteSlotFromScreenPosition(p2, p3)
	local v3 = p2 or UILibrary:GetMouseLocation()
	local v4 = self.Frame.AbsolutePosition + self.Frame.AbsoluteSize / 2

	if (v3 - v4).Magnitude <= self.Frame.AbsoluteSize.X * 0.1 then
		return
	end

	local v5 = math.atan2(v3.Y - v4.Y, v3.X - v4.X) + 1.5707963267948966
	local v6 = { v5 - 6.283185307179586, v5, v5 + 6.283185307179586 }

	for k, _emote_wheel_slot in pairs(self._emote_wheel_slots) do
		if not (_emote_wheel_slot.EquippedData or p3) then
			continue
		end

		for _, v7 in pairs(v6) do
			local v8 = tonumber(k)
			local v9 = v * (v8 - 1) + v2
			local v10 = v * v8 + v2

			if v9 <= v7 and v7 < v10 then
				return _emote_wheel_slot, k
			end
		end
	end
end

function EmoteWheel:SetEnabled(is_enabled)
	self:_Clear()
	self._is_enabled = is_enabled

	if not self._is_enabled then
		return
	end

	table.insert(self._connections, PlayerDataController:GetDataChangedSignal("EquippedEmotes"):Connect(function()
		self:_Generate()
	end))
	task.spawn(self._Generate, self, true)
end

function EmoteWheel:HighlightSlot(last_highlighted_wheel_slot)
	self._last_highlighted_wheel_slot = last_highlighted_wheel_slot

	for _, _emote_wheel_slot in pairs(self._emote_wheel_slots) do
		_emote_wheel_slot:SetHighlighted(_emote_wheel_slot == self._last_highlighted_wheel_slot)
	end

	self.EmoteWheelSlotHighlighted:Fire()
end

function EmoteWheel:StopInputs()
	for _, _input_connection in pairs(self._input_connections) do
		_input_connection:Disconnect()
	end

	self._input_connections = {}

	if self._finish_picking_bindable then
		self._finish_picking_bindable:Destroy()
		self._finish_picking_bindable = nil
	end

	self:HighlightSlot(nil)
end

function EmoteWheel:FinishInputs()
	if self._finish_picking_bindable then
		self._finish_picking_bindable:Fire()
	end
end

function EmoteWheel:StartInputs(p)
	self:StopInputs()
	self._finish_picking_bindable = Instance.new("BindableEvent")
	local v3 = nil
	local v4 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function finish()
		local emoteSlotFromScreenPosition, v5 = self:GetEmoteSlotFromScreenPosition(v3, p)

		if emoteSlotFromScreenPosition then
			if not p then
				v5 = emoteSlotFromScreenPosition.EquippedData and v5
			end
		else
			v5 = emoteSlotFromScreenPosition
		end

		self.EmoteKeyPicked:Fire(v5)
	end

	self._finish_picking_bindable.Event:Connect(finish)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function set_last_mouse_location(mouseLocation, p2)
		local emoteSlotFromScreenPosition, _ = self:GetEmoteSlotFromScreenPosition(mouseLocation, p)

		if emoteSlotFromScreenPosition or not p2 then
			v3 = mouseLocation
			self:HighlightSlot(emoteSlotFromScreenPosition)
		end
	end

	table.insert(self._input_connections, UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonA then
			v4 = true
		end
	end))
	table.insert(self._input_connections, UserInputService.InputEnded:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonA) and v4 then
			finish() -- equivalent call inferred; original call site unknown
		end
	end))
	table.insert(self._input_connections, UserInputService.InputChanged:Connect(function(input)
		if ControlsController.CurrentControls ~= "Gamepad" then
			return
		end

		if input.KeyCode == Enum.KeyCode.Thumbstick1 or input.KeyCode == Enum.KeyCode.Thumbstick2 then
			local _ThumbstickPositionToScreenPosition = self:_ThumbstickPositionToScreenPosition(input.Position)
			local emoteSlotFromScreenPosition, _ = self:GetEmoteSlotFromScreenPosition(
				_ThumbstickPositionToScreenPosition,
				p
			)

			if not emoteSlotFromScreenPosition then
				return
			end

			v3 = _ThumbstickPositionToScreenPosition
			self:HighlightSlot(emoteSlotFromScreenPosition)
		end
	end))
	table.insert(self._input_connections, RunService.RenderStepped:Connect(function()
		if ControlsController.CurrentControls == "Gamepad" then
			if GamepadService.GamepadCursorEnabled then
				GamepadService:DisableGamepadCursor()
			end
		else
			local mouseLocation, v5 = UILibrary:GetMouseLocation()
			set_last_mouse_location(mouseLocation, v5) -- equivalent call inferred; original call site unknown
		end
	end))
end

function EmoteWheel:Destroy()
	self:_Clear()
	self:SetEnabled(false)
	self:StopInputs()
	self.Frame:Destroy()
	self.EmoteKeyPicked:Destroy()
	self.EmoteWheelSlotHighlighted:Destroy()
end

function EmoteWheel._NormalizeAngle(_, p)
	if p < 0 then
		return p + 6.283185307179586
	end

	if p > 6.283185307179586 then
		p -= 6.283185307179586
	end

	return p
end

function EmoteWheel:_ThumbstickPositionToScreenPosition(data)
	local v3 = self.Frame.AbsolutePosition + self.Frame.AbsoluteSize / 2

	if data.Magnitude <= 0.5 then
		return v3
	end

	return v3 + Vector2.new(data.X, -data.Y) * 1000
end

function EmoteWheel:_ClearSlots()
	for _, _emote_wheel_slot in pairs(self._emote_wheel_slots) do
		_emote_wheel_slot:Destroy()
	end

	self._emote_wheel_slots = {}
end

function EmoteWheel:_Clear()
	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self._connections = {}
	self:_ClearSlots()
end

function EmoteWheel:_Generate(p)
	self._generate_hash += 1
	local _generate_hash = self._generate_hash
	local names = {}

	for k, _emote_wheel_slot in pairs(self._emote_wheel_slots) do
		names[k] = _emote_wheel_slot.EquippedData and _emote_wheel_slot.EquippedData.Name or nil
	end

	self:_ClearSlots()
	local equippedEmotes = PlayerDataController:Get("EquippedEmotes")
	local v3 = 360 / CONSTANTS.MAX_EQUIPPABLE_EMOTES

	for i = 1, CONSTANTS.MAX_EQUIPPABLE_EMOTES do
		if _generate_hash ~= self._generate_hash then
			break
		end

		local v4 = tostring(i)
		local v5 = EmoteWheelSlot.new(equippedEmotes[v4])
		v5:SetRotation(v3 * 0.5 + (i - 1) * v3 + math.deg(v2))
		v5.Frame.Parent = self.Frame.Slots
		self._emote_wheel_slots[v4] = v5

		if p then
			continue
		end

		local v6 = names[v4]
		local v7

		if v5.EquippedData then
			v7 = v5.EquippedData.Name or nil
		end

		if v6 == v7 then
			continue
		end

		v5:EquipBounceEffect()
		task.defer(self.HighlightSlot, self, v5)
	end
end

function EmoteWheel:_Init() end

return EmoteWheel