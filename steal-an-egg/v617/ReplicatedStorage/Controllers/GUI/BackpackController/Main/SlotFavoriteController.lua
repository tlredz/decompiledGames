local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Trove = require(ReplicatedStorage.Packages.Trove)
local SlotFavoriteController = {}
SlotFavoriteController.__index = SlotFavoriteController

local function visible(parent)
	local screenGui = parent:FindFirstAncestorWhichIsA("ScreenGui")

	if screenGui == nil or not screenGui.Enabled then
		return false
	end

	while not parent:IsA("GuiObject") or parent.Visible do
		parent = parent.Parent

		if parent == screenGui then
			return true
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pointerPosition()
	local guiInset = GuiService:GetGuiInset()
	return UserInputService:GetMouseLocation() - guiInset
end

local function inside(p, p2)
	local absolutePosition = p.AbsolutePosition
	local v = absolutePosition + p.AbsoluteSize
	return p2.X >= absolutePosition.X and p2.Y >= absolutePosition.Y and p2.X <= v.X and p2.Y <= v.Y
end

function SlotFavoriteController.new(instance)
	local trove = Trove.new()
	local object = setmetatable({
		Entries = {},
		Trove = trove,
		PressTrove = trove:Extend()
	}, SlotFavoriteController)
	trove:Connect(UserInputService.InputBegan, function(p)
		if p.KeyCode ~= Enum.KeyCode.ButtonL2 then
			return
		end

		local selectedObject = GuiService.SelectedObject
		local entry = object.Entries[selectedObject]
		local v2 = entry and entry.GetTool()

		if object:_canFavorite(selectedObject, entry, v2) then
			object:Cancel()
			entry.OnFavorite(v2)
		end
	end)
	trove:Connect(UserInputService.InputEnded, function(p)
		local press = object.Press

		if not press or p.UserInputType ~= Enum.UserInputType.MouseButton2 then
			return
		end

		local v2

		if p.UserInputState == Enum.UserInputState.Cancel then
			v2 = false
		else
			v2 = object:_valid(press)
		end

		object:Cancel()

		if v2 then
			press.Entry.OnFavorite(press.Tool)
		end
	end)
	trove:Connect(UserInputService.WindowFocusReleased, function()
		object:Cancel()
	end)
	trove:Connect(GuiService.MenuOpened, function()
		object:Cancel()
	end)

	if instance then
		trove:Connect(instance.Destroying, function()
			object:Destroy()
		end)
	end

	return object
end

function SlotFavoriteController:_canFavorite(p2, p3, p4)
	local v

	if p3 == nil or self.Entries[p2] ~= p3 then
		return false
	else
		v = visible(p2)

		if v then
			if p3.GetTool() == p4 then
				return (p3.CanFavorite(p4))
			else
				return false
			end
		end
	end

	return v
end

function SlotFavoriteController:_valid(data)
	if not self:_canFavorite(data.Button, data.Entry, data.Tool) then
		return false
	end

	local v = pointerPosition() -- equivalent call inferred; original call site unknown
	local button = data.Button
	local absolutePosition = button.AbsolutePosition
	local v2 = absolutePosition + button.AbsoluteSize
	return v.X >= absolutePosition.X and v.Y >= absolutePosition.Y and v.X <= v2.X and v.Y <= v2.Y and (v - data.Position).Magnitude <= 8
end

function SlotFavoriteController:_begin(button, p2)
	self:Cancel()
	local entry = self.Entries[button]

	if not entry then
		return
	end

	local press = {
		Button = button,
		Entry = entry,
		Tool = entry.GetTool(),
		Position = pointerPosition()
	}

	if not self:_valid(press) then
		return
	end

	self.Press = press
	self.PressTrove:Connect(RunService.Heartbeat, function()
		if p2.UserInputState == Enum.UserInputState.Cancel or not self:_valid(press) then
			self:Cancel()
		end
	end)
end

function SlotFavoriteController:Register(instance, p)
	self:Unregister(instance)
	local clone = table.clone(p)
	clone.Trove = self.Trove:Extend()
	self.Entries[instance] = clone
	clone.Trove:Connect(instance.InputBegan, function(p2)
		if p2.UserInputType == Enum.UserInputType.MouseButton2 then
			self:_begin(instance, p2)
		end
	end)
	clone.Trove:Connect(instance.Destroying, function()
		self:Unregister(instance)
	end)
end

function SlotFavoriteController:Unregister(p)
	local entry = self.Entries[p]

	if not entry then
		return
	end

	if self.Press and self.Press.Button == p then
		self:Cancel()
	end

	self.Entries[p] = nil
	self.Trove:Remove(entry.Trove)
end

function SlotFavoriteController:Cancel()
	self.Press = nil
	self.PressTrove:Clean()
end

function SlotFavoriteController:Destroy()
	self:Cancel()
	self.Trove:Destroy()
	table.clear(self.Entries)
end

return SlotFavoriteController