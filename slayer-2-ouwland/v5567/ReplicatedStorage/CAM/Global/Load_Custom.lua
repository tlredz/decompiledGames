local insert = table.insert
local clamp = math.clamp
local CustomizationInfo = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("CustomizationInfo"))
local Update_Item_equippation = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Characters"):WaitForChild("Update_Item_equippation"))

function add_clothing_to(instance, parent, instance2)
	if parent:FindFirstChild(instance2.Name) == nil then
		local clone = instance2:Clone()

		for _, child in ipairs(clone:GetChildren()) do
			local child2 = instance:FindFirstChild(child:FindFirstChild("CorName") ~= nil and child.CorName.Value or child.Name)

			if child2 == nil then
				continue
			end

			local v = child
			local part = child2

			local function upd_new_clone_size()
				if v:FindFirstChild("Weld") ~= nil then
					if v:FindFirstChild("Tang") ~= nil then
						v.Tang:Destroy()
					end

					if v:FindFirstChild("Ds") == nil then
						local vector3Value = Instance.new("Vector3Value")
						vector3Value.Value = v.Size
						vector3Value.Name = "Ds"
						vector3Value.Parent = v
					end

					local weld = v.Weld
					local value = v.CorrespondingSize.Value
					local v3 = part.Size / value
					v.Size = v.Ds.Value * v3
					local clone2 = weld:Clone()
					clone2.Name = "Tang"
					clone2.Parent = v
					clone2.Part1 = v
					clone2.Part0 = part
					local C0 = clone2.C0
					local p = C0.p
					local v4 = C0 - p
					local v5 = p * v3
					clone2.C0 = CFrame.new(v5) * v4
					local C1 = clone2.C1
					local p2 = C1.p
					local v6 = C1 - p2
					local v7 = p2 * v3
					clone2.C1 = CFrame.new(v7) * v6
				end
			end

			upd_new_clone_size()
		end

		clone.Parent = parent
	end
end

local function trim_to_kept_parts(parent, instance, attributeName: string)
	local attribute = parent:GetAttribute(attributeName)

	if attribute == nil then
		return
	end

	local v = "," .. attribute .. ","

	for _, child in instance:GetChildren() do
		for _, part in child:GetChildren() do
			if not part:IsA("BasePart") or string.find(v, "," .. part.Name .. ",", 1, true) then
				continue
			end

			part:Destroy()
		end
	end
end

