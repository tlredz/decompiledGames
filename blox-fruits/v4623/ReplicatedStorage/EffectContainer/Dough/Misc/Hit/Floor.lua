local currentCamera = workspace.CurrentCamera
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local misc = Util.Misc
local FX = require(game.ReplicatedStorage.FX)
local dough = FX:WaitForChild("Dough")
return function(instance)
	local cFrame = instance.CFrame or instance.Position
	local _ = instance.Color
	local scale = instance.Scale or 1
	local duration = instance.Duration or 1
	local _ = typeof(cFrame) == "Vector3" and CFrame.new(cFrame)
	local magnitude = (currentCamera.CFrame.p - cFrame.p).Magnitude

	if 150 + 15 * scale < magnitude then
		return
	end

	local clone = dough.Misc.Hit.Floor.Reference:Clone()
	clone:SetPrimaryPartCFrame(cFrame)
	local v = 0

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("BasePart") then
			local size = descendant.Size
			descendant.Size = Vector3.new(scale * size.X / 5, size.Y, scale * size.Z / 5)
		end

		if not descendant:IsA("ParticleEmitter") then
			continue
		end

		misc.ScaleParticle(descendant, scale / 5, {
			ZOffset = descendant.ZOffset + 0.5
		})
		descendant.Lifetime = NumberRange.new(descendant.Lifetime.Min * duration, descendant.Lifetime.Max * duration)
		v = math.max(descendant.Lifetime.Max, v)
	end

	clone.Parent = _WorldOrigin

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")

		if emitCount then
			emitter:Emit(emitCount * (instance.FastMode and 0.25 or 1))
		end
	end

	Util.Debris:AddItem(clone, v + 0.1)
end