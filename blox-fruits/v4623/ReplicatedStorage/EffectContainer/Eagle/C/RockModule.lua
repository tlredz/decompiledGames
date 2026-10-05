local createVector = vector.create
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
game:GetService("ReplicatedStorage")
local random = Random.new()
local _ = workspace.CurrentCamera
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { workspace.Map }
local RockModule = {}
RockModule.VoxelDestructAreas = {}

function RockModule.Crater(raycastResult: RaycastResult, p: number, p2: number, vector2: Vector3, p3: number, parent)
	local cframe = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal)

	if not (raycastResult and raycastResult.Instance and raycastResult.Instance.Parent) then
		return
	end

	for i = 1, p2 do
		local v = p / p2 * i
		local v2 = vector2 / p2 * i
		local total = 0

		while total <= 360 do
			total += 360 / p3 * random:NextNumber(0.8, 1.4)
			local position = (cframe * CFrame.new(
				math.sin((math.rad(total))) * v * random:NextNumber(0.8, 1.4),
				math.cos((math.rad(total))) * v * random:NextNumber(0.8, 1.4),
				0
			)).Position

			if not workspace:Raycast(position + raycastResult.Normal * 5, raycastResult.Normal * -10, raycastParams) then
				continue
			end

			local position2 = position
			local v4 = v2
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
				part.Color = raycastResult.Instance.Color
				part.Material = raycastResult.Instance.Material
				part.CanQuery = false
				part.Parent = parent
				TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					Size = createVector(1, 1, 1) * v4 * random:NextNumber(0.8, 1.4) - Vector3.new(
						0,
						v4 * random:NextNumber(0.8, 1.4) / 2,
						0
					)
				}):Play()
				task.wait(Random.new():NextNumber(1, 3.5))
				local number = random:NextNumber(1, 2)
				TweenService:Create(part, TweenInfo.new(number, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					Position = part.Position + cframe.LookVector * -part.Size.X
				}):Play()
				task.wait(number)
				TweenService:Create(
					part,
					TweenInfo.new(random:NextNumber(0.1, 0.3), Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						Size = createVector(0, 0, 0)
					}
				):Play()
				task.wait(0.3)
				part:Destroy()
			end)
		end
	end
end

function RockModule.Rocks(raycastResult: RaycastResult, p: number, p2: number, p3, p4, p5, parent)
	local cframe = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal)

	if not (raycastResult and raycastResult.Instance and raycastResult.Instance.Parent) then
		return
	end

	for _ = 1, p do
		local number = random:NextNumber(0, 360)
		local number2 = random:NextNumber(0, p2)
		local position = (cframe * CFrame.new(
			math.sin((math.rad(number))) * number2 * random:NextNumber(0.8, 1.4),
			math.cos((math.rad(number))) * number2 * random:NextNumber(0.8, 1.4),
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

		local number3 = random:NextNumber(p3, p4)
		local part = Instance.new("Part")
		part.Anchored = false
		part.Size = createVector(0, 0, 0)
		part.CollisionGroup = "Player"
		part.CFrame = CFrame.lookAt(
			position,
			cframe.Position + cframe.LookVector * (number3 / 2) * random:NextNumber(0.8, 1.4)
		) * CFrame.Angles(
			random:NextNumber(0, 6.283185307179586),
			random:NextNumber(0, 6.283185307179586),
			random:NextNumber(0, 6.283185307179586)
		)
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.FrontSurface = Enum.SurfaceType.Smooth
		part.Color = raycastResult.Instance.Color
		part.Material = raycastResult.Instance.Material
		part.Massless = true
		part.CanQuery = false
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
		bodyVelocity.Parent = part
		bodyVelocity.Velocity = raycastResult2.Normal + Vector3.new(
			random:NextNumber(-3, 3),
			random:NextNumber(-3, 3),
			random:NextNumber(-3, 3)
		) * p5 * random:NextNumber(0.7, 1.4)
		task.delay(0.3, bodyVelocity.Destroy, bodyVelocity)
		part.Parent = parent
		TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			Size = createVector(1, 1, 1) * number3 * random:NextNumber(0.8, 1.4)
		}):Play()
		task.delay(Random.new():NextNumber(1, 3.5), function()
			TweenService:Create(
				part,
				TweenInfo.new(random:NextNumber(0.3, 0.6), Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					Size = createVector(0, 0, 0)
				}
			):Play()
			task.wait(0.3)
			part:Destroy()
		end)
	end
end

return RockModule