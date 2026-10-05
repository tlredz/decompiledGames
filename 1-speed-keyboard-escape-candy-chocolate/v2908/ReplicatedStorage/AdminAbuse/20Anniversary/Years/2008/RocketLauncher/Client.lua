local mouseLoc = script.Parent:WaitForChild("MouseLoc")
local mouse = game.Players.LocalPlayer:GetMouse()

mouseLoc.OnClientInvoke = function()
	return mouse.Hit.p
end