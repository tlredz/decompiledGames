local parent = script.Parent
parent.CanBeDropped = false
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or input.KeyCode ~= Enum.KeyCode.Backspace then
		return
	end

	parent.EatRemote:InvokeServer("Display")
end)
local activatedConnection = nil
parent.Equipped:connect(function()
	activatedConnection = parent.Activated:connect(function()
		parent.EatRemote:InvokeServer("Display")
	end)
end)
parent.Unequipped:connect(function()
	if activatedConnection then
		activatedConnection:Disconnect()
	end
end)
local Anims = require(game.ReplicatedStorage.Util.Anims)
Anims:Preload("FruitEat")