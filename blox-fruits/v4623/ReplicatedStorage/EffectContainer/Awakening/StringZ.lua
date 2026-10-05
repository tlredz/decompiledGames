local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage.FX)
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function flameWhipTrail(cFrame, cframe, value, curveSize, parent)
	local clone = FX:WaitForChild("StringEffects").OverheatWhipTrail:Clone()
	Util.Debris:AddItem(clone, value + 2)
	clone.Parent = _WorldOrigin
	clone.CFrame = cFrame
	local v = false

	if parent then
		local clone2 = FX:WaitForChild("StringEffects").OverheatWhip:Clone()
		Util.Debris:AddItem(clone2, 4)
		local whipStart = clone2.WhipStart
		Util.Debris:AddItem(whipStart, 4)
		local whipEnd = clone2.WhipEnd
		clone2.WhipBeam.CurveSize0 = curveSize
		clone2.WhipBeamOuter.CurveSize0 = curveSize
		clone2.CFrame = parent.CFrame
		whipStart.Parent = parent
		clone2.Parent = _WorldOrigin
		spawn(function()
			while parent ~= nil and v == false do
				RunService.RenderStepped:Wait()
				whipEnd.WorldPosition = (clone.CFrame * CFrame.new(0, 0, -16)).p
			end

			clone2:Destroy()
			whipEnd:Destroy()
		end)
	end

	local character = game.Players.LocalPlayer.Character

	if character ~= nil and (character:FindFirstChild("HumanoidRootPart").Position - clone.Position).magnitude <= 15 then
		Util.CameraShaker:ShakeOnce(2, 2, 0.2, 0.2)
	end

	Util.Sound:Play("SetFireLoud", cFrame.p, nil, 1 + math.random(-15, 15) / 100, 1)
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(value or 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			CFrame = cFrame * cframe
		}
	)
	tween.Completed:Connect(function()
		v = true
	end)
	return tween
end

-- equivalent calls inferred from this helper; original call sites unknown
local function slashEffectModel(p, p2)
	spawn(function()
		local children = {}
		local children2 = {}
		local clone

		if p2 == 0 then
			clone = FX:WaitForChild("StringEffects").OverheatLRSlash:Clone()
		elseif p2 == 1 then
			clone = FX:WaitForChild("StringEffects").OverheatRLSlash:Clone()
		else
			clone = FX:WaitForChild("StringEffects").OverheatXShape:Clone()
		end

		local flameEmbers = clone.CenterAt.FlameEmbers

		for _, child in pairs(clone:GetChildren()) do
			if child:IsA("Beam") then
				table.insert(children, child)
			elseif child:IsA("Attachment") and string.find(child.Name, "Corner") then
				table.insert(children2, child)
			end
		end

		clone.CFrame = p * CFrame.new(0, 0, -5)
		Util.Debris:AddItem(clone, 8)
		clone.Parent = _WorldOrigin
		flameEmbers:Emit(10)
		Util.Sound:Play("SetFire2", clone.Position, nil, 1.3 + math.random(-10, 10) / 100, 0.8)
		local cFrame = clone.CFrame * CFrame.new(0, 0, -140)
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				CFrame = cFrame
			}
		)
		tween.Completed:Connect(function()
			spawn(function()
				local lastTime = tick()
				local v2 = {
					{ 0, 1 },
					{ 0.12, 0 },
					{ 0.8, 0 },
					{ 1, 1 }
				}

				while tick() - lastTime < 0.5 do
					local v3 = (tick() - lastTime) / 0.5
					RunService.RenderStepped:Wait()

					for _, v4 in pairs(v2) do
						local v5 = v4[2]
						v4[2] = v5 + (1 - v5) * v3
					end

					for _, v4 in pairs(children) do
						v4.Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(v2[1][1], v2[1][2]),
							NumberSequenceKeypoint.new(v2[2][1], v2[2][2]),
							NumberSequenceKeypoint.new(v2[3][1], v2[3][2]),
							NumberSequenceKeypoint.new(v2[4][1], v2[4][2])
						})
						local curveSize0 = v4.CurveSize0
						v4.CurveSize0 = curveSize0 + (10 - curveSize0) * v3
					end
				end
			end)

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			wait(1)
			clone:Destroy()
		end)

		for _, v2 in pairs(children) do
			if string.find(v2.Name, "Outer") then
				v2.Width0 = 5
				v2.Width1 = 25
			else
				v2.Width0 = 3
				v2.Width1 = 7.5
			end

			TweenService:Create(v2, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
				Width0 = 0.1,
				Width1 = 0.1
			}):Play()
		end

		for _, v2 in pairs(children2) do
			local vector = Vector3.new(v2.Position.X * 2, v2.Position.Y * 2, v2.Position.Z * 2)
			TweenService:Create(v2, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
				Position = vector
			}):Play()
		end

		tween:Play()
	end)
end

local function slashEffectLash(cFrame, hand, slashNum)
	if slashNum == 0 then
		local v = flameWhipTrail(
			cFrame * CFrame.new(0, 0, 5) * CFrame.Angles(0, 0, -0.5235987755982988) * CFrame.Angles(
				0,
				1.2217304763960306,
				0
			),
			CFrame.Angles(0, -2.0943951023931953, 0),
			0.25,
			10,
			hand
		)
		slashEffectModel(cFrame, slashNum) -- equivalent call inferred; original call site unknown
		v:Play()
	else
		if slashNum == 1 then
		end

		local v = flameWhipTrail(
			cFrame * CFrame.new(0, 0, 5) * CFrame.Angles(0, 0, 0.5235987755982988) * CFrame.Angles(
				0,
				-1.0471975511965976,
				0
			),
			CFrame.Angles(0, 1.9198621771937625, 0),
			0.25,
			-10,
			hand
		)
		slashEffectModel(cFrame, slashNum) -- equivalent call inferred; original call site unknown
		v:Play()
	end
end

return function(data)
	local cFrame = data.CFrame
	local hand = data.Hand or nil
	local slashNum = data.SlashNum

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 500 then
		return
	end

	slashEffectLash(cFrame, hand, slashNum)
end