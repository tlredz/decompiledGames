local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utility = script.Parent.Utility
local MathHelper = require(utility.MathHelper)
local VisualHelper = require(utility.VisualHelper)
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local Cache = require(script.Cache)
local Rocks = {}
Rocks.Cache = Cache("Default", workspace.Terrain)
Rocks.Random = Random.new()

function Rocks.CircleRocks(p, vector2: Vector3, p2: number, p3: number, vector3: Vector3, duration: number, ...)
	local v = {}

	for i = 1, p2 do
		local v2 = CFrame.new(vector2 + createVector(0, 1, 0)) * CFrame.Angles(0, math.rad(i * (360 / p2)), 0) * CFrame.new(
			0,
			0,
			-p3
		)
		local rayCast = MathHelper:RayCast(v2.Position, v2.UpVector * -15, ...)

		if not rayCast then
			continue
		end

		local v3 = p.Cache:Get()
		v3.Color = rayCast.Instance.Color
		v3.Material = rayCast.Instance.Material
		v3.CFrame = CFrame.lookAt(rayCast.Position, (Vector3.new(vector2.X, rayCast.Position.Y, vector2.Z))) * CFrame.fromEulerAnglesXYZ(
			0.2 + p.Random:NextNumber(-0.7, -0.5),
			p.Random:NextNumber(-0.1, 0.1),
			p.Random:NextNumber(-0.15, 0.15)
		)
		v3.Position -= Vector3.new(0, vector3.Y / 2 / 2 + 0.3)
		v3.Size = Vector3.new(vector3.X * 1.3, vector3.Y / 1.4, vector3.Z * p.Random:NextNumber(1.3, 3.5)) * p.Random:NextNumber(
			1,
			1.5
		)
		table.insert(v, v3)
	end

	task.delay(duration, function()
		for _, v2 in v do
			VisualHelper:Tween(
				v2,
				TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, p.Random:NextNumber(0, 2)),
				{
					Size = createVector(0, 0, 0)
				}
			)
		end

		task.wait(3)

		for _, v2 in v do
			p.Cache:Release(v2)
		end
	end)
end

function Rocks.JoinRocks(p, cframe: CFrame, p2: number, p3: number, vector2: Vector3, duration: number, duration2: number, ...)
	local v = {}

	for i = 0, 360, 360 / p2 do
		if i == 0 then
			continue
		end

		local v2 = math.sin(3.141592653589793 / p2) * p3 * 2 * 1.01
		local v3 = cframe * CFrame.Angles(0, math.rad(i), 0) * CFrame.new(0, -2, p3) * CFrame.Angles(
			0.7853981633974483,
			0,
			0
		)
		local v4 = vector2 * math.random(50, 120) / 100
		local v5 = 5 + vector2 * 2
		local v6 = CFrame.new(v3.Position) * CFrame.new(0, v5, 0)
		local rayCast = MathHelper:RayCast(v6.Position, v6.UpVector * (-v5 * 5.5), ...)

		if not rayCast then
			continue
		end

		local v7 = p.Cache:Get()
		v7.Material = rayCast.Instance.Material
		v7.Color = rayCast.Instance.Color
		v7.CFrame = cframe * CFrame.Angles(0, math.rad(i), 0) * CFrame.new(0, 0, p3 / 2)
		v7.Size = Vector3.new(v2, v4, v4)
		table.insert(v, v7)
		local v8 = rayCast.Position.Y < v3.Position.Y and -1 or 1
		local _ = v3 * CFrame.new(0, (v3.Position - rayCast.Position).Magnitude * v8, 0)
		local v9 = CFrame.new(rayCast.Position, rayCast.Position + rayCast.Normal) * CFrame.Angles(
			1.5707963267948966,
			0,
			0
		)
		local components, v10, v11 = cframe:components()
		local _, _, _, v12, v13, v14, v15, v16, v17, v18, v19, v20 = v9:components()
		VisualHelper:Tween(v7, TweenInfo.new(duration, Enum.EasingStyle.Quad), {
			CFrame = CFrame.new(
				v9.Position,
				CFrame.new(components, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20).Position
			) * CFrame.Angles(math.rad((math.random(20, 50))), 0, 0)
		})
	end

	task.delay(duration2, function()
		for _, v2 in v do
			VisualHelper:Tween(v2, TweenInfo.new(1, Enum.EasingStyle.Quad), {
				Size = createVector(1, 0, 0)
			})
			VisualHelper:Tween(v2, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
				CFrame = v2.CFrame * CFrame.new(0, -vector2 * 1.25, 0)
			})
		end

		task.wait(1)

		for _, v2 in v do
			p.Cache:Release(v2)
		end
	end)
end

function Rocks.AirRocks(p, cframe: CFrame, size: Vector3, value, p2: number, duration: number, duration2: number, value2: number?, color: Color3?, p3, p4, callback)
	local v = value2 or 10
	local v2 = p4 or p.Cache.Template:Clone()
	v2.Anchored = false
	v2.Material = p3 or v2.Material
	v2.Color = color or v2.Color
	v2.Size = size
	v2.CFrame = cframe * CFrame.Angles(
		math.rad((p.Random:NextNumber(-360, 360))),
		math.rad((p.Random:NextNumber(-360, 360))),
		(math.rad((p.Random:NextNumber(-360, 360))))
	)

	if typeof(value) == "string" then
		v2.CollisionGroup = value
	else
		v2.CanCollide = value
	end

	v2.Parent = p.Cache.Parent
	rocks:ApplyCollision(v2, nil, true)
	task.delay(duration, function()
		if typeof(callback) == "function" then
			return callback(v2)
		end

		VisualHelper:Tween(v2, TweenInfo.new(duration2), {
			Size = createVector(0, 0, 0)
		})
		task.wait(duration2)
		v2:Destroy()
	end)
	v2.AssemblyLinearVelocity = CFrame.lookAt(
		cframe.Position,
		cframe.Position + Vector3.new(p.Random:NextNumber(-0.5, 0.5), 1, p.Random:NextNumber(-0.5, 0.5))
	).LookVector * p2

	if v then
		v2.AssemblyAngularVelocity = Vector3.new(math.random(v), math.random(v), math.random(v))
	end

	return v2
end

return Rocks