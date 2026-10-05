local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CraterExtension = {}
local TweenService = game:GetService("TweenService")
game:GetService("ReplicatedStorage")
game:GetService("PhysicsService")
game:GetService("RunService")
game:GetService("Debris")
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local random = math.random
workspace:WaitForChild("Debree"):WaitForChild("Craters")
local Craters_Config = require(script.Parent:WaitForChild("Craters_Config"))

function CraterExtension.Ground(cframe, p, p2, _, p3, p4, value)
	local random2 = Random.new()

	if typeof(cframe) == "Vector3" then
		cframe = CFrame.new(cframe)
	end

	local v = cframe * CFrame.new(0, 0.5, 0)
	local total = 30
	local v2 = 360 / p3
	local v3 = p2 or createVector(2, 2, 2)
	local v4 = value or 3

	local function OuterRocksLoop()
		for _ = 1, p3 do
			local v5 = v * CFrame.fromEulerAnglesXYZ(0, math.rad(total), 0) * CFrame.new(p / 2 + p / 2.7, 10, 0)
			local raycastResult = workspace:Raycast(v5.Position, v5.UpVector * -20, vfxUtility.RayParams.Map)
			total += v2

			if not raycastResult then
				continue
			end

			local get_Part = Craters_Config.Get_Part()
			local get_Part2 = Craters_Config.Get_Part()
			get_Part.CFrame = CFrame.new(raycastResult.Position - createVector(0, 0.5, 0)) * CFrame.fromRotationBetweenVectors(
				createVector(0, 1, 0),
				raycastResult.Normal
			) * CFrame.fromEulerAnglesXYZ(
				random2:NextNumber(-0.25, 0.5),
				random2:NextNumber(-0.25, 0.25),
				random2:NextNumber(-0.25, 0.25)
			)
			get_Part.Size = Vector3.new(v3.X * 1.3, v3.Y / 1.4, v3.Z * 1.3) * random2:NextNumber(1, 1.5)
			get_Part2.Size = Vector3.new(get_Part.Size.X * 1.01, get_Part.Size.Y * 0.25, get_Part.Size.Z * 1.01)
			get_Part2.CFrame = get_Part.CFrame * CFrame.new(0, get_Part.Size.Y / 2 - get_Part2.Size.Y / 2.1, 0)

			if raycastResult.Instance.Material == Enum.Material.Concrete or raycastResult.Instance.Material == Enum.Material.Air or raycastResult.Instance.Material == Enum.Material.Wood or raycastResult.Instance.Material == Enum.Material.Neon or raycastResult.Instance.Material == Enum.Material.WoodPlanks then
				get_Part.Material = raycastResult.Instance.Material
			else
				get_Part.Material = Enum.Material.Concrete
			end

			get_Part2.Material = raycastResult.Instance.Material
			get_Part.BrickColor = BrickColor.new("Dark grey")
			get_Part.Anchored = true
			get_Part.CanTouch = false
			get_Part.CanCollide = false
			get_Part2.BrickColor = raycastResult.Instance.BrickColor
			get_Part2.Anchored = true
			get_Part2.CanTouch = false
			get_Part2.CanCollide = false

			if p4 then
				get_Part.BrickColor = BrickColor.new("Pastel light blue")
				get_Part2.BrickColor = BrickColor.new("Lily white")
				get_Part.Material = Enum.Material.Ice
				get_Part2.Material = Enum.Material.Sand
			end

			task.delay(v4, function()
				TweenService:Create(get_Part, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Size = createVector(0.01, 0.01, 0.01)
				}):Play()
				TweenService:Create(get_Part2, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Size = createVector(0.01, 0.01, 0.01),
					CFrame = get_Part.CFrame * CFrame.new(0, get_Part.Size.Y / 2 - get_Part.Size.Y / 2.1, 0)
				}):Play()
			end)
			Craters_Config.Delete_Part(get_Part, v4 + 0.6)
			Craters_Config.Delete_Part(get_Part2, v4 + 0.6)
		end
	end

	local function InnerRocksLoop()
		for _ = 1, p3 do
			local v5 = v * CFrame.fromEulerAnglesXYZ(0, math.rad(total), 0) * CFrame.new(p / 2 + p / 10, 10, 0)
			local raycastResult = game.Workspace:Raycast(v5.Position, v5.UpVector * -20, vfxUtility.RayParams.Map)
			total += v2

			if not raycastResult then
				continue
			end

			local get_Part = Craters_Config.Get_Part()
			local get_Part2 = Craters_Config.Get_Part()
			get_Part.CFrame = CFrame.new(raycastResult.Position - Vector3.new(0, v3.Y * 0.4, 0)) * CFrame.fromRotationBetweenVectors(
				createVector(0, 1, 0),
				raycastResult.Normal
			) * CFrame.fromEulerAnglesXYZ(
				random2:NextNumber(-1, -0.3),
				random2:NextNumber(-0.15, 0.15),
				random2:NextNumber(-0.15, 0.15)
			)
			get_Part.Size = Vector3.new(v3.X * 1.3, v3.Y * 0.7, v3.Z * 1.3) * random2:NextNumber(1, 1.5)
			get_Part2.Size = Vector3.new(get_Part.Size.X * 1.01, get_Part.Size.Y * 0.25, get_Part.Size.Z * 1.01)
			get_Part2.CFrame = get_Part.CFrame * CFrame.new(0, get_Part.Size.Y / 2 - get_Part2.Size.Y / 2.1, 0)

			if raycastResult.Instance.Material == Enum.Material.Concrete or raycastResult.Instance.Material == Enum.Material.Air or raycastResult.Instance.Material == Enum.Material.Wood or raycastResult.Instance.Material == Enum.Material.Neon or raycastResult.Instance.Material == Enum.Material.WoodPlanks then
				get_Part.Material = raycastResult.Instance.Material
			else
				get_Part.Material = Enum.Material.Concrete
			end

			get_Part2.Material = raycastResult.Instance.Material
			get_Part.BrickColor = BrickColor.new("Dark grey")
			get_Part.Anchored = true
			get_Part.CanTouch = false
			get_Part.CanCollide = false
			get_Part2.BrickColor = raycastResult.Instance.BrickColor
			get_Part2.Anchored = true
			get_Part2.CanTouch = false
			get_Part2.CanCollide = false

			if p4 then
				get_Part.BrickColor = BrickColor.new("Pastel light blue")
				get_Part2.BrickColor = BrickColor.new("Lily white")
				get_Part.Material = Enum.Material.Ice
				get_Part2.Material = Enum.Material.Sand
			end

			task.delay(v4, function()
				TweenService:Create(get_Part, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Size = createVector(0.01, 0.01, 0.01)
				}):Play()
				TweenService:Create(get_Part2, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Size = createVector(0.01, 0.01, 0.01),
					CFrame = get_Part.CFrame * CFrame.new(0, get_Part.Size.Y / 2 - get_Part.Size.Y / 2.1, 0)
				}):Play()
			end)
			Craters_Config.Delete_Part(get_Part, v4 + 0.6)
			Craters_Config.Delete_Part(get_Part2, v4 + 0.6)
		end
	end

	InnerRocksLoop()
	OuterRocksLoop()
