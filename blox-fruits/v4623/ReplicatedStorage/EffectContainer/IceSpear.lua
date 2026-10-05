local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(data)
	local cFrame = data.CFrame
	local targetCFrame = data.TargetCFrame

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
		return
	end

	local v = math.min(250, (cFrame.p - targetCFrame.p).magnitude)
	local cframe = CFrame.new(cFrame.p, targetCFrame.p)
	local v2 = cframe * CFrame.new(0, 0, -v)
	Util.Sound:Play("IceShoot", cFrame)
	local iceSpear = ReplicatedStorage.Assets.Models.IceSpear

	local function fn(p, p2, p3)
		local clone = ReplicatedStorage.Assets.Models.IceSpearShockwave:Clone()
		clone.CFrame = p * CFrame.Angles(0, 1.5707963267948966, 1.5707963267948966)
		clone.Mesh.Scale = createVector(1, 1, 1) * p2 / 250
		clone.Parent = _WorldOrigin
		local tween = TweenService:Create(clone, TweenInfo.new(0.3), {
			Transparency = 1
		})
		local tween2 = TweenService:Create(clone.Mesh, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Scale = clone.Mesh.Scale * createVector(2, 3, 2)
		})
		tween.Completed:Connect(function()
			if not p3 then
				wait(clone.Dust.Lifetime.Max + 0.1)
			end

			clone:Destroy()
		end)
		tween:Play()
		tween2:Play()

		if not p3 then
			clone.Dust:Emit(8)
		end
	end

	local function lerp(object, p, p2)
		return object:lerp(p, p2)
	end

	local v3 = v / 20
	local random = Random.new()
	local v4 = cframe:Lerp(v2, 0.3333333333333333) * CFrame.new(
		random:NextNumber(-5, 5) * v3,
		random:NextNumber(-1, 5) * v3,
		0
	)
	local v5 = cframe:Lerp(v2, 0.6666666666666666) * CFrame.new(
		random:NextNumber(-5, 5) * v3,
		random:NextNumber(-1, 5) * v3,
		0
	)

	local function cubicBezier(p, cframe2, object, object2, p2)
		local lerped = cframe2:lerp(object, p)
		local lerped2 = object:lerp(object2, p)
		local lerped3 = object2:lerp(p2, p)
		return (lerped:lerp(lerped2, p):lerp(lerped2:lerp(lerped3, p), p))
	end

	local cframe2 = CFrame.Angles(0, -1.5707963267948966, 1.5707963267948966)
	local clone = iceSpear:Clone()
	clone.CFrame = cframe * cframe2
	clone.Parent = _WorldOrigin
	fn(cframe, 7)
	local v6 = masterClock:GetTime() - data.Timestamp
	local v7 = math.max(v / 240 - v6, 0)
	local lastTime = tick()
	local now = 0

	while tick() - lastTime < v7 do
		local v8 = cubicBezier(math.min(1, (tick() - lastTime) / v7 + 0.001), cframe, v4, v5, v2)
		clone.CFrame = CFrame.new(v8.p, v8.p - (clone.CFrame.p - v8.p).unit) * cframe2

		if tick() - now > 0.08 + math.random() * 0.08 then
			now = tick()
			fn(v8, 7)
		end

		RunService.RenderStepped:Wait()
	end

	clone.Dust.Enabled = false
	clone.CFrame = targetCFrame
	clone.Transparency = 1
	Util.Debris:AddItem(clone, 1.5)
	Effect.new("IceRockExplosion"):replicate({
		CFrame = targetCFrame,
		Scale = 15
	})
	Util.Sound:Play("IceExplosion", targetCFrame)
end