local OutfitCodec = {
	properties = {
		"BackAccessory",
		"FaceAccessory",
		"FrontAccessory",
		"HairAccessory",
		"HatAccessory",
		"NeckAccessory",
		"ShouldersAccessory",
		"WaistAccessory",
		"Shirt",
		"Pants",
		"GraphicTShirt",
		"Face",
		"Head",
		"Torso",
		"LeftArm",
		"RightArm",
		"LeftLeg",
		"RightLeg",
		"BodyTypeScale",
		"DepthScale",
		"HeadScale",
		"HeightScale",
		"ProportionScale",
		"WidthScale",
		"ClimbAnimation",
		"FallAnimation",
		"IdleAnimation",
		"JumpAnimation",
		"RunAnimation",
		"SwimAnimation",
		"WalkAnimation",
		"MoodAnimation"
	},
	colors = {
		"HeadColor",
		"TorsoColor",
		"LeftArmColor",
		"RightArmColor",
		"LeftLegColor",
		"RightLegColor"
	},
	assets = {
		"Shirt",
		"Pants",
		"GraphicTShirt",
		"Face",
		"Head",
		"Torso",
		"LeftArm",
		"RightArm",
		"LeftLeg",
		"RightLeg",
		"ClimbAnimation",
		"FallAnimation",
		"IdleAnimation",
		"JumpAnimation",
		"RunAnimation",
		"SwimAnimation",
		"WalkAnimation",
		"MoodAnimation"
	}
}

function OutfitCodec.encode(instance)
	local v = {
		props = {},
		colors = {},
		accessories = {}
	}

	for _, property in ipairs(OutfitCodec.properties) do
		v.props[property] = instance[property]
	end

	for _, color in ipairs(OutfitCodec.colors) do
		local v2 = instance[color]
		v.colors[color] = { v2.R, v2.G, v2.B }
	end

	for _, v2 in ipairs(instance:GetAccessories(true)) do
		table.insert(v.accessories, {
			AssetId = v2.AssetId,
			AccessoryType = v2.AccessoryType.Name,
			IsLayered = v2.IsLayered,
			Order = v2.Order,
			Puffiness = v2.Puffiness
		})
	end

	v.emotes = instance:GetEmotes()
	v.equippedEmotes = instance:GetEquippedEmotes()
	v.adjustments = {}

	for _, accessoryDescription in ipairs(instance:GetChildren()) do
		if accessoryDescription:IsA("AccessoryDescription") then
			v.adjustments[tostring(accessoryDescription.AssetId)] = {
				position = {
					accessoryDescription.Position.X,
					accessoryDescription.Position.Y,
					accessoryDescription.Position.Z
				},
				rotation = {
					accessoryDescription.Rotation.X,
					accessoryDescription.Rotation.Y,
					accessoryDescription.Rotation.Z
				},
				scale = { accessoryDescription.Scale.X, accessoryDescription.Scale.Y, accessoryDescription.Scale.Z }
			}
		end
	end

	return v
end

function OutfitCodec.decode(data)
	local humanoidDescription = Instance.new("HumanoidDescription")

	for _, property in ipairs(OutfitCodec.properties) do
		if data.props[property] ~= nil then
			humanoidDescription[property] = data.props[property]
		end
	end

	for _, color in ipairs(OutfitCodec.colors) do
		local color2 = data.colors[color]

		if color2 then
			humanoidDescription[color] = Color3.new(color2[1], color2[2], color2[3])
		end
	end

	local clones = {}

	for _, v in ipairs(data.accessories or {}) do
		local clone = table.clone(v)
		clone.AccessoryType = Enum.AccessoryType[v.AccessoryType]
		table.insert(clones, clone)
	end

	humanoidDescription:SetAccessories(clones, true)

	for _, accessoryDescription in ipairs(humanoidDescription:GetChildren()) do
		if not accessoryDescription:IsA("AccessoryDescription") then
			continue
		end

		local v = data.adjustments and data.adjustments[tostring(accessoryDescription.AssetId)]

		if not v then
			continue
		end

		accessoryDescription.Position = Vector3.new(table.unpack(v.position))
		accessoryDescription.Rotation = Vector3.new(table.unpack(v.rotation))
		accessoryDescription.Scale = Vector3.new(table.unpack(v.scale))
	end

	if data.emotes then
		humanoidDescription:SetEmotes(data.emotes)
	end

	if data.equippedEmotes then
		humanoidDescription:SetEquippedEmotes(data.equippedEmotes)
	end

	return humanoidDescription
end

function OutfitCodec.ids(p)
	local v = {}
	local v2 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function add(value)
		if type(value) == "number" and value > 0 and not v[value] then
			v[value] = true
			table.insert(v2, value)
		end
	end

	for _, asset in ipairs(OutfitCodec.assets) do
		add(p.props[asset]) -- equivalent call inferred; original call site unknown
	end

	for _, v3 in ipairs(p.accessories or {}) do
		add(v3.AssetId) -- equivalent call inferred; original call site unknown
	end

	return v2
end

function OutfitCodec.setAccessoriesPreservingFit(instance, p)
	local v = {}

	for _, accessoryDescription in ipairs(instance:GetChildren()) do
		if accessoryDescription:IsA("AccessoryDescription") then
			v[accessoryDescription.AssetId] = {
				accessoryDescription.Position,
				accessoryDescription.Rotation,
				accessoryDescription.Scale
			}
		end
	end

	instance:SetAccessories(p, true)

	for _, accessoryDescription in ipairs(instance:GetChildren()) do
		if not (accessoryDescription:IsA("AccessoryDescription") and v[accessoryDescription.AssetId]) then
			continue
		end

		local v2 = v[accessoryDescription.AssetId]
		accessoryDescription.Position = v2[1]
		accessoryDescription.Rotation = v2[2]
		accessoryDescription.Scale = v2[3]
	end
end

return OutfitCodec