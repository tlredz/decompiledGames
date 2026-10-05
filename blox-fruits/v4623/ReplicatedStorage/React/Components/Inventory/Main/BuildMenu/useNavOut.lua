local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local React = require(game.ReplicatedStorage.Packages.React)
local useLastInput = require(game.ReplicatedStorage.React.Hooks.useLastInput)
return function(p, callback, p2)
	local v = useLastInput()
	React.useEffect(function()
		if v == "Gamepad" then
			local current = p2.current
			local count = 0

			if current then
				local function getIfSelected()
					if current == GuiService.SelectedObject then
						return true
					elseif GuiService.SelectedObject == nil then
						return false
					else
						return GuiService.SelectedObject:IsDescendantOf(current) == true
					end
				end

				local v2

				if current == GuiService.SelectedObject then
					v2 = true
				elseif GuiService.SelectedObject == nil then
					v2 = false
				else
					v2 = GuiService.SelectedObject:IsDescendantOf(current) == true
				end

				local inputBeganConnection = nil

				-- equivalent calls inferred from this helper; original call sites unknown
				local function tryHookListener()
					count = 0

					if inputBeganConnection then
						inputBeganConnection:Disconnect()
					end

					inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
						if input.KeyCode == p then
							count += 1

							if count >= 2 then
								callback()
							end
						end
					end)
				end

				if v2 then
					tryHookListener() -- equivalent call inferred; original call site unknown
				end

				local selectedObjectChangedConnection = GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
					local v3

					if current == GuiService.SelectedObject then
						v3 = true
					elseif GuiService.SelectedObject == nil then
						v3 = false
					else
						v3 = GuiService.SelectedObject:IsDescendantOf(current) == true
					end

					if v3 then
						tryHookListener() -- equivalent call inferred; original call site unknown
					elseif inputBeganConnection then
						inputBeganConnection:Disconnect()
					end
				end)
				return function()
					selectedObjectChangedConnection:Disconnect()

					if inputBeganConnection then
						inputBeganConnection:Disconnect()
					end
				end
			end
		end

		return function() end
	end, { p2.current, v })
end