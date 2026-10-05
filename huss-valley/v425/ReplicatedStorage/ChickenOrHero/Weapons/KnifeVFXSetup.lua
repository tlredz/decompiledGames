local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local v = {
	CopperBite = {
		184,
		113,
		64,
		"sparkles",
		2
	},
	Ashsteel = {
		164,
		181,
		192,
		"sparkles",
		2
	},
	IronFang = {
		189,
		218,
		237,
		"sparkles",
		2
	},
	ForestEdge = {
		102,
		194,
		113,
		"sparkles",
		2
	},
	AmberSting = {
		255,
		179,
		51,
		"sparkles",
		4
	},
	RoseQuartz = {
		255,
		134,
		200,
		"sparkles",
		4
	},
	TidalShard = {
		71,
		207,
		255,
		"smoke",
		4
	},
	VenomThorn = {
		143,
		248,
		61,
		"smoke",
		4
	},
	MoltenFang = {
		255,
		96,
		25,
		"fire",
		8
	},
	SpectralReaper = {
		113,
		247,
		194,
		"smoke",
		7
	},
	StormTalon = {
		106,
		179,
		255,
		"sparkles",
		12
	},
	Moonfang = {
		195,
		177,
		255,
		"sparkles",
		6
	},
	SolarPhoenix = {
		255,
		195,
		53,
		"fire",
		12
	},
	VoidSovereign = {
		157,
		70,
		255,
		"smoke",
		10
	},
	GlacialCrown = {
		135,
		236,
		255,
		"sparkles",
		12
	},
	CelestialDragon = {
		255,
		127,
		199,
		"fire",
		10
	},
	BaseDagger = {
		185,
		208,
		223,
		"sparkles",
		1
	},
	SpoonDagger = {
		185,
		255,
		237,
		"sparkles",
		2
	},
	BalloonDagger = {
		255,
		122,
		184,
		"sparkles",
		3
	}
}
return {
	apply = function(parent)
		local v2 = v[parent.Name]

		if parent:GetAttribute("Rarity") == "Epic" or parent:GetAttribute("Rarity") == "Legendary" then
			if not v2 then
				return false
			end

			for _, child in parent:GetChildren() do
				if child:GetAttribute("KnifeVFXGenerated") then
					child:Destroy()
				end
			end

			local color = Color3.fromRGB(v2[1], v2[2], v2[3])

			for _, childName in { "Blade", "StowedBlade" } do
				local part = parent:FindFirstChild(childName)

				if not (part and part:IsA("BasePart")) then
					continue
				end

				local part2 = Instance.new("Part")
				part2.Name = childName .. "Aura"
				part2.Size = createVector(0.1, 0.1, 0.1)
				part2.Transparency = 1
				part2.CanCollide = false
				part2.CanTouch = false
				part2.CanQuery = false
				part2.CastShadow = false
				part2.Massless = true
				part2.CFrame = part.CFrame
				part2:SetAttribute("WeaponVFX", true)
				part2:SetAttribute("KnifeVFXGenerated", true)
				local weld = Instance.new("Weld")
				weld.Name = "VFXWeld"
				weld.Part0 = part
				weld.Part1 = part2
				weld.Parent = part2
				local fantasyCrateSkin = parent:GetAttribute("FantasyCrateSkin") == true
				local X = fantasyCrateSkin and part.Size.X or part.Size.Z
				local v3 = fantasyCrateSkin and createVector(1, 0, 0) or createVector(-0, -0, -1)
				local attachment = Instance.new("Attachment")
				attachment.Name = "EdgeTip"
				attachment.Position = v3 * X * 0.42
				attachment.Parent = part2
				local attachment2 = Instance.new("Attachment")
				attachment2.Name = "EdgeHeel"
				attachment2.Position = v3 * -X * 0.1
				attachment2.Parent = part2
				local trail = Instance.new("Trail")
				trail.Name = "BladeStreak"
				trail.Attachment0 = attachment2
				trail.Attachment1 = attachment
				trail.Color = ColorSequence.new(color, Color3.new(1, 1, 1))
				trail.Lifetime = v2[5] >= 7 and 0.24 or 0.12
				trail.MinLength = 0.08
				trail.LightEmission = 0.85
				trail.FaceCamera = true
				trail.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.48),
					NumberSequenceKeypoint.new(1, 1)
				})
				trail.WidthScale = NumberSequence.new(1, 0)
				trail.Enabled = false
				trail:SetAttribute("VFXAuthoredEnabled", true)
				trail.Parent = part2
				local particleEmitter = Instance.new("ParticleEmitter")
				particleEmitter.Name = parent.Name .. "Motes"
				particleEmitter.Texture = "rbxasset://textures/particles/" .. v2[4] .. "_main.dds"
				particleEmitter.Color = ColorSequence.new(color, color:Lerp(Color3.new(1, 1, 1), 0.65))
				particleEmitter.LightEmission = 0.8
				particleEmitter.LightInfluence = 0
				particleEmitter.Rate = v2[5]
				particleEmitter:SetAttribute("VFXBaseRate", v2[5])
				particleEmitter:SetAttribute("VFXAuthoredEnabled", true)
				particleEmitter.Lifetime = NumberRange.new(0.25, v2[4] == "smoke" and 0.85 or 0.55)
				particleEmitter.Speed = NumberRange.new(0.15, v2[4] == "fire" and 1.6 or 0.7)
				particleEmitter.Acceleration = Vector3.new(0, v2[4] == "fire" and 2 or 0.5, 0)
				particleEmitter.SpreadAngle = Vector2.new(80, 80)
				particleEmitter.Rotation = NumberRange.new(0, 360)
				particleEmitter.RotSpeed = NumberRange.new(-90, 90)
				particleEmitter.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.2, v2[4] == "smoke" and 0.3 or 0.14),
					NumberSequenceKeypoint.new(1, 0)
				})
				particleEmitter.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.2, 0.25),
					NumberSequenceKeypoint.new(1, 1)
				})
				particleEmitter.Enabled = false
				particleEmitter.Parent = attachment
				part2.Parent = parent
				CollectionService:AddTag(part2, "ValleyWeaponVFX")
			end

			return true
		else
			for _, child in parent:GetChildren() do
				if child:GetAttribute("KnifeVFXGenerated") then
					child:Destroy()
				end
			end

			return false
		end
	end
}