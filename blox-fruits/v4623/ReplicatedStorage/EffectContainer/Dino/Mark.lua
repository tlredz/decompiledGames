local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.MasterClock
local _ = Util.BoatTween
local _ = Util.Debris
local _ = Util.Sound
local _ = Util.PartCache
local player = nil
local _ = Util.CameraShaker
local FX = require(game.ReplicatedStorage.FX)
local mark = FX:WaitForChild("Dino").Mark
return function(player2)
	player = player2.player
	local character = player2.Character
	local duration = player2.Duration
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 900 then
			return
		end

		if character:GetAttribute("DinoMarkTimestamp") then
			character:SetAttribute("DinoMarkTimestamp", tick() + duration)
			return
		end

		character:SetAttribute("DinoMarkTick", nil)
		character:SetAttribute("DinoMarkTimestamp", tick() + duration)
		local clone = mark.Logo:Clone()
		clone.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(0, 5 + humanoidRootPart.Size.Y / 2, 0))
		clone.Weld.Part0 = humanoidRootPart
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "TRexFruitVFXColor")
		local clone2 = mark.Hit:Clone()
		clone2.CFrame = CFrame.new(humanoidRootPart.Position)
		clone2.Weld.Part0 = humanoidRootPart
		Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "TRexFruitVFXColor")
		local emitters = {}
		local emitters2 = {}

		for _, emitter in ipairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter:Emit(1)
			table.insert(emitters, emitter)
		end

		for _, emitter in ipairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				table.insert(emitters2, emitter)
			end
		end

		local lastTime = tick()
		local lastTime2 = tick()

		while true do
			if character:GetAttribute("DinoMarkTick") and tick() - lastTime2 > 0.25 then
				lastTime2 = tick()
				local v = math.random(-180, 180)

				for _, v2 in ipairs(emitters2) do
					v2.Rotation = NumberRange.new(v, v)
					v2:Emit(1)
				end
			end

			if tick() - lastTime > 0.666 then
				lastTime = tick()

				for _, v in ipairs(emitters) do
					v:Clear()
					v:Emit(1)
				end
			end

			task.wait()

			if not (tick() - character:GetAttribute("DinoMarkTimestamp") > 0 or not character:IsDescendantOf(workspace)) then
				continue
			end

			character:SetAttribute("DinoMarkTick", nil)
			character:SetAttribute("DinoMarkTimestamp", nil)
			Util.Debris:AddItem(clone, 1)
			Util.Debris:AddItem(clone2, 1)
			break
		end
	end
end