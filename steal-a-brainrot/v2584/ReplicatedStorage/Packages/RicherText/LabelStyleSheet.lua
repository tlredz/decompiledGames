local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReflectionService = game:GetService("ReflectionService")
local GradientComponent = require(script.Parent.GradientComponent)
local vide = require(ReplicatedStorage.Packages.vide)
local source = vide.source
local effect = vide.effect

local function getPropertyNames(p: string)
	local propertiesOfClass = ReflectionService:GetPropertiesOfClass(p, {
		Security = SecurityCapabilities.fromCurrent()
	})
	local names = {}

	for _, v in propertiesOfClass do
		if not v.Permits.Write or v.Display.DeprecationMessage or v.Owner == "Instance" then
			continue
		end

		table.insert(names, v.Name)
	end

	return names
end

local v = {
	"TextColor3",
	"TextTransparency",
	"TextStrokeTransparency",
	"TextStrokeColor3"
}
local propertyNames = getPropertyNames("UIStroke")
local propertyNames2 = getPropertyNames("UIGradient")

local function bindProperties(instance, styleRule, propertyNames3)
	local connections = {}

	for _, propertyName in propertyNames3 do
		styleRule:SetProperty(propertyName, instance[propertyName])
		local v2 = propertyName
		table.insert(connections, instance:GetPropertyChangedSignal(propertyName):Connect(function()
			styleRule:SetProperty(v2, instance[v2])
		end))
	end

	return connections
end

local function copyProperties(p, p2, items)
	for _, item in items do
		p2[item] = p[item]
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disconnectAll(list)
	for _, connection in list do
		connection:Disconnect()
	end

	table.clear(list)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findFirstOfClass(parent, className: string)
	for _, child in parent:GetChildren() do
		if child:IsA(className) then
			return child
		end
	end

	return nil
end

local function resetGradientDefaults(instance)
	instance:ResetPropertyToDefault("Color")
	instance:ResetPropertyToDefault("Offset")
	instance:ResetPropertyToDefault("Transparency")
	instance:ResetPropertyToDefault("Rotation")
	instance:ResetPropertyToDefault("Enabled")

	for _, tag in instance:GetTags() do
		instance:RemoveTag(tag)
	end

	for k in instance:GetAttributes() do
		instance:SetAttribute(k, nil)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resetStrokeDefaults(object)
	object:ResetPropertyToDefault("Thickness")
	object:ResetPropertyToDefault("Transparency")
	object:ResetPropertyToDefault("Color")
	object:ResetPropertyToDefault("LineJoinMode")
	object:ResetPropertyToDefault("StrokeSizingMode")
end

