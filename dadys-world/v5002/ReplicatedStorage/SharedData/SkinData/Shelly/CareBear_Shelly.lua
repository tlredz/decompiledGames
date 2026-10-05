local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CareBearShelly = {}
CareBearShelly.Name = "Cheer Bear"
CareBearShelly.RobuxCost = script:GetAttribute("RobuxCost") or -1
CareBearShelly.ProductId = 3367979900
CareBearShelly.OverwriteAnimations = {
	Walk = "rbxassetid://97569421338492",
	Idle = "rbxassetid://81739221582887",
	Ability = "rbxassetid://132074253259163",
	Run = "rbxassetid://87952146739155",
	Quirk = "rbxassetid://82843565036740",
	Decode = "rbxassetid://110404137593348"
}
CareBearShelly.FaceTextures = {
	Normal = "rbxassetid://106193491655983",
	Blink = "rbxassetid://71985632980435",
	Hurt = "rbxassetid://138250515155630"
}
CareBearShelly.USE_SKIN_MODEL = true

function CareBearShelly.ApplySkin(instance, instance2)
	local Universe = require(ReplicatedStorage.SharedUtils.Universe)

	if Universe:IsLobby() then
		return
	end

	local clone = instance2:WaitForChild("Head"):WaitForChild("Attachment"):Clone()
	clone.Parent = instance:WaitForChild("Head")
end

function CareBearShelly.UseAbility(instance)
	local head = instance:WaitForChild("Head")
	local emittersByName = {}

	for _, emitter in pairs(head:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
			continue
		end

		emittersByName[emitter.Name] = emitter
	end

	if emittersByName.Icon then
		emittersByName.Icon:Emit(1)
	end

	if emittersByName.Stars then
		emittersByName.Stars:Emit(1)
	end

	if emittersByName.Sparkles then
		emittersByName.Sparkles:Emit(5)
	end
end

return CareBearShelly