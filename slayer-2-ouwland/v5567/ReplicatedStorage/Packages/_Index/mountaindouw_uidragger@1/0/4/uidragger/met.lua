local Met = {}
local GamepadService = game:GetService("GamepadService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
require(script.Parent.UiDraggerSettings)
Met.__index = Met

function Met:ClearAllConnections()
	if self.Connections ~= nil then
		for _, connection in ipairs(self.Connections) do
			connection:Disconnect()
		end

		self.Connections = nil
	end
end

function Met:Connect(object, callback)
	local connection = object:Connect(callback)

	if self.Connections == nil then
		self.Connections = {}
	end

	table.insert(self.Connections, connection)
	return connection
end

function Met:Recalibrate(UI, dragSettings)
	if UI then
		self.UI = UI
	end

	self.DragSettings = dragSettings
	self:ClearAllConnections()
end

local function getPlatfornm()
	if not RunService:IsRunning() then
		return 1
	end

	if game.Players.LocalPlayer:FindFirstChild("PlayerGui") ~= nil and game.Players.LocalPlayer.PlayerGui:FindFirstChild("TouchGui") ~= nil and game.Players.LocalPlayer.PlayerGui.TouchGui:FindFirstChild("TouchControlFrame") ~= nil and game.Players.LocalPlayer.PlayerGui.TouchGui.TouchControlFrame:FindFirstChild("JumpButton") ~= nil then
		return 2
	end

	if UserInputService.GamepadEnabled ~= true then
		return 1
	end

	local lastInputType = UserInputService:GetLastInputType()

	if lastInputType ~= Enum.UserInputType.Keyboard and lastInputType.Name:sub(1, 5) ~= "Mouse" then
		if UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonY) == "ButtonTriangle" then
			return 4
		end

		return 3
	end

	return 1
end

function Met:GlidePosition(p2)
	self.CurrentValues.CurrentPosition.X += p2.X
	self.CurrentValues.CurrentPosition.Y += p2.Y
end

function Met:UpdatePosition(point: Vector2)
	if point == nil then
		return
	end

	self.CurrentValues.CurrentPosition.X = point.X - self.CurrentValues.Offset.X
	self.CurrentValues.CurrentPosition.Y = point.Y - self.CurrentValues.Offset.Y
end

function Met:UpdatePositionWithInset(point: Vector2, p2: number)
	if point == nil then
		return
	end

	self.CurrentValues.CurrentPosition.X = point.X - self.CurrentValues.Offset.X
	self.CurrentValues.CurrentPosition.Y = point.Y - self.CurrentValues.Offset.Y - p2
end

local v = {
	X = 0,
	Y = 0
}

