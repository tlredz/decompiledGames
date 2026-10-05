local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EasyVisuals = require(ReplicatedStorage.Client.UI.VFX.EasyVisuals)

for _, effectObject in EasyVisuals.new(script.Parent, "Wrapper", 0.5, nil, nil, script.Parent.Gradient.Color).EffectObjects do
	if effectObject.__class == "Gradient" then
		effectObject:SetRotation(script.Parent.Gradient.Rotation, script.Parent.Gradient.Rotation)
	end
end