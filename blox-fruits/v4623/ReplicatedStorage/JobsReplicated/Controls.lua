local Controls = {}
game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
game:GetService("GuiService")
local v = {}
local controlSchemes = {
	Computer = 1,
	Mobile = 2,
	Console = 4,
	ConsoleOrComputer = 5,
	Any = 4294967295
}
Controls.ControlSchemes = controlSchemes
Controls.ControlPriorities = {
	First = 0,
	UI = 1000,
	Skill = 4000,
	Tool = 5000,
	Last = 100000
}
local class = {}
class.__index = class
local v3 = {}
local v4 = {}
Controls.Translation = {}

function Controls.GetDeviceType()
	if UserInputService.GamepadEnabled then
		return controlSchemes.Console
	end

	if UserInputService.MouseEnabled then
		return controlSchemes.Computer
	end

	if UserInputService.TouchEnabled then
		return controlSchemes.Mobile
	end

	error("no controls available?")
end

function Controls.IsConsole()
	return Controls.GetDeviceType() == controlSchemes.Console
end

function Controls.IsMobile()
	return Controls.GetDeviceType() == controlSchemes.Mobile
end

function Controls:RegisterControlBindings()
	self.ActiveInputs = {}
	self.numActiveInputs = 0
	local object = setmetatable(self, class)
	object.ActiveInputs = {}
	local controlBinds = self.ControlBinds
	self.ControlBinds = {}

	for k, controlBind in controlBinds do
		object:AddBinding(k, controlBind)
	end

	if self.Name then
		v4[self.Name] = object
	end

	table.insert(v3, object)
	return object
end

function Controls.GetNamedControl(p: string)
	return v4[p]
end

function Controls:IsActive()
	return v4[self]:IsActive()
end

local v5 = {}

function class:AddBinding(button, p2)
	local _ = "BUTTON_ID" .. tostring(math.random())

	if self.ControlBinds[button] == p2 then
		return warn("re-register?")
	end

	if typeof(button) == "Instance" and button:IsA("GuiButton") and not v5[button] then
		local inputBeganConnection = nil
		v5[button] = button.Activated:Connect(function(_, _)
			if inputBeganConnection then
				return
			end

			inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then
					return
				end

				if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
					inputBeganConnection:Disconnect()
					inputBeganConnection = nil
					local v6 = nil
					v6 = {
						KeyCode = button,
						State = "Begin",
						Changed = {
							Connect = function(self, callback)
								v6.conn = input.Changed:Connect(function(p3)
									v6[p3] = input[p3]
									callback(p3)
								end)
								return {
									Disconnect = function(self)
										v6.conn:Disconnect()
									end
								}
							end
						}
					}
					InputBegan(v6, false)
					v[button] = nil
				end
			end)
		end)
		local ancestryChangedConnection = nil
		ancestryChangedConnection = button.AncestryChanged:Connect(function(_, parent)
			if not parent then
				ancestryChangedConnection:Disconnect()
				v5[button]:Disconnect()
				self.ControlBinds[button] = nil
				v5[button] = nil
			end
		end)
	end

	self.ControlBinds[button] = p2
end

function class:Match(p2, p3: number)
	for k, controlBind in self.ControlBinds do
		if bit32.band(p3, controlBind) == 0 then
			continue
		end

		local v6

		if p2.KeyCode == Enum.KeyCode.Unknown then
			v6 = p2.UserInputType
		else
			v6 = p2.KeyCode
		end

		if v6 == k then
			return true
		end
	end

	return false
end

function class:IsActive()
	local activeInputs = self.ActiveInputs

	if activeInputs then
		for _, _ in activeInputs do
			return true
		end
	end

	return false
end

function InputBegan(data, p)
	if p then
		return
	end

	local userInputType

	if data.KeyCode == Enum.KeyCode.Unknown then
		userInputType = data.UserInputType
	else
		userInputType = data.KeyCode
	end

	if typeof(data) ~= "table" then
		if not v[userInputType] then
			v[userInputType] = {}
		end

		v[userInputType][data] = true
	end

	local deviceType = Controls.GetDeviceType()
	local v6 = {}

	for _, v7 in v3 do
		if not (v7:Match(data, deviceType) and (v7.AllowSimultaneousInputs or not v7:IsActive())) then
			continue
		end

		local v8 = {}
		task.spawn(function(callback, p2, list)
			list[1] = callback(p2)
		end, v7.OnBegan, data, v8)

		if v8[1] == false then
			continue
		end

		table.insert(v6, v7)
		local activeInputs = v7.ActiveInputs

		if activeInputs then
			activeInputs[data] = {
				startTime = tick()
			}
		end
	end

	if #v6 > 0 then
		local changedConnection = nil
		changedConnection = data.Changed:Connect(function(p2)
			local v7 = data[p2]
			local v8 = v7 == Enum.UserInputState.End

			for _, v9 in v6 do
				local onChanged = v9.OnChanged

				if onChanged then
					task.spawn(onChanged, data, p2, v7)
				end

				if not v8 then
					continue
				end

				changedConnection:Disconnect()
				local onEnded = v9.OnEnded

				if onEnded then
					task.spawn(onEnded, data)
				end

				local activeInputs = v9.ActiveInputs

				if activeInputs then
					activeInputs[data] = nil
				end
			end
		end)
	end
end

UserInputService.InputBegan:Connect(InputBegan)
UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	local userInputType

	if input.KeyCode == Enum.KeyCode.Unknown then
		userInputType = input.UserInputType
	else
		userInputType = input.KeyCode
	end

	if not userInputType then
		return
	end

	if v[userInputType] then
		v[userInputType][input] = nil
	end
end)
return Controls