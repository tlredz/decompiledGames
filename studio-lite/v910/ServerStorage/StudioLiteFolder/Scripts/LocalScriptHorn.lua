local mouse = game.Players.LocalPlayer:GetMouse()
script.Parent:WaitForChild("src")
src = script.Parent.src.Value
mouse.KeyDown:connect(function(p)
	if p == "h" then
		src:Play()
	end
end)
mouse.KeyUp:connect(function(p)
	if p == "h" then
		src:Stop()
	end
end)
src.Parent.ChildRemoved:connect(function(p)
	if p.Name == "SeatWeld" then
		src:Stop()
		script.Parent:Destroy()
	end
end)