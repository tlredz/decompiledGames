local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local legacyUiLoader = require(ReplicatedStorage.client.legacy.legacyUiLoader)
local confirmation = legacyUiLoader.PlayerGui.backpack.inventory.Confirmation
local Confirmation = {
	changed = function(callback)
		callback(confirmation.Visible)
		return confirmation:GetPropertyChangedSignal("Visible"):Connect(function()
			callback(confirmation.Visible)
		end)
	end
}
local v = nil

function Confirmation.prompt(p)
	v = p
	confirmation.Visible = true
	confirmation.Title.Text = p.text

	if v.no then
		confirmation.Confirm.Text = "Confirm"
		confirmation.Cancel.Visible = true
	else
		confirmation.Confirm.Text = "Okay"
		confirmation.Cancel.Visible = false
	end

	v = p
	return confirmation.Title
end

function Confirmation.cancel()
	confirmation.Visible = false

	if v.no then
		v.no()
	end
end

confirmation.Confirm.Activated:Connect(function()
	confirmation.Visible = false
	v.yes()
end)
confirmation.Cancel.Activated:Connect(function()
	confirmation.Visible = false

	if v.no then
		v.no()
	end
end)
UserInputService.InputBegan:Connect(function(input)
	if (input.KeyCode == Enum.KeyCode.KeypadEnter or input.KeyCode == Enum.KeyCode.Return) and confirmation.Visible then
		confirmation.Visible = false
		v.yes()
	end
end)
return Confirmation