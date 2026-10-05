local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Contract = require(script.Contract)
local Describe = require(script.Describe)
local UITemplates = {
	Types = Describe.Types
}
local vector = Vector2.new(256, 256)
local uITemplates = nil
local guiObjectsByChildName = {}
local object = setmetatable({}, {
	__mode = "k"
})
local v = {}
local object2 = setmetatable({}, {
	__mode = "k"
})
local object3 = setmetatable({}, {
	__mode = "k"
})

local function getEntry(instance)
	local v2 = object3[instance]

	if not v2 then
		v2 = {
			sprites = {},
			cancelled = false,
			activated = nil
		}
		object3[instance] = v2
		instance.Destroying:Once(function()
			UITemplates.Release(instance)
		end)
	end

	return v2
end

local function getTemplatesFolder()
	if uITemplates and uITemplates.Parent then
		return uITemplates
	end

	local starterGuiClone = ReplicatedStorage:FindFirstChild("StarterGuiClone")
	uITemplates = starterGuiClone and starterGuiClone:FindFirstChild("UITemplates") or nil

	if not uITemplates then
		warn("[UITemplates] ReplicatedStorage.StarterGuiClone.UITemplates is missing")
	end

	return uITemplates
end

-- equivalent calls inferred from this helper; original call sites unknown
local function warnOnce(p: string, p2: string)
	if v[p] then
		return
	end

	v[p] = true
	warn(p2)
end

function UITemplates.GetPrototype(childName: string)
	if type(childName) ~= "string" then
		return nil
	end

	local v2 = guiObjectsByChildName[childName]

	if v2 and v2.Parent then
		return v2
	end

	if not (uITemplates and uITemplates.Parent) then
		local starterGuiClone = ReplicatedStorage:FindFirstChild("StarterGuiClone")
		uITemplates = starterGuiClone and starterGuiClone:FindFirstChild("UITemplates") or nil

		if not uITemplates then
			warn("[UITemplates] ReplicatedStorage.StarterGuiClone.UITemplates is missing")
		end
	end

	local guiObject = uITemplates and uITemplates:FindFirstChild(childName)

	if guiObject and guiObject:IsA("GuiObject") then
		guiObjectsByChildName[childName] = guiObject
		return guiObject
	end

	warnOnce("prototype:" .. childName, "[UITemplates] no template named " .. childName) -- equivalent call inferred; original call site unknown
	return nil
end

local function resolveByPath(child, list)
	for _, childName in ipairs(list) do
		child = child:FindFirstChild(childName)

		if not child then
			return nil
		end
	end

	return child
end

local function buildPath(instance, parent)
	local result = {}

	while parent and parent ~= instance do
		table.insert(result, 1, parent.Name)
		parent = parent.Parent
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function instanceFitsRole(button, role)
	if role.property then
		return (pcall(function()
			return button[role.property]
		end))
	end

	return button:IsA("GuiButton")
end

local function findRole(instance, p, p2: string)
	local role = Contract.Roles[p2]

	if not role then
		return nil
	end

	local v2 = p or instance
	local v3 = object[v2]

	if v3 then
		local v4 = v3[p2]

		if v4 then
			local v5 = resolveByPath(instance, v4)

			if v5 then
				return v5
			end
		elseif v4 == false then
			return nil
		end
	end

	local v4 = nil

	for _, childName in ipairs(role.candidates) do
		local child = instance:FindFirstChild(childName, true)

		if not child then
			continue
		end

		v4 = child
		break
	end

	if not v4 then
		-- equivalent call inferred; original call site unknown
		if instanceFitsRole(instance, role) then
			v4 = instance
		end
	end

	if v4 and role.descend then
		for _ = 1, 4 do
			local v6 = nil

			for _, childName in ipairs(role.candidates) do
				local child = v4:FindFirstChild(childName)

				if not child then
					continue
				end

				v6 = child
				break
			end

			if not v6 then
				break
			end

			v4 = v6
		end
	end

	local v6 = object[v2]

	if not v6 then
		v6 = {}
		object[v2] = v6
	end

	local v7

	if v4 then
		v7 = buildPath(instance, v4) or false
	else
		v7 = false
	end

	v6[p2] = v7
	return v4
