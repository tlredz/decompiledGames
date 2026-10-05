local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local currentCamera = workspace.CurrentCamera
local Crackutils = {}

function Crackutils.CastToMouseCFrame(value: number?, p)
	local screenPointToRay = currentCamera:ScreenPointToRay(mouse.X, mouse.Y)
	local raycastResult = workspace:Raycast(screenPointToRay.Origin, screenPointToRay.Direction * (value or 1000), p)

	if raycastResult then
		return CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		)
	end

	print("Raycast failed")
	return mouse.Hit
end

function Crackutils.CastToCharacterGroundPosition(value: number?)
	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { character }
	local raycastResult = workspace:Raycast(humanoidRootPart.Position, Vector3.new(0, -(value or 10), 0), raycastParams)

	if raycastResult then
		return CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		)
	end

	print("Raycast failed")
	return humanoidRootPart.CFrame
end

return Crackutils