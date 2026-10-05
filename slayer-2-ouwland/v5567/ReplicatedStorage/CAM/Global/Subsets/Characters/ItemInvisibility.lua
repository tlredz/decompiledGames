local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local ItemInvisibility = {
	MarkerName = "invisdd12S$$"
}
local v = {
	InvisibleItem = true,
	Invisibility = true,
	Transparency = true
}

function ItemInvisibility.Apply(instance, instance2)
	if instance == nil or instance2 == nil then
		return
	end

	local v2 = instance2:FindFirstChild("Invisibility") ~= nil or instance2:FindFirstChild("Transparency") ~= nil
	local v3 = {}

	for _, child in ipairs(instance2:GetChildren()) do
		if child.Name ~= "InvisibleItem" then
			continue
		end

		for _, v4 in ipairs(string.split(string.lower((tostring(child.Value))))) do
			if table.find(v3, v4) == nil then
				table.insert(v3, v4)
			end
		end
	end

	local tool_Accessories = instance:FindFirstChild("Tool_Accessories")
	local weapon_Unequipped_Config = instance:FindFirstChild("Weapon_Unequipped_Config")

	if tool_Accessories == nil and weapon_Unequipped_Config == nil then
		return
	end

	local children = tool_Accessories == nil and {} or tool_Accessories:GetChildren() or {}

	for _, v4 in ipairs(weapon_Unequipped_Config == nil and {} or weapon_Unequipped_Config:GetChildren() or {}) do
		for _, child in ipairs(v4:GetChildren()) do
			table.insert(children, child)
		end
	end

	for _, parent in ipairs(children) do
		local v5 = table.find(v3, string.lower(parent.Name)) ~= nil or (table.find(v3, "all") ~= nil or v2)

		if v5 and parent:FindFirstChild(ItemInvisibility.MarkerName) == nil then
			local boolValue = Instance.new("BoolValue")
			boolValue.Name = ItemInvisibility.MarkerName
			boolValue.Parent = parent

			for _, v6 in ipairs(parent:QueryDescendants("Decal:not([$SetTransparency],[$istransparent]),Beam:not([$SetTransparency],[$istransparent]),Trail:not([$SetTransparency],[$istransparent]),ParticleEmitter:not([$SetTransparency],[$istransparent]),BasePart:not([$SetTransparency],[$istransparent])")) do
				if v6.ClassName == "Beam" or v6.ClassName == "Trail" then
					v6:SetAttribute("SetTransparency", v6.Transparency)
					v6.Transparency = NumberSequence.new(1)
				elseif v6.ClassName == "ParticleEmitter" then
					v6:SetAttribute("SetTransparency", v6.Enabled)
					v6.Enabled = false
				elseif v6.Transparency == 0 then
					v6:SetAttribute("SetTransparency", true)
					v6.Transparency = 1
				end
			end
		elseif not v5 and parent:FindFirstChild(ItemInvisibility.MarkerName) ~= nil then
			parent[ItemInvisibility.MarkerName]:Destroy()

			for _, v6 in ipairs(parent:QueryDescendants("Decal[$SetTransparency],Beam[$SetTransparency],Trail[$SetTransparency],ParticleEmitter[$SetTransparency],BasePart[$SetTransparency]")) do
				if v6.ClassName == "Beam" or v6.ClassName == "Trail" then
					v6.Transparency = v6:GetAttribute("SetTransparency")
				elseif v6.ClassName == "ParticleEmitter" then
					v6.Enabled = v6:GetAttribute("SetTransparency")
				else
					v6.Transparency = 0
				end

				v6:SetAttribute("SetTransparency", nil)
			end
		end
	end
end

function ItemInvisibility.BindNpc(instance)
	if instance == nil or instance:FindFirstChild("Tool_Accessories") == nil and instance:FindFirstChild("Weapon_Unequipped_Config") == nil then
		return nil
	end

	local getvaluesfolder = Utility.getvaluesfolder(instance)

	if getvaluesfolder == nil then
		return nil
	end

	local function refresh(p)
		if p ~= nil and not v[p.Name] then
			return
		end

		ItemInvisibility.Apply(instance, getvaluesfolder)
	end

	local childAddedConnection = getvaluesfolder.ChildAdded:Connect(refresh)
	local childRemovedConnection = getvaluesfolder.ChildRemoved:Connect(refresh)
	ItemInvisibility.Apply(instance, getvaluesfolder)
	return function()
		childAddedConnection:Disconnect()
		childRemovedConnection:Disconnect()
	end
end

return ItemInvisibility