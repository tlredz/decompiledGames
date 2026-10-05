local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextParser = require(script.Parent.TextParser)
local LabelStyleSheet = require(script.Parent.LabelStyleSheet)
local VirtualInstance = require(script.Parent.VirtualInstance)
local Gradients = require(ReplicatedStorage.Packages.Gradients)
local vide = require(ReplicatedStorage.Packages.vide)
local create = vide.create
local apply = vide.apply
local source = vide.source
local changed = vide.changed
local derive = vide.derive
local effect = vide.effect
local cleanup = vide.cleanup
local batch = vide.batch
local untrack = vide.untrack
local font = Font.fromEnum(Enum.Font.SourceSans)

local function RicherTextLabel(parent)
	local automaticSize = parent.AutomaticSize
	local automaticSize2 = parent:GetAttribute("AutomaticSize")
	local textBounds = parent:GetAttribute("TextBounds")
	local maxVisibleGraphemes = parent.MaxVisibleGraphemes
	local v = source(parent.TextSize)
	local v2 = source(parent.FontFace)
	local v3 = source(parent.TextSize)
	local v4 = source(parent.TextScaled)
	local v5 = source(parent.TextWrapped)
	local v6 = source(parent.TextTransparency)
	local v7 = source(parent.TextXAlignment.Name)
	local v8 = source(parent.TextYAlignment.Name)
	local v9 = source("None")
	local v10 = source(parent.AbsoluteSize)
	local v11 = source(parent.AbsolutePosition)
	local v12 = source(Vector2.one)
	local v13 = source(Vector2.zero)
	local v14 = source(parent.Text)
	local v15 = source(1)
	local v16 = source({})
	local v17 = source(1)
	local v18 = derive(function()
		return v10() / v15()
	end)
	local v19 = derive(function()
		local v20 = v16()
		local total = 0
		local v21 = 0

		for _, v22 in v20 do
			total += v22.height
			v21 = math.max(v21, v22.width)
		end

		return (vector.create(v21, total))
	end)
	local v20 = derive(function()
		return TextParser.parse(v14())
	end)
	local v21 = source(0)
	local v22 = derive(function()
		local v23 = v20()
		local v24 = v2()
		v21()
		local flag = false
		local thread = task.spawn(function()
			local v25 = {
				[v24.Family] = true
			}
			TextParser.loadFont(v24)

			for _, v26 in v23 do
				if not (v26.t == "text" and v26.a) then
					continue
				end

				local fontFace = v26.a.fontFace

				if not fontFace or v25[fontFace.Family] then
					continue
				end

				v25[fontFace.Family] = true
				TextParser.loadFont(fontFace)
			end

			if flag then
				v21(v21() + 1)
			end
		end)

		if coroutine.status(thread) == "dead" then
			flag = false
		else
			flag = true
		end

		if flag then
			return font
		end

		return v24
	end)
	local v23 = derive(function()
		local v24 = v18()
		local v25 = v9()

		if v25 == "None" or v25 == "Y" then
			return v24.X
		end

		local v26 = v11()
		local v27 = v13()
		local v28 = v12()
		local v29 = v26 - v27
		return (math.max(v28.X - v29.X, 0))
	end)
	local v24 = LabelStyleSheet.create(parent)
	cleanup(v24.destroy)
	effect(function()
		local v25 = v4()
		local v26

		if v25 then
			v26 = v18()
		else
			v26 = untrack(v18)
		end

		local v27 = v23()
		local v28 = v20()
		local v29 = not TextParser.hasNewlines(v28)
		local v30, v31

		if v25 then
			if v5() then
				v30 = v27
			end

			if v29 and not v30 then
				v31 = TextParser.maximumTextSize(v28, v22(), Vector2.new(v27, v26.Y))
			else
				v31 = TextParser.maximumMultilineTextSize(v28, v22(), Vector2.new(v27, v26.Y), v30, v17())
			end
		else
			v31 = v()

			if v5() then
				v30 = v27
			end
		end

		v3(v31)
		v16(TextParser.parseLines(v31, v22(), v28, v30, v17()))
	end)
	v9(parent:GetAttribute("AutomaticSize") or parent.AutomaticSize.Name)
	parent:SetAttribute("AutomaticSize", v9())
	parent.AutomaticSize = Enum.AutomaticSize.None
	local v25 = { (parent:GetAttributeChangedSignal("AutomaticSize"):Connect(function()
			v9(parent:GetAttribute("AutomaticSize"))
			parent:SetAttribute("AutomaticSize", v9())
		end)) }

	local function hookParent()
		if v25[3] then
			v25[3]:Disconnect()
			v25[3] = nil
		end

		if v25[4] then
			v25[4]:Disconnect()
			v25[4] = nil
		end

		batch(function()
			local parent2 = parent.Parent

			if parent2 and parent2:IsA("GuiBase2d") then
				v13(parent2.AbsolutePosition)
				v12(parent2.AbsoluteSize)
				v25[3] = parent2:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
					v12(parent2.AbsoluteSize)
				end)
				v25[4] = parent2:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
					v13(parent2.AbsolutePosition)
				end)
			else
				v12(Vector2.zero)
				v13(Vector2.zero)
			end
		end)
	end

	hookParent()
	v25[2] = parent:GetPropertyChangedSignal("Parent"):Connect(hookParent)
	cleanup(function()
		for _, connection in v25 do
			connection:Disconnect()
		end

		table.clear(v25)
	end)
	cleanup(function()
		parent.AutomaticSize = Enum.AutomaticSize[v9()] or automaticSize

		if automaticSize2 == nil then
			parent:SetAttribute("AutomaticSize", nil)
		end

		parent:SetAttribute("TextBounds", textBounds)
		parent.MaxVisibleGraphemes = maxVisibleGraphemes
	end)
	effect(function()
		parent:SetAttribute("TextBounds", v19())
	end)
	local v26 = {}
	local v27 = {}
	local count = 0
	local count2 = 0
	effect(function()
		local imageTransparency = v6()

		for i = 1, count2 do
			v27[i].label.ImageTransparency = imageTransparency
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clearGradientEffect(p)
		if p.gradientEffectCleanup then
			p.gradientEffectCleanup()
			p.gradientEffectCleanup = nil
		end
	end

	local function acquireText()
		count += 1
		local v28 = v26[count]

		if v28 then
			v28.label.Visible = true
			return v28
		end

		local textLabel = Instance.new("TextLabel")
		textLabel.Archivable = false
		textLabel.RichText = true
		textLabel.BackgroundTransparency = 1
		textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		textLabel.TextXAlignment = Enum.TextXAlignment.Center
		textLabel.TextYAlignment = Enum.TextYAlignment.Center
		textLabel:ResetPropertyToDefault("TextColor3")
		textLabel:ResetPropertyToDefault("TextTransparency")
		textLabel:ResetPropertyToDefault("TextStrokeTransparency")
		textLabel:ResetPropertyToDefault("TextStrokeColor3")
		textLabel.Parent = parent
		local uIScale = Instance.new("UIScale")
		uIScale.Archivable = false
		uIScale.Parent = textLabel
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Archivable = false
		uIStroke.Name = "Disabled"
		uIStroke.Enabled = false
		uIStroke.Parent = textLabel
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Archivable = false
		uIGradient.Name = "Disabled"
		uIGradient.Enabled = false
		uIGradient.Parent = uIStroke
		local uIGradient2 = Instance.new("UIGradient")
		uIGradient2.Archivable = false
		uIGradient2.Name = "Disabled"
		uIGradient2.Enabled = false
		uIGradient2.Parent = textLabel
		local v29 = {
			label = VirtualInstance.wrap(textLabel),
			instance = textLabel,
			scale = uIScale,
			stroke = uIStroke,
			strokeGradient = uIGradient,
			gradient = uIGradient2,
			gradientEffectCleanup = nil
		}
		v26[count] = v29
		return v29
	end

	local function acquireImage()
		count2 += 1
		local v28 = v27[count2]

		if v28 then
			v28.label.Visible = true
			return v28
		end

		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Archivable = false
		imageLabel.BackgroundTransparency = 1
		imageLabel.Parent = parent
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Archivable = false
		uIGradient.Name = "Disabled"
		uIGradient.Enabled = false
		uIGradient.Parent = imageLabel
		local v29 = {
			label = VirtualInstance.wrap(imageLabel),
			instance = imageLabel,
			gradient = uIGradient
		}
		v27[count2] = v29
		return v29
	end

	effect(function()
		local v28 = v16()
		local fontFace = v22()
		local v30 = v3()
		local v31 = v7()
		local v32 = v8()
		local v33 = v18()
		local v34 = v19()
		local v35 = v9()
		count = 0
		count2 = 0
		local Y = v33.Y

		if v35 == "Y" or v35 == "XY" then
			Y = math.max(Y, v34.y)
		end

		local v36 = 0

		if v32 == "Bottom" then
			v36 = Y - v34.y
		elseif v32 == "Center" then
			v36 = (Y - v34.y) / 2
		end

		local v37

		if #v28 == 1 then
			v37 = v32 == "Center"
		else
			v37 = false
		end

		for _, v38 in v28 do
			local v39 = v38.y + v36

			for k, node in v38.nodes do
				local x = node.x or 0
				local node2 = v38.nodes[k + 1]
				local v40

				if node2 then
					v40 = node2.x or v38.width
				else
					v40 = v38.width
				end

				local v41 = v40 - x

				if v31 == "Right" then
					x += v33.X - v38.width
				elseif v31 == "Center" then
					x += (v33.X - v38.width) / 2
				end

				if node.t == "text" then
					local v42 = acquireText()
					clearGradientEffect(v42) -- equivalent call inferred; original call site unknown
					local scale = 1
					local size

					if node.a then
						if node.a.size then
							size = tonumber(node.a.size) or v30
						else
							if node.a.scale then
								scale = tonumber(node.a.scale) or 1
							end

							size = v30
						end
					else
						size = v30
					end

					v42.label.FontFace = fontFace
					v42.label.Text = TextParser.getDisplayText(node)
					v42.label.TextSize = size
					v42.label.Size = UDim2.fromOffset(scale == 0 and 0 or v41 / scale, size)
					v42.label.Position = UDim2.fromOffset(x + v41 / 2, v39 + v38.height / 2)
					v42.scale.Scale = scale
					local stroke = node.a and node.a.stroke
					local gradient = node.a and node.a.gradient
					v24.updateNodeStroke(v42.stroke, v42.strokeGradient, stroke)

					if typeof(gradient) == "string" and Gradients.hasEffect(gradient) then
						v24.updateNodeGradient(v42.gradient, nil)
						v42.gradientEffectCleanup = Gradients.apply(v42.instance, gradient)
					else
						v24.updateNodeGradient(v42.gradient, gradient)
					end
				elseif node.t == "image" then
					local v42 = acquireImage()
					local size

					if node.a then
						if node.a.size then
							size = tonumber(node.a.size) or v30
						elseif node.a.scale then
							size = v30 * (tonumber(node.a.scale) or 1)
						else
							size = v30
						end
					else
						size = v30
					end

					local v43 = not (node.a and node.a.padding) and 0 or tonumber(node.a.padding) or 0
					local v44 = size - v43
					v42.label.Image = "rbxassetid://" .. tostring(node.v)
					v42.label.ImageTransparency = untrack(v6)
					v42.label.Size = UDim2.fromOffset(v44, v44)

					if v37 then
						local v45 = v38.height - v30 / 2 - v44 / 2
						v42.label.Position = UDim2.fromOffset(x + v43 / 2, v39 + v45)
					else
						v42.label.Position = UDim2.fromOffset(x + v43 / 2, v39 + v43 / 2)
					end

					v24.updateNodeGradient(v42.gradient, node.a and node.a.gradient)
				end
			end
		end

		local v38 = count + 4

		for i = count + 1, math.min(v38, #v26) do
			clearGradientEffect(v26[i]) -- equivalent call inferred; original call site unknown
			v26[i].label.Visible = false
		end

		for i = #v26, v38 + 1, -1 do
			clearGradientEffect(v26[i]) -- equivalent call inferred; original call site unknown
			VirtualInstance.cancel(v26[i].label)
			v26[i].instance:Destroy()
			v26[i] = nil
		end

		local v39 = count2 + 4

		for i = count2 + 1, math.min(v39, #v27) do
			v27[i].label.Visible = false
		end

		for i = #v27, v39 + 1, -1 do
			VirtualInstance.cancel(v27[i].label)
			v27[i].instance:Destroy()
			v27[i] = nil
		end
	end)
	cleanup(function()
		for _, v28 in v26 do
			clearGradientEffect(v28) -- equivalent call inferred; original call site unknown
			v28.instance:Destroy()
		end

		for _, v28 in v27 do
			v28.instance:Destroy()
		end

		table.clear(v26)
		table.clear(v27)
	end)
	local v28 = create("Frame")({
		Archivable = false,
		Name = "UIScaleProber",
		Size = UDim2.fromOffset(1000, 1000),
		BackgroundTransparency = 1,
		changed("AbsoluteSize", function(point: Vector2)
			v15(point.X / 1000)
		end)
	})
	cleanup(v28)
	local v29 = create("UISizeConstraint")({
		Archivable = false,
		MinSize = function()
			local v30 = v9()
			local v31 = v19()

			if v30 == "None" then
				return Vector2.zero
			elseif v30 == "X" then
				return Vector2.new(v31.x, 0)
			elseif v30 == "Y" then
				return Vector2.new(0, v31.y)
			end

			return Vector2.new(v31.x, v31.y)
		end
	})
	cleanup(v29)
	return apply(parent)({
		MaxVisibleGraphemes = 0,
		v28,
		v29,
		changed("LineHeight", v17),
		changed("AbsoluteSize", v10),
		changed("AbsolutePosition", v11),
		changed("TextScaled", v4),
		changed("TextWrapped", v5),
		changed("TextTransparency", v6),
		changed("TextSize", v),
		changed("FontFace", v2),
		changed("TextXAlignment", function(p)
			v7(p.Name)
		end),
		changed("TextYAlignment", function(p)
			v8(p.Name)
		end),
		changed("Text", v14)
	})
end

return RicherTextLabel