function Met:Start(p, p2)
	if p ~= nil then
		self:Recalibrate(p, p2)
	end

	if self.UI == nil then
		return
	end

	self:ClearAllConnections()
	local absolutePosition = self.UI.AbsolutePosition
	local absoluteSize = self.UI.AbsoluteSize
	local Y = GuiService:GetGuiInset().Y

	if self.CurrentValues == nil then
		self.CurrentValues = {
			Position = {
				X = absolutePosition.X,
				Y = absolutePosition.Y
			},
			Size = {
				X = absoluteSize.X,
				Y = absoluteSize.Y
			},
			Offset = {
				X = 0,
				Y = 0
			}
		}
	else
		self.CurrentValues.Position.X = absolutePosition.X
		self.CurrentValues.Position.Y = absolutePosition.Y
		self.CurrentValues.Size.X = absoluteSize.X
		self.CurrentValues.Size.Y = absoluteSize.Y
		self.CurrentValues.Offset.X = 0
		self.CurrentValues.Offset.Y = 0
	end

	local mouseLocation = UserInputService:GetMouseLocation()
	local v2 = nil

	if self.DragSettings ~= nil and self.DragSettings.AnchorPoint ~= nil then
		if self.DragSettings.AnchorPoint == true then
			local v3 = mouseLocation - absolutePosition
			self.CurrentValues.Offset.X = v3.X
			self.CurrentValues.Offset.Y += v3.Y - Y
		else
			local v3 = absoluteSize.X * self.DragSettings.AnchorPoint.X
			local v4 = absoluteSize.Y * self.DragSettings.AnchorPoint.Y
			self.CurrentValues.Offset.X = v3
			self.CurrentValues.Offset.Y += v4
		end
	end

	self.CurrentValues.CurrentPosition = {
		X = mouseLocation.X - self.CurrentValues.Offset.X,
		Y = mouseLocation.Y - self.CurrentValues.Offset.Y - Y
	}
	local platfornm = getPlatfornm()

	if platfornm == 1 or platfornm == 2 then
		self:Connect(UserInputService.InputEnded, function(p3)
			if p3.UserInputType == Enum.UserInputType.MouseButton1 or p3.UserInputType == Enum.UserInputType.Touch then
				self:UpdatePosition(p3.Position)
				self:End(self.CurrentValues.CurrentPosition)
			end
		end)
		self:Connect(UserInputService.InputChanged, function(p3)
			if p3.UserInputType == Enum.UserInputType.MouseMovement or p3.UserInputType == Enum.UserInputType.Touch then
				self:UpdatePosition(p3.Position)
				self.Changed:Fire(self.CurrentValues.CurrentPosition)
			end
		end)
	else
		local gamepadCursorEnabled = GamepadService.GamepadCursorEnabled

		if not gamepadCursorEnabled then
			v2 = v
		end

		local v3 = {
			X = 0,
			Y = 0
		}
		self:Connect(UserInputService.InputEnded, function(p3)
			if p3.KeyCode == Enum.KeyCode.ButtonA then
				local currentPosition = self.CurrentValues.CurrentPosition
				local v5

				if not gamepadCursorEnabled then
					v5 = v3 or nil
				end

				self:End(currentPosition, v5)
			end
		end)
		self:Connect(UserInputService.InputChanged, function(data)
			if data.UserInputType == Enum.UserInputType.Gamepad1 and data.KeyCode == Enum.KeyCode.Thumbstick1 then
				v3.X = data.Position.X
				v3.Y = -data.Position.Y
			end
		end)
		self:Connect(RunService.RenderStepped, function()
			if gamepadCursorEnabled then
				self:UpdatePositionWithInset(UserInputService:GetMouseLocation(), Y)
				self.Changed:Fire(self.CurrentValues.CurrentPosition)
			elseif (v3.X ^ 2 + v3.Y ^ 2) ^ 0.5 > 0.25 then
				self:GlidePosition(v3)
				self.Changed:Fire(self.CurrentValues.CurrentPosition, v3)
			end
		end)
	end

	self.Started:Fire(self.CurrentValues.CurrentPosition, v2)
	return self.CurrentValues.CurrentPosition, v2
end

function Met:End(p, _)
	self.Ended:Fire(p)
	self:ClearAllConnections()
end

function Met:AddThread(thread)
	if self.Thread ~= nil then
		if self.Thread.Remove == nil then
			local index = table.find(self.Thread, self)

			if index ~= nil then
				table.remove(self.Thread, index)
			end
		else
			self.Thread:Remove(self)
		end
	end

	if thread == nil then
		return self
	end

	if thread.Add then
		thread:Add(self)
	else
		table.insert(thread, self)
	end

	self.Thread = thread
	return self
end

function Met:Destroy()
	if self.Changed ~= nil then
		self.Changed:Destroy()
		self.Changed = nil
	end

	if self.Ended ~= nil then
		self.Ended:Destroy()
		self.Ended = nil
	end

	if self.Started ~= nil then
		self.Started:Destroy()
		self.Started = nil
	end

	self.UI = nil
	self:Recalibrate()

	if self.Thread ~= nil then
		if self.Thread.Remove ~= nil then
			self.Thread:Remove(self)
			return
		end

		local index = table.find(self.Thread, self)

		if index ~= nil then
			table.remove(self.Thread, index)
		end
	end
end

return Met