local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
game:GetService("TweenService")
game:GetService("RunService")
local FX = require(ReplicatedStorage.FX)

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local mammoth = FX:WaitForChild("Mammoth")

local function jump(character, rootPart, stage, cFrame)
	local mammoth2 = character:FindFirstChild("Mammoth").Mammoth
	local _ = mammoth2["body4.002"]

	if stage == 1 then
		Util.Sound:Play("MammothBlast", rootPart, 20, 1 + math.random(-30, 30) / 100, 0.57)
		local clone = mammoth.MoveWind:Clone()
		local clone2 = mammoth.MoveWind:Clone()
		local clone3 = mammoth.MoveWind:Clone()
		local clone4 = mammoth.MoveWind:Clone()
		clone.Parent = mammoth2.FOOTSTEP_FL.Attachment
		clone2.Parent = mammoth2.FOOTSTEP_FR.Attachment
		clone3.Parent = mammoth2.FOOTSTEP_BL.Attachment
		clone4.Parent = mammoth2.FOOTSTEP_BR.Attachment
		clone:Emit(3)
		clone2:Emit(3)
		clone3:Emit(3)
		clone4:Emit(3)
		Util.Debris:AddItem(clone, 0.22)
		Util.Debris:AddItem(clone2, 0.22)
		Util.Debris:AddItem(clone3, 0.22)
		Util.Debris:AddItem(clone4, 0.22)
		task.wait(0.13)
		clone.LockedToPart = false
		clone2.LockedToPart = false
		clone3.LockedToPart = false
		clone4.LockedToPart = false
		local cframe = CFrame.new(rootPart.Position, rootPart.Position + cFrame.LookVector)

		if cframe.LookVector ~= cframe.LookVector then
			cframe = rootPart.CFrame
		end

		local part = Instance.new("Part")
		part.CanCollide = false
		part.Anchored = true
		part.CanQuery = false
		part.Transparency = 1
		part.Size = createVector(31.25, 31.25, 31.25)
		part.CFrame = cframe
		local clone_2 = mammoth2["body4.002"].FLIGHT:Clone()
		clone_2.Parent = part
		local clone_3 = mammoth2["body4.002"].FLIGHT2:Clone()
		clone_3.Parent = part
		local clone5 = mammoth2["body4.002"].GeppoRing:Clone()
		clone5.Parent = part

		for _, child in pairs(clone5:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end

		task.defer(function()
			local lastTime = tick()
			local now = 0

			while tick() - lastTime < 0.09000000000000001 do
				local velocity = rootPart.Velocity

				if velocity.Magnitude < 0.1 then
					velocity = cframe.LookVector
				end

				part.CFrame = CFrame.new(rootPart.Position, rootPart.Position + velocity) * CFrame.new(0, 0, -7.5)

				if tick() - now > 0.015873015873015872 then
					part.FLIGHT:Emit(2)
					part.FLIGHT2:Emit(2)
					now = tick()
				end

				task.wait()
			end

			part.CFrame = CFrame.new(0, -1000, 0)
			task.wait(1.5)
			part:Destroy()
		end)
		part.Parent = workspace._WorldOrigin
	elseif stage == 2 then
		task.wait(0.05)

		if cFrame.LookVector ~= cFrame.LookVector then
			cFrame = rootPart.CFrame
		end

		local v = rootPart.Size.Y * 0.5 + rootPart.Parent.Humanoid.HipHeight + 5
		local part = Instance.new("Part")
		part.CanCollide = false
		part.Anchored = true
		part.CanQuery = false
		part.Transparency = 1
		part.Size = createVector(31.25, 31.25, 31.25)
		part.CFrame = cFrame
		local clone_4 = mammoth2["body4.002"].DASHLINES:Clone()
		clone_4.Parent = part
		local clone_5 = mammoth2["body4.002"].DASHLINES2:Clone()
		clone_5.Parent = part
		local clone_6 = mammoth2["body4.002"].DashRing:Clone()
		clone_6.Parent = part
		local clone_7 = mammoth2["body4.002"].SmokeBack:Clone()
		clone_7.Parent = part
		task.defer(function()
			local lastTime = tick()
			local now = 0

			while tick() - lastTime < 0.135 do
				local lookVector = rootPart.Velocity * createVector(1, 0, 1)

				if lookVector.Magnitude < 0.1 then
					lookVector = cFrame.LookVector
				end

				part.CFrame = CFrame.new(rootPart.Position, rootPart.Position + lookVector) * CFrame.new(0, 0, -7.5)

				if tick() - now > 0.015873015873015872 then
					local dot = lookVector.Unit:Dot(rootPart.CFrame.LookVector)
					part.DASHLINES:Emit(2)
					part.DASHLINES2:Emit(2)

					if dot > 0.99 then
						part.DashRing.ringbig:Emit(3)
					end

					local rayMap, _, _ = Util.RayMap(rootPart.Position, (Vector3.new(0, -v, 0)))

					if rayMap then
						part.SmokeBack.Smoke.Color = ColorSequence.new(rayMap.Color)
						part.SmokeBack.Smoke:Emit(part.SmokeBack.Smoke:GetAttribute("EmitCount"))
					end

					now = tick()
				end

				task.wait()
			end

			part.CFrame = CFrame.new(0, -1000, 0)
			task.wait(1.5)
			part:Destroy()
		end)
		part.Parent = workspace._WorldOrigin
		Util.Sound:Play("MammothBlast", rootPart, 20, 1 + math.random(-30, 30) / 100, 0.45)
		Util.Sound:Play("MammothFallCrush", rootPart, 20, 1 + math.random(-30, 30) / 100, 0.45)
	end
end

return function(player)
	local rootPart = player.RootPart or nil
	local character = player.Character or nil
	jump(character, rootPart, player.stage, player.CFrame)
end