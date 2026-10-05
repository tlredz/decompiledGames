local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local module = require("../../roblox_packages/vide")
local source = module.source
local action = module.action
local effect = module.effect
local read = module.read
local cleanup = module.cleanup
return function(data)
	local enabled = data.enabled or source(true)
	local v = source(nil)
	effect(function()
		if read(enabled) == false then
			if data.hover then
				data.hover(false)
			end

			if data.hold then
				data.hold(false)
			end
		end
	end)

	local function input_ended(data2)
		if not read(enabled) or data2 ~= v() then
			return
		end

		v(nil)

		if data.hold then
			data.hold(false)
		end

		if data.input then
			data.input(data2)
		end
	end

	local function input_began(data2)
		if data2.KeyCode ~= data.keycode and data2.UserInputType ~= Enum.UserInputType.MouseButton1 and data2.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		if not read(enabled) or data2.UserInputState ~= Enum.UserInputState.Begin then
			return
		end

		v(data2)

		if data.hold then
			data.hold(true)
		end

		if data.input then
			data.input(data2)
		end

		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function(_)
			if data.input then
				data.input(data2)
			end

			if v() ~= data2 then
				input_ended(data2)
				heartbeatConnection:Disconnect()
			end
		end)
	end

	local function input_changed(p)
		if not read(enabled) or p ~= v() then
			return
		end

		assert(data.input)
		data.input(p)
	end

	return action(function(button)
		assert(button:IsA("GuiButton"), "instance has no input events")
		cleanup(button.InputBegan:Connect(input_began))
		cleanup(button.InputEnded:Connect(input_ended))
		cleanup(UserInputService.InputEnded:Connect(input_ended))
		effect(function()
			button.Active = read(enabled)
		end)

		if data.clicked then
			local clicked = data.clicked
			cleanup(button.Activated:Connect(clicked))

			if data.keycode then
				cleanup(UserInputService.InputBegan:Connect(function(input, gameProcessed)
					if gameProcessed then
						return
					end

					if input.KeyCode == data.keycode then
						clicked(input)
					end
				end))
			end
		end

		if data.input then
			cleanup(button.InputChanged:Connect(input_changed))
		end

		if data.wheel then
			local wheel = data.wheel
			cleanup(button.MouseWheelForward:Connect(function()
				wheel(-1)
			end))
			cleanup(button.MouseWheelBackward:Connect(function()
				wheel(1)
			end))
		end

		if data.hover then
			local hover = data.hover
			cleanup(button.MouseEnter:Connect(function()
				if read(enabled) == false then
					return
				end

				hover(true)
			end))
			cleanup(button.MouseLeave:Connect(function()
				if read(enabled) == false then
					return
				end

				hover(false)
			end))
		end
	end)
end