end

function CraterExtension.Cascade(cframe, p, p2, _, p3, p4, value)
	local random2 = Random.new()

	if typeof(cframe) == "Vector3" then
		cframe = CFrame.new(cframe)
	end

	local v = cframe * CFrame.new(0, 0.5, 0)
	local total = 30
	local v2 = 360 / p3
	local v3 = p2 or createVector(2, 2, 2)
	local v4 = value or 3

	local function OuterRocksLoop()
		for _ = 1, p3 do
			local v5 = v * CFrame.fromEulerAnglesXYZ(0, math.rad(total), 0) * CFrame.new(p / 2 + p / 2.7, 10, 0)
			local raycastResult = workspace:Raycast(v5.Position, v5.UpVector * -20, vfxUtility.RayParams.Map)
			total += v2

			if not raycastResult then
				continue
			end

			local get_Part = Craters_Config.Get_Part()
			local get_Part2 = Craters_Config.Get_Part()
			get_Part.CFrame = CFrame.new(raycastResult.Position - createVector(0, 0.5, 0)) * CFrame.fromRotationBetweenVectors(
				createVector(0, 1, 0),
				raycastResult.Normal
			) * CFrame.fromEulerAnglesXYZ(
				random2:NextNumber(-0.25, 0.5),
				random2:NextNumber(-0.25, 0.25),
				random2:NextNumber(-0.25, 0.25)
			)
			get_Part.Size = Vector3.new(v3.X * 1.3, v3.Y / 1.4, v3.Z * 1.3) * random2:NextNumber(1, 1.5)
			get_Part2.Size = Vector3.new(get_Part.Size.X * 1.01, get_Part.Size.Y * 0.25, get_Part.Size.Z * 1.01)
			get_Part2.CFrame = get_Part.CFrame * CFrame.new(0, get_Part.Size.Y / 2 - get_Part2.Size.Y / 2.1, 0)

			if raycastResult.Instance.Material == Enum.Material.Concrete or raycastResult.Instance.Material == Enum.Material.Air or raycastResult.Instance.Material == Enum.Material.Wood or raycastResult.Instance.Material == Enum.Material.Neon or raycastResult.Instance.Material == Enum.Material.WoodPlanks then
				get_Part.Material = raycastResult.Instance.Material
			else
				get_Part.Material = Enum.Material.Concrete
			end

			get_Part2.Material = raycastResult.Instance.Material
			get_Part.BrickColor = BrickColor.new("Dark grey")
			get_Part.Anchored = true
			get_Part.CanTouch = false
			get_Part.CanCollide = false
			get_Part2.BrickColor = raycastResult.Instance.BrickColor
			get_Part2.Anchored = true
			get_Part2.CanTouch = false
			get_Part2.CanCollide = false

			if p4 then
				get_Part.BrickColor = BrickColor.new("Pastel light blue")
				get_Part2.BrickColor = BrickColor.new("Lily white")
				get_Part.Material = Enum.Material.Ice
				get_Part2.Material = Enum.Material.Sand
			end

			task.delay(v4, function()
				TweenService:Create(get_Part, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Size = createVector(0.01, 0.01, 0.01)
				}):Play()
				TweenService:Create(get_Part2, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Size = createVector(0.01, 0.01, 0.01),
					CFrame = get_Part.CFrame * CFrame.new(0, get_Part.Size.Y / 2 - get_Part.Size.Y / 2.1, 0)
				}):Play()
			end)
			Craters_Config.Delete_Part(get_Part, v4 + 0.6)
			Craters_Config.Delete_Part(get_Part2, v4 + 0.6)
		end
	end

	local function InnerRocksLoop()
		for _ = 1, p3 do
			local v5 = v * CFrame.fromEulerAnglesXYZ(0, math.rad(total), 0) * CFrame.new(p / 2 + p / 10, 10, 0)
			local raycastResult = game.Workspace:Raycast(v5.Position, v5.UpVector * -20, vfxUtility.RayParams.Map)
			total += v2

			if not raycastResult then
				continue
			end

			local get_Part = Craters_Config.Get_Part()
			local get_Part2 = Craters_Config.Get_Part()
			get_Part.CFrame = CFrame.new(raycastResult.Position - Vector3.new(0, v3.Y * 0.4, 0)) * CFrame.fromRotationBetweenVectors(
				createVector(0, 1, 0),
				raycastResult.Normal
			) * CFrame.fromEulerAnglesXYZ(
				random2:NextNumber(-1, -0.3),
				random2:NextNumber(-0.15, 0.15),
				random2:NextNumber(-0.15, 0.15)
			)
			get_Part.Size = Vector3.new(v3.X * 1.3, v3.Y * 0.7, v3.Z * 1.3) * random2:NextNumber(1, 1.5)
			get_Part2.Size = Vector3.new(get_Part.Size.X * 1.01, get_Part.Size.Y * 0.25, get_Part.Size.Z * 1.01)
			get_Part2.CFrame = get_Part.CFrame * CFrame.new(0, get_Part.Size.Y / 2 - get_Part2.Size.Y / 2.1, 0)

			if raycastResult.Instance.Material == Enum.Material.Concrete or raycastResult.Instance.Material == Enum.Material.Air or raycastResult.Instance.Material == Enum.Material.Wood or raycastResult.Instance.Material == Enum.Material.Neon or raycastResult.Instance.Material == Enum.Material.WoodPlanks then
				get_Part.Material = raycastResult.Instance.Material
			else
				get_Part.Material = Enum.Material.Concrete
			end

			get_Part2.Material = raycastResult.Instance.Material
			get_Part.BrickColor = BrickColor.new("Dark grey")
			get_Part.Anchored = true
			get_Part.CanTouch = false
			get_Part.CanCollide = false
			get_Part2.BrickColor = raycastResult.Instance.BrickColor
			get_Part2.Anchored = true
			get_Part2.CanTouch = false
			get_Part2.CanCollide = false

			if p4 then
				get_Part.BrickColor = BrickColor.new("Pastel light blue")
				get_Part2.BrickColor = BrickColor.new("Lily white")
				get_Part.Material = Enum.Material.Ice
				get_Part2.Material = Enum.Material.Sand
			end

			task.delay(v4, function()
				TweenService:Create(get_Part, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Size = createVector(0.01, 0.01, 0.01)
				}):Play()
				TweenService:Create(get_Part2, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Size = createVector(0.01, 0.01, 0.01),
					CFrame = get_Part.CFrame * CFrame.new(0, get_Part.Size.Y / 2 - get_Part.Size.Y / 2.1, 0)
				}):Play()
			end)
			Craters_Config.Delete_Part(get_Part, v4 + 0.6)
			Craters_Config.Delete_Part(get_Part2, v4 + 0.6)
		end
	end

	InnerRocksLoop()
	OuterRocksLoop()
