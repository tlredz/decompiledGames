local parent = script.Parent
local parent2 = parent.Parent.Parent
local SFX = game.SoundService:WaitForChild("SFX")
parent.Activated:Connect(function()
	SFX.Click:Play()
	parent2.Visible = false
end)