local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Text = require(ReplicatedStorage.Omni.Libs.Text)
local v = {}
local v2 = {}
local v3 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function IsSpecialCharacter(label)
	if label:IsA("TextLabel") then
		return label.Text:match("%p") ~= nil
	end

	return false
end

local DeepCopy

DeepCopy = function(items, options)
	local v4 = options or {}

	if v4[items] then
		return v4[items]
	end

	local result = {}
	v4[items] = result

	for k, item in pairs(items) do
		if type(item) == "table" then
			result[k] = DeepCopy(item, v4)
		else
			result[k] = item
		end
	end

	local metatable = getmetatable(items)

	if metatable then
		setmetatable(result, metatable)
	end

	return result
end

local function GetTextProperties(label)
	local v4 = {
		WordSorting = true,
		Dynamic = true
	}

	if not label:IsA("TextLabel") then
		return v4
	end

	local uIStroke = label:FindFirstChildWhichIsA("UIStroke")
	local color, thickness, transparency, strokeScaled

	if uIStroke then
		color = uIStroke.Color
		thickness = uIStroke.Thickness
		transparency = uIStroke.Transparency

		if uIStroke.StrokeSizingMode == Enum.StrokeSizingMode.ScaledSize then
			strokeScaled = true
		else
			strokeScaled = false
		end
	end

	v4.Font = label.FontFace
	v4.Color = label.TextColor3
	v4.Transparency = label.TextTransparency
	v4.Rotation = label.Rotation
	v4.StrokeSize = thickness
	v4.StrokeColor = color
	v4.StrokeTransparency = transparency
	v4.StrokeScaled = strokeScaled

	if label.TextScaled then
		v4.ScaleSize = "FrameXY"
		return v4
	end

	v4.Size = label.TextSize
	return v4
end

function v3:Create(items)
	if v[self] then
		return v[self]
	end

	local originalProperties = GetTextProperties(self)

	if self:IsA("TextLabel") then
		self.Text = ""
	end

	local currentProperties = DeepCopy(originalProperties)

	if typeof(items) == "table" then
		for k, item in items do
			currentProperties[k] = item
		end
	end

	local object = setmetatable({}, {
		__index = v2
	})
	object.Instance = self
	object.CurrentText = ""
	object.Animations = {}
	object.Appearing = {}
	object.Connections = {}
	object.AppearCallbacks = {}
	object.Connections.Appear = self:GetAttributeChangedSignal("Appeared"):Connect(function()
		if object.Destroyed or self:GetAttribute("Appeared") ~= true then
			return
		end

		local textGeneration = self:GetAttribute("TextGeneration")

		if object.CompletedGeneration == textGeneration then
			return
		end

		object.CompletedGeneration = textGeneration

		for _, appearCallback in object.AppearCallbacks do
			appearCallback()
		end
	end)
	object.Connections.Destroy = self.AncestryChanged:Connect(function(_, parent)
		if not parent then
			object:Destroy()
		end
	end)
	object.CurrentProperties = currentProperties
	object.OriginalProperties = originalProperties
	v[self] = object
	self:ClearAllChildren()
	object:_Generate(object.CurrentText, currentProperties)
	object.Connections.Update = Text.GetUpdateSignal(self):Connect(function()
		object:_Update()
	end)
	return object
end

function v2:_Update()
	local childrenByName = {}
	local currentCharacters = {}
	local v5 = 1

	for _, child in self.Instance:GetChildren() do
		local name = tonumber(child.Name)

		if name then
			childrenByName[name] = child
		end
	end

	for _, v6 in childrenByName do
		local childrenByName2 = {}

		for _, child in v6:GetChildren() do
			local name = tonumber(child.Name)

			if name then
				childrenByName2[name] = child
			end
		end

		for _, v7 in childrenByName2 do
			for k in v7:GetAttributes() do
				v7:SetAttribute(k, nil)
			end

			currentCharacters[v5] = v7
			v5 += 1
		end
	end

	self.CurrentCharacters = currentCharacters
end

function v2:_Generate(...)
	self.Updating = true
	self.Instance:SetAttribute("TextGeneration", (self.Instance:GetAttribute("TextGeneration") or 0) + 1)
	self.Instance:SetAttribute("Appeared", nil)
	Text.Create(self.Instance, ...)
	self:_Update()
	self.LastGenerate = tick()
	self.Updating = nil
end

