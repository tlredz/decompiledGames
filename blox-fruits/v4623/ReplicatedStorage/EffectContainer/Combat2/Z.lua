local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage.FX)
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local _ = Util.RocksModule
local _ = Util.DestroyAfter
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }

local function slam(_, hrp, _, _)
	Util.Sound:Play("DodgeQuick2", hrp)
	local position = hrp.Position
	local ray = Ray.new(position, createVector(0, -5, 0))
	local part, v, _ = workspace:FindPartOnRayWithIgnoreList(ray, raycastParams.FilterDescendantsInstances)
	local combat = FX:WaitForChild("Combat")
	local clone = combat.LightningSpark:Clone()
	local clone2 = combat.Shockwave:Clone()
	local clone3 = combat.Shockwave2:Clone()
	local clone4 = combat.ParticlesDash:Clone()
	clone.CFrame = hrp.CFrame * CFrame.new(0, 0, -9) * CFrame.Angles(1.5707963267948966, 0, 0)
	clone.Parent = _WorldOrigin
	clone2.CFrame = hrp.CFrame * CFrame.new(-4, 0, 0)
	clone2.Parent = _WorldOrigin
	clone3.CFrame = hrp.CFrame * CFrame.new(4, 0, 0)
	clone3.Parent = _WorldOrigin
	Util.DestroyAfter(clone2, 3)
	Util.DestroyAfter(clone3, 3)
	Util.DestroyAfter(clone, 1.5)
	TweenService:Create(clone2, TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(12.429, 15.5, 57.286)
	}):Play()
	TweenService:Create(clone2, TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		CFrame = clone2.CFrame * CFrame.new(-5, 0, -15)
	}):Play()
	TweenService:Create(clone2, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()
	TweenService:Create(clone3, TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(12.429, 15.5, 57.286)
	}):Play()
	TweenService:Create(clone3, TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		CFrame = clone3.CFrame * CFrame.new(5, 0, -15)
	}):Play()
	TweenService:Create(clone3, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()
	combat.ringdash:Clone()
	local clone5 = combat.spiraldash:Clone()
	clone5.CFrame = hrp.CFrame * CFrame.new(0, 0, 6) * CFrame.Angles(-1.5707963267948966, 0, 0)
	clone5.Parent = _WorldOrigin
	Util.DestroyAfter(clone5, 3)
	TweenService:Create(clone5, TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(25.801, 52.801, 25.001)
	}):Play()
	TweenService:Create(clone5, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
		CFrame = clone5.CFrame * CFrame.new(0, 23, 3) * CFrame.Angles(0, -2.91469985083053, 0)
	}):Play()
	TweenService:Create(clone5, TweenInfo.new(0.44, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
		Transparency = 1
	}):Play()
	TweenService:Create(clone.Mesh, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
		Scale = createVector(0.05, 3, 0.05)
	}):Play()
	TweenService:Create(clone.Decal, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0), {
		Transparency = 1
	}):Play()
	spawn(function()
		clone4.CFrame = hrp.CFrame * CFrame.new(0, 0, 9)
		clone4.Parent = _WorldOrigin
		Util.DestroyAfter(clone4, 3)

		local function groundEffects(_, p)
			local clone6 = FX:WaitForChild("StringEffects").StringFlightGroundParticles:Clone()

			if p then
				clone4.SlashSmoke.Color = ColorSequence.new(p.Color)
				clone4.Smoke.Color = ColorSequence.new(p.Color)
			end

			return clone6
		end

		local v2 = part
		local clone6 = FX:WaitForChild("StringEffects").StringFlightGroundParticles:Clone()

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
			CFrame = clone5.CFrame * CFrame.new(0, 23, 3) * CFrame.Angles(0, -2.9670597283903604, 0)
		}):Play()
	end)
	spawn(function()
		local clone6 = combat.ringdash:Clone()

		for _ = 1, 1 do
			clone6.CFrame = hrp.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
			clone6.Parent = _WorldOrigin
			Util.DestroyAfter(clone6, 2)
			TweenService:Create(clone6, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(18.434, 1.9, 18.434)
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
		clone6.CFrame = hrp.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
		clone6.Parent = _WorldOrigin
		Util.DestroyAfter(clone6, 2)
		TweenService:Create(clone6, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(27.434, 2.2, 27.434)
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

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 400 or (hrp == nil or hrp.Parent == nil) then
		return
	end

	slam(plr, hrp, cFrame, mouse)
end