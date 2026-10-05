local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local Signal = require(ReplicatedStorage.Modules.Signal)
local WeaponStatusHandler = require(Players.LocalPlayer.PlayerScripts.Modules.WeaponStatusHandler)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules.UILibrary)
local dropdownButton = Players.LocalPlayer.PlayerScripts.UserInterface.DropdownButton
local dropdownSlot = Players.LocalPlayer.PlayerScripts.UserInterface.DropdownSlot
local _ = {
	ReleaseRatio = 1.025
}
local DropdownSlot = {}
DropdownSlot.__index = DropdownSlot

function DropdownSlot.new(reference, options, value)
	assert(typeof(reference) == "Instance", "Argument 1 invalid, expected a valid UI element")
	assert(typeof(options) == "table", "Argument 2 invalid, expected a table")
	local self = setmetatable({}, DropdownSlot)
	self.Selected = Signal.new()
	self.Frame = dropdownSlot:Clone()
	self.Background = self.Frame:WaitForChild("Background")
	self.List = self.Frame:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self._destroyed = false
	self._reference = reference
	self._options = options
	self._max_options = value or 5
	self._connections = {}
	self._selected = false
	self:_Init()
	return self
end

function DropdownSlot:Cancel()
	self:_Select(nil)
end

function DropdownSlot:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true

	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self.Selected:Destroy()
	pcall(self.Frame.Destroy, self.Frame)
end

function DropdownSlot:_Select(...)
	if self._selected then
		return
	end

	self._selected = true
	self.Selected:Fire(...)
end

function DropdownSlot:_Update()
	local screenPointToPosition = UILibrary:ScreenPointToPosition(self._reference.AbsolutePosition)
	local absoluteSize = self._reference.AbsoluteSize
	local v = absoluteSize.Y / absoluteSize.X
	self.Frame.Position = UDim2.new(
		0,
		screenPointToPosition.X,
		0,
		(math.clamp(
			screenPointToPosition.Y,
			20,
			(math.max(
				20,
				UILibrary.MainGui.AbsoluteSize.Y + UILibrary.MainGui.AbsolutePosition.Y - self.Frame.AbsoluteSize.Y - 20
			))
		))
	)
	self.Frame.Size = UDim2.new(0, absoluteSize.X, 0, absoluteSize.Y)
	self.Container.Size = UDim2.new(1, 0, v, 0)
end

function DropdownSlot:_Setup()
	self.Background.Size = UDim2.new(1, 10, math.min(self._max_options, #self._options), 10)
	self.List.Size = UDim2.new(1, 0, self._max_options, 0)
	self.Layout.CellSize = UDim2.new(1, 0, 1, 0)

	for _, _option in pairs(self._options) do
		local text = tostring(_option)
		local clone = dropdownButton:Clone()
		clone.Button.Title.Text = text
		clone.Parent = self.Container
		ButtonEffect:Add(clone.Button, nil, {
			ReleaseRatio = UDim2.new(0, -3, 0, -3),
			HoverRatio = UDim2.new(0, -3, 0, -3),
			PressRatio = UDim2.new(0, -10, 0, -10)
		})
		WeaponStatusHandler:ApplyItemStatusToText(
			clone.Button.Title,
			ItemLibrary.Items[text] and ItemLibrary.Items[text].Status
		)
		local v2 = _option
		clone.Button.MouseButton1Click:Connect(function()
			self:_Select(v2)
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function hover(visible)
			clone.Button.Hovering.Visible = visible
			clone.Button.Title.TextColor3 = visible and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
		end

		local v4 = clone
		clone.MouseEnter:Connect(function()
			hover(true) -- equivalent call inferred; original call site unknown
		end)
		local v5 = clone
		clone.MouseLeave:Connect(function()
			v5.Button.Hovering.Visible = false
			v5.Button.Title.TextColor3 = Color3.fromRGB(0, 0, 0)
		end)
		clone.Button.Hovering.Visible = false
		clone.Button.Title.TextColor3 = Color3.fromRGB(0, 0, 0)
	end

	self.Frame.Parent = UILibrary.MainGui
end

function DropdownSlot:_Init()
	self.Selected:Connect(function()
		task.defer(self.Destroy, self)
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
	end)
	self.Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_Update()
	end)
	table.insert(self._connections, self._reference.AncestryChanged:Connect(function()
		if not (Players.LocalPlayer:FindFirstChild("PlayerGui") and self._reference:IsDescendantOf(Players.LocalPlayer.PlayerGui)) then
			self.Selected:Fire(nil)
		end
	end))
	table.insert(self._connections, self._reference:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_Update()
	end))
	table.insert(self._connections, self._reference:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_Update()
	end))
	table.insert(self._connections, UserInputService.InputBegan:Connect(function(input, _)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch and input.KeyCode ~= Enum.KeyCode.ButtonA then
			return
		end

		if not UILibrary:IsMouseWithinBounds(self.Background.AbsolutePosition, self.Background.AbsoluteSize) then
			self.Selected:Fire(nil)
		end
	end))
	self:_Setup()
	self:_Update()
end

return DropdownSlot