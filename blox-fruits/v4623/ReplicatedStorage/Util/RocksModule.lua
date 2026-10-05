local createVector = vector.create
local RocksModule = {}
local TweenService = game:GetService("TweenService")
game:GetService("ReplicatedStorage")
game:GetService("PhysicsService")
game:GetService("RunService")
local _WorldOrigin = workspace._WorldOrigin
local random = Random.new()

function RocksModule.Ground(p, p2, p3, p4, p5, p6, value, p7, p8)
	local Global = require(game.ReplicatedStorage.Global)

	if Global.FastMode then
		return
	end

	local filterDescendantsInstances = p4 or { workspace.Map }
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
	local v2 = p + Vector3.new(0, math.min(2.5, p2 / 10), 0)
	local total = 30
	local v3 = 360 / p5
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	local v4 = p3 or createVector(2, 2, 2)
	local v5 = value or 3

	local function OuterRocksLoop()
		for _ = 1, p5 do
			local v6 = CFrame.new(v2) * CFrame.fromEulerAnglesXYZ(0, math.rad(total), 0) * CFrame.new(
				p2 / 2 + p2 / 2.7,
				p2 / 6,
				0
			)
			local raycastResult = workspace:Raycast(v6.Position, Vector3.new(0, -p2 / 2, 0), raycastParams)
			total += v3

			if not (raycastResult and raycastResult.Instance and raycastResult.Instance.Transparency < 1) then
				continue
			end

			local part = Instance.new("Part")
			local part2

			if p8 then
				part2 = nil
			else
				part2 = Instance.new("Part")
			end

			part.CFrame = CFrame.new(raycastResult.Position - Vector3.new(0, v4.Y, 0), v2)
			part.Size = Vector3.new(v4.X * 1.3, v4.Y / 1.4, v4.Z * 1.3) * random:NextNumber(1, 1.5)

			if part2 then
				part2.Size = Vector3.new(part.Size.X * 1.01, part.Size.Y * 0.25, part.Size.Z * 1.01)
				part2.CFrame = part.CFrame * CFrame.new(0, part.Size.Y / 2 - part2.Size.Y / 2.1, 0)
				part2.BrickColor = raycastResult.Instance.BrickColor
				part2.Anchored = true
				part2.CanQuery = false
				part2.CanTouch = false
				part2.CanCollide = false

				if raycastResult.Instance.Material == Enum.Material.Concrete or raycastResult.Instance.Material == Enum.Material.Air or raycastResult.Instance.Material == Enum.Material.Wood or raycastResult.Instance.Material == Enum.Material.Neon or raycastResult.Instance.Material == Enum.Material.WoodPlanks then
					part.Material = raycastResult.Instance.Material
				else
					part.Material = Enum.Material.Concrete
				end

				part2.Material = raycastResult.Instance.Material
				part.BrickColor = BrickColor.new("Dark grey")
			else
				part.Material = raycastResult.Instance.Material
				part.BrickColor = raycastResult.Instance.BrickColor
			end

			part.Anchored = true
			part.CanQuery = false
			part.CanTouch = false
			part.CanCollide = false

			if p6 then
				part.BrickColor = BrickColor.new("Pastel light blue")
				part.Material = Enum.Material.Ice

				if part2 then
					part2.BrickColor = BrickColor.new("Lily white")
					part2.Material = Enum.Material.Sand
				end
			end

			part.Parent = _WorldOrigin

			if part2 then
				part2.Parent = _WorldOrigin
			end

			local cFrame = CFrame.new(raycastResult.Position - createVector(0, 0.5, 0), v2) * CFrame.fromEulerAnglesXYZ(
				random:NextNumber(-0.25, 0.5),
				random:NextNumber(-0.25, 0.25),
				random:NextNumber(-0.25, 0.25)
			)
			TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
				CFrame = cFrame
			}):Play()

			if part2 then
				local cFrame2 = cFrame * CFrame.new(0, part.Size.Y / 2 - part2.Size.Y / 2.1, 0)
				TweenService:Create(part2, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
					CFrame = cFrame2
				}):Play()
			end

			task.delay(v5, function()
				TweenService:Create(part, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Size = createVector(0.01, 0.01, 0.01)
				}):Play()

				if part2 then
					TweenService:Create(part2, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
						Size = createVector(0.01, 0.01, 0.01),
						CFrame = part.CFrame * CFrame.new(0, part.Size.Y / 2 - part.Size.Y / 2.1, 0)
					}):Play()
				end

				task.delay(0.6, function()
					part:Destroy()

					if part2 then
						part2:Destroy()
					end
				end)
			end)
		end
	end

	local function InnerRocksLoop()
		for _ = 1, p5 do
			local v6 = CFrame.new(v2) * CFrame.fromEulerAnglesXYZ(0, math.rad(total), 0) * CFrame.new(
				p2 / 2 + p2 / 10,
				p2 / 6,
				0
			)
			local raycastResult = game.Workspace:Raycast(v6.Position, Vector3.new(0, -p2 / 2, 0), raycastParams)
			total += v3

			if not (raycastResult and raycastResult.Instance and raycastResult.Instance.Transparency < 1) then
				continue
			end

			local part = Instance.new("Part")
			local part2 = Instance.new("Part")
			part.CFrame = CFrame.new(raycastResult.Position - Vector3.new(0, v4.Y, 0), v2)
			part.Size = Vector3.new(v4.X * 1.3, v4.Y * 0.7, v4.Z * 1.3) * random:NextNumber(1, 1.5)
			part2.Size = Vector3.new(part.Size.X * 1.01, part.Size.Y * 0.25, part.Size.Z * 1.01)
			part2.CFrame = part.CFrame * CFrame.new(0, part.Size.Y / 2 - part2.Size.Y / 2.1, 0)

			if raycastResult.Instance.Material == Enum.Material.Concrete or raycastResult.Instance.Material == Enum.Material.Air or raycastResult.Instance.Material == Enum.Material.Wood or raycastResult.Instance.Material == Enum.Material.Neon or raycastResult.Instance.Material == Enum.Material.WoodPlanks then
				part.Material = raycastResult.Instance.Material
			else
				part.Material = Enum.Material.Concrete
			end

			part2.Material = raycastResult.Instance.Material
			part.BrickColor = BrickColor.new("Dark grey")
			part.Anchored = true
			part.CanQuery = false
			part.CanTouch = false
			part.CanCollide = false
			part2.BrickColor = raycastResult.Instance.BrickColor
			part2.Anchored = true
			part2.CanQuery = false
			part2.CanTouch = false
			part2.CanCollide = false

			if p6 then
				part.BrickColor = BrickColor.new("Pastel light blue")
				part2.BrickColor = BrickColor.new("Lily white")
				part.Material = Enum.Material.Ice
				part2.Material = Enum.Material.Sand
			end

			part.Parent = _WorldOrigin
			part2.Parent = _WorldOrigin
			local cFrame = CFrame.new(raycastResult.Position - Vector3.new(0, v4.Y * 0.4, 0), v2) * CFrame.fromEulerAnglesXYZ(
				random:NextNumber(-1, -0.3),
				random:NextNumber(-0.15, 0.15),
				random:NextNumber(-0.15, 0.15)
			)
			local cFrame2 = cFrame * CFrame.new(0, part.Size.Y / 2 - part2.Size.Y / 2.1, 0)
			TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
				CFrame = cFrame
			}):Play()
			TweenService:Create(part2, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
				CFrame = cFrame2
			}):Play()
			task.delay(v5, function()
				TweenService:Create(part, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Size = createVector(0.01, 0.01, 0.01)
				}):Play()
				TweenService:Create(part2, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Size = createVector(0.01, 0.01, 0.01),
					CFrame = part.CFrame * CFrame.new(0, part.Size.Y / 2 - part.Size.Y / 2.1, 0)
				}):Play()
				task.delay(0.6, function()
					part:Destroy()
					part2:Destroy()
				end)
			end)
		end
	end

	if p7 == false then
		OuterRocksLoop()
	else
		InnerRocksLoop()
		task.delay(0.1, function()
			OuterRocksLoop()
		end)
	end
end

return RocksModule