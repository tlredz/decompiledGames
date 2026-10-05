local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local React = require(game.ReplicatedStorage.Packages.React)
local Option = require(game.ReplicatedStorage.Packages.Option)
local useLastInput = require(game.ReplicatedStorage.React.Hooks.useLastInput)
return function(flag: boolean?)
	local state, setState = React.useState((Option.none()))

	local function trySetThumbstickTarget(object)
		if Option.match(state, function(p)
			return Option.match(object, function(p2)
				return p ~= p2
			end, function()
				return true
			end)
		end, function()
			return object:isSome()
		end) then
			setState(object)
		end
	end

	React.useEffect(function()
		if flag == false then
			return function() end
		end

		local inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
			if input.KeyCode ~= Enum.KeyCode.Thumbstick1 then
				return
			end

			local vector = Vector2.new(input.Position.X, input.Position.Y)

			if vector.Magnitude < 0.5 then
				trySetThumbstickTarget(Option.none())
			elseif math.abs(vector.X) > math.abs(vector.Y) then
				if vector.X > 0 then
					trySetThumbstickTarget(Option.some(Enum.KeyCode.DPadRight))
				elseif vector.X < 0 then
					trySetThumbstickTarget(Option.some(Enum.KeyCode.DPadLeft))
				else
					trySetThumbstickTarget(Option.none())
				end
			elseif vector.Y > 0 then
				trySetThumbstickTarget(Option.some(Enum.KeyCode.DPadUp))
			elseif vector.Y < 0 then
				trySetThumbstickTarget(Option.some(Enum.KeyCode.DPadDown))
			else
				trySetThumbstickTarget(Option.none())
			end
		end)
		return function()
			inputChangedConnection:Disconnect()
		end
	end, { state:asNullable(), flag })

	if not RunService:IsRunning() then
		local v = useLastInput()
		React.useEffect(function()
			if flag == false then
				return function() end
			end

			if v ~= "Gamepad" then
				return function() end
			end

			local v2 = { UserInputService.InputBegan:Connect(function(input)
					if input.KeyCode == Enum.KeyCode.Up then
						trySetThumbstickTarget(Option.some(Enum.KeyCode.DPadUp))
					elseif input.KeyCode == Enum.KeyCode.Down then
						trySetThumbstickTarget(Option.some(Enum.KeyCode.DPadDown))
					elseif input.KeyCode == Enum.KeyCode.Right then
						trySetThumbstickTarget(Option.some(Enum.KeyCode.DPadRight))
					elseif input.KeyCode == Enum.KeyCode.Left then
						trySetThumbstickTarget(Option.some(Enum.KeyCode.DPadLeft))
					end
				end), UserInputService.InputEnded:Connect(function(_)
					if state then
						for _, v3 in ipairs(UserInputService:GetKeysPressed()) do
							if v3.KeyCode == Enum.KeyCode.Right or v3.KeyCode == Enum.KeyCode.Left or v3.KeyCode == Enum.KeyCode.Up or v3.KeyCode == Enum.KeyCode.Down then
								return
							end
						end

						trySetThumbstickTarget(Option.none())
					end
				end) }
			return function()
				for _, connection in ipairs(v2) do
					connection:Disconnect()
				end
			end
		end, { state:asNullable(), v, flag })
	end

	return state:asNullable()
end