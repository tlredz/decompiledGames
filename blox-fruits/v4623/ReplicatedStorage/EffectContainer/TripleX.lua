local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(p)
	local cFrame = p.CFrame

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 500 then
		return
	end

	local cFrame2 = cFrame + createVector(0, 35, 0)
	local clone = script.Inner:Clone()
	local clone2 = script.Outer:Clone()
	clone.CFrame = cFrame2
	clone2.CFrame = cFrame2
	clone.Size = createVector(0.05, 0.05, 0.05)
	clone2.Size = createVector(0.05, 0.05, 0.05)
	clone.Parent = _WorldOrigin
	clone2.Parent = _WorldOrigin
	TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
		Size = createVector(140, 70, 140)
	}):Play()
	TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
		Size = createVector(145, 72.5, 145)
	}):Play()
	local v2 = Util.Sound:Play("WindFast", cFrame2)
	local lastTime = tick()
	local total = 0
	local v3 = false

	while tick() - lastTime < 2 do
		local v4 = math.min(1, (tick() - lastTime) / 2)

		if total < v4 then
			total += 0.1
			local clone3 = script.ShockwaveTransparent:Clone()
			clone3.CFrame = cFrame2 - createVector(0, 35, 0)
			clone3.Parent = _WorldOrigin
			TweenService:Create(clone3, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			local tween = TweenService:Create(clone3.Mesh, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
				Scale = clone3.Mesh.Scale * createVector(2, 1, 2)
			})
			tween.Completed:Connect(function()
				clone3.Dust.Enabled = false
				wait(0.5)
				clone3:Destroy()
			end)
			tween:Play()
		end

		if v4 > 0.8 then
			if not v3 then
				Util.Sound:FadeOut(v2, 0.5)
				v3 = true
			end

			local transparency = (v4 - 0.8) / 0.2
			clone.Transparency = transparency
			clone2.Transparency = transparency * 0.5 + 0.5
			clone.Size = Vector3.new(1 - transparency, 0.5, 1 - transparency) * 140
			clone2.Size = clone.Size + createVector(5, 2.5, 5)
		end

		clone.CFrame = cFrame2 * CFrame.Angles(0, v4 * 3.141592653589793 * 9, 0)
		clone2.CFrame = clone.CFrame
		RunService.RenderStepped:Wait()
	end

	clone:Destroy()
	clone2:Destroy()
end