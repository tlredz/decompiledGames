local createVector = vector.create
local RocksModule2 = {}
local TweenService = game:GetService("TweenService")
game:GetService("ReplicatedStorage")
game:GetService("PhysicsService")
game:GetService("RunService")

function RocksModule2.Ground(position, p, p2, p3, p4, _, value, p5)
	local random = Random.new()
	local total = 30
	local v = 360 / p4
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
	raycastParams.FilterDescendantsInstances = p3 or { workspace.Map }
	local v2 = p2 or createVector(2, 2, 2)
	local v3 = value or 3
	local parent = p5 or workspace._WorldOrigin

	local function InnerRocksLoop()
		for _ = 1, p4 do
			local v5 = CFrame.new(position) * CFrame.fromEulerAnglesXYZ(0, math.rad(total), 0) * CFrame.new(
				p / 2 + p / 10,
				10,
				0
			)
			local raycastResult = game.Workspace:Raycast(v5.Position, createVector(0, -20, 0), raycastParams)
			total += v

			if not (raycastResult and raycastResult.Instance and raycastResult.Instance.Transparency < 1) then
				continue
			end

			local part = Instance.new("Part")
			part.Size = Vector3.new(v2.X * 1.1, v2.Y * 0.65, v2.Z * 1.1) * random:NextNumber(1, 1.5)
			part.CFrame = CFrame.new(raycastResult.Position - Vector3.new(0, v2.Y * 0.4, 0), position) * CFrame.fromEulerAnglesXYZ(
				random:NextNumber(-1, -0.3),
				random:NextNumber(-0.15, 0.15),
				random:NextNumber(-0.15, 0.15)
			)
			part.Material = raycastResult.Instance.Material
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.BrickColor = raycastResult.Instance.BrickColor
			part.Parent = parent
			task.delay(v3, function()
				TweenService:Create(part, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Size = createVector(0.01, 0.01, 0.01)
				}):Play()
				task.delay(0.6, function()
					part:Destroy()
				end)
			end)
		end
	end

	InnerRocksLoop()
end

return RocksModule2