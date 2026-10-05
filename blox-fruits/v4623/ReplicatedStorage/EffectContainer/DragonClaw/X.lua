local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local sound = Util.Sound
local masterClock = Util.MasterClock
local debris = Util.Debris
TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
local _ = coroutine.resume
local _ = coroutine.create

local function lerp(object, p, p2)
	return object:lerp(p, p2)
end

local function cubicBezier(p, cframe, object, object2, p2)
	local lerped = cframe:lerp(object, p)
	local lerped2 = object:lerp(object2, p)
	local lerped3 = object2:lerp(p2, p)
	return (lerped:lerp(lerped2, p):lerp(lerped2:lerp(lerped3, p), p))
end

return function(data)
	local subEffect = data.SubEffect or 1

	if subEffect == 1 then
		local boolean = data.Boolean
		local rightHand = data.RightHand
		local leftHand = data.LeftHand

		if rightHand and leftHand then
			if boolean then
				if (workspace.CurrentCamera.CFrame.Position - rightHand.Position).Magnitude > 800 then
					return
				end

				coroutine.wrap(function()
					for i = 1, 2 do
						local clone = script.ClawHold:Clone()

						if i == 1 then
							clone.CFrame = rightHand.CFrame
							clone.Parent = rightHand
							local weldConstraint = Instance.new("WeldConstraint")
							weldConstraint.Name = "clawhold1weld"
							weldConstraint.Parent = clone
							weldConstraint.Part0 = rightHand
							weldConstraint.Part1 = clone
							local play = Util.Sound:Play("Mera_FireLoop", clone)
							play.Looped = true
						end

						if i ~= 2 then
							continue
						end

						clone.CFrame = leftHand.CFrame
						clone.Parent = leftHand
						local weldConstraint = Instance.new("WeldConstraint")
						weldConstraint.Name = "clawhold2weld"
						weldConstraint.Parent = clone
						weldConstraint.Part0 = leftHand
						weldConstraint.Part1 = clone
						local play_2 = Util.Sound:Play("Mera_FireLoop", clone)
						play_2.Looped = true
					end
				end)()
			else
				local clawHold = rightHand:FindFirstChild("ClawHold")

				if clawHold then
					clawHold.Name = ""

					for _, emitter in pairs(clawHold:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					if clawHold:FindFirstChild("Mera_FireLoop") then
						sound:FadeOut(clawHold.Mera_FireLoop, 0.3)
					end

					task.delay(0.7, function()
						clawHold:Destroy()
					end)
				end

				local clawHold2 = leftHand:FindFirstChild("ClawHold")

				if clawHold2 then
					clawHold2.Name = ""

					for _, emitter in pairs(clawHold2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					if clawHold2:FindFirstChild("Mera_FireLoop") then
						sound:FadeOut(clawHold2.Mera_FireLoop, 0.3)
					end

					task.delay(0.7, function()
						clawHold2:Destroy()
					end)
				end
			end
		end
	elseif subEffect == 2 then
		local cFrame = data.CFrame
		local targetCFrame = data.TargetCFrame
		local timestamp = data.Timestamp

		if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude > 800 then
			return
		end

		Util.Sound:Play("Burning", cFrame.Position)
		Util.Sound:Play("ShortExplosion3", cFrame.Position)
		local clone = script.AirLines:Clone()
		clone.CFrame = cFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
		clone.Parent = _WorldOrigin
		debris:AddItem(clone, 3)
		local clone2 = script.FlameBurst:Clone()
		clone2.CFrame = cFrame
		clone2.Parent = _WorldOrigin
		debris:AddItem(clone2, 3)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		task.delay(0.9, function()
			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
		task.delay(0.5, function()
			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)

		for i = 1, 6 do
			local v = i
			task.spawn(function()
				local clone3 = script.DragonHead:Clone()
				Util.Debris:AddItem(clone3, 10)
				clone3:SetPrimaryPartCFrame(cFrame * CFrame.new(10, 0, -4))
				clone3.Parent = _WorldOrigin
				local flameDebrisFree = clone3.Part1.Particle.FlameDebrisFree
				local botFree = clone3.Part1.Particle.botFree
				local shockwave1Free = clone3.Part1.Particle.Shockwave1Free

				if v == 1 then
					Util.Sound:Play("CRoar", clone3.Head)
					Util.Sound:Play("CFire move", clone3.Head)
				end

				local v2 = math.min(250, (cFrame.p - targetCFrame.p).magnitude)
				local cframe = CFrame.new(cFrame.p, targetCFrame.p)
				local v3 = cframe * CFrame.new(0, 0, -v2)
				task.delay(0.3, function()
					TweenService:Create(clone3.Outline, tweenInfo, {
						Size = createVector(4.208, 0.001, 0.001),
						Transparency = 1
					}):Play()
					TweenService:Create(clone3.Head, tweenInfo, {
						Size = createVector(4.183, 0.001, 0.001),
						Transparency = 1
					}):Play()
					TweenService:Create(clone3.Eye, tweenInfo, {
						Size = createVector(0.65, 0.001, 0.001),
						Transparency = 1
					}):Play()
					TweenService:Create(clone3["Meshes/test2_Icosphere.001"], tweenInfo, {
						Size = createVector(4.004, 0.001, 0.001),
						Transparency = 1
					}):Play()
				end)
				task.delay(0.35, function()
					for i2, effect in pairs(clone3.Part1:GetDescendants()) do
						if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
							continue
						end

						effect.Enabled = false
					end

					clone3.Part1.Trail.Enabled = false
				end)
				task.delay(2, function()
					clone3:Destroy()
				end)
				local v4 = v2 / 20
				local random = Random.new()
				local v5 = cframe:Lerp(v3, 0.3333333333333333) * CFrame.new(
					random:NextNumber(-5, 5) * v4,
					random:NextNumber(-1, 5) * v4,
					0
				)
				local v6 = cframe:Lerp(v3, 0.6666666666666666) * CFrame.new(
					random:NextNumber(-5, 5) * v4,
					random:NextNumber(-1, 5) * v4,
					0
				)
				local v7 = masterClock:GetTime() - timestamp
				local lastTime = tick()

				while tick() - lastTime < 0.35 do
					for k, v8 in pairs({ flameDebrisFree, botFree, shockwave1Free }) do
						if v8 then
							v8:Emit(2)
						end
					end

					local v8 = math.min(1, (tick() - lastTime) / 0.35)
					local now = tick()
					local v9 = cubicBezier(v8, cframe, v5, v6, v3) * CFrame.new(
						math.sin(now * 6 * 4) * 20 * (1 - v8 ^ 1.6),
						math.cos(now * 6 * 4) * 20 * (1 - v8 ^ 1.6),
						0
					)
					clone3:SetPrimaryPartCFrame(CFrame.new(v9.p, v9.p - (clone3.PrimaryPart.CFrame.p - v9.p).unit) * CFrame.Angles(
						0,
						1.5707963267948966,
						0
					))
					RunService.RenderStepped:Wait()
				end
			end)
			task.wait(0.1)
		end
	end
end