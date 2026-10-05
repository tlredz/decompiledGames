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
Random.new()

local function emitAll(folder)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")

		if emitCount then
			local emitDelay = emitter:GetAttribute("EmitDelay")

			if emitDelay then
				local v = emitter
				local v2 = emitCount
				task.delay(emitDelay, function()
					v:Emit(v2)
				end)
			else
				emitter:Emit(emitCount)
			end
		else
			emitter:Emit(1)
		end
	end
end

local FX = require(ReplicatedStorage.FX)
local twinHooks = FX:WaitForChild("TwinHooks")

local function attack(_, hrp, _, _, _, stage)
	if stage == 1 then
		Util.Sound:Play("HookSwingLoop1", hrp, nil, 1 + math.random(-9, 6) / 100, 3)
		Util.Sound:Play("HookSwingLoop2", hrp, nil, 1 + math.random(-9, 6) / 100, 3)
		local clone = twinHooks.spinning.SpinningHooks:Clone()
		clone.Parent = hrp
		Util.Debris:AddItem(clone, 1)
		emitAll(clone)
		local clone2 = twinHooks.SpinL:Clone()
		local clone3 = twinHooks.SpinR:Clone()
		clone2.Parent = _WorldOrigin
		clone3.Parent = _WorldOrigin
		Util.Debris:AddItem(clone2, 0.1)
		Util.Debris:AddItem(clone3, 0.1)

		for _, beam in pairs(clone2:GetDescendants()) do
			if beam:IsA("Beam") then
				TweenService:Create(beam, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end
		end

		for _, beam in pairs(clone3:GetDescendants()) do
			if beam:IsA("Beam") then
				TweenService:Create(beam, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end
		end

		local motor6D = Instance.new("Motor6D")
		motor6D.Parent = hrp
		motor6D.Part0 = hrp
		motor6D.Part1 = clone2
		Util.Debris:AddItem(motor6D, 0.5)
		local motor6D2 = Instance.new("Motor6D")
		motor6D2.Parent = hrp
		motor6D2.Part0 = hrp
		motor6D2.Part1 = clone3
		Util.Debris:AddItem(motor6D2, 0.5)
		local ray, _, _ = Util.Ray(
			hrp.Position,
			createVector(-0, -1, -0) * (hrp.Size.Y * 0.5 + hrp.Parent.Humanoid.HipHeight + 3),
			{ workspace.Characters, workspace.Enemies },
			false
		)

		if ray then
			local clone4 = twinHooks.spinning.SpinningHooksGround:Clone()
			clone4.Parent = hrp
			Util.Debris:AddItem(clone4, 1)
			emitAll(clone4)
			clone4.Left.Left2.Smoke.Color = ColorSequence.new(ray.Color)
			clone4.Right.Right2.Smoke.Color = ColorSequence.new(ray.Color)
		end
	end
end

return function(data)
	local plr = data.plr
	local hrp = data.hrp
	local stage = data.stage

	if (hrp.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 700 then
		return
	end

	local part = data.part

	while data.holding and data.holding.Value and data.holding:IsDescendantOf(workspace) do
		attack(plr, hrp, nil, nil, part, stage)
		task.wait(0.285)
	end
end