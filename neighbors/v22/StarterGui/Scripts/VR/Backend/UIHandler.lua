local _ = game.Players.LocalPlayer
local _ = workspace.CurrentCamera
local vRScreen = script:WaitForChild("VRScreen")
vRScreen.SurfaceGui.Enabled = true

if workspace:FindFirstChild("VRScreen") then
	workspace.VRScreen:Destroy()
end

vRScreen:Destroy()
return true