local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Z = FX:WaitForChild("Soul").Z
local _ = Util.Sound
local _ = Util.MasterClock
local _ = Util.Debris

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cflerp(object, p, p2)
	return object:lerp(p, p2)
end

local function vanishSmoke(position, value)
	if (position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
		return
	end

	local cFrame = CFrame.new(position) * CFrame.Angles(0, math.rad((math.random(0, 360))), 0)

	for _ = 1, 8 do
		local clone = Z.Cloud:Clone()
		Util.Debris:AddItem(clone, 2)
		clone.Size = Vector3.new()
		clone.CFrame = cFrame
		clone.Parent = _WorldOrigin
		local v2 = math.random(25, 38)
		local v3 = math.random(30, 50) / 100
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(v3 / 2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
			{
				Size = Vector3.new(v2, v2, v2) * (value or 1)
			}
		)
		local tween2 = TweenService:Create(
			clone,
			TweenInfo.new(v3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				CFrame = cFrame * CFrame.new(0, math.random(5, 15), 0 - math.random(20, 30)) * CFrame.Angles(
					math.rad((math.random(0, 360))),
					math.rad((math.random(0, 360))),
					(math.rad((math.random(0, 360))))
				)
			}
		)
		tween.Completed:Connect(function()
			if clone then
				clone:Destroy()
			end
		end)
		tween:Play()
		tween2:Play()
		cFrame *= CFrame.Angles(0, 0.7853981633974483, 0)
	end
end

local function windRing(cFrame)
	local clone = Z.Wind:Clone()
	Util.Debris:AddItem(clone, 2)
	clone.CFrame = cFrame
	clone.Size = Vector3.new()
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Transparency = 1,
			CFrame = clone.CFrame * CFrame.Angles(0, 3.07177948351002, 0),
			Size = createVector(75.9, 33.397, 76.155)
		}
	)
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	clone.Parent = _WorldOrigin
	tween:Play()
end

local function soulField(position, p)
	local clone = Z.FieldBubble:Clone()
	Util.Debris:AddItem(clone, p + 1)
	local mesh = clone.Mesh
	mesh.Scale = Vector3.new()
	clone.Position = position
	clone.Parent = _WorldOrigin
	clone.Rays.Enabled = true
	clone.Ring.Enabled = true
	task.spawn(function()
		for _ = 1, 5 do
			windRing(CFrame.new(position) * CFrame.Angles(
				math.rad((math.random(1, 360))),
				math.rad((math.random(1, 360))),
				(math.rad((math.random(1, 360))))
			))
			wait(0.1)
		end
	end)
	local tween = TweenService:Create(
		mesh,
		TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
		{
			Scale = createVector(70, 70, 70)
		}
	)
	tween:Play()
	tween.Completed:Connect(function()
		wait(0.35)
		local tween2 = TweenService:Create(
			clone,
			TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Transparency = 1
			}
		)
		tween2.Completed:Connect(function()
			task.spawn(function()
				clone.Rays.Enabled = false
				clone.Ring.Enabled = false
				wait(2)
				clone:Destroy()
			end)
		end)
		tween2:Play()
	end)
	local parent = Util.Sound:Play("Energy22", position, nil, 2.5, 1)
	local flangeSoundEffect = Instance.new("FlangeSoundEffect")
	flangeSoundEffect.Depth = 1
	flangeSoundEffect.Rate = 1
	flangeSoundEffect.Parent = parent
	local tween2 = TweenService:Create(
		parent,
		TweenInfo.new(2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
		{
			PlaybackSpeed = 0.2
		}
	)
	tween2.Completed:Connect(function()
		local tween3 = TweenService:Create(
			parent,
			TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Volume = 0
			}
		)
		tween3.Completed:Connect(function()
			parent:Destroy()
		end)
		tween3:Play()
	end)
	tween2:Play()
	return parent
end

local function soulBall(position, position2, duration)
	local clone = Z.Ball:Clone()
	Util.Debris:AddItem(clone, duration + 1.5)
	clone.Position = position
	clone.Parent = _WorldOrigin
	task.spawn(function()
		wait(duration / 2)
		local clone2 = Z.Blast:Clone()
		Util.Debris:AddItem(clone2, 3)
		clone2.Position = (position + position2) / 2
		clone2.Parent = _WorldOrigin
		clone2.Slash:Emit(2)
	end)
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
		{
			Position = position2
		}
	)
	tween:Play()
	tween.Completed:Connect(function()
		clone.Center.Burst.Enabled = false
		clone.Center.Ring.Enabled = false
		clone.Trail.Enabled = false
		local tween2 = TweenService:Create(
			clone,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Transparency = 1
			}
		)
		tween2.Completed:Connect(function()
			clone:Destroy()
		end)
		tween2:Play()
	end)
	Util.Sound:Play("ElectricBounce", clone, nil, math.random(16, 20) / 10, 1)
end

return function(data)
	local stage = data.Stage or 1

	if stage == 1 then
		local position = data.Position

		if (position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
			return
		end

		soulField(position, 2)
	elseif stage == 2 then
		local position = data.Position

		if (position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
			return
		end

		for _ = 1, 4 do
			local v = CFrame.new(position) * CFrame.Angles(
				math.rad((math.random(-180, 180))),
				math.rad((math.random(-180, 180))),
				(math.rad((math.random(-180, 180))))
			) * CFrame.new(0, 0, -40)
			soulBall(v.Position, (v * CFrame.new(0, 0, 70)).Position, 0.5)
			wait(0.2)
		end
	elseif stage == 3 then
		local position = data.Position

		if (position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
			return
		end

		vanishSmoke(position, 1.2)
		local clone = Z.Blast:Clone()
		Util.Debris:AddItem(clone, 5)
		local blastSmoke = clone.At.BlastSmoke
		local spikes = clone.Spikes
		local sparks = clone.Sparks
		clone.Position = position
		clone.Parent = _WorldOrigin
		Util.Sound:Play("Explosion2", position, nil, 1, 1)
		blastSmoke:Emit(math.random(20, 25))
		spikes:Emit(math.random(4, 5))
		sparks:Emit(math.random(15, 20))
	else
		local root = stage == 4 and data.Root

		if root then
			if (root.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
				return
			end

			local clone = Z.ZCharge.At:Clone()
			Util.Debris:AddItem(clone, 3)
			clone.Parent = root
			clone.Ring:Emit(1)
			clone.Sparkle:Emit(1)
			Util.Sound:Play("MagicCast", root.Position, nil, 2, 1)
		end
	end
end