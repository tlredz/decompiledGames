local createVector = vector.create
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local RockModule = {}
local random = Random.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function Random2(p, p2)
	return random:NextNumber(p, p2)
end

function RockModule.GetGround(p, value, _)
	local raycastParams = RaycastParams.new()
	raycastParams.IgnoreWater = true
	raycastParams.FilterDescendantsInstances = { workspace.Island }
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	local raycastResult = workspace:Raycast(
		p + createVector(0, 5, 0),
		createVector(0, -1, 0) * ((value or 1000) + 2),
		raycastParams
	)

	if raycastResult then
		return {
			Position = raycastResult.Position,
			Object = raycastResult.Instance
		}
	end
end

function RockModule.Rocks(p, data)
	local rockSize = data.RockSize or createVector(1, 1, 1)
	local duration = data.Duration or 2
	local amount = data.Amount or 20
	local radius = data.Radius or 10
	local chance = data.Chance or 100
	local rockPart = data.RockPart or script:FindFirstChild("Rock")
	local list = data.List or {
		Enum.RaycastFilterType.Include,
		{ workspace.Island }
	}
	task.spawn(function()
		PeodizService.ForLoop({
			Step = amount
		}, function(p2)
			local v = math.floor(p2 * amount)

			if random:NextNumber(0, 100) <= chance then
				local v2 = 6.283185307179586 / amount * (v - 1)
				local vector2 = Vector3.new(math.cos(v2) * radius, 0, math.sin(v2) * radius)
				local position = (p * CFrame.new(vector2 + createVector(0, 1, 0))).Position
				local ground = RockModule.GetGround(position, 15, list)

				if ground then
					local clone = rockPart:Clone()
					clone.Size = rockSize * Vector3.new(
						random:NextNumber(0.1, 2),
						random:NextNumber(0.1, 2),
						Random2(0.1, 2)
					)
					clone.CFrame = CFrame.lookAt(ground.Position - Vector3.new(0, clone.Size.Y / 2, 0), p.Position) * CFrame.new(
						0,
						0,
						-5
					)
					clone.CollisionGroup = "Effect"
					clone.Color = ground.Object.Color
					clone.Material = ground.Object.Material
					clone.Parent = workspace.Effects
					TweenService:Create(
						clone,
						TweenInfo.new(random:NextNumber(0.19, 0.28), Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Position = ground.Position - Vector3.new(0, clone.Size.Y / 3, 0)
						}
					):Play()
					task.delay(duration * random:NextNumber(0.95, 1.05), function()
						local tween = TweenService:Create(
							clone,
							TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
							{
								Position = ground.Position - Vector3.new(0, clone.Size.Y * 2, 0)
							}
						)
						tween:Play()
						tween.Completed:Wait()
						clone:Destroy()
					end)
				end
			end
		end)
	end)
end

