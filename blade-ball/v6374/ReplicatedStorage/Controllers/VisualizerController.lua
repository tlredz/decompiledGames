local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("Lighting")
game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
require3(ReplicatedStorage2.Packages.Observers)
local v2 = require3(ReplicatedStorage2.Packages.Trove)
local currentCamera = workspace.CurrentCamera
local v3 = nil
local v4 = v2.new()
local part = Instance.new("Part")
part.Name = "Black"
part.Material = Enum.Material.SmoothPlastic
part.Color = Color3.new()
part.Transparency = 0.5
part.CanCollide = false
part.CanQuery = false
part.CanTouch = false
part.Anchored = true
local VisualizerController = {}

function VisualizerController.Visualize(_, folder, p: number)
	if not folder then
		return
	end

	v4:Clean()
	part.Parent = workspace
	local extentsSize = folder:GetExtentsSize()
	local v5 = math.max(extentsSize.X, extentsSize.Y, extentsSize.Z)
	local viewportSize = currentCamera.ViewportSize
	math.min(viewportSize.X, viewportSize.Y)

	for _, part2 in folder:GetDescendants() do
		if part2:IsA("BasePart") then
			part2.Anchored = true
		end
	end

	folder:ScaleTo(folder:GetScale() * (0.25 / v5) * p)
	folder.Parent = workspace

	for _, part2 in folder:GetDescendants() do
		if part2:IsA("BasePart") then
			part2.CastShadow = false
		end
	end

	v3 = folder
end

function VisualizerController.Clear(_)
	v3 = nil
	v4:Clean()
	part.Parent = nil
end

function VisualizerController.Start(_)
	RunService.PreRender:Connect(function()
		if v3 then
			local cFrame = currentCamera.CFrame
			local position = cFrame.Position
			local lookVector = cFrame.LookVector
			v3:PivotTo(CFrame.lookAt(position + lookVector * 0.25, position))
			local fieldOfView = currentCamera.FieldOfView
			local viewportSize = currentCamera.ViewportSize
			local v5 = viewportSize.X / viewportSize.Y
			local v6 = math.tan((math.rad(fieldOfView / 2))) * 2 * 2
			part.Size = Vector3.new(v6 * v5, v6, 1)
			part:PivotTo(CFrame.lookAt(position + lookVector * 2.5, position))
		end
	end)
	v.InputBegan:Connect(function(input, _)
		if not v3 then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonR2 then
			v3 = nil
			v4:Clean()
			part.Parent = nil
		end
	end)
end

return VisualizerController