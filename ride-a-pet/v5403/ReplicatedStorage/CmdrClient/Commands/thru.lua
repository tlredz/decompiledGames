local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
return {
	Name = "thru",
	Aliases = { "t", "through" },
	Description = "Teleports you through whatever your mouse is hovering over, placing you equidistantly from the wall.",
	Group = "DefaultDebug",
	Args = {
		{
			Type = "number",
			Name = "Extra distance",
			Description = "Go through the wall an additional X studs.",
			Default = 0
		}
	},
	ClientRun = function(p, p2)
		local character = p.Executor.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return "You don't have a character."
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
			return "No target to go through."
		end

		local position = humanoidRootPart.Position
		local v = raycastResult.Position - position
		humanoidRootPart.CFrame = CFrame.new(v * 2 + v.Unit * p2 + position)
		return "Blinked!"
	end
}