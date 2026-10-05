local createVector = vector.create
local Players = game:GetService("Players")
Players = Players.LocalPlayer
require(game.ReplicatedStorage.Modules.Server)
local Rocks = {}
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local v = math.random(8, 17)

function Rocks.Spawn(instance)
	TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local v2 = 360 / v
	local model = Instance.new("Model")
	model.Parent = workspace
	Debris:AddItem(model, 5.75)

	for i = 1, v do
		local v3 = math.sin(3.141592653589793 / v) * 7.75 * 2 * 1.01
		local v4 = instance.CFrame * CFrame.Angles(0, math.rad(i * v2), 0) * CFrame.new(0, 0, 7.75) * CFrame.Angles(
			0.7853981633974483,
			0,
			0
		)
		local v5 = 1.475 * math.random(50, 120) / 100
		local v6 = CFrame.new(v4.Position) * CFrame.new(0, 5.07, 0)
		local part, v7, v8 = workspace:FindPartOnRayWithWhitelist(
			Ray.new(v6.Position, v6.UpVector * -10.14),
			{ workspace.Places }
		)

		if not (part and part.Transparency ~= 1) then
			continue
		end

		local clone = script.Part:Clone()
		clone.CanCollide = false
		clone.Size = Vector3.new(v3, v5, v5)
		clone.Color = part.Color
		clone.Material = part.Material
		clone.MaterialVariant = part.MaterialVariant
		local v9 = v7.Y < v4.Position.Y and -1 or 1
		local _ = v4 * CFrame.new(0, (v4.Position - v7).Magnitude * v9, 0)
		local cframe = CFrame.new(v7, v7 + v8) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone.CFrame = instance.CFrame * CFrame.Angles(0, math.rad(i * v2), 0) * CFrame.new(0, 0, 3.875)
		clone.Parent = model
		local components, v10, v11 = instance.CFrame:components()
		local _, _, _, v12, v13, v14, v15, v16, v17, v18, v19, v20 = cframe:GetComponents()
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
			{
				CFrame = CFrame.new(
					cframe.Position,
					CFrame.new(components, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20).Position
				) * CFrame.Angles(math.rad((math.random(20, 50))), 0, 0)
			}
		)
		tween:Play()
		tween:Destroy()
		coroutine.resume(coroutine.create(function()
			wait(5.5)

			if clone then
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
					TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
					{
						CFrame = clone.CFrame * CFrame.new(0, -0.043750000000000004, 0)
					}
				)
				tween3:Play()
				tween3:Destroy()
			end
		end))
	end

	instance:Destroy()
end

return Rocks