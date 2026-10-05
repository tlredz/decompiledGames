local localPlayer = game.Players.LocalPlayer
local _ = localPlayer.PlayerGui
local Client = require(localPlayer.PlayerScripts.Client)
local ContextActionService = game:GetService("ContextActionService")
local decoratorNotice2 = Client.Interface.DecoratorNotice2
decoratorNotice2.EquipButton.MouseButton1Click:Connect(function()
	decoratorNotice2.Visible = false
end)
ContextActionService:BindActionAtPriority("CloseMissingPoster", function()
	if not decoratorNotice2.Visible then
		return Enum.ContextActionResult.Pass
	end

	decoratorNotice2.Visible = false
	return Enum.ContextActionResult.Sink
end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonB, Enum.KeyCode.ButtonA)
Client.Events.ShowDecoratorNotice:Connect(function()
	print("receive dec event")
	decoratorNotice2.Visible = true
end)
return {}