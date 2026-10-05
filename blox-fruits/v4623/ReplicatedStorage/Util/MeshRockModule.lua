local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
local v = { workspace.Map }
return function(data)
	local Util = require(ReplicatedStorage:WaitForChild("Util"))
	local debris = Util.Debris
	local amount = data.Amount
	local firstDuration = data.FirstDuration
	local rocksLength = data.RocksLength
	local cframe = data.Cframe
	local iteration = data.Iteration
	local max = data.Max
	local v2 = 360 / amount
	local model = Instance.new("Model")
	debris:AddItem(model, firstDuration + rocksLength + 2)

	for i = 1, amount do
		local v3 = math.sin(3.141592653589793 / amount) * iteration * 2 * 1.01
		local v4 = cframe * CFrame.Angles(0, math.rad(i * v2), 0) * CFrame.new(0, 0, iteration) * CFrame.Angles(
			0.7853981633974483,
			0,
			0
		)
		local v5 = max * math.random(50, 120) / 100
		local v6 = 5 + max * 2
		local v7 = CFrame.new(v4.Position) * CFrame.new(0, v6, 0)
		local part, v8, v9 = workspace:FindPartOnRayWithWhitelist(Ray.new(v7.p, v7.upVector * (-v6 * 2)), v)

		if not (part and part.Transparency < 1) then
			continue
		end

		local clone = script.Part:Clone()
		clone.CanCollide = false
		clone.Size = Vector3.new(v3, v5, v5)
		clone.Color = part.Color
		clone.Material = part.Material
		local v10 = v8.Y < v4.Position.Y and -1 or 1
		local _ = v4 * CFrame.new(0, (v4.Position - v8).Magnitude * v10, 0)
		local v11 = CFrame.new(v8, v8 + v9) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone.CFrame = cframe * CFrame.Angles(0, math.rad(i * v2), 0) * CFrame.new(0, 0, iteration / 2)
		clone.Parent = model
		local components, v12, v13 = cframe:components()
		local _, _, _, v14, v15, v16, v17, v18, v19, v20, v21, v22 = v11:components()
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(firstDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
			{
				CFrame = CFrame.new(
					v11.Position,
					CFrame.new(components, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22).Position
				) * CFrame.Angles(math.rad((math.random(20, 50))), 0, 0)
			}
		)
		tween:Play()
		tween:Destroy()
		task.delay(rocksLength, function()
			local tween2 = TweenService:Create(
				clone.Mesh,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
				{
					Scale = createVector(1, 0, 0)
				}
			)
			tween2:Play()
			tween2:Destroy()
			local tween3 = TweenService:Create(
				clone,
				TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
				{
					CFrame = clone.CFrame * CFrame.new(0, -max * 1.25, 0)
				}
			)
			tween3:Play()
			tween3:Destroy()
		end)
	end

	model.Parent = _WorldOrigin
end