return {
	create = function(parent)
		local styleSheet = Instance.new("StyleSheet")
		styleSheet.Archivable = false
		styleSheet.Parent = parent
		local styleRule = Instance.new("StyleRule")
		styleRule.Archivable = false
		styleRule.Selector = "TextLabel>TextLabel"
		styleRule.Parent = styleSheet
		local styleRule2 = Instance.new("StyleRule")
		styleRule2.Archivable = false
		styleRule2.Selector = "TextLabel>TextLabel>#DefaultLabelGradient , TextLabel>ImageLabel>#DefaultLabelGradient"
		styleRule2.Parent = styleSheet
		local styleRule3 = Instance.new("StyleRule")
		styleRule3.Archivable = false
		styleRule3.Selector = "TextLabel>TextLabel>#DefaultStroke"
		styleRule3.Parent = styleSheet
		local styleRule4 = Instance.new("StyleRule")
		styleRule4.Archivable = false
		styleRule4.Selector = "TextLabel>TextLabel>#DefaultStroke>#DefaultStrokeGradient"
		styleRule4.Parent = styleSheet
		local styleLink = Instance.new("StyleLink")
		styleLink.Archivable = false
		styleLink.StyleSheet = styleSheet
		styleLink.Parent = parent
		local strokeGradient = source(false)
		local labelGradient = source(false)
		local stroke = source(false)
		local v5 = nil
		local v6 = {}
		local v7 = nil
		local v8 = {}
		local v9 = nil
		local v10 = {}
		local connections = {}
		local connections2 = {}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function unbindStrokeGradient()
			disconnectAll(v10) -- equivalent call inferred; original call site unknown
			v9 = nil
			strokeGradient(false)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function bindStrokeGradient(p)
			unbindStrokeGradient() -- equivalent call inferred; original call site unknown
			v9 = p
			v10 = bindProperties(p, styleRule4, propertyNames2)
			strokeGradient(true)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function rescanStrokeGradient()
			unbindStrokeGradient() -- equivalent call inferred; original call site unknown

			if v5 then
				local v11 = nil

				for _, uIGradient in v5:GetChildren() do
					if not uIGradient:IsA("UIGradient") then
						continue
					end

					v11 = uIGradient
					break
				end

				if v11 then
					bindStrokeGradient(v11) -- equivalent call inferred; original call site unknown
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function stopObservingStrokeChildren()
			disconnectAll(connections) -- equivalent call inferred; original call site unknown
		end

		local function observeStrokeChildren(instance)
			stopObservingStrokeChildren() -- equivalent call inferred; original call site unknown
			table.insert(connections, instance.ChildAdded:Connect(function(uIGradient)
				if uIGradient:IsA("UIGradient") and not v9 then
					bindStrokeGradient(uIGradient) -- equivalent call inferred; original call site unknown
				end
			end))
			table.insert(connections, instance.ChildRemoved:Connect(function(child)
				if child == v9 then
					rescanStrokeGradient() -- equivalent call inferred; original call site unknown
				end
			end))
			rescanStrokeGradient() -- equivalent call inferred; original call site unknown
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function unbindStroke()
			disconnectAll(v6) -- equivalent call inferred; original call site unknown
			unbindStrokeGradient() -- equivalent call inferred; original call site unknown
			stopObservingStrokeChildren() -- equivalent call inferred; original call site unknown
			v5 = nil
			stroke(false)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function bindStroke(p)
			unbindStroke() -- equivalent call inferred; original call site unknown
			v5 = p
			v6 = bindProperties(p, styleRule3, propertyNames)
			stroke(true)
			observeStrokeChildren(p)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function rescanStroke()
			unbindStroke() -- equivalent call inferred; original call site unknown
			local firstOfClass = findFirstOfClass(parent, "UIStroke") -- equivalent call inferred; original call site unknown

			if firstOfClass then
				bindStroke(firstOfClass) -- equivalent call inferred; original call site unknown
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function unbindLabelGradient()
			disconnectAll(v8) -- equivalent call inferred; original call site unknown
			v7 = nil
			labelGradient(false)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function bindLabelGradient(p)
			unbindLabelGradient() -- equivalent call inferred; original call site unknown
			v7 = p
			v8 = bindProperties(p, styleRule2, propertyNames2)
			labelGradient(true)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function rescanLabelGradient()
			unbindLabelGradient() -- equivalent call inferred; original call site unknown
			local firstOfClass = findFirstOfClass(parent, "UIGradient") -- equivalent call inferred; original call site unknown

			if firstOfClass then
				bindLabelGradient(firstOfClass) -- equivalent call inferred; original call site unknown
			end
		end

		table.insert(connections2, parent.ChildAdded:Connect(function(instance)
			if instance:IsA("UIStroke") and not v5 then
				bindStroke(instance) -- equivalent call inferred; original call site unknown
			elseif instance:IsA("UIGradient") and not v7 then
				bindLabelGradient(instance) -- equivalent call inferred; original call site unknown
			end
		end))
		table.insert(connections2, parent.ChildRemoved:Connect(function(child)
			if child == v5 then
				rescanStroke() -- equivalent call inferred; original call site unknown
			elseif child == v7 then
				rescanLabelGradient() -- equivalent call inferred; original call site unknown
			end
		end))

		for _, propertyName in v do
			styleRule:SetProperty(propertyName, parent[propertyName])
			local v11 = propertyName
			table.insert(connections2, parent:GetPropertyChangedSignal(propertyName):Connect(function()
				styleRule:SetProperty(v11, parent[v11])
			end))
		end

		local firstOfClass = findFirstOfClass(parent, "UIStroke") -- equivalent call inferred; original call site unknown

		if firstOfClass then
			disconnectAll(v6) -- equivalent call inferred; original call site unknown
			unbindStrokeGradient() -- equivalent call inferred; original call site unknown
			disconnectAll(connections) -- equivalent call inferred; original call site unknown
			v5 = nil
			stroke(false)
			v5 = firstOfClass
			v6 = bindProperties(firstOfClass, styleRule3, propertyNames)
			stroke(true)
			observeStrokeChildren(firstOfClass)
		end

		local firstOfClass2 = findFirstOfClass(parent, "UIGradient") -- equivalent call inferred; original call site unknown

		if firstOfClass2 then
			bindLabelGradient(firstOfClass2) -- equivalent call inferred; original call site unknown
		end

		local function createNodeStroke(callback)
			local uIGradient = Instance.new("UIGradient")
			uIGradient.Name = "Disabled"
			uIGradient.Archivable = false
			uIGradient.Enabled = false
			local uIStroke = Instance.new("UIStroke")
			uIStroke.Name = "Disabled"
			uIStroke.Archivable = false
			uIStroke.Enabled = false
			uIGradient.Parent = uIStroke
			effect(function()
				local v11 = callback()

				if v11 then
					uIStroke.Name = "NodeStroke"
					uIStroke.Enabled = true
					uIStroke.Thickness = v11.thickness or v11.th or 1
					uIStroke.Transparency = v11.transparency or v11.tr or 0
					uIStroke.Color = v11.color or Color3.new(0, 0, 0)
					uIStroke.LineJoinMode = v11.joins or Enum.LineJoinMode.Round
					uIStroke.StrokeSizingMode = v11.sizing or Enum.StrokeSizingMode.FixedSize
					uIGradient.Name = "Disabled"
					uIGradient.Enabled = false
				elseif stroke() then
					uIStroke.Name = "DefaultStroke"
					uIStroke.Enabled = true
					resetStrokeDefaults(uIStroke) -- equivalent call inferred; original call site unknown

					if strokeGradient() then
						uIGradient.Name = "DefaultStrokeGradient"
						resetGradientDefaults(uIGradient)
					else
						uIGradient.Name = "Disabled"
						uIGradient.Enabled = false
					end
				else
					uIStroke.Name = "Disabled"
					uIStroke.Enabled = false
					uIGradient.Name = "Disabled"
					uIGradient.Enabled = false
				end
			end)
			return uIStroke
		end

		local function createNodeGradient(callback)
			local uIGradient = Instance.new("UIGradient")
			uIGradient.Name = "Disabled"
			uIGradient.Archivable = false
			uIGradient.Enabled = false
			effect(function()
				local v11 = callback()

				if v11 then
					uIGradient.Name = "NodeGradient"
					GradientComponent.apply(uIGradient, v11)
				elseif labelGradient() then
					uIGradient.Name = "DefaultLabelGradient"
					resetGradientDefaults(uIGradient)
				else
					uIGradient.Name = "Disabled"
					uIGradient.Enabled = false
				end
			end)
			return uIGradient
		end

		local function updateNodeStroke(instance, p, data)
			if data then
				instance.Name = "NodeStroke"
				instance.Enabled = true
				instance.Thickness = data.thickness or data.th or 1
				instance.Transparency = data.transparency or data.tr or 0
				instance.Color = data.color or Color3.new(0, 0, 0)
				instance.LineJoinMode = data.joins or Enum.LineJoinMode.Round
				instance.StrokeSizingMode = data.sizing or Enum.StrokeSizingMode.FixedSize
				p.Name = "Disabled"
				p.Enabled = false
			elseif stroke() then
				instance.Name = "DefaultStroke"
				instance.Enabled = true
				resetStrokeDefaults(instance) -- equivalent call inferred; original call site unknown
				local v11 = v5

				for _, propertyName in propertyNames do
					instance[propertyName] = v11[propertyName]
				end

				instance:SetAttribute("OriginalThickness", v5:GetAttribute("OriginalThickness") or v5.Thickness)

				if strokeGradient() then
					p.Name = "DefaultStrokeGradient"
					resetGradientDefaults(p)
					local v12 = v9

					for _, propertyName in propertyNames2 do
						p[propertyName] = v12[propertyName]
					end
				else
					p.Name = "Disabled"
					p.Enabled = false
				end
			else
				instance.Name = "Disabled"
				instance.Enabled = false
				p.Name = "Disabled"
				p.Enabled = false
			end
		end

		local function updateNodeGradient(p, p2: string?)
			if p2 then
				p.Name = "NodeGradient"
				GradientComponent.apply(p, p2)
			elseif labelGradient() then
				p.Name = "DefaultLabelGradient"
				resetGradientDefaults(p)
			else
				p.Name = "Disabled"
				p.Enabled = false
			end
		end

		local function destroy()
			disconnectAll(connections2) -- equivalent call inferred; original call site unknown
			unbindStroke() -- equivalent call inferred; original call site unknown
			unbindLabelGradient() -- equivalent call inferred; original call site unknown
			styleSheet:Destroy()
			styleLink:Destroy()
		end

		return {
			strokeGradient = strokeGradient,
			labelGradient = labelGradient,
			stroke = stroke,
			createNodeStroke = createNodeStroke,
			createNodeGradient = createNodeGradient,
			updateNodeStroke = updateNodeStroke,
			updateNodeGradient = updateNodeGradient,
			destroy = destroy
		}
	end
}