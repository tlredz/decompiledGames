local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebris = require(script.Parent.ClientDebris)
local ImpactFx = require(script.Parent.ImpactFx)
local v = {}
local v2 = {}

local function removeBoulder(result)
	local index = table.find(v, result)

	if index then
		table.remove(v, index)
	end

	pcall(function()
		result:Destroy()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getBallPos(instance)
	if instance:IsA("BasePart") then
		return instance.Position
	end

	if not instance:IsA("Model") then
		return nil
	end

	if instance.PrimaryPart then
		return instance.PrimaryPart.Position
	end

	return instance:GetPivot().Position
end

local BoulderRain = {}

function BoulderRain.warn(data)
	local x = data.x or 0
	local groundY = data.groundY or 0
	local z = data.z or 0
	local warnSec = data.warnSec or 1.5
	local radius = data.radius or 5
	local part = Instance.new("Part")
	part.Name = "ChichineBoulderWarnDisc"
	part.Shape = Enum.PartType.Cylinder
	part.Size = Vector3.new(0.3, radius * 10, radius * 10)
	part.CFrame = CFrame.new(x, groundY + 0.15, z) * CFrame.Angles(0, 0, 1.5707963267948966)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255, 80, 0)
	part.Transparency = 0.35
	part.Parent = ClientDebris()
	table.insert(v2, part)
	task.spawn(function()
		while part and part.Parent do
			TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true), {
				Transparency = 0.65
			}):Play()
			task.wait(0.62)
		end
	end)
	task.delay(math.max(0, warnSec - 0.2), function()
		if not part.Parent then
			return
		end

		local tween = TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Transparency = 1
		})
		tween.Completed:Once(function()
			tween:Destroy()
			local index = table.find(v2, part)

			if index then
				table.remove(v2, index)
			end

			pcall(function()
				part:Destroy()
			end)
		end)
		tween:Play()
	end)
end

function BoulderRain.spawn(data)
	local assets = ReplicatedStorage:FindFirstChild("AdminAbuse") and ReplicatedStorage.AdminAbuse:FindFirstChild("ChichineBossRoom") and ReplicatedStorage.AdminAbuse.ChichineBossRoom:FindFirstChild("Assets")
	local killBall = assets and assets:FindFirstChild("KillBall")

	if not killBall then
		return
	end

	local success, result = pcall(function()
		return killBall:Clone()
	end)

	if not (success and result) then
		return
	end

	local diameter = data.diameter or 6

	if result:IsA("BasePart") then
		result.Size = Vector3.new(diameter, diameter, diameter)
		result.CFrame = CFrame.new(data.x or 0, data.y or 0, data.z or 0) * CFrame.Angles(1.5707963267948966, 0, 0)
		result.CanCollide = false
		result.CanTouch = false
		result.Anchored = true
		result.CastShadow = false
	elseif result:IsA("Model") then
		local extentsSize = result:GetExtentsSize()
		local v3 = math.max(extentsSize.X, extentsSize.Y, extentsSize.Z)

		if v3 > 0 then
			result:ScaleTo(diameter / v3)
		end

		result:PivotTo(CFrame.new(data.x or 0, data.y or 0, data.z or 0))

		for _, part in result:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.CanCollide = false
			part.CanTouch = false
			part.Anchored = true
			part.CastShadow = false
		end
	end

	result.Parent = ClientDebris()
	table.insert(v, result)
	local cFrame

	if result:IsA("BasePart") then
		cFrame = result.CFrame
	else
		cFrame = result:GetPivot()
	end

	local v3 = math.random() * 3.141592653589793 * 2
	local v4 = math.random() * 6 + 2
	local v5 = (data.fallSpeed or 5) * 2
	local vector = Vector3.new(math.cos(v3) * v4, -v5, math.sin(v3) * v4)
	local gravity = workspace.Gravity
	local damage = data.damage or 50
	local v6 = false
	local groundY = data.groundY or 0
	local v7 = (data.diameter or 6) * 0.5
	local v8 = v7 + 2
	local total = 0
	local v9 = false
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
		if v9 or not result.Parent then
			heartbeatConnection:Disconnect()
			return
		end

		total += dt
		local vector2 = Vector3.new(
			vector.X * total,
			vector.Y * total - 0.5 * gravity * total * total,
			vector.Z * total
		)

		if result:IsA("BasePart") then
			result.CFrame = cFrame + vector2
		elseif result:IsA("Model") then
			result:PivotTo(cFrame + vector2)
		end

		local ballPos = getBallPos(result) -- equivalent call inferred; original call site unknown

		if not ballPos then
			return
		end

		if not v6 then
			local character = Players.LocalPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				local v11 = ballPos.X - humanoidRootPart.Position.X
				local v12 = ballPos.Y - humanoidRootPart.Position.Y
				local v13 = ballPos.Z - humanoidRootPart.Position.Z

				if v11 * v11 + v12 * v12 + v13 * v13 <= v8 * v8 then
					v6 = true
					local humanoid = character:FindFirstChildOfClass("Humanoid")

					if humanoid and humanoid.Health > 0 then
						humanoid:TakeDamage(damage)
					end
				end
			end
		end

		if ballPos.Y - v7 <= groundY + 0.5 then
			v9 = true
			heartbeatConnection:Disconnect()
			ImpactFx.explosion(ballPos.X, groundY, ballPos.Z, v7 * 6)
			removeBoulder(result)
		end
	end)
	local lifeMin = data.lifeMin or 4
	local lifeMax = data.lifeMax or 9
	local v10 = lifeMin + math.random() * (lifeMax - lifeMin)
	task.delay(v10, function()
		heartbeatConnection:Disconnect()
		removeBoulder(result)
	end)
end

function BoulderRain.cleanup()
	for _, v3 in v do
		local v4 = v3
		pcall(function()
			v4:Destroy()
		end)
	end

	table.clear(v)

	for _, v3 in v2 do
		local v4 = v3
		pcall(function()
			v4:Destroy()
		end)
	end

	table.clear(v2)
end

return BoulderRain