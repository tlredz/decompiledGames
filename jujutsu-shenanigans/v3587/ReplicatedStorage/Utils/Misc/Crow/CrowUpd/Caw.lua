local crow = game.ReplicatedStorage.Sounds.Misc.Crow
local crow2 = game.ReplicatedStorage.Animations.Misc.Crow
local animControl = script.Parent.Parent:WaitForChild("AnimControl")
local humanoidRootPart = script.Parent.Parent:WaitForChild("HumanoidRootPart")
animControl:LoadAnimation(crow2):Play(0)
script.Parent.OnClientEvent:Connect(function()
	local clone = crow["Caw" .. math.random(1, 3)]:Clone()
	clone.SoundGroup = game.SoundService.Effect
	clone.Parent = humanoidRootPart
	clone:Play()
	clone.Ended:Connect(function()
		clone:Destroy()
	end)
end)