return function(p, parent, p2, p3)
	local v = {}
	parent:SetAttribute(
		"currentcustidd",
		parent.Name .. tostring(math.random(1, 99999)) .. tostring(math.random(1, 99999))
	)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function skin_color()
		local bodyColors = CustomizationInfo.getBodyColors(p, p2)
		return bodyColors[clamp(p2.Customization.skinColor.Value, 1, #bodyColors)]
	end

	local skinColor = p2.Customization.skinColor

	local function update()
		local v2 = skin_color() -- equivalent call inferred; original call site unknown

		for _, v3 in parent:QueryDescendants("BasePart[$Color=bc],SurfaceAppearance[$Color=bc]") do
			v3.Color = v2
		end

		if parent:FindFirstChildOfClass("Humanoid") == nil then
			for _, part in ipairs(parent:GetChildren()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
					part.Color = v2
				end
			end
		else
			local v3 = parent:FindFirstChildOfClass("BodyColors")

			if v3 == nil then
				v3 = Instance.new("BodyColors")
				v3.Parent = parent
			end

			v3.LeftArmColor3 = v2
			v3.RightArmColor3 = v2
			v3.RightLegColor3 = v2
			v3.LeftLegColor3 = v2
			v3.HeadColor3 = v2
			v3.TorsoColor3 = v2
		end
	end

	update()

	if p3 == nil then
		insert(v, skinColor.Changed:Connect(update))
		insert(v, p2.Race.Changed:Connect(update))
	end

	local secondary = p2.Customization.Hair.Secondary
	local secondaryHairFolder = parent:FindFirstChild("SecondaryHairFolder") or Instance.new("Configuration", parent)
	secondaryHairFolder.Name = "SecondaryHairFolder"
	local head = parent.Head

	local function upd_color()
		for _, child in ipairs(secondaryHairFolder:GetChildren()) do
			for _, part in ipairs(child:GetChildren()) do
				if not part:IsA("BasePart") then
					continue
				end

				local color = part:GetAttribute("Color")

				if color == "nc" then
					continue
				end

				if color == "c2" then
					part.Color = Color3.new(
						secondary.Color2.R.Value,
						secondary.Color2.G.Value,
						secondary.Color2.B.Value
					)
				else
					part.Color = Color3.new(secondary.Color.R.Value, secondary.Color.G.Value, secondary.Color.B.Value)
				end
			end
		end
	end

	local function update2()
		for _, child in ipairs(secondaryHairFolder:GetChildren()) do
			child:Destroy()
		end

		if parent:GetAttribute("HairDisabled") then
			return
		end

		local hairs = CustomizationInfo.getHairs(p, p2)
		local v3 = clamp(secondary.Value.Value, 0, #hairs)
		local child = game.ReplicatedStorage.Assets.Appearance.Hairs:FindFirstChild("Hair" .. v3)

		if child then
			local clone = child:Clone()
			clone.Parent = secondaryHairFolder
			clone.Head_Weld.Part1 = head
		end

		upd_color()
	end

	update2()

	if p3 == nil then
		for i = 1, 2 do
			insert(v, secondary["Color" .. (i == 1 and "" or i)].R.Changed:Connect(upd_color))
			insert(v, secondary["Color" .. (i == 1 and "" or i)].G.Changed:Connect(upd_color))
			insert(v, secondary["Color" .. (i == 1 and "" or i)].B.Changed:Connect(upd_color))
		end

		insert(v, secondary.Value.Changed:Connect(update2))
		insert(v, parent:GetAttributeChangedSignal("HairDisabled"):Connect(update2))
	end

	local primary = p2.Customization.Hair.Primary
	local primaryHairFolder = parent:FindFirstChild("PrimaryHairFolder") or Instance.new("Configuration", parent)
	primaryHairFolder.Name = "PrimaryHairFolder"
	local head2 = parent.Head

	local function upd_color2()
		for _, child in ipairs(primaryHairFolder:GetChildren()) do
			for _, part in ipairs(child:GetChildren()) do
				if not part:IsA("BasePart") then
					continue
				end

				local color = part:GetAttribute("Color")

				if color == "nc" then
					continue
				end

				if color == "c2" then
					part.Color = Color3.new(primary.Color2.R.Value, primary.Color2.G.Value, primary.Color2.B.Value)
				else
					part.Color = Color3.new(primary.Color.R.Value, primary.Color.G.Value, primary.Color.B.Value)
				end
			end
		end
	end

	local function update3()
		for _, child in ipairs(primaryHairFolder:GetChildren()) do
			child:Destroy()
		end

		if parent:GetAttribute("HairDisabled") then
			return
		end

		local hairs = CustomizationInfo.getHairs(p, p2)
		local v3 = clamp(primary.Value.Value, 0, #hairs)
		local child = game.ReplicatedStorage.Assets.Appearance.Hairs:FindFirstChild("Hair" .. v3)

		if child then
			local clone = child:Clone()
			clone.Parent = primaryHairFolder
			clone.Head_Weld.Part1 = head2
		end

		upd_color2()
	end

	update3()

	if p3 == nil then
		for i = 1, 2 do
			insert(v, primary["Color" .. (i == 1 and "" or i)].R.Changed:Connect(upd_color2))
			insert(v, primary["Color" .. (i == 1 and "" or i)].G.Changed:Connect(upd_color2))
			insert(v, primary["Color" .. (i == 1 and "" or i)].B.Changed:Connect(upd_color2))
		end

		insert(v, primary.Value.Changed:Connect(update3))
		insert(v, parent:GetAttributeChangedSignal("HairDisabled"):Connect(update3))
	end

	local beard = p2.Customization.Hair.Beard
	local beardFolder = parent:FindFirstChild("BeardFolder") or Instance.new("Configuration", parent)
	beardFolder.Name = "BeardFolder"
	local head3 = parent.Head

	local function upd_color3()
		for _, child in ipairs(beardFolder:GetChildren()) do
			for _, part in ipairs(child:GetChildren()) do
				if not part:IsA("BasePart") then
					continue
				end

				local color = part:GetAttribute("Color")

				if color == "nc" then
					continue
				end

				if color == "c2" then
					part.Color = Color3.new(beard.Color2.R.Value, beard.Color2.G.Value, beard.Color2.B.Value)
				else
					part.Color = Color3.new(beard.Color.R.Value, beard.Color.G.Value, beard.Color.B.Value)
				end
			end
		end
	end

	local function update4()
		for _, child in ipairs(beardFolder:GetChildren()) do
			child:Destroy()
		end

		if parent:GetAttribute("BeardDisabled") then
			return
		end

		local beards = CustomizationInfo.getBeards(p, p2)
		local v3 = clamp(beard.Value.Value, 0, #beards)
		local child = game.ReplicatedStorage.Assets.Appearance.Beards:FindFirstChild("Beard" .. v3)

		if child then
			local clone = child:Clone()
			clone.Parent = beardFolder
			clone.Weld.Part1 = head3
		end

		upd_color3()
	end

	update4()

	if p3 == nil then
		for i = 1, 2 do
			insert(v, beard["Color" .. (i == 1 and "" or i)].R.Changed:Connect(upd_color3))
			insert(v, beard["Color" .. (i == 1 and "" or i)].G.Changed:Connect(upd_color3))
			insert(v, beard["Color" .. (i == 1 and "" or i)].B.Changed:Connect(upd_color3))
		end

		insert(v, beard.Value.Changed:Connect(update4))
		insert(v, parent:GetAttributeChangedSignal("BeardDisabled"):Connect(update4))
	end

	local horns = p2.Customization:FindFirstChild("Horns")

	if horns ~= nil then
		local hornsFolder = parent:FindFirstChild("HornsFolder") or Instance.new("Configuration", parent)
		hornsFolder.Name = "HornsFolder"
		local head4 = parent.Head

		local function update5()
			for _, child in ipairs(hornsFolder:GetChildren()) do
				child:Destroy()
			end

			if parent:GetAttribute("HornsDisabled") then
				return
			end

			local horns2 = CustomizationInfo.getHorns(p, p2)
			local v3 = clamp(horns.Value, 0, #horns2)
			local horns3 = game.ReplicatedStorage.Assets.Appearance:FindFirstChild("Horns")
			local child = horns3 and horns3:FindFirstChild("Horn" .. v3)

			if child then
				local clone = child:Clone()
				clone.Parent = hornsFolder
				clone.Weld.Part0 = head4
			end
		end

		update5()

		if p3 == nil then
			insert(v, horns.Changed:Connect(update5))
			insert(v, p2.Race.Changed:Connect(update5))
			insert(v, parent:GetAttributeChangedSignal("HornsDisabled"):Connect(update5))
		end
	end

	local eyes = p2.Customization.Face.Eyes

	local function update5()
		local eyes2 = CustomizationInfo.getEyes(p, p2)
		local eye = eyes2[clamp(eyes.Value, 1, #eyes2)]
		local fakeHead = parent.Head.FakeHead

		if fakeHead:FindFirstChild("eyes") == nil then
			local decal = Instance.new("Decal", fakeHead)
			decal.Name = "eyes"
			decal.Face = "Front"
		end

		fakeHead.eyes.Texture = eye.Texture
	end

	update5()

	if p3 == nil then
		insert(v, eyes.Changed:Connect(update5))
		insert(v, p2.Race.Changed:Connect(update5))
	end

	local nose = p2.Customization.Face.Nose

	local function update6()
		local noses = CustomizationInfo.getNoses(p, p2)
		local nos = noses[clamp(nose.Value, 1, #noses)]
		local fakeHead = parent.Head.FakeHead

		if fakeHead:FindFirstChild("nose") == nil then
			local decal = Instance.new("Decal", fakeHead)
			decal.Name = "nose"
			decal.Face = "Front"
		end

		fakeHead.nose.Texture = nos.Texture
	end

	update6()

	if p3 == nil then
		insert(v, nose.Changed:Connect(update6))
	end

	local mouth = p2.Customization.Face.Mouth

	local function update7()
		local mouths = CustomizationInfo.getMouths(p, p2)
		local mouth2 = mouths[clamp(mouth.Value, 1, #mouths)]
		local fakeHead = parent.Head.FakeHead

		if fakeHead:FindFirstChild("mouth") == nil then
			local decal = Instance.new("Decal", fakeHead)
			decal.Name = "mouth"
			decal.Face = "Front"
		end

		fakeHead.mouth.Texture = mouth2.Texture
	end

	update7()

	if p3 == nil then
		insert(v, mouth.Changed:Connect(update7))
		insert(v, p2.Race.Changed:Connect(update7))
	end

	local accessory = p2.Customization.Face.Accessory

	local function update8()
		local facialAccessories = CustomizationInfo.getFacialAccessories(p, p2)
		local v3 = facialAccessories[clamp(accessory.Value, 0, #facialAccessories)] or {
			Texture = ""
		}
		local fakeHead = parent.Head.FakeHead

		if fakeHead:FindFirstChild("accessory") == nil then
			local decal = Instance.new("Decal", fakeHead)
			decal.Name = "accessory"
			decal.ZIndex = -5
			decal.Face = "Front"
		end

		fakeHead.accessory.Texture = v3.Texture
	end

	update8()

	if p3 == nil then
		insert(v, accessory.Changed:Connect(update8))
	end

	local shirt = p2.Customization.Shirt
	local shirtFolder = parent:FindFirstChild("ShirtFolder") or Instance.new("Configuration", parent)
	shirtFolder.Name = "ShirtFolder"

	local function upd_color4()
		for _, child in ipairs(shirtFolder:GetChildren()) do
			for _, part in ipairs(child:GetChildren()) do
				if not (part:IsA("BasePart") and part:GetAttribute("Color") ~= "nc") then
					continue
				end

				local color = part:GetAttribute("Color")

				if color == "bc" then
					part.Color = skin_color()
				else
					local v2 = color == "c3" and 3 or color == "c2" and 2 or 1
					part.Color = Color3.new(
						shirt["Color" .. v2].R.Value,
						shirt["Color" .. v2].G.Value,
						shirt["Color" .. v2].B.Value
					)
				end
			end
		end
	end

	local function update9()
		for _, child in ipairs(shirtFolder:GetChildren()) do
			child:Destroy()
		end

		if parent:GetAttribute("ShirtDisabled") then
			return
		end

		local shirts = CustomizationInfo.getShirts(p, p2)
		local v3 = clamp(shirt.Value.Value, 0, #shirts)
		local child = game.ReplicatedStorage.Assets.Appearance.Shirts:FindFirstChild("Shirt" .. v3)

		if child then
			add_clothing_to(parent, shirtFolder, child)
			trim_to_kept_parts(parent, shirtFolder, "ShirtKeepParts")
		end

		upd_color4()
	end

	update9()

	if p3 == nil then
		for i = 1, 3 do
			insert(v, shirt["Color" .. i].R.Changed:Connect(upd_color4))
			insert(v, shirt["Color" .. i].G.Changed:Connect(upd_color4))
			insert(v, shirt["Color" .. i].B.Changed:Connect(upd_color4))
		end

		insert(v, p2.Customization.skinColor.Changed:Connect(upd_color4))
		insert(v, p2.Race.Changed:Connect(upd_color4))
		insert(v, shirt.Value.Changed:Connect(update9))
		insert(v, parent:GetAttributeChangedSignal("ShirtDisabled"):Connect(update9))
		insert(v, parent:GetAttributeChangedSignal("ShirtKeepParts"):Connect(update9))
	end

	local pants = p2.Customization.Pants
	local pantsFolder = parent:FindFirstChild("PantsFolder") or Instance.new("Configuration", parent)
	pantsFolder.Name = "PantsFolder"

	local function upd_color5()
		for _, child in ipairs(pantsFolder:GetChildren()) do
			for _, part in ipairs(child:GetChildren()) do
				if not (part:IsA("BasePart") and part:GetAttribute("Color") ~= "nc") then
					continue
				end

				local color = part:GetAttribute("Color")

				if color == "bc" then
					part.Color = skin_color()
				else
					local v2 = color == "c3" and 3 or color == "c2" and 2 or 1
					part.Color = Color3.new(
						pants["Color" .. v2].R.Value,
						pants["Color" .. v2].G.Value,
						pants["Color" .. v2].B.Value
					)
				end
			end
		end
	end

	local function update10()
		for _, child in ipairs(pantsFolder:GetChildren()) do
			child:Destroy()
		end

		if parent:GetAttribute("PantsDisabled") then
			return
		end

		local pants2 = CustomizationInfo.getPants(p, p2)
		local v3 = clamp(pants.Value.Value, 0, #pants2)
		local child = game.ReplicatedStorage.Assets.Appearance.Pants:FindFirstChild("Pants" .. v3)

		if child then
			add_clothing_to(parent, pantsFolder, child)
			trim_to_kept_parts(parent, pantsFolder, "PantsKeepParts")
		end

		upd_color5()
	end

	update10()

	if p3 == nil then
		for i = 1, 3 do
			insert(v, pants["Color" .. i].R.Changed:Connect(upd_color5))
			insert(v, pants["Color" .. i].G.Changed:Connect(upd_color5))
			insert(v, pants["Color" .. i].B.Changed:Connect(upd_color5))
		end

		insert(v, p2.Customization.skinColor.Changed:Connect(upd_color5))
		insert(v, p2.Race.Changed:Connect(upd_color5))
		insert(v, pants.Value.Changed:Connect(update10))
		insert(v, parent:GetAttributeChangedSignal("PantsDisabled"):Connect(update10))
		insert(v, parent:GetAttributeChangedSignal("PantsKeepParts"):Connect(update10))
	end

	local shoes = p2.Customization.Shoes
	local shoeFolder = parent:FindFirstChild("ShoeFolder") or Instance.new("Configuration", parent)
	shoeFolder.Name = "ShoeFolder"

	local function upd_color6()
		for _, child in ipairs(shoeFolder:GetChildren()) do
			for _, part in ipairs(child:GetChildren()) do
				if not (part:IsA("BasePart") and part:GetAttribute("Color") ~= "nc") then
					continue
				end

				local color = part:GetAttribute("Color")

				if color == "bc" then
					part.Color = skin_color()
				else
					local v2 = color == "c3" and 3 or color == "c2" and 2 or 1
					part.Color = Color3.new(
						shoes["Color" .. v2].R.Value,
						shoes["Color" .. v2].G.Value,
						shoes["Color" .. v2].B.Value
					)
				end
			end
		end
	end

	local function update11()
		for _, child in ipairs(shoeFolder:GetChildren()) do
			child:Destroy()
		end

		if parent:GetAttribute("ShoesDisabled") then
			return
		end

		local shoes2 = CustomizationInfo.getShoes(p, p2)
		local v3 = clamp(shoes.Value.Value, 0, #shoes2)
		local child = game.ReplicatedStorage.Assets.Appearance.Shoes:FindFirstChild("Shoe" .. v3)

		if child then
			add_clothing_to(parent, shoeFolder, child)
			trim_to_kept_parts(parent, shoeFolder, "ShoesKeepParts")
		end

		upd_color6()
	end

	update11()

	if p3 == nil then
		for i = 1, 3 do
			insert(v, shoes["Color" .. i].R.Changed:Connect(upd_color6))
			insert(v, shoes["Color" .. i].G.Changed:Connect(upd_color6))
			insert(v, shoes["Color" .. i].B.Changed:Connect(upd_color6))
		end

		insert(v, p2.Customization.skinColor.Changed:Connect(upd_color6))
		insert(v, p2.Race.Changed:Connect(upd_color6))
		insert(v, shoes.Value.Changed:Connect(update11))
		insert(v, parent:GetAttributeChangedSignal("ShoesDisabled"):Connect(update11))
		insert(v, parent:GetAttributeChangedSignal("ShoesKeepParts"):Connect(update11))
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function disconnectAll()
		for _, connection in ipairs(v) do
			connection:Disconnect()
		end

		table.clear(v)
	end

	insert(v, (parent:GetPropertyChangedSignal("Parent"):Connect(function()
		if parent.Parent == nil then
			disconnectAll() -- equivalent call inferred; original call site unknown
		end
	end)))
	insert(v, (parent:GetAttributeChangedSignal("currentcustidd"):Connect(disconnectAll)))
	Update_Item_equippation(parent)
end