end

local function setIfPresent(p, p2: string, p3)
	if not p or p3 == nil then
		return
	end

	pcall(function()
		p[p2] = p3
	end)
end

local v2 = {
	string = true,
	number = true,
	boolean = true,
	Color3 = true,
	Vector2 = true,
	Vector3 = true,
	UDim = true,
	UDim2 = true
}

-- equivalent calls inferred from this helper; original call sites unknown
local function setAttribute(instance, k: string, attribute)
	if not (attribute ~= nil and v2[typeof(attribute)]) then
		return
	end

	pcall(function()
		instance:SetAttribute(k, attribute)
	end)
end

function UITemplates.Release(p)
	local v3 = object3[p]

	if not v3 then
		return
	end

	v3.cancelled = true

	for _, sprite in ipairs(v3.sprites) do
		local v4 = sprite
		pcall(function()
			v4:Stop()
		end)
	end

	table.clear(v3.sprites)

	if v3.activated then
		v3.activated:Disconnect()
		v3.activated = nil
	end

	object3[p] = nil
end

local function attachSprite(instance, role, animated)
	local success, result = pcall(function()
		return require(ReplicatedStorage.Modules.SpriteClip2)
	end)

	if not (success and result) then
		return
	end

	role.ImageRectSize = vector
	role.ImageRectOffset = Vector2.new(0, 0)
	local frameRate = animated.frameRate or 10
	local success2, result2 = pcall(function()
		return result.ImageSprite.new({
			adornee = role,
			spriteSheetId = animated.Image,
			spriteSize = vector,
			spriteCount = 4,
			columnCount = 2,
			frameRate = frameRate,
			isLooped = true
		})
	end)

	if not (success2 and result2) then
		return
	end

	local entry = getEntry(instance)
	entry.cancelled = false
	table.insert(entry.sprites, result2)
	result2:Play()
	local sequence = animated.sequence

	if type(sequence) == "table" and #sequence > 0 then
		result2:Pause()
		local v3 = 1 / math.max(1, frameRate)
		task.spawn(function()
			local v4 = 1

			while not entry.cancelled and role.Parent do
				result2:SetFrame(sequence[v4])
				v4 = v4 % #sequence + 1
				task.wait(v3)
			end
		end)
	end
end

