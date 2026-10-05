workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.MasterClock
local _ = Util.BoatTween
local _ = Util.Debris
local sound = Util.Sound
local _ = Util.PartCache
local player = nil
local _ = Util.CameraShaker
local FX = require(game.ReplicatedStorage.FX)
local TAP = FX:WaitForChild("Dino").TAP

local function ClawSlash(folder, humanoidRootPart, data)
	local multiplier = data.Multiplier
	local slashAngle = data.SlashAngle
	local slashAngle2 = data.SlashAngle2
	local yPosition = data.YPosition
	local clone = data.SlashType:Clone()
	clone.CFrame = humanoidRootPart.CFrame
	clone.Weld.Part0 = humanoidRootPart
	clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.new(0, yPosition, 0) * slashAngle * slashAngle2
	Util.SetParentOverrideWithColor(clone, folder, player, "TRexFruitVFXColor")

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("Beam") then
			descendant.CurveSize0 *= multiplier
			descendant.CurveSize1 *= multiplier
			descendant.Width0 *= multiplier
			descendant.Width1 *= multiplier
		elseif descendant:IsA("Attachment") then
			descendant.Position = Vector3.new(
				descendant.Position.X * multiplier,
				descendant.Position.Y * multiplier,
				descendant.Position.Z * multiplier
			)
		end
	end

	task.spawn(function()
		task.wait(0.125)
		local clone2 = TAP.SlashHit:Clone()
		clone2.CFrame = clone.CFrame * CFrame.new(0, 0, -9)
		Util.SetParentOverrideWithColor(clone2, folder, player, "TRexFruitVFXColor")

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end)
	coroutine.wrap(function()
		for _, beam in pairs(clone:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Enabled = true
			local startDelay = beam:GetAttribute("StartDelay")
			local v = beam
			local v2 = beam:GetAttribute("EndDelay")
			coroutine.wrap(function()
				local tween = TweenService:Create(
					v,
					TweenInfo.new(v2 / 1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						Width0 = v.Width0,
						Width1 = v.Width1
					}
				)
				v.Width0 = 0
				v.Width1 = 0
				task.wait(startDelay)
				tween:Play()
				task.wait(v2)

				if v:IsDescendantOf(clone.Slash2) then
					task.wait(0.0035000000000000005)
				elseif v:IsDescendantOf(clone.Slash3) then
					task.wait(0.01)
				elseif v:IsDescendantOf(clone) and not (v:IsDescendantOf(clone.Slash3) or v:IsDescendantOf(clone.Slash2)) then
					task.wait(0.012)
				end

				local tween2 = TweenService:Create(
					v,
					TweenInfo.new(v2 / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween2:Play()
				tween2.Completed:Wait()
				v:Destroy()
			end)()
		end
	end)()
	local tween = TweenService:Create(
		clone.Weld,
		TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.Angles(
				-2.6179938779914944,
				0,
				0
			)
		}
	)
	tween:Play()
	tween.Completed:Wait()
	clone.Weld.Enabled = false
	clone.Anchored = true
	TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		CFrame = clone.CFrame * CFrame.Angles(-1.3089969389957472, 0, 0)
	}):Play()
end

