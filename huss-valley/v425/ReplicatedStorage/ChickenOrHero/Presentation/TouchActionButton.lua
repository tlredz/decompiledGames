local UserInputService = game:GetService("UserInputService")
local TouchActionButton = {}

function TouchActionButton.bind(data, callback)
	local inputBeganConnection = data.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch and data.Visible and data.Interactable then
			callback(true)
		end
	end)
	local activatedConnection = data.Activated:Connect(function(p)
		if (not p or p.UserInputType ~= Enum.UserInputType.Touch) and data.Visible and data.Interactable then
			callback(false)
		end
	end)
	return {
		Disconnect = function()
			inputBeganConnection:Disconnect()
			activatedConnection:Disconnect()
		end
	}
end

function TouchActionButton.update(state, p, p2, text)
	state.Visible = UserInputService.TouchEnabled and p

	if not state.Visible then
		return
	end

	local label = state.Label

	if p2 > 0.02 then
		text = ("%.1f"):format(p2) or text
	end

	label.Text = text
	state.BackgroundTransparency = p2 > 0.02 and 0.45 or 0.12
	state.Label.TextTransparency = p2 > 0.02 and 0.25 or 0
end

return TouchActionButton