function UITemplates.Populate(instance, p: string, p2: string, options)
	local v3 = options or {}
	local v4 = Describe.Get(p, p2, v3)
	UITemplates.Release(instance)
	local v5 = object2[instance]
	local templateKey = instance:GetAttribute("TemplateKey")

	if not v5 and type(templateKey) == "string" then
		v5 = guiObjectsByChildName[templateKey]
	end

	local function role(p3: string)
		local role2 = findRole(instance, v5, p3)

		if role2 or not v3.strict or Contract.OptionalRoles[p3] then
			return role2
		end

		warnOnce(
			"role:" .. tostring(templateKey or instance.Name) .. ":" .. p3,
			"[UITemplates] " .. tostring(templateKey or instance.Name) .. " has no child for role " .. p3
		) -- equivalent call inferred; original call site unknown
		return role2
	end

	local role2 = findRole(instance, v5, "Name")

	if not role2 and v3.strict and not Contract.OptionalRoles.Name then
		warnOnce(
			"role:" .. tostring(templateKey or instance.Name) .. ":Name",
			"[UITemplates] " .. tostring(templateKey or instance.Name) .. " has no child for role Name"
		) -- equivalent call inferred; original call site unknown
	end

	local name = v4.Name

	if role2 and name ~= nil then
		local v6 = "Text"
		pcall(function()
			role2[v6] = name
		end)
	end

	local role3 = findRole(instance, v5, "Description")

	if not role3 and v3.strict and not Contract.OptionalRoles.Description then
		warnOnce(
			"role:" .. tostring(templateKey or instance.Name) .. ":Description",
			"[UITemplates] " .. tostring(templateKey or instance.Name) .. " has no child for role Description"
		) -- equivalent call inferred; original call site unknown
	end

	local description = v4.Description

	if role3 and description ~= nil then
		local v6 = "Text"
		pcall(function()
			role3[v6] = description
		end)
	end

	local role4 = findRole(instance, v5, "Value")

	if not role4 and v3.strict and not Contract.OptionalRoles.Value then
		warnOnce(
			"role:" .. tostring(templateKey or instance.Name) .. ":Value",
			"[UITemplates] " .. tostring(templateKey or instance.Name) .. " has no child for role Value"
		) -- equivalent call inferred; original call site unknown
	end

	local value = v4.Value

	if role4 and value ~= nil then
		local v6 = "Text"
		pcall(function()
			role4[v6] = value
		end)
	end

	local role5 = findRole(instance, v5, "Image")

	if not role5 and v3.strict and not Contract.OptionalRoles.Image then
		warnOnce(
			"role:" .. tostring(templateKey or instance.Name) .. ":Image",
			"[UITemplates] " .. tostring(templateKey or instance.Name) .. " has no child for role Image"
		) -- equivalent call inferred; original call site unknown
	end

	local role6 = findRole(instance, v5, "Shadow")

	if not role6 and v3.strict and not Contract.OptionalRoles.Shadow then
		warnOnce(
			"role:" .. tostring(templateKey or instance.Name) .. ":Shadow",
			"[UITemplates] " .. tostring(templateKey or instance.Name) .. " has no child for role Shadow"
		) -- equivalent call inferred; original call site unknown
	end

	if role6 == role5 then
		role6 = nil
	end

	local image = v4.Image

	if v3.useIcon and v4.Icon and v4.Icon ~= "" then
		image = v4.Icon
	end

	if role5 and image ~= nil then
		local v6 = "Image"
		pcall(function()
			role5[v6] = image
		end)
	end

	if role6 and image ~= nil then
		local v6 = "Image"
		pcall(function()
			role6[v6] = image
		end)
	end

	if role6 and role6:IsA("GuiObject") then
		role6.Visible = not v3.hideShadow
	end

	local function clearImageRect(zeros)
		local zero = Vector2.zero

		if zeros and zero ~= nil then
			local v6 = "ImageRectSize"
			pcall(function()
				zeros[v6] = zero
			end)
		end

		local zero2 = Vector2.zero

		if zeros then
			if zero2 == nil then
				return
			end

			local v6 = "ImageRectOffset"
			pcall(function()
				zeros[v6] = zero2
			end)
		end
	end

	local zero = Vector2.zero

	if role5 and zero ~= nil then
		local v6 = "ImageRectSize"
		pcall(function()
			role5[v6] = zero
		end)
	end

	local zero2 = Vector2.zero

	if role5 and zero2 ~= nil then
		local v6 = "ImageRectOffset"
		pcall(function()
			role5[v6] = zero2
		end)
	end

	local zero3 = Vector2.zero

	if role6 and zero3 ~= nil then
		local v6 = "ImageRectSize"
		pcall(function()
			role6[v6] = zero3
		end)
	end

	local zero4 = Vector2.zero

	if role6 and zero4 ~= nil then
		local v6 = "ImageRectOffset"
		pcall(function()
			role6[v6] = zero4
		end)
	end

	if v4.Color then
		local color = v4.Color

		if role5 and color ~= nil then
			local v6 = "BackgroundColor3"
			pcall(function()
				role5[v6] = color
			end)
		end

		local v6 = v4.Image == "" and 0 or 1

		if role5 and v6 ~= nil then
			local v7 = "BackgroundTransparency"
			pcall(function()
				role5[v7] = v6
			end)
		end
	end

	local type2 = v4.Type

	if type2 ~= nil and v2[typeof(type2)] then
		local v6 = "TemplateType"
		pcall(function()
			instance:SetAttribute(v6, type2)
		end)
	end

	local id = v4.Id

	if id ~= nil and v2[typeof(id)] then
		local v6 = "ItemId"
		pcall(function()
			instance:SetAttribute(v6, id)
		end)
	end

	local name2 = v4.Name

	if name2 ~= nil and v2[typeof(name2)] then
		local v6 = "ItemName"
		pcall(function()
			instance:SetAttribute(v6, name2)
		end)
	end

	local missing = v4.Missing

	if missing ~= nil and v2[typeof(missing)] then
		local v6 = "Missing"
		pcall(function()
			instance:SetAttribute(v6, missing)
		end)
	end

	local rarity = v4.Rarity

	if rarity ~= nil and v2[typeof(rarity)] then
		local v6 = "Rarity"
		pcall(function()
			instance:SetAttribute(v6, rarity)
		end)
	end

	local gradient = v4.Gradient

	if gradient ~= nil and v2[typeof(gradient)] then
		local v6 = "Gradient"
		pcall(function()
			instance:SetAttribute(v6, gradient)
		end)
	end

	local progress = v4.Progress

	if progress ~= nil and v2[typeof(progress)] then
		local v6 = "Progress"
		pcall(function()
			instance:SetAttribute(v6, progress)
		end)
	end

	local owned = v3.owned

	if owned ~= nil and v2[typeof(owned)] then
		local v6 = "Owned"
		pcall(function()
			instance:SetAttribute(v6, owned)
		end)
	end

	for k, attribute in pairs(v4.Attributes) do
		setAttribute(instance, k, attribute) -- equivalent call inferred; original call site unknown
	end

	if v3.attributes then
		for k, attribute in pairs(v3.attributes) do
			setAttribute(instance, k, attribute) -- equivalent call inferred; original call site unknown
		end
	end

	local animate = v3.animate ~= false

	if v4.Animated and animate then
		if role5 and role5:IsA("ImageLabel") then
			attachSprite(instance, role5, v4.Animated)
		end

		if role6 and role6:IsA("ImageLabel") then
			attachSprite(instance, role6, v4.Animated)
		end
	end

	if v3.onActivated then
		local role7 = findRole(instance, v5, "Button")

		if not role7 and v3.strict and not Contract.OptionalRoles.Button then
			warnOnce(
				"role:" .. tostring(templateKey or instance.Name) .. ":Button",
				"[UITemplates] " .. tostring(templateKey or instance.Name) .. " has no child for role Button"
			) -- equivalent call inferred; original call site unknown
		end

		if role7 and role7:IsA("GuiButton") then
			local entry = getEntry(instance)
			entry.activated = role7.Activated:Connect(function()
				v3.onActivated(instance, v4)
			end)
		end
	end

	if not v3.styleController then
		return v4
	end

	local stylesheet = v3.stylesheet

	if not stylesheet and v5 then
		stylesheet = v5:GetAttribute("stylesheet")
	end

	local v6 = stylesheet or instance:GetAttribute("stylesheet")

	if type(v6) == "string" and v6 ~= "" then
		v3.styleController:Apply(instance, v6)
	end

	return v4
