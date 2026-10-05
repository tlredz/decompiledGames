local UserInputService = game:GetService("UserInputService")
local React = require(game.ReplicatedStorage.Packages.React)
local useStateMachine = require(game.ReplicatedStorage.React.Hooks.useStateMachine)
local useGuiServiceSelect = require(game.ReplicatedStorage.React.Hooks.useGuiServiceSelect)
local useOnScreenEffect = require(game.ReplicatedStorage.React.Hooks.useOnScreenEffect)
return function(p, flag: boolean, flag2: boolean, p2: string, items, p3)
	local state, setState = React.useState(nil)
	local v, v2, v3 = useStateMachine(state, p, items)
	local v4 = React.useMemo(function()
		local result = {}

		for k, _ in pairs(items) do
			local v5

			if p2 and typeof(k) == "string" then
				v5 = k .. "_" .. p2
			else
				v5 = tostring(k)
			end

			result[k] = v5
		end

		table.freeze(result)
		return result
	end, { items, p2 })
	local v5

	if p3 and p3[v] then
		v5 = p3[v]
	elseif p2 and typeof(v) == "string" then
		v5 = v .. "_" .. p2
	else
		v5 = v
	end

	useOnScreenEffect(function()
		local inputEndedConnection = nil

		if flag and not flag2 and v2 then
			-- equivalent calls inferred from this helper; original call sites unknown
			local function tryApplyKeyCode(keyCode)
				if v2[keyCode] then
					setState(keyCode)
				end
			end

			inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
				tryApplyKeyCode(input.KeyCode) -- equivalent call inferred; original call site unknown
			end)
		elseif state then
			setState(nil)
		end

		return function()
			if inputEndedConnection then
				inputEndedConnection:Disconnect()
			end
		end
	end, { flag, flag2, v2 })
	useGuiServiceSelect(v5, flag)

	if state then
		setState(nil)
	end

	return v, v4, v2, v3
end