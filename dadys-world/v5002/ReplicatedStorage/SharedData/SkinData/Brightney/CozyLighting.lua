return {
	Name = "Cozy Lighting",
	Cost = 600,
	DandyStore = true,
	OverwriteAnimations = {
		Run = "rbxassetid://107213778341008",
		Walk = "rbxassetid://132234132467513",
		Idle = "rbxassetid://110296047788215",
		Quirk = "rbxassetid://97570975245266",
		Decode = "rbxassetid://94228335063954",
		Ability = "rbxassetid://122545518084611"
	},
	FaceTextures = {
		Normal = "rbxassetid://97624151771851",
		Blink = "rbxassetid://138193537710087",
		Hurt = "rbxassetid://117730009102629"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(folder)
		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(222, 204, 183)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(222, 204, 183))
				})
			elseif descendant:IsA("Light") then
				descendant.Color = Color3.fromRGB(255, 192, 46)
			end
		end
	end
}