end

function UITemplates.Render(guiObject, p: string, value: string, options)
	local v3 = nil
	local name = nil

	if typeof(guiObject) == "Instance" then
		if guiObject:IsA("GuiObject") then
			name = guiObject.Name
			v3 = guiObject
		end
	elseif type(guiObject) == "string" then
		v3 = UITemplates.GetPrototype(guiObject)
		name = guiObject
	end

	if not v3 then
		return nil, nil
	end

	local v4 = options or {}
	local clone = v3:Clone()
	object2[clone] = v3
	clone:SetAttribute("TemplateKey", name)
	local name2 = v4.name

	if not name2 then
		if type(value) == "string" and value ~= "" and value then
			name2 = value
		else
			name2 = name
		end
	end

	clone.Name = name2

	if v4.layoutOrder ~= nil then
		clone.LayoutOrder = v4.layoutOrder
	end

	local populate = UITemplates.Populate(clone, p, value, v4)
	clone.Visible = v4.visible ~= false

	if v4.parent then
		clone.Parent = v4.parent
	end

	return clone, populate
end

function UITemplates.GetRole(guiObject, p: string)
	if not (guiObject and guiObject:IsA("GuiObject")) then
		return nil
	end

	local v3 = object2[guiObject]
	local templateKey = guiObject:GetAttribute("TemplateKey")

	if not v3 and type(templateKey) == "string" then
		v3 = guiObjectsByChildName[templateKey]
	end

	return (findRole(guiObject, v3, p))
end

function UITemplates.Describe(p: string, p2: string, p3)
	return Describe.Get(p, p2, p3)
end

return UITemplates