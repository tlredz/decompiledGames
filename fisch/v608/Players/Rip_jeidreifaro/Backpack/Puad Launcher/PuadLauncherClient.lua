local parent = script.Parent

if not parent:IsA("Tool") then
	return
end

local UserInputService = game:GetService("UserInputService")
local RayVisual = require(game.ReplicatedStorage.shared.utils.RayVisual)
local raycastParams = RaycastParams.new()
raycastParams.RespectCanCollide = true
raycastParams.IgnoreWater = false
raycastParams.CollisionGroup = "Players"
raycastParams.ExcludeInstances = {
	game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait(),
	workspace.active:WaitForChild("debrisfx")
}
parent.Activated:Connect(function()
	local mouseLocation = UserInputService:GetMouseLocation()
	local viewportPointToRay = workspace.CurrentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	local raycast = RayVisual.raycast(viewportPointToRay.Origin, viewportPointToRay.Direction * 256, raycastParams)

	if raycast then
		parent.Fire:FireServer(raycast.Position)
	else
		parent.Fire:FireServer(viewportPointToRay.Origin + viewportPointToRay.Direction * 256)
	end
end)