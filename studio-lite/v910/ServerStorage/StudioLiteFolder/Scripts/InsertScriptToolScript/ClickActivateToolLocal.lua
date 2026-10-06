local parent = script.Parent.Parent
local activateEvent = parent:WaitForChild("ActivateEvent", 99999)
local mouse = game.Players.LocalPlayer:GetMouse()
parent.Activated:Connect(function()
	activateEvent:FireServer(mouse.Hit.Position, mouse.Target)
end)