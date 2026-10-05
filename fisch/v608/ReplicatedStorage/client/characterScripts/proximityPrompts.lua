local ProximityPromptService = game:GetService("ProximityPromptService")
local humanoid = script.Parent:WaitForChild("Humanoid")
humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
	if humanoid.Sit then
		ProximityPromptService.Enabled = false
	else
		ProximityPromptService.Enabled = true
	end
end)