local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PropTextures = {
	Textures = {
		Brick = true,
		BrickGray = true,
		ConcreteBlock = true,
		Dirt = true,
		Wood = true,
		WoodFrameGray = true,
		WoodFrameWhite = true,
		BackroomYellow = true,
		BackroomWhite = true,
		BackroomCarpet = true
	}
}

function PropTextures.IsValid(p: string?)
	return p ~= nil and PropTextures.Textures[p] == true
end

function PropTextures.GetTemplate(childName: string)
	local assets = ReplicatedStorage:FindFirstChild("Assets")

	if assets == nil then
		return nil
	end

	local propTextures = assets:FindFirstChild("PropTextures")

	if propTextures == nil then
		return nil
	end

	local texture = propTextures:FindFirstChild(childName)

	if texture == nil or not texture:IsA("Texture") then
		return nil
	end

	return texture
end

function PropTextures.ResetOnModel(instance)
	local touch = instance:FindFirstChild("Touch")

	if touch ~= nil then
		for _, v in Enum.NormalId:GetEnumItems() do
			local child = touch:FindFirstChild("CustomTexture_" .. v.Name)

			if child then
				child:Destroy()
			end
		end
	end

	instance:SetAttribute("CurrentTexture", nil)
end

function PropTextures.ApplyColorToCustomTextures(instance, color: Color3)
	local touch = instance:FindFirstChild("Touch")

	if touch == nil then
		return
	end

	for _, v in Enum.NormalId:GetEnumItems() do
		local texture = touch:FindFirstChild("CustomTexture_" .. v.Name)

		if texture ~= nil and texture:IsA("Texture") then
			texture.Color3 = color
		end
	end
end

function PropTextures.ApplyToModel(instance, currentTexture: string)
	if not PropTextures.IsValid(currentTexture) then
		return false, "Invalid texture"
	end

	local template = PropTextures.GetTemplate(currentTexture)

	if template == nil then
		return false, "Texture template not found"
	end

	local touch = instance:FindFirstChild("Touch")

	if touch == nil then
		return false, "Touch part not found"
	end

	local currentColor = instance:GetAttribute("CurrentColor")

	for _, face in Enum.NormalId:GetEnumItems() do
		local name = "CustomTexture_" .. face.Name
		local child = touch:FindFirstChild(name)

		if child then
			child:Destroy()
		end

		local clone = template:Clone()
		clone.Name = name
		clone.Face = face
		clone.ZIndex = math.max(template.ZIndex, 5)

		if currentColor ~= nil then
			clone.Color3 = currentColor
		end

		clone.Parent = touch
	end

	instance:SetAttribute("CurrentTexture", currentTexture)
	return true, "Texture applied"
end

function PropTextures.GetAppliedTexture(instance)
	return (instance:GetAttribute("CurrentTexture"))
end

return PropTextures