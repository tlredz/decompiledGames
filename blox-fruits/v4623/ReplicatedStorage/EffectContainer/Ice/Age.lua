local createVector = vector.create
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage:WaitForChild("FX"))
local iceAge = FX:WaitForChild("IceEffects").IceAge
local GetWaterHeightAtLocation = require(game.ReplicatedStorage.Util.GetWaterHeightAtLocation)
return function(data)
	local cFrame = data.CFrame
	local duration = data.Duration or 0.4
	local scale = data.Scale or 7
	local radius = data.Radius or 20
	local offset = data.Offset or 10

	if not data.Color then
		Color3.fromRGB(110, 153, 202)
	end

	local magnitude = (cFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude

	if 750 + radius * 2 < magnitude then
		return
	end

	local v = duration * 0.85
	local halfRadius = radius / 2
	local halfOffset = offset / 2
	local halfScale = scale / 2
	local v5 = math.ceil(halfRadius / 5.4)
	local v6 = cFrame * CFrame.new(0, 0.1, 0)
	local ray = Util.Ray
	local p = v6.p
	local v7 = { workspace.Characters, workspace.Enemies }
	local v8, vector2, v9 = ray(p, createVector(0, -10, 0), v7)

	if not v8 and vector2.Y < ({ GetWaterHeightAtLocation(vector2) })[1] then
		vector2 = Vector3.new(vector2.X, ({ GetWaterHeightAtLocation(vector2) })[1], vector2.Z)
		v9 = createVector(0, 1, 0)
	end

	if vector2.Y < ({ GetWaterHeightAtLocation(vector2) })[1] then
		vector2 = Vector3.new(vector2.X, ({ GetWaterHeightAtLocation(vector2) })[1], vector2.Z)
		v9 = createVector(0, 1, 0)
	end

	if not v8 then
		vector2 = v6.p
		v9 = createVector(0, 1, 0)
	end

	local cFrame2 = CFrame.new(vector2, vector2 + v9) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(0, 0.1, 0)

	if (cFrame2.p - workspace.CurrentCamera.CFrame.Position).Magnitude < halfRadius + 50 then
		local clone = iceAge.Blur:Clone()
		clone.Parent = game.Lighting
		TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Size = 0
		}):Play()
		task.delay(0.3, function()
			clone:Destroy()
		end)
	end

	local clone = iceAge.eff:Clone()
	clone.CFrame = cFrame2
	clone.Parent = workspace._WorldOrigin
	Util.Debris:AddItem(clone, 4)

	for _, child in ipairs(clone.Attachment:GetChildren()) do
		Util.ScaleParticle({
			Emitter = child,
			Scale = halfRadius / 40,
			Time = 0
		})
		child:Emit((math.ceil(child:GetAttribute("EmitCount") * 0.4)))
	end

	local clone2 = FX:WaitForChild("IceEffects").IceAge.Floor:Clone()
	clone2.Transparency = 1
	clone2.CFrame = cFrame2 * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0)
	clone2.Size = clone2.Size.unit
	clone2.Material = "Neon"
	clone2.Parent = workspace._WorldOrigin
	local tween = TweenService:Create(clone2, TweenInfo.new(v, Enum.EasingStyle.Exponential), {
		Transparency = 0,
		Size = clone2.Size * halfRadius * 5.75 * (v8 and 1 or 0.75) * createVector(1, 0, 1) + createVector(0, 1, 0)
	})
	tween.Completed:Connect(function()
		task.wait(0.25)
		clone2.Material = "Glass"
		local v11 = v * 14
		task.delay(v11, function()
			local tween2 = TweenService:Create(
				clone2,
				TweenInfo.new(v11 * 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					Size = Vector3.new()
				}
			)
			tween2.Completed:Connect(function()
				clone2:Destroy()
			end)
			tween2:Play()
		end)
	end)
	tween:Play()
	local descendants = iceAge.Cube:GetDescendants()

	for i = 1, 3 do
		for i2 = 1, 360, 360 / v5 do
			if math.random() > 0.6666 then
				continue
			end

			local v11 = cFrame2 * CFrame.Angles(0, math.rad(i2) + 9 * (math.random() - 0.5) / v5, 0) * CFrame.new(
				(math.random() - 0.5) * halfScale * i / 1.5,
				0.5,
				-halfOffset - halfRadius * i / 3 + halfScale / 2
			) * CFrame.Angles(-0.666, 0, 0)
			local v12 = halfScale * (0.9 + math.random() * 0.6)
			local clone3 = FX:WaitForChild("IceEffects").IceStomp["Spike" .. math.random(1, 5)]:Clone()
			clone3.Transparency = 1
			clone3.CFrame = v11 * CFrame.Angles(-0.5 - math.random() * 0.2, 0, 0)
			clone3.Size = clone3.Size.unit
			clone3.Parent = workspace._WorldOrigin

			for _, emitter in pairs(descendants) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local clone4 = emitter:Clone()
				Util.ScaleParticle({
					Emitter = clone4,
					Scale = v12 / 6,
					Time = 0
				})
				clone4.Parent = clone3
				clone4:Emit((math.ceil(emitter:GetAttribute("EmitCount") * 0.4)))
			end

			local v14 = v * 1.5 + math.random() * v * 0.25
			local tween2 = TweenService:Create(clone3, TweenInfo.new(v14, Enum.EasingStyle.Exponential), {
				Transparency = 0,
				CFrame = clone3.CFrame * CFrame.new(0, v12 / 2, 0),
				Size = clone3.Size * v12 * (2 + math.random() * 1.25) * createVector(1, 1, 1) * ((i - 1) * 0.5 + 1)
			})
			tween2.Completed:Connect(function()
				task.wait(0.15)
				clone3.Material = "Glass"
				local v18 = v14 * (11 + math.random() * 3) * 0.6
				task.wait(0.1 + v18)
				local tween3 = TweenService:Create(
					clone3,
					TweenInfo.new(v18 * 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						CFrame = clone3.CFrame * CFrame.new(0, -v12 / 2, 0),
						Size = Vector3.new()
					}
				)
				tween3.Completed:Connect(function()
					clone3.Transparency = 1
					wait(4)
					clone3:Destroy()
				end)
				tween3:Play()
			end)
			tween2:Play()
		end

		wait()
	end
end