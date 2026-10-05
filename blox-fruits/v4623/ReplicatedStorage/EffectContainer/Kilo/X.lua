local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(data)
	local root = data.Root
	local reference = data.Reference

	if not root or (root.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
		return
	end

	if data.Boom then
		local cFrame = data.CFrame
		Util.Sound:Play("LoudTremorWave1", cFrame)

		for i = -1, 1, 2 do
			local clone = script.WaveMesh:Clone()
			clone.CFrame = cFrame * CFrame.Angles(0, -i / 6, 0) * CFrame.new(i * 8, 0, -17)
			clone.Parent = workspace._WorldOrigin
			local tween = TweenService:Create(clone, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {
				Size = createVector(1.25, 37.5, 187.5),
				Transparency = 1,
				CFrame = clone.CFrame * CFrame.new(0, 0, -60) + createVector(0, 2, 0)
			})
			tween.Completed:Connect(function()
				clone:Destroy()
			end)
			tween:Play()
		end

		local clone = script.Boom:Clone()
		clone.Size /= 2
		clone.CFrame = cFrame * CFrame.new(0, 0, -6) + createVector(0, 9, 0)
		clone.Parent = workspace._WorldOrigin
		local tween = TweenService:Create(clone, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {
			Size = createVector(80, 30, 80),
			Transparency = 1,
			CFrame = clone.CFrame + createVector(0, -2.5, 0)
		})
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		tween:Play()

		for i = 1, 10 do
			local clone2 = script.SpinWind:Clone()
			clone2.Transparency = 0.5
			clone2.CFrame = cFrame * CFrame.new(0, 0, -i * 4) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.Angles(
				math.random() * 3.141592653589793 * 2,
				0,
				0
			)
			clone2.Parent = workspace._WorldOrigin
			local tween2 = TweenService:Create(
				clone2,
				TweenInfo.new(0.15 + math.random() * 0.25, Enum.EasingStyle.Quad),
				{
					Size = createVector(62.5, 30, 30),
					Transparency = 1,
					CFrame = clone2.CFrame * CFrame.Angles(3.141592653589793, 0, 0) + cFrame.LookVector * (i * 4 + 15)
				}
			)
			tween2.Completed:Connect(function()
				clone2:Destroy()
			end)
			tween2:Play()

			if i % 3 == 0 then
				local clone3 = script.ThinRing:Clone()
				clone3.Size *= 3
				clone3.CFrame = cFrame * CFrame.new(0, 0, -i * 7) * CFrame.Angles(1.5707963267948966, 0, 0)
				clone3.Parent = workspace._WorldOrigin
				local tween3 = TweenService:Create(clone3, TweenInfo.new(i / 7 + 0.3, Enum.EasingStyle.Exponential), {
					Size = createVector(31.25, 0, 31.25) * (i / 10 + 1),
					Transparency = 1,
					CFrame = clone3.CFrame + cFrame.LookVector * 40
				})
				tween3.Completed:Connect(function()
					clone3:Destroy()
				end)
				tween3:Play()
			end

			local ray = Util.Ray
			local v2 = cFrame.p + createVector(0, 1, 0) + Vector3.new(math.random() - 0.5, 0, math.random() - 0.5).unit * 12
			local v3 = { workspace.Characters, workspace.Enemies }
			local v4, v5 = ray(v2, createVector(0, -10, 0), v3)

			if not v4 then
				continue
			end

			local part = Instance.new("Part")
			part.Color = v4.Color
			part.Material = v4.Material
			part.Transparency = v4.Material
			part.Size = Vector3.new(1 + math.random() * 0.5, 1 + math.random() * 0.5, 1 + math.random() * 0.5) * (1 + math.random()) * 6
			part.CFrame = (CFrame.new(v5) - createVector(0, 4, 0)) * CFrame.Angles(
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2
			)
			part.Anchored = false
			part.CanCollide = false
			part.TopSurface = 0
			part.BottomSurface = 0
			part.Velocity = cFrame.LookVector * math.random(80, 250) + Vector3.new(0, math.random(80, 120), 0)
			part.RotVelocity = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 30
			local tween3 = TweenService:Create(part, TweenInfo.new(0.5 + math.random()), {
				Size = createVector(0.05, 0.05, 0.05)
			})
			tween3.Completed:Connect(function()
				part:Destroy()
			end)
			tween3:Play()
			part.Parent = _WorldOrigin
		end
	else
		local v = Util.Sound:Play("FallingFast", root)
		local count = 0

		while root and root:IsDescendantOf(workspace) and reference and reference:IsDescendantOf(workspace) do
			count += 1

			if count % 2 == 0 then
				local clone = script.ThinRing:Clone()
				clone.Size *= 2
				clone.CFrame = CFrame.new(root.Position)
				clone.Parent = workspace._WorldOrigin
				local tween = TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
					Size = createVector(50, 0, 50),
					Transparency = 1,
					CFrame = clone.CFrame + createVector(0, 7, 0)
				})
				tween.Completed:Connect(function()
					clone:Destroy()
				end)
				tween:Play()
			end

			local clone = script.Shockwave:Clone()
			clone.Size *= 2
			clone.CFrame = CFrame.new(root.Position) * CFrame.Angles(-1.5707963267948966, 0, 0)
			clone.Parent = workspace._WorldOrigin
			local tween = TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
				Size = createVector(0, 0, 40),
				Transparency = 1,
				CFrame = clone.CFrame + createVector(0, 7, 0),
				Color = clone.Color:Lerp(Color3.new(1, 1, 1), 0.15)
			})
			tween.Completed:Connect(function()
				clone:Destroy()
			end)
			tween:Play()
			wait()
		end

		Util.Sound:FadeOut(v, 0.3)
	end
end