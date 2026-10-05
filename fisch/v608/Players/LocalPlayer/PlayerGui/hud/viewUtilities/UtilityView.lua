local UserInputService = game:GetService("UserInputService")
game:GetService("Players")
script.Parent.Activated:Connect(function()
	script.Parent.Parent.safezone.UtilityBoat.Visible = true
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function update()
	local preferredInput = UserInputService.PreferredInput

	if preferredInput == Enum.PreferredInput.Gamepad then
		script.Parent.Text = "[Button Y] Here To View Utilities"
	elseif preferredInput == Enum.PreferredInput.Touch then
		script.Parent.Text = "[Tap] Here To View Utilities"
	else
		script.Parent.Text = "[Click] Here To View Utilities"
	end
end

UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(update)
update() -- equivalent call inferred; original call site unknown