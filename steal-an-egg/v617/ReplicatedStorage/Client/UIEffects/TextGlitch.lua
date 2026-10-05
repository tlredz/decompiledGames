local v = {
	"#",
	"%",
	"&",
	"$",
	"@",
	"/",
	"\\",
	"0",
	"1",
	"7",
	"X",
	"?"
}
local v2 = { Color3.fromRGB(0, 229, 255), Color3.fromRGB(255, 238, 0), Color3.fromRGB(255, 0, 128) }
local v3 = { Color3.fromRGB(255, 0, 110), Color3.fromRGB(0, 225, 255) }
return {
	Bind = function(label)
		assert(label:IsA("TextLabel"), (`{label:GetFullName()} must be a TextLabel to glitch`))
		local textGlitchIntervalMin = label:GetAttribute("TextGlitchIntervalMin") or 1.2
		local textGlitchIntervalMax = label:GetAttribute("TextGlitchIntervalMax") or 3.5
		local textGlitchBurstMin = label:GetAttribute("TextGlitchBurstMin") or 0.12
		local textGlitchBurstMax = label:GetAttribute("TextGlitchBurstMax") or 0.35
		local textGlitchGhosts = label:GetAttribute("TextGlitchGhosts") ~= false
		local random = Random.new()
		local uIStroke = label:FindFirstChildOfClass("UIStroke")
		local uIGradient = label:FindFirstChildOfClass("UIGradient")
		local position = label.Position
		local rotation = label.Rotation
		local textTransparency = label.TextTransparency
		local color

		if uIStroke == nil then
			color = nil
		else
			color = uIStroke.Color
		end

		local offset

		if uIGradient == nil then
			offset = nil
		else
			offset = uIGradient.Offset
		end

		local text = label.Text
		local zIndex = label.ZIndex
		local clones = {}
		local v4 = false
		local flag = false
		local textChangedConnection = label:GetPropertyChangedSignal("Text"):Connect(function()
			if not v4 then
				text = label.Text
			end
		end)

		if textGlitchGhosts then
			label.ZIndex = math.max(label.ZIndex, 2)

			for _, textColor in v3 do
				local clone = label:Clone()
				clone:ClearAllChildren()

				for k in clone:GetAttributes() do
					clone:SetAttribute(k, nil)
				end

				clone.Name = "GlitchGhost"
				clone.TextColor3 = textColor
				clone.TextTransparency = 1
				clone.BackgroundTransparency = 1
				clone.ZIndex = label.ZIndex - 1
				clone.Parent = label.Parent
				table.insert(clones, clone)
			end
		end

		local function scrambled()
			local v5 = {}

			for i = 1, #text do
				v5[i] = string.sub(text, i, i)
			end

			for _ = 1, random:NextInteger(1, 2) do
				local integer = random:NextInteger(1, (math.max(#v5, 1)))

				if v5[integer] ~= nil and v5[integer] ~= " " then
					v5[integer] = v[random:NextInteger(1, #v)]
				end
			end

			return table.concat(v5)
		end

		local function setGhosts(flag2: boolean, integer: number, integer2: number)
			for k, v5 in clones do
				if flag2 then
					local v6 = k == 1 and 1 or -1
					v5.Text = label.Text
					v5.Rotation = label.Rotation
					v5.TextTransparency = 0.25
					v5.Position = position + UDim2.fromOffset(integer + v6 * 3, integer2 + v6 * 2)
				else
					v5.TextTransparency = 1
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function restore()
			label.Text = text
			label.Position = position
			label.Rotation = rotation
			label.TextTransparency = textTransparency

			if uIStroke ~= nil and color ~= nil then
				uIStroke.Color = color
			end

			if uIGradient ~= nil and offset ~= nil then
				uIGradient.Offset = offset
			end

			for _, v5 in clones do
				v5.TextTransparency = 1
			end

			v4 = false
		end

		local function burst()
			v4 = true
			local number = random:NextNumber(textGlitchBurstMin, textGlitchBurstMax)
			local total = 0

			while total < number and not flag do
				local integer = random:NextInteger(-4, 4)
				local integer2 = random:NextInteger(-3, 3)
				label.Position = position + UDim2.fromOffset(integer, integer2)
				label.Rotation = rotation + random:NextNumber(-2, 2)
				local v5 = label
				local text2

				if random:NextNumber() < 0.65 then
					text2 = scrambled()
				else
					text2 = text
				end

				v5.Text = text2
				label.TextTransparency = random:NextNumber() < 0.12 and 1 or textTransparency

				if uIStroke ~= nil and color ~= nil then
					local v7 = uIStroke
					local color2

					if random:NextNumber() < 0.5 then
						color2 = v2[random:NextInteger(1, #v2)]
					else
						color2 = color
					end

					v7.Color = color2
				end

				if uIGradient ~= nil then
					uIGradient.Offset = Vector2.new(random:NextNumber(-0.5, 0.5), 0)
				end

				setGhosts(true, integer, integer2)
				total += task.wait(0.03)
			end

			restore() -- equivalent call inferred; original call site unknown
		end

		task.spawn(function()
			while not flag do
				task.wait(random:NextNumber(textGlitchIntervalMin, textGlitchIntervalMax))

				if flag then
					break
				else
					burst()
				end
			end
		end)
		return function()
			if flag then
				return
			end

			flag = true
			textChangedConnection:Disconnect()
			restore() -- equivalent call inferred; original call site unknown
			label.ZIndex = zIndex

			for _, v5 in clones do
				v5:Destroy()
			end

			table.clear(clones)
		end
	end
}