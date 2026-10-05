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
return function(p)
	local root = p.Root
	local reference = p.Reference

	if not root or (root.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
		return
	end

	local v = Util.Sound:Play("FallingFast", root)
	local count = 0

	while root and root:IsDescendantOf(workspace) and reference and reference:IsDescendantOf(workspace) do
		count += 1

		if count % 2 == 0 then
			local clone = script.ThinRing:Clone()
			clone.Size *= 2
			clone.CFrame = CFrame.new(root.Position) - createVector(0, 5, 0)
			clone.Parent = workspace._WorldOrigin
			local tween = TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
				Size = createVector(70, 0, 70),
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
		clone.CFrame = CFrame.new(root.Position - createVector(0, 5, 0)) * CFrame.Angles(-1.5707963267948966, 0, 0)
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
	local cframe = CFrame.new(root.Position - createVector(0, 2, 0))
	Util.Sound:Play("LoudTremorWave1", cframe)
	local v2 = Util.Sound:Play("Earthquake", cframe)
	local clone = script.Boom:Clone()
	clone.CFrame = cframe * CFrame.new(0, 25, 0)
	clone.Parent = workspace._WorldOrigin
	local tween = TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
		Size = createVector(0, 80, 0),
		Transparency = 1,
		CFrame = clone.CFrame + createVector(0, -7, 0)
	})
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween:Play()
	local clone2 = script.Boom:Clone()
	clone2.Size = createVector(0, 60, 0)
	clone2.CFrame = cframe * CFrame.new(0, 12, 0)
	clone2.Parent = workspace._WorldOrigin
	local tween2 = TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
		Size = createVector(70, 10, 70),
		Transparency = 1,
		CFrame = clone2.CFrame + createVector(0, -10, 0)
	})
	tween2.Completed:Connect(function()
		clone2:Destroy()
	end)
	tween2:Play()

	for i = 1, 5 do
		local clone3 = script.ThinRing:Clone()
		clone3.Size *= 2
		clone3.CFrame = cframe
		clone3.Parent = workspace._WorldOrigin
		local tween3 = TweenService:Create(clone3, TweenInfo.new(i / 6 + 0.1, Enum.EasingStyle.Exponential), {
			Size = Vector3.new(i * 15, 0, i * 15) * 2,
			Transparency = 1,
			CFrame = clone3.CFrame + Vector3.new(0, i * 4, 0)
		})
		tween3.Completed:Connect(function()
			clone3:Destroy()
		end)
		tween3:Play()
	end

	for _ = 1, 8 do
		local clone3 = script.ThinRing:Clone()
		clone3.Size *= 4
		clone3.CFrame = cframe
		clone3.Parent = workspace._WorldOrigin
		local tween3 = TweenService:Create(clone3, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {
			Size = createVector(135, 0, 135),
			Transparency = 1,
			CFrame = clone3.CFrame + createVector(0, 4, 0)
		})
		tween3.Completed:Connect(function()
			clone3:Destroy()
		end)
		tween3:Play()
		local clone4 = script.ThinRing:Clone()
		clone4.Size *= 2
		clone4.CFrame = cframe
		clone4.Parent = workspace._WorldOrigin
		local tween4 = TweenService:Create(clone4, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Size = createVector(112.5, 0, 112.5),
			Transparency = 1,
			CFrame = clone4.CFrame + createVector(0, 25, 0)
		})
		tween4.Completed:Connect(function()
			clone4:Destroy()
		end)
		tween4:Play()

		for _ = 1, 3 do
			local ray = Util.Ray
			local v5 = cframe.p + createVector(0, 3, 0) + Vector3.new(math.random() - 0.5, 0, math.random() - 0.5).unit * 30
			local v6 = { workspace.Characters, workspace.Enemies }
			local v7, v8 = ray(v5, createVector(0, -10, 0), v6)

			if not v7 then
				continue
			end

			local part = Instance.new("Part")
			part.Color = v7.Color
			part.Material = v7.Material
			part.Transparency = v7.Transparency
			part.Size = Vector3.new(1 + math.random() * 0.5, 1 + math.random() * 0.5, 1 + math.random() * 0.5) * (1 + math.random()) * 6
			part.CFrame = (CFrame.new(v8) - createVector(0, 4, 0)) * CFrame.Angles(
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2
			)
			part.Anchored = false
			part.CanCollide = false
			part.TopSurface = 0
			part.BottomSurface = 0
			part.Velocity = Vector3.new(math.random() - 0.5, 0, math.random() - 0.5).unit * math.random(80, 250) + Vector3.new(
				0,
				math.random(100, 140),
				0
			)
			part.RotVelocity = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 30
			local tween5 = TweenService:Create(part, TweenInfo.new(0.5 + math.random()), {
				Size = createVector(0.05, 0.05, 0.05)
			})
			tween5.Completed:Connect(function()
				part:Destroy()
			end)
			tween5:Play()
			part.Parent = _WorldOrigin
		end

		wait(0.1)
	end

	Util.Sound:FadeOut(v2, 0.3)
end