end

local TweenService2 = game:GetService("TweenService")

function CraterExtension.GroundCrater(cframe, p, p2, _, p3, p4, value)
	local random2 = Random.new()

	if typeof(cframe) == "Vector3" then
		cframe = CFrame.new(cframe)
	end

	local v = cframe * CFrame.new(0, 0.5, 0)
	local total = 30
	local v2 = 360 / p3
	local v3 = p2 or createVector(2, 2, 2)
	local v4 = value or 3

	local function OuterRocksLoop()
		for _ = 1, p3 do
			local v5 = v * CFrame.fromEulerAnglesXYZ(0, math.rad(total), 0) * CFrame.new(p / 2 + p / 2.7, 10, 0)
			local raycastResult = workspace:Raycast(v5.Position, v5.UpVector * -20, vfxUtility.RayParams.Map)
			total += v2

			if not raycastResult then
				continue
			end

			local part = Instance.new("Part")
			local part2 = Instance.new("Part")
			part.CFrame = CFrame.new(raycastResult.Position - createVector(0, 0.5, 0), v.Position) * CFrame.fromEulerAnglesXYZ(
				random2:NextNumber(-0.25, 0.5),
				random2:NextNumber(-0.25, 0.25),
				random2:NextNumber(-0.25, 0.25)
			)
			part.Size = Vector3.new(v3.X * 1.3, v3.Y / 1.4, v3.Z * 1.3) * random2:NextNumber(1, 1.5)
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
			part.CanTouch = false
			part.CanCollide = false
			part2.BrickColor = raycastResult.Instance.BrickColor
			part2.Anchored = true
			part2.CanTouch = false
			part2.CanCollide = false

			if p4 then
				part.BrickColor = BrickColor.new("Pastel light blue")
				part2.BrickColor = BrickColor.new("Lily white")
				part.Material = Enum.Material.Ice
				part2.Material = Enum.Material.Sand
			end

			task.delay(v4, function()
				TweenService2:Create(part, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Size = createVector(0.01, 0.01, 0.01)
				}):Play()
				TweenService2:Create(part2, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
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

	local function InnerRocksLoop()
		for _ = 1, p3 do
			local v5 = v * CFrame.fromEulerAnglesXYZ(0, math.rad(total), 0) * CFrame.new(p / 2 + p / 10, 10, 0)
			local raycastResult = game.Workspace:Raycast(v5.Position, v5.UpVector * -20, vfxUtility.RayParams.Map)
			total += v2

			if not raycastResult then
				continue
			end

			local get_Part = Craters_Config.Get_Part()
			local get_Part2 = Craters_Config.Get_Part()
			get_Part.CFrame = CFrame.new(raycastResult.Position - Vector3.new(0, v3.Y * 0.4, 0), v.Position) * CFrame.fromEulerAnglesXYZ(
				random2:NextNumber(-1, -0.3),
				random2:NextNumber(-0.15, 0.15),
				random2:NextNumber(-0.15, 0.15)
			)
			get_Part.Size = Vector3.new(v3.X * 1.3, v3.Y * 0.7, v3.Z * 1.3) * random2:NextNumber(1, 1.5)
			get_Part2.Size = Vector3.new(get_Part.Size.X * 1.01, get_Part.Size.Y * 0.25, get_Part.Size.Z * 1.01)
			get_Part2.CFrame = get_Part.CFrame * CFrame.new(0, get_Part.Size.Y / 2 - get_Part2.Size.Y / 2.1, 0)

			if raycastResult.Instance.Material == Enum.Material.Concrete or raycastResult.Instance.Material == Enum.Material.Air or raycastResult.Instance.Material == Enum.Material.Wood or raycastResult.Instance.Material == Enum.Material.Neon or raycastResult.Instance.Material == Enum.Material.WoodPlanks then
				get_Part.Material = raycastResult.Instance.Material
			else
				get_Part.Material = Enum.Material.Concrete
			end

			get_Part2.Material = raycastResult.Instance.Material
			get_Part.BrickColor = BrickColor.new("Dark grey")
			get_Part.Anchored = true
			get_Part.CanTouch = false
			get_Part.CanCollide = false
			get_Part2.BrickColor = raycastResult.Instance.BrickColor
			get_Part2.Anchored = true
			get_Part2.CanTouch = false
			get_Part2.CanCollide = false

			if p4 then
				get_Part.BrickColor = BrickColor.new("Pastel light blue")
				get_Part2.BrickColor = BrickColor.new("Lily white")
				get_Part.Material = Enum.Material.Ice
				get_Part2.Material = Enum.Material.Sand
			end

			task.delay(v4, function()
				TweenService2:Create(get_Part, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Size = createVector(0.01, 0.01, 0.01)
				}):Play()
				TweenService2:Create(get_Part2, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Size = createVector(0.01, 0.01, 0.01),
					CFrame = get_Part.CFrame * CFrame.new(0, get_Part.Size.Y / 2 - get_Part.Size.Y / 2.1, 0)
				}):Play()
			end)
			Craters_Config.Delete_Part(get_Part, v4 + 0.6)
			Craters_Config.Delete_Part(get_Part2, v4 + 0.6)
		end
	end

	InnerRocksLoop()
	OuterRocksLoop()