function RockModule.Debris(p, data)
	local partTemplate = data.PartTemplate or script:FindFirstChild("Rock")
	local count = data.Count or 10
	local force = data.Force or 100
	local v = math.max(0, data.Radius or 0)
	local lifetime = data.Lifetime or 2
	local v2 = not data.Direction and createVector(0, 1, 0) or data.Direction.Unit or createVector(0, 1, 0)
	local list = data.List or {
		Enum.RaycastFilterType.Include,
		{ workspace.Island }
	}
	local bVLifetime = data.BVLifetime or 0.25
	local spreadAngle = data.SpreadAngle or 0.5
	local v3 = math.clamp(data.SpreadForce or 0.66, 0, 1)
	local v4 = math.clamp(data.SpreadSize or 0.25, 0, 1)
	local v5 = math.clamp(v3, 0, 1)
	local v6 = math.clamp(v4, 0, 1)
	local v7 = math.max(0, v)
	PeodizService.ForLoop({
		Step = count
	}, function(p2)
		math.floor(p2 * count)
		local position = (p * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(0, 0, Random2(0, v7))).Position
		local ground = RockModule.GetGround(position, 15, list)

		if ground then
			local clone = partTemplate:Clone()
			clone.Size = partTemplate.Size
			clone.Color = ground.Object.Color
			clone.Material = ground.Object.Material
			clone.CFrame = CFrame.new(ground.Position) * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			clone.Anchored = false
			clone.CanCollide = true
			clone.Size = clone.Size * random:NextNumber(v6, 1) * Vector3.new(
				random:NextNumber(0.85, 1),
				random:NextNumber(0.85, 1),
				Random2(0.85, 1)
			)
			clone.CollisionGroup = "Effect"
			clone.Parent = workspace.Effects

			if clone:IsA("BasePart") then
				local bodyVelocity = Instance.new("BodyVelocity")
				local random2 = Random2(-spreadAngle, spreadAngle) -- equivalent call inferred; original call site unknown
				local v10 = -spreadAngle
				bodyVelocity.Velocity = (v2 + Vector3.new(
					random2,
					random:NextNumber(v10, spreadAngle),
					Random2(-spreadAngle, spreadAngle)
				)).Unit * force * random:NextNumber(v5, 1)
				bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
				bodyVelocity.P = 1000
				bodyVelocity.Parent = clone
				_G.PU:Dust(bodyVelocity, bVLifetime)
				Instance.new("Attachment", clone)
				task.delay(lifetime * random:NextNumber(0.95, 1.05), function()
					local tween = TweenService:Create(
						clone,
						TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
						{
							Size = Vector3.new()
						}
					)
					tween:Play()
					tween.Completed:Wait()
					clone:Destroy()
				end)
			end
		end
	end)
end

function RockModule.SideRock(data)
	local partTemplate = data.PartTemplate or script:FindFirstChild("Rock")
	local track = data.Track
	local radius = data.Radius or 5
	local list = data.List or {
		Enum.RaycastFilterType.Include,
		{ workspace.Island }
	}
	local lifetime = data.Lifetime or 1
	local step = data.Step or 0.2
	local width = data.Width or 1
	local fadeTime = data.FadeTime or 1.5

	if not track then
		return
	end

	task.spawn(function()
		PeodizService.HeartbeatWait({
			Time = lifetime,
			WaitTime = step
		}, function(_)
			local ground = RockModule.GetGround(track.CFrame.Position, 15, list)

			if ground then
				local _, v, _ = track.CFrame:ToOrientation()
				local cframe = CFrame.fromOrientation(0, v, 0)
				local v4 = random:NextNumber(data.RadiusWidth[1], data.RadiusWidth[2]) or random:NextNumber(0.85, 1)
				local v5 = math.random(1, 2) == 1 and 1 or -1
				local vector2 = Vector3.new(v5 * radius * v4, 0, 0)
				local clone = partTemplate:Clone()
				clone.Size = Vector3.new()
				clone.Anchored = true
				clone.CanCollide = false
				clone.Material = ground.Object.Material
				clone.Color = ground.Object.Color
				clone.CollisionGroup = "Effect"
				clone.CFrame = CFrame.new(ground.Position) * cframe * CFrame.new(vector2) * CFrame.Angles(
					0,
					3.141592653589793 * math.random(-15, 10) / 100,
					v5 * 3.141592653589793 * math.random(80, 90) / 100
				)
				clone.Parent = workspace.Effects
				local v6 = width * random:NextNumber(1, 2)
				local size = Vector3.new(v6, v6 / 1.5, v6 / 1.5) * 3.75
				TweenService:Create(clone, TweenInfo.new(0.33, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = size
				}):Play()
				_G.PU:Dust(clone, fadeTime + 1)
				task.delay(fadeTime * random:NextNumber(0.95, 1.25), function()
					local tween = TweenService:Create(
						clone,
						TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
						{
							Position = clone.Position - Vector3.new(0, clone.Size.Y * 2, 0)
						}
					)
					tween:Play()
					tween.Completed:Wait()
					clone:Destroy()
				end)
			end
		end)
	end)
end

return RockModule