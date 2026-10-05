local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
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
			clone.CFrame = CFrame.new(root.Position) - createVector(0, 5, 0)
			clone.Parent = workspace._WorldOrigin
			local tween = TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
				Size = createVector(35, 0, 35),
				Transparency = 1,
				CFrame = clone.CFrame + createVector(0, 7, 0)
			})
			tween.Completed:Connect(function()
				clone:Destroy()
			end)
			tween:Play()
		end

		local clone = script.Shockwave:Clone()
		clone.CFrame = CFrame.new(root.Position - createVector(0, 5, 0)) * CFrame.Angles(-1.5707963267948966, 0, 0)
		clone.Parent = workspace._WorldOrigin
		local tween = TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
			Size = createVector(0, 0, 20),
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
			Size = Vector3.new(i * 15, 0, i * 15),
			Transparency = 1,
			CFrame = clone3.CFrame + Vector3.new(0, i * 4, 0)
		})
		tween3.Completed:Connect(function()
			clone3:Destroy()
		end)
		tween3:Play()
	end

	local clone3 = script.ThinRing:Clone()
	clone3.Size *= 4
	clone3.CFrame = cframe
	clone3.Parent = workspace._WorldOrigin
	local tween3 = TweenService:Create(clone3, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), {
		Size = createVector(90, 0, 90),
		Transparency = 1,
		CFrame = clone3.CFrame + createVector(0, 3, 0)
	})
	tween3.Completed:Connect(function()
		clone3:Destroy()
	end)
	tween3:Play()
end