local class = {}
local v = {}
local GuiService = game:GetService("GuiService")
local GamepadService = game:GetService("GamepadService")
local UserInputService = game:GetService("UserInputService")
game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastSignal = require(ReplicatedStorage.Modules.FastSignal)
local Janitor = require(ReplicatedStorage.Modules.Janitor)
local module = require("@self/GamepadState")
local v2 = {}
local v3 = {}
class.ContainerEnabled = FastSignal.new()
class.ContainerDisabled = FastSignal.new()

function v:new()
	local v4

	if typeof(self) == "Instance" then
		v4 = self:IsA("GuiObject")
	else
		v4 = false
	end

	assert(v4, "first parameter must be a GuiObject")

	if v2[self] then
		warn((`{self} already has a Gamepad Container object!`))
	end

	local object = setmetatable({}, {
		__index = v
	})
	object.Janitor = Janitor.new()
	object.Frame = self
	object.Destroyed = false
	object.EnableButtonExit = true
	object.EnableDefaultBehavior = true
	object.EnableCursorBehavior = false
	object.Enabled = FastSignal.new()
	object.Disabled = FastSignal.new()
	object.ExitRequested = FastSignal.new()
	self.SelectionGroup = true
	self.Active = true
	self.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
	self.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
	self.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
	self.SelectionBehaviorRight = Enum.SelectionBehavior.Stop
	self:AddTag("GamepadContainerObject")
	object.Enabled:Connect(function()
		class.ContainerEnabled:Fire(object)

		if object.EnableCursorBehavior then
			task.wait()
			class:ShowCursor(object.DefaultElement or object.Frame)
		elseif object.EnableDefaultBehavior then
			task.wait()
			class:Select(object.DefaultElement or object.Frame)
		end
	end)
	object.Disabled:Connect(function()
		class.ContainerDisabled:Fire(object)

		if object.EnableCursorBehavior then
			task.wait()
			class:HideCursor()
		elseif object.EnableDefaultBehavior and not class:IsAnyContainerVisible() then
			class:HideCursor()
			class:Unselect()
		end
	end)
	object.Janitor:Add(self:GetPropertyChangedSignal("Visible"):Connect(function()
		if not module.GamepadEnabled then
			return
		end

		if object.ExitConnection then
			object.ExitConnection:Disconnect()
			object.ExitConnection = nil
		end

		if self.Visible then
			object.Enabled:Fire()
			table.insert(v3, object)
			object.ExitConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
				if not gameProcessed and input.KeyCode == Enum.KeyCode.ButtonB then
					if not object:IsAtTop() then
						return
					end

					object.ExitRequested:Fire()

					if object.EnableButtonExit then
						object:Exit()
					end
				end
			end)
		else
			if table.find(v3, object) then
				table.remove(v3, table.find(v3, object))
			end

			object.Disabled:Fire()
		end
	end))
	object.Janitor:Add(function()
		if object.ExitConnection then
			object.ExitConnection:Disconnect()
			object.ExitConnection = nil
		end

		v2[object.Frame] = nil
	end)
	object.Janitor:Add(object.Enabled)
	object.Janitor:Add(object.Disabled)
	object.Janitor:Add(object.ExitRequested)
	v2[object.Frame] = object
	return object
end

function v:IsAtTop()
	return not not self:IsVisible() and #v3 ~= 0 and v3[#v3] == self
end

function v:Exit()
	if v3[#v3] ~= self then
		return false
	end

	task.wait()
	self.Frame.Visible = false
	class:Unselect()
	return true
end

function v:IsVisible()
	if self.Frame.Visible then
		local screenGui = self.Frame:FindFirstAncestorOfClass("ScreenGui")

		if screenGui and screenGui.Enabled then
			return true
		end
	end

	return false
end

function v:Destroy()
	if self.Destroyed then
		return
	end

	self.Destroyed = true
	self.Janitor:Destroy()
	self.Janitor = nil
	self.Frame = nil
end

function class:Select(ancestor)
	if not module.GamepadEnabled then
		return
	end

	if GamepadService.GamepadCursorEnabled then
		GamepadService:DisableGamepadCursor()
		task.wait()
	end

	GuiService:Select(ancestor)
	task.wait()
	return GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(ancestor)
end

function class:Unselect()
	if not module.GamepadEnabled or GamepadService.GamepadCursorEnabled then
		return
	end

	GuiService.SelectedObject = nil
end

function class.SpecificallySelect(_, selectedObject)
	if not module.GamepadEnabled then
		return
	end

	GuiService.SelectedObject = selectedObject
end

function class:ShowCursor(p)
	if not module.GamepadEnabled then
		return
	end

	GamepadService:EnableGamepadCursor(p)
end

function class:HideCursor()
	GamepadService:DisableGamepadCursor()
end

function class.CreateGroup(_, p)
	return v.new(p)
end

function class:IsAnyContainerVisible()
	for _, v4 in next, v2, nil do
		if v4.EnableDefaultBehavior and v4:IsVisible() then
			return true
		end
	end

	return false
end

function class.GetContainers(_)
	return v2
end

function class.GetVisibleContainers(_)
	return v3
end

function class.GetHighestOrderVisibleContainer(_)
	if #v3 == 0 then
		return nil
	end

	return v3[#v3]
end

function class.GetSelected(_)
	return GuiService.SelectedObject
end

return (setmetatable(class, {
	__index = module
}))