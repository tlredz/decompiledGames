local ContextActionService = game:GetService("ContextActionService")
local React = require(game.ReplicatedStorage.Packages.React)
local useLastInput = require(game.ReplicatedStorage.React.Hooks.useLastInput)
return function(data)
	local v = useLastInput()
	local state, setState = React.useState(nil)
	local ref = React.useRef(1)
	React.useEffect(function()
		setState(nil)
	end, { v })
	React.useEffect(function()
		ContextActionService:BindActionAtPriority(data.ActionName, function(actionName: string, inputState, inputObject)
			if actionName ~= data.ActionName or inputState ~= Enum.UserInputState.End or data.InputType == "Gamepad" and inputObject.UserInputType ~= Enum.UserInputType.Gamepad1 then
				return Enum.ContextActionResult.Pass
			end

			ref.current += 1
			setState({
				ActionName = actionName,
				InputState = inputState,
				InputObject = inputObject,
				UID = ref.current
			})
			return Enum.ContextActionResult.Sink
		end, false, data.Priority, table.unpack(data.Triggers))
		return function()
			ContextActionService:UnbindAction(data.ActionName)
		end
	end, {
		v,
		data.ActionName,
		data.InputType,
		data.Priority,
		data.Triggers
	})
	return state
end