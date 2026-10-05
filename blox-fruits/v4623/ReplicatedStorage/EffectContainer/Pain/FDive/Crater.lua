local createVector = vector.create
local TweenService = game:GetService("TweenService")
game:GetService("ReplicatedStorage")
game:GetService("HttpService")
local random = Random.new()
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace._WorldOrigin, workspace.Enemies }
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Exclude
overlapParams.FilterDescendantsInstances = { workspace.Characters, workspace._WorldOrigin, workspace.Enemies }
return function(raycastResult: RaycastResult, p: number, p2: number, vector2: Vector3, p3: number)
	local cframe = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal)

	if not (raycastResult and raycastResult.Instance and raycastResult.Instance.Parent) then
		return
	end

	for i = 1, p2 do
		local v = p / p2 * (i / 2) ^ 0.5
		local v2 = vector2 / p2 * i * 1.5
		local total = 0

		while total <= 360 do
			total += 360 / p3 * random:NextNumber(0.8, 1.4)
			local position = (cframe * CFrame.new(
				math.sin((math.rad(total))) * v * random:NextNumber(0.8, 1.4),
				math.cos((math.rad(total))) * v * random:NextNumber(0.8, 1.4),
				0
			)).Position
			local raycastResult2 = workspace:Raycast(
				position + raycastResult.Normal * 5,
				raycastResult.Normal * -10,
				raycastParams
			)

			if not raycastResult2 then
				continue
			end

			local position2 = position
			local v4 = v2
			local v5 = raycastResult2
			task.spawn(function()
				local part = Instance.new("Part")
				part.Anchored = true
				part.Size = createVector(0, 0, 0)
				part.CFrame = CFrame.lookAt(
					position2,
					cframe.Position + cframe.LookVector * (v4 / 2) * random:NextNumber(0.8, 1.4)
				)
				part.TopSurface = Enum.SurfaceType.Smooth
				part.CanCollide = false
				part.BottomSurface = Enum.SurfaceType.Smooth
				part.FrontSurface = Enum.SurfaceType.Smooth
				part.Color = v5.Instance.Color
				part.Transparency = v5.Instance.Transparency
				part.Material = v5.Instance.Material
				part.CanQuery = false
				part:SetAttribute("DontDestroy", true)
				part.Parent = raycastResult.Instance.Parent
				TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					Size = createVector(1, 1, 1) * v4 * random:NextNumber(0.8, 1.4) - Vector3.new(
						0,
						v4 * random:NextNumber(0.8, 1.4) / 2,
						0
					)
				}):Play()
				task.wait(Random.new():NextNumber(6, 8))
				TweenService:Create(part, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					Position = part.Position + cframe.LookVector * -part.Size.X
				}):Play()
				task.wait(2)
				TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					Size = createVector(0, 0, 0)
				}):Play()
				task.wait(0.3)
				part:Destroy()
			end)
		end
	end
end