local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
return {
	Name = "blink",
	Aliases = { "b" },
	Description = "Teleports you to where your mouse is hovering.",
	Group = "DefaultDebug",
	Args = {},
	ClientRun = function(p)
		local character = p.Executor.Character

		if not character then
			return "You don't have a character."
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return "No HumanoidRootPart found."
		end

		local currentCamera = Workspace.CurrentCamera
		local mouseLocation = UserInputService:GetMouseLocation()
		local viewportPointToRay = currentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { character }
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
		local raycastResult = Workspace:Raycast(
			viewportPointToRay.Origin,
			viewportPointToRay.Direction * 1000,
			raycastParams
		)

		if not raycastResult then
			return "No valid position found."
		end

		humanoidRootPart.CFrame = CFrame.new(raycastResult.Position)
		return "Blinked!"
	end
}