end

local v = {
	InnerRadius = 10,
	OuterRadius = 15,
	Lifetime = 1.5,
	Amount = 12,
	Size = 0.5,
	GroundAllowance = -20,
	Velocity = {
		Min = 20,
		Max = 40
	}
}

function CraterExtension:GroundRocks()
	local CF = self.CF

	if not CF then
		return false
	end

	self.InnerRadius = self.InnerRadius or v.InnerRadius
	self.OuterRadius = self.OuterRadius or v.OuterRadius
	self.Lifetime = self.Lifetime or v.Lifetime
	self.Amount = self.Amount or v.Amount
	self.Size = self.Size or v.Size
	self.GroundAllowance = self.GroundAllowance or v.GroundAllowance
	self.Velocity = self.Velocity or v.Velocity
	local v2 = {}

	for i = 1, 360, 360 / self.Amount do
		local v3 = math.random(self.InnerRadius, self.OuterRadius) * math.cos((math.rad(i)))
		local v4 = math.random(self.InnerRadius, self.OuterRadius) * math.sin((math.rad(i)))
		local raycastResult = workspace:Raycast(
			(CF * CFrame.new(v3, 10, v4)).Position,
			Vector3.new(0, self.GroundAllowance, 0),
			vfxUtility.RayParams.Map
		)

		if not (raycastResult and raycastResult.Instance) then
			continue
		end

		local v5 = typeof(self.Size) == "table" and math.random(self.Size.Min * 10, self.Size.Max * 10) / 10 or self.Size
		local part = Instance.new("Part")
		part.CFrame = CFrame.new(raycastResult.Position) * CFrame.Angles(
			math.rad((math.random(-180, 180))),
			math.rad((math.random(-180, 180))),
			(math.rad((math.random(-180, 180))))
		)
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.Material = raycastResult.Material
		part.Size = createVector(0, 0, 0)
		part.MaterialVariant = raycastResult.Instance.MaterialVariant
		part.Color = raycastResult.Instance.Color
		part.CanQuery = false
		part.CanTouch = false
		part.CollisionGroup = "Debree"
		local tween = TweenService2:Create(part, TweenInfo.new(0.25), {
			Size = createVector(1, 1, 1) * v5
		})
		tween:Play()
		tween:Destroy()
		v2[#v2 + 1] = part
		local attachment = Instance.new("Attachment")
		local linearVelocity = Instance.new("LinearVelocity")
		linearVelocity.MaxForce = 40000
		linearVelocity.Attachment0 = attachment
		linearVelocity.VectorVelocity = vector.create(0, 1 * random(self.Velocity.Min, self.Velocity.Max), 0)
		linearVelocity.Parent = attachment
		attachment.Parent = part
		Debris:AddItem(attachment, 0.25)
	end

	task.wait(self.Lifetime)

	for _, v3 in pairs(v2) do
		local tween = TweenService2:Create(v3, TweenInfo.new(0.5), {
			Size = createVector(0, 0, 0)
		})
		tween:Play()
		tween:Destroy()
		Debris:AddItem(v3, 0.5)
		task.wait(0.1)
	end
end

return CraterExtension