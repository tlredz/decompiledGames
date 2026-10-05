local createVector = vector.create
local Effect = require(game.ReplicatedStorage.Effect)
local Util = require(game.ReplicatedStorage.Util)
local TweenService = game:GetService("TweenService")

local function func(data)
	local cFrame = data.CFrame
	local radius = data.Radius
	local darkChance = data.DarkChance or 0.3
	Util.Sound:Play("QuickSlice", cFrame)

	for _ = 1, math.random(2, 3) * (data.Evolution and 1 or 2) do
		local v2 = darkChance > 1 and createVector(1, 1, 1) * math.floor(math.random() + 0.5) * 3 or Vector3.new()
		task.spawn(function()
			local v3 = {
				CFrame = cFrame * CFrame.Angles(
					3.141592653589793 * math.random() * 2,
					3.141592653589793 * math.random() * 2,
					3.141592653589793 * math.random() * 2
				),
				VertexColor = math.random() < darkChance and v2 or (createVector(0.196, 1, 0.2685)):Lerp(
					createVector(1, 1, 1),
					math.random() * 0.15
				) * 3,
				Scale = createVector(1, 1, 1) * radius * (1 + math.random() * 0.25) * 0.1,
				GrowScale = 0.4 + math.random() * 0.4,
				Step = 1,
				Start = 1,
				RotSpeed = 1.5707963267948966,
				Transparency = { 0.1, 0.2 }
			}
			Effect.new("SpriteSlice"):replicate(v3)
		end)

		for _ = 1, math.random(1, 2) do
			local v3 = 0.03 + math.random() * 0.01
			local v4 = 0.8 + math.random() * 0.4
			local clone = script.LightningSpark:Clone()
			clone.Mesh.Scale = Vector3.new(v3, v4, v3) * (radius / 10)
			clone.CFrame = cFrame * CFrame.Angles(
				3.141592653589793 * math.random() * 2,
				3.141592653589793 * math.random() * 2,
				3.141592653589793 * math.random() * 2
			) * CFrame.new(0, radius, radius * (math.random() - 0.5) * 2)
			clone.Decal.Color3 = math.random() < darkChance / 3 and Color3.new(
				darkChance > 1 and 3 or 0,
				darkChance > 1 and 3 or 0,
				darkChance > 1 and 3 or 0
			) or Color3.new(0.5879999846220016, 3, 0.8055000007152557):Lerp(
				Color3.new(3, 3, 3),
				0.15 + math.random() * 0.15
			)
			clone.Parent = workspace._WorldOrigin
			local tween = TweenService:Create(clone.Mesh, TweenInfo.new(0.1), {
				Scale = Vector3.new(),
				Offset = Vector3.new(0, -radius * 2, 0)
			})
			tween.Completed:Connect(function()
				clone:Destroy()
			end)
			tween:Play()
		end

		if data.Evolution then
			wait()
		else
			task.wait()
		end
	end

	task.wait(0.1)
	local v = darkChance > 1 and createVector(1, 1, 1) * math.floor(math.random() + 0.5) * 3 or Vector3.new()
	local v2 = {
		CFrame = cFrame * CFrame.Angles(
			3.141592653589793 * math.random() * 2,
			3.141592653589793 * math.random() * 2,
			3.141592653589793 * math.random() * 2
		),
		VertexColor = math.random() < darkChance and v or (createVector(0.196, 1, 0.2685)):Lerp(
			createVector(1, 1, 1),
			math.random() * 0.15
		) * 3,
		Scale = createVector(1, 1, 1) * radius * (1 + math.random() * 0.25) * 0.1,
		GrowScale = 1.4 + math.random() * 0.4,
		Step = 1,
		Start = math.random(1, 3),
		RotSpeed = 1.5707963267948966,
		Transparency = { 0.2, 0.3 }
	}
	Effect.new("SpriteSlice"):replicate(v2)
end

return func