local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local _ = Util.RocksModule
local destroyAfter = Util.DestroyAfter
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }

local function slam(_, hrp, cFrame, _)
	Util.Sound:Play("DodgeQuick2", hrp)
	local position = cFrame.Position
	local ray = Ray.new(position, createVector(0, -5, 0))
	local part, v, _ = workspace:FindPartOnRayWithIgnoreList(ray, raycastParams.FilterDescendantsInstances)
	local combat = ReplicatedStorage.FX.Combat
	local clone = combat.LightningSpark:Clone()
	local clone2 = combat.Shockwave:Clone()
	local clone3 = combat.Shockwave2:Clone()
	local clone4 = combat.ParticlesDash:Clone()
	clone.CFrame = cFrame * CFrame.new(0, 0, -18) * CFrame.Angles(1.5707963267948966, 0, 0)
	clone.Parent = _WorldOrigin
	destroyAfter(clone, 7)
	clone2.CFrame = cFrame * CFrame.new(-5.2, 0, 0)
	clone2.Parent = _WorldOrigin
	destroyAfter(clone2, 7)
	clone3.CFrame = cFrame * CFrame.new(5.2, 0, 0)
	clone3.Parent = _WorldOrigin
	destroyAfter(clone3, 7)
	Util.DestroyAfter(clone2, 3)
	Util.DestroyAfter(clone3, 3)
	Util.DestroyAfter(clone, 1.5)
	TweenService:Create(clone2, TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(16.1577, 20.15, 114.572)
	}):Play()
	TweenService:Create(clone2, TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		CFrame = clone2.CFrame * CFrame.new(-6.5, 0, -30)
	}):Play()
	TweenService:Create(clone2, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()
	TweenService:Create(clone3, TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(16.1577, 20.15, 114.572)
	}):Play()
	TweenService:Create(clone3, TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		CFrame = clone3.CFrame * CFrame.new(6.5, 0, -30)
	}):Play()
	TweenService:Create(clone3, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()
	combat.ringdash:Clone()
	local clone5 = combat.spiraldash:Clone()
	clone5.CFrame = cFrame * CFrame.new(0, 0, 12) * CFrame.Angles(-1.5707963267948966, 0, 0)
	clone5.Parent = _WorldOrigin
	destroyAfter(clone5, 7)
	Util.DestroyAfter(clone5, 3)
	TweenService:Create(clone5, TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(33.5413, 105.602, 32.5013)
	}):Play()
	TweenService:Create(clone5, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
		CFrame = clone5.CFrame * CFrame.new(0, 46, 3.9000000000000004) * CFrame.Angles(0, -2.91469985083053, 0)
	}):Play()
	TweenService:Create(clone5, TweenInfo.new(0.44, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
		Transparency = 1
	}):Play()
	TweenService:Create(clone.Mesh, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
		Scale = createVector(0.065, 6, 0.065)
	}):Play()
	TweenService:Create(clone.Decal, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0), {
		Transparency = 1
	}):Play()
	spawn(function()
		clone4.CFrame = cFrame * CFrame.new(0, 0, 18)
		clone4.Parent = _WorldOrigin
		destroyAfter(clone4, 7)
		Util.DestroyAfter(clone4, 3)

		local function groundEffects(_, p)
			local clone6 = ReplicatedStorage.FX.StringEffects.StringFlightGroundParticles:Clone()

			if p then
				clone4.SlashSmoke.Color = ColorSequence.new(p.Color)
				clone4.Smoke.Color = ColorSequence.new(p.Color)
			end

			return clone6
		end

		local v2 = part
		local clone6 = ReplicatedStorage.FX.StringEffects.StringFlightGroundParticles:Clone()

		if v2 then
			clone4.SlashSmoke.Color = ColorSequence.new(v2.Color)
			clone4.Smoke.Color = ColorSequence.new(v2.Color)
		end

		spawn(function()
			local v3 = time()

			for _ = 1, 600 do
				if clone6 == nil or time() - v3 > 10 then
					break
				end

				task.wait()
				local ray2, position2, _ = Util.Ray(
					hrp.Position,
					-CFrame.new(hrp.Position).upVector.Unit,
					raycastParams.FilterDescendantsInstances,
					false
				)

				if not ray2 then
					break
				end

				clone6.Position = position2
			end
		end)

		for _, child in ipairs(clone4.Slash1:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end

		if part then
			for _, emitter in ipairs(clone4:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit((emitter:GetAttribute("EmitCount") or 1) * 2 / 3)
				end
			end
		end

		wait(0.3)
		TweenService:Create(clone5, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
			CFrame = clone5.CFrame * CFrame.new(0, 46, 3.9000000000000004) * CFrame.Angles(0, -2.9670597283903604, 0)
		}):Play()
	end)
	spawn(function()
		local clone6 = combat.ringdash:Clone()

		for _ = 1, 1 do
			clone6.CFrame = cFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
			clone6.Parent = _WorldOrigin
			destroyAfter(clone6, 7)
			Util.DestroyAfter(clone6, 2)
			TweenService:Create(clone6, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(23.9642, 3.8, 23.9642)
			}):Play()
			TweenService:Create(clone6, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				CFrame = clone6.CFrame * CFrame.new(0, 0, 0)
			}):Play()
			TweenService:Create(clone6, TweenInfo.new(0.444, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end
	end)

	for _ = 1, 1 do
		local clone6 = combat.ringdash:Clone()
		combat.spiraldash:Clone()
		clone6.CFrame = cFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
		clone6.Parent = _WorldOrigin
		destroyAfter(clone6, 7)
		Util.DestroyAfter(clone6, 2)
		TweenService:Create(clone6, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(35.6642, 4.4, 35.6642)
		}):Play()
		TweenService:Create(clone6, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			CFrame = clone6.CFrame * CFrame.new(0, 0, 0)
		}):Play()
		TweenService:Create(clone6, TweenInfo.new(0.444, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end
end

return function(data)
	local plr = data.plr
	local hrp = data.hrp
	local cFrame = data.CFrame
	local mouse = data.mouse

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 600 or (hrp == nil or hrp.Parent == nil) then
		return
	end

	slam(plr, hrp, cFrame, mouse)
end