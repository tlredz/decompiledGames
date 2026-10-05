local RunService = game:GetService("RunService")
local SetParentOverrideWithColor = require(game.ReplicatedStorage.Util.SetParentOverrideWithColor)
local Debris = require(game.ReplicatedStorage.Util.Debris)
return function(part, instance, p, p2)
	local clone = instance:WaitForChild("MagnetAuraModel"):Clone()
	local part2 = assert(clone.PrimaryPart)
	clone:PivotTo(part.CFrame)
	SetParentOverrideWithColor(clone, p, p2, "MagnetFruitVFXColor")
	local scale = clone:GetScale()

	for _, emitter in clone:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	part2.Anchored = false
	part2.Massless = true
	local weld = Instance.new("Weld")
	weld.Part0 = part2
	weld.Part1 = part
	weld.C1 = CFrame.new(0, 60, -35)
	weld.Parent = clone
	local lastTime = os.clock()

	while clone.Parent and part.Parent and p.Parent do
		local v2 = math.clamp((os.clock() - lastTime) / 0.3333333333333333, 0, 1)
		clone:ScaleTo(scale * (v2 * -0.9 + 1))

		if v2 >= 1 then
			local clone2 = instance:WaitForChild("ExStartImpact"):Clone()
			clone2.CFrame = part2.CFrame
			SetParentOverrideWithColor(clone2, p, p2, "MagnetFruitVFXColor")
			local v3 = 0

			for _, emitter in clone2:GetDescendants() do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				v3 = math.max(v3, emitter.Lifetime.Max)
				emitter:Emit((emitter:GetAttribute("EmitCount")))
			end

			Debris:AddItem(clone2, v3)
			break
		else
			RunService.Heartbeat:Wait()
		end
	end

	clone:Destroy()
end