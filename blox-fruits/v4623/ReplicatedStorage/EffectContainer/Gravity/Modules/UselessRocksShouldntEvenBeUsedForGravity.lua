local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
CustomCollisions.new("Rocks")

local function AlignCFrame(data, normal)
	local v = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p, unit2, v, unit3)
end

local function RockCrater(p, data)
	local raycastResult = Workspace:Raycast(
		p + createVector(0, 0.1, 0),
		createVector(0, 1, 0) * -data.Radius,
		raycastParams
	)

	if not raycastResult then
		return
	end

	local folder = Instance.new("Folder", Workspace._WorldOrigin)
	folder.Name = "UselessRocksShouldntEvenBeUsedForGravityContainer"
	task.delay(7, function()
		folder:Destroy()
	end)
	task.spawn(function()
		local craterRock = script.CraterRock
		local radius = data.Radius
		local size = data.Size
		local duration = data.Duration
		local amount = data.Amount
		local randomOffset = data.RandomOffset or 0.25
		local v = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
		local v2 = {}

		for _ = 1, amount do
			local clone = craterRock:Clone()
			clone.Parent = folder
			table.insert(v2, clone)
		end

		task.spawn(function()
			task.wait(duration * 2)

			for _, v3 in pairs(v2) do
				v3:Destroy()
			end

			v2 = nil
		end)
		local v3 = 360 / #v2
		local total = 0

		for _, v4 in pairs(v2) do
			total += v3
			v4.CFrame = v * CFrame.Angles(0, math.rad(total), 0) * CFrame.new(0, 0, radius)

			if math.random(1, 5) < 2 then
				v4.CFrame = CFrame.new(v4.Position, raycastResult.Position) * CFrame.new(0, 0, randomOffset * radius)
			end

			v4.CFrame = CFrame.new(v4.Position, raycastResult.Position) * CFrame.new(
				0,
				math.random(-5, 5) / 3,
				math.random(-randomOffset * 100, randomOffset * 100) / 100 * radius
			)
			local part, v5 = Workspace:FindPartOnRayWithIgnoreList(
				Ray.new(v4.Position + createVector(0, 1, 0), createVector(0, 1, 0) * -radius),
				raycastParams.FilterDescendantsInstances
			)

			if part then
				local v6 = (v4.Position - raycastResult.Position).Magnitude / 300
				local v7 = size * math.random(15, 30) / 10
				local v8 = size * math.random(5, 20) / 10
				local v9 = size * math.random(30, 50) / 10
				v4.Size = Vector3.new(v7 * v6, v8 * v6, v9 * v6)
				v4.Position = v5 + Vector3.new(0, -v4.Size.Y * math.random(5, 6) / 15, 0)
				v4.CFrame = CFrame.new(v4.Position, raycastResult.Position) * CFrame.new(
					0,
					math.random(-5, 5) / 3,
					math.random(-randomOffset * 100, randomOffset * 100) / 100 * radius
				)
				v4.CFrame = CFrame.new(
					v4.Position,
					v.Position + Vector3.new(0, math.random(-55, -45) / 100 + v4.Size.Y / 200, 0)
				) * CFrame.Angles(math.rad(-math.random(10, 15) / 2 - 45 * v6), 0, 0) * CFrame.Angles(
					0,
					0,
					(math.rad((math.random(-5, 5))))
				)
				v4.Material = part.Material
				v4.Color = part.Color
			else
				v4:Destroy()
				v2[v4] = nil
			end

			TweenService:Create(
				v4,
				TweenInfo.new(0.075, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
				{
					Position = v4.Position + Vector3.new(0, v4.Size.Y * math.random(3, 5) / 10, 0)
				}
			):Play()
			local v6 = v4
			local v7 = v4
			task.spawn(function()
				task.wait(duration + math.random(10, 50) / 100)
				local tween = TweenService:Create(
					v6,
					TweenInfo.new(
						0.5,
						Enum.EasingStyle.Back,
						Enum.EasingDirection.In,
						0,
						false,
						math.random(10, 35) / 100
					),
					{
						Position = v6.Position + Vector3.new(
							math.random(-1, 1),
							-v6.Size.Y * math.random(20, 25) / 10,
							math.random(-1, 1)
						)
					}
				)
				tween:Play()
				tween.Completed:Wait()
				v6:Destroy()
				v2[v6] = nil
			end)
		end
	end)
end

return RockCrater