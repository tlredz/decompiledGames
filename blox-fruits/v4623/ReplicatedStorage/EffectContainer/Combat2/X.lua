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
local rocksModule = Util.RocksModule
local destroyAfter = Util.DestroyAfter
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }

local function slam(_, hrp, _, _)
	Util.Sound:Play("GroundSmash", hrp)
	local combat = FX:WaitForChild("Combat")
	local clone = combat.outwind:Clone()
	local clone2 = combat.outwind2:Clone()
	local clone3 = combat.LightningSpark:Clone()
	local clone4 = combat.purple:Clone()
	local clone5 = combat.Ringp:Clone()
	local clone6 = combat.shockyeah:Clone()
	local v = hrp.CFrame * createVector(0, 0, -2)
	local ray = Ray.new(v, createVector(0, -5, 0))
	local part, v2, v3 = workspace:FindPartOnRayWithIgnoreList(ray, raycastParams.FilterDescendantsInstances)
	local clone7

	if part then
		clone7 = combat.cracks:Clone()
		clone7.CFrame = CFrame.new(v2 + v3 * 0.1)
		clone7.Parent = _WorldOrigin
		destroyAfter(clone7, 1.5)
		TweenService:Create(
			clone7,
			TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
			{
				Size = createVector(45, 0.05, 45)
			}
		):Play()
		TweenService:Create(
			clone7.Decal,
			TweenInfo.new(1.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In, 0, false, 0),
			{
				Transparency = 1
			}
		):Play()
	else
		clone7 = nil
	end

	Util.DestroyAfter(clone, 1.5)
	Util.DestroyAfter(clone2, 1.5)
	Util.DestroyAfter(clone3, 1.5)
	Util.DestroyAfter(clone4, 1.5)
	Util.DestroyAfter(clone5, 1.5)
	Util.DestroyAfter(clone6, 1.5)
	wait(0.067)
	spawn(function()
		local clone8 = combat.Ribbon:Clone()
		Util.DestroyAfter(clone8, 1.8)
		clone8.CFrame = CFrame.new(v) * CFrame.new(0, 5, 0)
		clone8.Parent = _WorldOrigin
		destroyAfter(clone8, 7)
		TweenService:Create(clone8, TweenInfo.new(0.44, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = createVector(60, 80, 60)
		}):Play()
		TweenService:Create(clone8, TweenInfo.new(0.34, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone8, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			CFrame = clone8.CFrame * CFrame.Angles(0, -2.9670597283903604, 0)
		}):Play()
		wait(0.2)
		TweenService:Create(clone8, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			CFrame = clone8.CFrame * CFrame.Angles(0, -2.9670597283903604, 0)
		}):Play()
		wait(0.2)
		TweenService:Create(clone8, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			CFrame = clone8.CFrame * CFrame.Angles(0, -2.9670597283903604, 0)
		}):Play()
		wait(0.2)
		TweenService:Create(clone8, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			CFrame = clone8.CFrame * CFrame.Angles(0, -2.9670597283903604, 0)
		}):Play()
		wait(0.2)
		TweenService:Create(clone8, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			CFrame = clone8.CFrame * CFrame.Angles(0, -2.9670597283903604, 0)
		}):Play()
	end)
	rocksModule.Ground(v + createVector(0, 1, 0), 20, createVector(4, 2.5, 4), {
		clone7,
		clone,
		clone2,
		clone3,
		clone5,
		clone6
	}, 6, false, 1)
	clone.CFrame = CFrame.new(v) * CFrame.new(0, 1, 0)
	clone.Parent = _WorldOrigin
	clone2.CFrame = CFrame.new(v) * CFrame.new(0, 11, 0)
	clone2.Parent = _WorldOrigin
	clone3.CFrame = CFrame.new(v) * CFrame.new(0, 3, 0)
	clone3.Parent = _WorldOrigin
	clone4.CFrame = CFrame.new(v) * CFrame.new(0, 1, 0)
	clone4.Parent = _WorldOrigin
	clone5.CFrame = CFrame.new(v) * CFrame.new(0, 10, 0)
	clone5.Parent = _WorldOrigin
	clone6.CFrame = CFrame.new(v)
	clone6.Parent = _WorldOrigin
	TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
		Size = createVector(65, 1.2, 65),
		Transparency = 1
	}):Play()
	TweenService:Create(clone, TweenInfo.new(0.417, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
		Size = createVector(50, 2, 50)
	}):Play()
	TweenService:Create(clone, TweenInfo.new(0.23, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), {
		Transparency = 1
	}):Play()
	TweenService:Create(clone3.Mesh, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
		Scale = createVector(0.05, 3, 0.05)
	}):Play()
	TweenService:Create(clone3.Decal, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0), {
		Transparency = 1
	}):Play()
	TweenService:Create(clone4, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		Size = createVector(70, 70, 70),
		Transparency = 1
	}):Play()
	TweenService:Create(clone5, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		CFrame = hrp.CFrame * CFrame.new(0, 15, 0),
		Size = createVector(60, 5, 60),
		Transparency = 1
	}):Play()
	TweenService:Create(clone6, TweenInfo.new(0.44, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = createVector(120, 0.72, 120)
	}):Play()
	TweenService:Create(clone6, TweenInfo.new(0.44, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
		Transparency = 1
	}):Play()

	if part and clone7 then
		local function groundEffects(_, part2)
			local clone8 = FX:WaitForChild("StringEffects").StringFlightGroundParticles:Clone()

			if part2 then
				clone7.Rocks.Color = ColorSequence.new(part2.Color)
				clone7.Attachment.ParticleEmitter.Color = ColorSequence.new(part2.Color)
			end

			spawn(function()
				task.wait()
				clone7.Rocks:Emit(8)
				task.wait()
				clone7.Rocks:Emit(8)
			end)
			return clone8
		end

		local v4 = groundEffects(v2, part)
		spawn(function()
			local v5 = time()

			for _ = 1, 600 do
				if v4 == nil or time() - v5 > 10 then
					break
				end

				task.wait()
				local ray2, position, _ = Util.Ray(
					hrp.Position,
					createVector(-0, -5, -0),
					raycastParams.FilterDescendantsInstances,
					false
				)

				if not ray2 then
					break
				end

				v4.Position = position
			end
		end)

		for _, child in ipairs(clone7.Attachment:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end
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