function v2:SetText(currentText: string, items, flag: boolean?)
	if typeof(currentText) ~= "string" or self.CurrentText == currentText and not flag then
		return
	end

	self.CurrentText = currentText
	table.clear(self.Animations)

	if typeof(items) == "table" then
		for k, item in items do
			self:SetAnimation(k, item.Name, item.Params)
		end
	end

	self:_Generate(currentText, self.CurrentProperties)
end

function v2:SetProperties(items)
	if typeof(items) ~= "table" then
		return
	end

	for k, item in items do
		self.CurrentProperties[k] = item
	end

	self:_Generate(self.CurrentText, self.CurrentProperties)
end

function v2:SetAnimation(value: number, value2: string, p2)
	if not (typeof(value) == "number" and typeof(value2) == "string") then
		return
	end

	self.Animations[value] = {
		Name = value2,
		Params = typeof(p2) == "table" and p2 or {}
	}
end

function v2:SetAppearing(name: string, p2)
	if typeof(name) == "string" then
		self.Appearing = {
			Name = name,
			Params = typeof(p2) == "table" and p2 or {}
		}
	else
		table.clear(self.Appearing)
	end
end

function v2.OnAppear(p, callback)
	if typeof(callback) ~= "function" then
		return
	end

	table.insert(p.AppearCallbacks, callback)
end

function v2.SkipAppearing(data)
	if data.Destroyed or data.Updating or data.Instance:GetAttribute("Appeared") == true or data.Appearing.Name ~= "Fade" and data.Appearing.Name ~= "FadeUp" then
		return false
	end

	if #data.CurrentCharacters == 0 then
		return false
	end

	for _, label in data.CurrentCharacters do
		if not label.Parent then
			continue
		end

		if label:IsA("TextLabel") then
			label.TextTransparency = 0
		else
			label.ImageTransparency = 0
		end

		local uIStroke = label:FindFirstChildWhichIsA("UIStroke")

		if uIStroke then
			uIStroke.Transparency = 0
		end

		local originalPosition = label:GetAttribute("OriginalPosition")

		if data.Appearing.Name == "FadeUp" and originalPosition then
			label.Position = originalPosition
		end
	end

	data.Instance:SetAttribute("Appeared", true)
	return true
end

function v2:Destroy()
	self.Destroyed = true
	self.Instance:SetAttribute("TextGeneration", (self.Instance:GetAttribute("TextGeneration") or 0) + 1)

	for _, connection in self.Connections do
		connection:Disconnect()
	end

	table.clear(self.Connections)
	v[self.Instance] = nil
end

local v4 = {}

for i = 1, 3 do
	local actor = Instance.new("Actor")
	local clone = script.WorkerTemplate:Clone()
	clone.Name = "GradientWorker - " .. i
	clone.Enabled = true
	clone.Parent = actor
	actor.Parent = script
	table.insert(v4, actor)
end

RunService.Heartbeat:Connect(function()
	local v5 = {}

	for k, v6 in v do
		if v6.Updating or #v6.CurrentCharacters == 0 then
			continue
		end

		if not (next(v6.Animations) or next(v6.Appearing) and k:GetAttribute("Appeared") ~= true) then
			continue
		end

		v5[k] = {}

		for childName, animation in v6.Animations do
			local child = v6.Instance:FindFirstChild(childName)

			if not child then
				continue
			end

			local count = 0
			local children = {}

			for _, child2 in child:GetChildren() do
				if not tonumber(child2.Name) then
					continue
				end

				-- equivalent call inferred; original call site unknown
				if IsSpecialCharacter(child2) then
					continue
				end

				count += 1
				children[count] = child2
			end

			table.insert(v5[v6.Instance], {
				List = children,
				Animation = animation.Name,
				Params = animation.Params
			})
		end
	end

	for k, v6 in v5 do
		local v7 = v[k]

		if not v7 then
			continue
		end

		local v8 = {
			Characters = v7.CurrentCharacters,
			Generation = k:GetAttribute("TextGeneration")
		}

		if k:GetAttribute("Appeared") ~= true then
			v8.Time = v7.LastGenerate
			v8.Name = v7.Appearing.Name
			v8.Params = v7.Appearing.Params
		end

		if #v6 > 0 then
			for _, v9 in v6 do
				local v10 = v4[math.random(1, #v4)]

				if v10 then
					v10:SendMessage("Update", k, v9.List, v9.Animation, v9.Params, v8)
				end
			end
		else
			local v9 = v4[math.random(1, #v4)]

			if v9 then
				v9:SendMessage("Update", k, nil, nil, nil, v8)
			end
		end
	end
end)
return table.freeze(v3)