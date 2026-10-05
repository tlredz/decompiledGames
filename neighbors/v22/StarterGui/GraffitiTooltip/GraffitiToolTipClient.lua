local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require(game.ReplicatedStorage.Modules.Server)
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character
local mouse = localPlayer:GetMouse()
local rankInGroup = localPlayer:GetRankInGroup(15109848)
local label = script.Parent:WaitForChild("Label")
local v = character:FindFirstChild("Spray Paint") and true or false
local v2 = false
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.CollisionGroup = "SprayPaint_Graffiti_Pixel"
raycastParams.FilterDescendantsInstances = { workspace:WaitForChild("Places"), workspace:WaitForChild("Prefabs") }
raycastParams.IgnoreWater = true

local function getSprayPaintAtMouse()
	if v or UserInputService.TouchEnabled and not v2 then
		return
	end

	local unitRay = mouse.UnitRay
	local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 150, raycastParams)

	if not raycastResult then
		return nil
	end

	if raycastResult.Instance:GetAttribute("StickyNote") then
		if raycastResult.Instance:GetAttribute("attachedToPlayer") and rankInGroup < 100 then
			return
		else
			return raycastResult.Instance:GetAttribute("StickyNote")
		end
	elseif raycastResult.Instance:IsDescendantOf(workspace.Graffiti) or raycastResult.Instance:IsDescendantOf(workspace.placementCanvases) then
		return raycastResult.Instance.Name
	end

	return nil
end

character.ChildAdded:Connect(function(child)
	if child.Name == "Spray Paint" or child.Name == "Wooden Sign" then
		v = true
	end
end)
character.ChildRemoved:Connect(function(child)
	if child.Name == "Spray Paint" or child.Name == "Wooden Sign" then
		v = false
	end
end)
mouse.Button1Down:Connect(function()
	v2 = true
end)
mouse.Button1Up:Connect(function()
	v2 = false
end)
RunService.RenderStepped:Connect(function(_)
	label.Position = UDim2.new(0, mouse.X + 15, 0, mouse.Y + 5)
end)

while task.wait(0.1) do
	local sprayPaintAtMouse = getSprayPaintAtMouse()

	if sprayPaintAtMouse then
		local child = Players:FindFirstChild(sprayPaintAtMouse)

		if child then
			label.Visible = true
			label.Text = `<b>{child.DisplayName}</b> (@{child.Name})`
		end
	else
		label.Visible = false
	end
end