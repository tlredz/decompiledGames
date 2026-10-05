local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(game.ReplicatedStorage.FX)
local _ = Util.Sound
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(p)
	local origin = p.Origin
	local v = math.clamp(p.TargetSize or 0, 0, 5)
	local magnitude = (origin.p - workspace.CurrentCamera.CFrame.p).magnitude

	if 400 + (not v and 0 or v * 100 or 0) < magnitude then
		return
	end

	for i = 1, 4 do
		for i2 = 0, 360, 36 do
			local v2 = origin * CFrame.Angles(0, math.rad(i2), 0)
			local cFrame = v2 * CFrame.new(0, -1.5, -40)
			local clone = game.ReplicatedStorage.Assets.Models.SandBall:Clone()
			clone.Mesh.Scale = createVector(28.5, 3, 3)
			clone.CFrame = cFrame
			local clone2 = FX:WaitForChild("SandDust"):Clone()
			clone2.Size = NumberSequence.new(4)
			clone2.Rate = 50
			clone2.Parent = clone
			clone.Parent = _WorldOrigin
			TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
				CFrame = v2 * CFrame.new(0, 0, -10)
			}):Play()
			local tween = TweenService:Create(clone.Mesh, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
				Scale = createVector(8.4, 3, 3)
			})
			local v7 = i
			local v8 = i2
			tween.Completed:Connect(function()
				clone2.Enabled = false

				if v then
					TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
						CFrame = v2 * CFrame.new(0, 0, -0.1)
					}):Play()
					local tween2 = TweenService:Create(
						clone.Mesh,
						TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							Scale = createVector(10, 10, 10) * v
						}
					)
					tween2.Completed:Connect(function()
						if v7 > 1 then
							TweenService:Create(clone.Mesh, TweenInfo.new(v7 / 9, Enum.EasingStyle.Sine), {
								Scale = Vector3.new(v7 * 6 + 30, 0, v7 * 6 + 30) * v / 2
							}):Play()
							local tween3 = TweenService:Create(clone, TweenInfo.new(v7 / 9, Enum.EasingStyle.Sine), {
								CFrame = v2 * CFrame.new(0, -0.1, 0)
							})
							tween3.Completed:Connect(function()
								clone:Destroy()
							end)
							tween3:Play()
						else
							local tween3 = TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Sine), {
								CFrame = v2 * CFrame.new(0, v * 10 + 20, 0)
							})
							tween3.Completed:Connect(function()
								local tween4 = TweenService:Create(
									clone.Mesh,
									TweenInfo.new(0.3, Enum.EasingStyle.Quad),
									{
										Scale = createVector(7.5, 7.5, 7.5) * v
									}
								)
								tween4.Completed:Connect(function()
									clone2.SpreadAngle = Vector2.new(360, 360)
									clone2.Size = NumberSequence.new(v * 2)
									clone2:Emit(8)
									local v9 = 0.3 + math.random() * 0.1
									TweenService:Create(clone, TweenInfo.new(v9), {
										CFrame = clone.CFrame * CFrame.Angles(
											math.random() * 3.141592653589793 * 2,
											math.random() * 3.141592653589793 * 2,
											math.random() * 3.141592653589793 * 2
										) * CFrame.new(0, 0, math.random(24, 34) * v)
									}):Play()
									local tween5 = TweenService:Create(clone.Mesh, TweenInfo.new(v9), {
										Scale = createVector(0, 0, 3)
									})
									tween5.Completed:Connect(function()
										clone:Destroy()
									end)
									tween5:Play()

									if v8 == 0 then
										Util.Sound:Play("ShortExplosionLoud", clone.Position)
									end
								end)
								tween4:Play()
							end)
							tween3:Play()
						end
					end)
					tween2:Play()
				else
					TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
						CFrame = clone.CFrame * CFrame.new(0, -0.25, 0)
					}):Play()
					local tween2 = TweenService:Create(clone.Mesh, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
						Scale = clone.Mesh.Scale * createVector(1, 0, 4) * 3.5
					})
					tween2.Completed:Connect(function()
						clone:Destroy()
					end)
					tween2:Play()
				end
			end)
			tween:Play()
		end

		Util.Sound:Play("SetFire", origin)
		wait(0.1)
	end
end