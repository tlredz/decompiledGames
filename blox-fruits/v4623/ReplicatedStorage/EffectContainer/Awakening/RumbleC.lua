local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local Lightning = require(game.ReplicatedStorage.Util.Lightning)
local FX = require(game.ReplicatedStorage.FX)
local glowingCrack = game.ReplicatedStorage.Assets.Models.GlowingCrack
local burntArea = game.ReplicatedStorage.Assets.Models.BurntArea
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(p)
	local target = p.Target
	local position = target + createVector(0, 200, 0)

	if (target - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
		return
	end

	local v2 = masterClock:GetTime() - p.Timestamp

	if v2 > 2 then
		return
	end

	local ray = Util.Ray
	local v3 = { workspace.Characters, workspace.Enemies }
	local _, vector2 = ray(position, createVector(-0, -1000, -0), v3)

	if vector2.Y < -4 then
		vector2 = Vector3.new(vector2.X, -4, vector2.Z)
	end

	local v4 = Util.Sound:Play("Thunder", position)

	for i = 0, 4, 0.6 do
		local clone = game.ReplicatedStorage.Assets.Models.ThorCloud:Clone()
		clone.CFrame = CFrame.new(position) * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0) + Vector3.new(
			math.sin(i * 1.57) * i * 12,
			0,
			math.cos(i * 1.57) * i * 12
		)
		clone.Mesh.Scale = Vector3.new()
		TweenService:Create(clone.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
			Scale = Vector3.new(25, 9 + math.random() * 2, 30) * (1 + math.random() * 0.5) * 5
		}):Play()
		clone.Parent = workspace._WorldOrigin
		local tween = TweenService:Create(clone.Mesh, TweenInfo.new(0.75, Enum.EasingStyle.Quad), {
			Scale = Vector3.new()
		})
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		delay(2, function()
			tween:Play()
		end)
	end

	wait(0.55 - v2)
	Util.Sound:Play("BigBangFire", vector2)
	local v5 = Util.Sound:Play("ElectricExplosionLong2", vector2)
	local lastTime = tick()
	local parent = false
	local clone = false
	local clones = {}

	for i = 1, 38 do
		if tick() - lastTime > 1.6666666666666665 then
			break
		end

		local lerped = position:Lerp(vector2, (math.min(1, i / 6)))
		local size = 2 + math.random() * 2.5 + i / 10
		local color = math.random() > 0.5 and Color3.fromRGB(110, 153, 202) or Color3.fromRGB(40, 225, 255)

		if i < 20 or i % 2 == 0 then
			Lightning.new({
				Lifetime = 0.1 + math.random() * 0.2,
				DrawType = "Singular",
				Colors = {
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(1, color)
				},
				Sizes = {
					{
						Size = size * 0.15,
						Time = 0
					},
					{
						Size = size,
						Time = 0.5
					},
					{
						Size = 0,
						Time = 1
					}
				},
				Transparencies = {
					{
						Transparency = 0,
						Time = 0
					},
					{
						Transparency = 0,
						Time = 1
					}
				},
				Points = {
					Start = {
						Position = position
					},
					End = {
						Position = lerped
					}
				},
				ArcSize = {
					Min = i * 0.5 + 10,
					Max = i * 1.5 + 20
				},
				ChangesSegmentOffset = true,
				OffsetChangePercent = {
					EqualOrBelow = 0.15,
					Bounds = { 0, 1 }
				}
			})
		end

		if i <= 5 or i % 2 == 0 then
			local clone2 = FX:WaitForChild("RumbleV2").RingRumble:Clone()
			clone2.Transparency = 0.3
			clone2.Color = Color3.fromRGB(110, 153, 202)
			clone2.Size = createVector(13.762, 0.534, 13.762)
			clone2.CFrame = CFrame.new(lerped) * CFrame.Angles(3.141592653589793, 0, 0)
			clone2.Parent = workspace._WorldOrigin
			local tween = TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
				Transparency = 1,
				Size = clone2.Size * math.min(27.5, i * 0.5 + 7.5),
				Color = Color3.new(1, 1, 1)
			})
			tween.Completed:Connect(function()
				clone2:Destroy()
			end)
			tween:Play()
			local clone3 = FX:WaitForChild("RumbleV2").ThunderSpike:Clone()
			clone3.Transparency = 0
			clone3.Anchored = true
			clone3.CanCollide = false
			clone3.Size *= i <= 5 and createVector(4, 6, 4) or createVector(10, 4, 10) * (i / 70 + 1)
			clone3.Color = Color3.fromRGB(40, 225, 255)
			clone3.CFrame = CFrame.new(lerped) * CFrame.new(0, clone3.Size.Y / 2, 0)
			clone3.Parent = workspace._WorldOrigin
			local tween2 = TweenService:Create(clone3, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
				Size = clone3.Size * createVector(0, 3, 0),
				Color = Color3.new(1, 1, 1),
				CFrame = clone3.CFrame * CFrame.new(0, clone3.Size.Y / 2, 0)
			})
			tween2.Completed:Connect(function()
				clone3:Destroy()
			end)
			tween2:Play()

			if not parent then
				local ray2 = Util.Ray
				local v10 = lerped + createVector(0, 1, 0)
				local v11 = { workspace.Enemies, workspace.Characters }
				local v12, v13, v14 = ray2(v10, createVector(0, -10, 0), v11)

				if v12 then
					local cFrame = CFrame.new(v13, v13 + v14) * CFrame.Angles(-1.5707963267948966, 0, 0)
					parent = Instance.new("Attachment")
					parent.CFrame = cFrame
					parent.Parent = workspace.Terrain
					local clone4 = FX:WaitForChild("ThorDust"):Clone()
					clone4.Size = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 10),
						NumberSequenceKeypoint.new(1, 60)
					})
					clone4.Rate *= 1.25
					clone4.Speed = NumberRange.new(clone4.Speed.Min * 1.4, clone4.Speed.Max * 1.4)
					clone4.Color = ColorSequence.new(v12.Color)
					clone4.Parent = parent

					for i2 = 1, 3 do
						local clone5 = glowingCrack:Clone()
						clone5.Size = createVector(0.05, 0.05, 0.05)
						clone5.Beam.Transparency = NumberSequence.new(1)
						clone5.Attachment0.CFrame = CFrame.new(0, 0, 65)
						clone5.Attachment1.CFrame = CFrame.new(0, 0, -65)
						clone5.Beam.Color = ColorSequence.new(Color3.fromRGB((i2 - 1) * 16 + 4, 180, 255))
						clone5.Beam.Width0 = 130
						clone5.Beam.Width1 = 130
						clone5.CFrame = (cFrame + createVector(0, 0.2, 0)) * CFrame.Angles(
							0,
							math.random() * 3.141592653589793 * 2,
							1.5707963267948966
						)
						clone5.Parent = workspace._WorldOrigin
						table.insert(clones, clone5)
					end

					clone = burntArea:Clone()
					clone.Decal.Transparency = 1
					clone.Size = createVector(221, 0, 221)
					clone.Decal.Color3 = v12.Color
					clone.CFrame = cFrame * CFrame.Angles(0, 3.141592653589793 * math.random() * 2, 0) + createVector(
						0,
						0.1,
						0
					)
					clone.Parent = workspace._WorldOrigin
					TweenService:Create(clone.Decal, TweenInfo.new(0.6), {
						Transparency = 0.4
					}):Play()
					coroutine.resume(coroutine.create(function()
						local lastTime2 = tick()

						while clone and clone.Parent and tick() - lastTime2 < 0.6 do
							local v16 = math.min(tick() - lastTime2, 0.6)

							for _, v17 in pairs(clones) do
								v17.Beam.Transparency = NumberSequence.new(1 - v16)
							end

							RunService.RenderStepped:Wait()
						end

						for _, v16 in pairs(clones) do
							v16.Beam.Transparency = NumberSequence.new(0.4)
						end
					end))
				end
			end
		end

		wait()
	end

	if parent then
		parent.ThorDust.Enabled = false
		Util.Sound:FadeOut(v5, 0.5)
		wait(1.5)
		parent:Destroy()
		Util.Sound:FadeOut(v4, 0.7)
		local tween = TweenService:Create(clone.Decal, TweenInfo.new(2), {
			Transparency = 1
		})
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		tween:Play()
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = 0.4
		TweenService:Create(numberValue, TweenInfo.new(2.5), {
			Value = 1
		}):Play()
		coroutine.resume(coroutine.create(function()
			while clone and clone.Parent do
				for _, v7 in pairs(clones) do
					v7.Beam.Transparency = NumberSequence.new(numberValue.Value)
				end

				RunService.RenderStepped:Wait()
			end

			for _, v7 in pairs(clones) do
				v7:Destroy()
			end

			numberValue:Destroy()
		end))
	end
end