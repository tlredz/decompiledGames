local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("Util"))
local RockRipple1 = {}

local function calculateRockDetails(p)
	local v = 6.283185307179586 * p
	local v2 = v / 18
	local v3 = math.floor(v / v2)
	local v4 = (1 + math.random() * 0.3) * 0.8
	local v5 = (1 + math.random() * -0.4) * 1.2
	local v6 = (1 + math.random() * -0.5) * 0.6
	return v3, (Vector3.new(v2 * v4, v2 / 2 * v5, v2 * v6))
end

local function randomTilt()
	return CFrame.Angles(
		math.rad((math.random(-15, 15))) * 2 + 1.35,
		math.rad((math.random(-15, 15))),
		(math.rad((math.random(-15, 15))))
	)
end

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include

-- equivalent calls inferred from this helper; original call sites unknown
local function castRayAboveAndSetColor(clone, vector2)
	local v = vector2 + createVector(0, 5, 0)
	local raycastResult = workspace:Raycast(v, createVector(0, -10, 0), raycastParams)

	if not raycastResult then
		return false
	end

	local instance = raycastResult.Instance
	clone.Color = instance.Color
	clone.Material = instance.Material
	return true
end

local function rippleTween(clone, vector2, p, p2, p3)
	local position = vector2 - Vector3.new(0, p2 + clone.Size.Y / 2, 0)
	clone.Position = position
	clone.Parent = workspace
	local v2 = p / p3 * (1 + math.random() * 1)
	local tween = TweenService:Create(clone, TweenInfo.new(v2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Position = vector2
	})
	tween.Completed:Connect(function()
		task.wait(1.5 + math.random() / 2.5)
		local v3 = {
			Position = position - createVector(0, 1, 0) * p2 / 1.5
		}
		TweenService:Create(clone, TweenInfo.new(v2 * 1.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), v3):Play()
	end)
	tween:Play()
end

local function shockwaveTween(clone, vector2, vector3, p, p2)
	local v = {
		Position = vector3 + (vector3 - vector2).unit * 3,
		Size = p * 2
	}
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(0.85 / p2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		v
	)
	tween.Completed:Connect(function()
		task.wait(1.5 + math.random() / 2.5)
		local v2 = {
			Position = vector2 - createVector(0, 4.6666665, 0)
		}
		TweenService:Create(
			clone,
			TweenInfo.new(0.425 / p2 * 1.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			v2
		):Play()
	end)
	tween:Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function makeRockFaceCenter(clone, vector2, data)
	local _ = (data - vector2).unit
	clone.CFrame = CFrame.lookAt(vector2, data) * randomTilt()
end

local function createRockLayer(p, data, instance, p2, p3, p4)
	local v, size = calculateRockDetails(p)
	local clones = {}

	for i = 1, v do
		local v3 = 6.283185307179586 / v * i
		local v4 = data.X + p * math.cos(v3)
		local v5 = data.Z + p * math.sin(v3)
		local vector2 = Vector3.new(v4, data.Y, v5)

		if math.random() < 0.4 + (1 - p4) ^ 0.5 * 0.575 then
			continue
		end

		local clone = instance:Clone()
		clone.Size = size
		makeRockFaceCenter(clone, vector2, data) -- equivalent call inferred; original call site unknown

		-- equivalent call inferred; original call site unknown
		if castRayAboveAndSetColor(clone, vector2) then
			if p3 then
				shockwaveTween(clone, vector2, vector2, size, p2)
			else
				rippleTween(clone, vector2, 0.425, 7, p2)
			end

			table.insert(clones, clone)
		else
			clone:Destroy()
		end
	end

	return clones
end

function RockRipple1.createRippleEffect(p, p2, p3, p4, p5, p6)
	local v = {}

	for i = 1, p3 do
		local v2 = p4 + (i - 1) * p5
		local v3 = i == p3
		table.insert(v, (createRockLayer(v2, p2, p, p6, v3, i / p3)))
		task.wait(0.05 / p6)
	end

	task.wait(7 / p6)

	for _, list in ipairs(v) do
		for _, v2 in ipairs(list) do
			v2:Destroy()
		end
	end
end

return RockRipple1