local createVector = vector.create
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
return function(data)
	local cFrame = data.CFrame
	local scale = data.Scale or 20
	local color = data.Color or Color3.fromRGB(110, 153, 202)
	local duration = data.Duration or 0.4
	local magnitude = (workspace.CurrentCamera.CFrame.p - cFrame.p).Magnitude

	if 750 + scale * 2 < magnitude then
		return
	end

	if data.Stage == 1 then
		tick()

		for _ = 1, 20 do
			local part = Instance.new("Part")
			part.Material = "Neon"
			part.Anchored = true
			part.CastShadow = false
			part.CanCollide = false
			part.Transparency = 1
			part.CFrame = cFrame * CFrame.Angles(
				3.141592653589793 * math.random() * 2,
				3.141592653589793 * math.random() * 2,
				3.141592653589793 * math.random() * 2
			)
			part.Size = createVector(1, 1, 1)
			part.Color = math.random() < 0.5 and color or color:Lerp(Color3.new(1, 1, 1), 0.3)
			local v = scale * (0.4 + math.random() * 0.6)
			local specialMesh = Instance.new("SpecialMesh", part)
			specialMesh.MeshType = "Brick"
			specialMesh.Scale = Vector3.new(0.25, 0.25, v)
			specialMesh.Offset = Vector3.new(0, 0, v / 2)
			part.Parent = workspace._WorldOrigin
			local tweenInfo = TweenInfo.new(duration * 0.5 + math.random() * duration * 0.5, Enum.EasingStyle.Quad)
			TweenService:Create(part, tweenInfo, {
				Transparency = 0
			}):Play()
			local tween = TweenService:Create(specialMesh, tweenInfo, {
				Offset = Vector3.new(),
				Scale = createVector(0.25, 0.25, 0)
			})
			tween.Completed:Connect(function()
				part:Destroy()
			end)
			tween:Play()
		end
	else
		local clone = script.FlashFreeze:Clone()
		clone:SetPrimaryPartCFrame(cFrame * CFrame.new(0, scale * 0.1, 0))
		clone.Parent = workspace._WorldOrigin

		for _, child in pairs(clone:GetChildren()) do
			TweenService:Create(
				child,
				TweenInfo.new(
					0.2 + child.Size.Magnitude * 0.08,
					child.Name == "Color1" and Enum.EasingStyle.Quad or Enum.EasingStyle.Exponential
				),
				{
					Size = child.Size * Vector3.new(scale / 5, scale / 250, scale / 5) * 1.1,
					Transparency = 1,
					CFrame = child.CFrame * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(0, -scale * 0.08, 0)
				}
			):Play()
		end

		Effect.new("Skills.Ice.Boom"):replicate({
			CFrame = cFrame,
			Width = scale * 1.2,
			Duration = 0.25,
			EmbersExtra = data.EmbersExtra
		})
		Effect.new("Skills.Ice.Boom"):replicate({
			CFrame = cFrame,
			Width = scale * 1.1,
			EmbersExtra = data.EmbersExtra
		})
		wait(2)
		clone:Destroy()
	end
end