local function TailSlash(folder, humanoidRootPart, data)
	local multiplier = data.Multiplier
	local multiplier2 = data.Multiplier2
	local slashAngle = data.SlashAngle
	local slashAngle2 = data.SlashAngle2
	local yPosition = data.YPosition
	local clone = data.SlashType:Clone()
	clone.CFrame = humanoidRootPart.CFrame
	clone.Weld.Part0 = humanoidRootPart
	clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.new(0, yPosition, 0) * slashAngle * slashAngle2
	Util.SetParentOverrideWithColor(clone, folder, player, "TRexFruitVFXColor")

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("Beam") then
			descendant.CurveSize0 *= multiplier
			descendant.CurveSize1 *= multiplier
			descendant.Width0 *= multiplier * multiplier2
			descendant.Width1 *= multiplier * multiplier2
		elseif descendant:IsA("Attachment") then
			descendant.Position = Vector3.new(
				descendant.Position.X * multiplier,
				descendant.Position.Y * multiplier,
				descendant.Position.Z * multiplier
			)
		end
	end

	task.spawn(function()
		task.wait(0.1)
		local clone2 = TAP.TailSlashHit:Clone()
		clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -0)
		Util.SetParentOverrideWithColor(clone2, folder, player, "TRexFruitVFXColor")

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end)

	for _, beam in pairs(clone:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		beam.Enabled = true
		local startDelay = beam:GetAttribute("StartDelay")
		local v = beam
		local v2 = beam:GetAttribute("EndDelay")
		task.spawn(function()
			local tween = TweenService:Create(v, TweenInfo.new(v2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Width0 = v.Width0,
				Width1 = v.Width1
			})
			v.Width0 = 0
			v.Width1 = 0
			task.wait(startDelay)
			tween:Play()
		end)
	end

	for _ = 1, 3 do
		local tween = TweenService:Create(
			clone.Weld,
			TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.Angles(
					0,
					1.2217304763960306,
					0
				)
			}
		)
		tween:Play()
		tween.Completed:Wait()
	end

	clone.Weld.Enabled = false
	clone.Anchored = true
	TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		CFrame = clone.CFrame * CFrame.Angles(0, 0.8726646259971648, 0)
	}):Play()

	for _, beam in pairs(clone:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		local v = beam
		task.spawn(function()
			local endDelay = v:GetAttribute("EndDelay")
			local tween = TweenService:Create(
				v,
				TweenInfo.new(endDelay / 1.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Width0 = 0,
					Width1 = 0
				}
			)
			tween:Play()
			tween.Completed:Wait()
			v:Destroy()
		end)
	end
end

return function(player2)
	player = player2.player
	local ID = player2.ID
	local character = player2.Character

	if character then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 600 then
			return
		end

		local folder = Instance.new("Folder", workspace._WorldOrigin)
		Util.Debris:AddItem(folder, 4)

		if humanoidRootPart then
			if ID == 1 then
				task.spawn(function()
					local v = {
						Multiplier = 1,
						SlashAngle = CFrame.Angles(0, 0, 1.3962634015954636),
						SlashAngle2 = CFrame.Angles(2.9670597283903604, 0, 0),
						YPosition = 2.5,
						SlashType = TAP.Slash
					}
					sound:Play("DinoM1_1", humanoidRootPart, nil, 1, 1)
					ClawSlash(folder, humanoidRootPart, v)
				end)
			elseif ID == 2 then
				task.spawn(function()
					local v = {
						Multiplier = 1,
						SlashAngle = CFrame.Angles(0, 0, -1.3962634015954636),
						SlashAngle2 = CFrame.Angles(2.9670597283903604, 0, 0),
						YPosition = 2.5,
						SlashType = TAP.Slash
					}
					sound:Play("DinoM1_2", humanoidRootPart, nil, 1, 1)
					ClawSlash(folder, humanoidRootPart, v)
				end)
			elseif ID == 3 then
				task.spawn(function()
					local v = {
						Multiplier = 1,
						SlashAngle = CFrame.Angles(0, 0, -0.7853981633974483),
						SlashAngle2 = CFrame.Angles(2.9670597283903604, 0, 0),
						YPosition = 2.5,
						SlashType = TAP.Slash
					}
					sound:Play("DinoM1_1", humanoidRootPart, nil, 1.2, 1)
					ClawSlash(folder, humanoidRootPart, v)
				end)
				task.spawn(function()
					local v = {
						Multiplier = 1,
						SlashAngle = CFrame.Angles(0, 0, 0.7853981633974483),
						SlashAngle2 = CFrame.Angles(2.9670597283903604, 0, 0),
						YPosition = 2.5,
						SlashType = TAP.Slash
					}
					sound:Play("DinoM1_2", humanoidRootPart, nil, 0.8, 1)
					ClawSlash(folder, humanoidRootPart, v)
				end)
			elseif ID == 4 then
				task.spawn(function()
					local v = {
						Multiplier = 1.75,
						Multiplier2 = 1.5,
						SlashAngle = CFrame.Angles(0, 0, -0.12217304763960307),
						SlashAngle2 = CFrame.Angles(0, -2.6179938779914944, 0),
						YPosition = 0,
						SlashType = TAP.TailSlash
					}
					sound:Play("DinoM1_3", humanoidRootPart, nil, 1, 1)
					TailSlash(folder, humanoidRootPart, v)
				end)
			end
		end
	end
end