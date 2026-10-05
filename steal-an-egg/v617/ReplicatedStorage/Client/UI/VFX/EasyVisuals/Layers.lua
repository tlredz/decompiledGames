local RunService = game:GetService("RunService")
local Gradient = require(script.Parent.Gradient)
local GradientTemplates = require(script.Parent.GradientTemplates)
local Stroke = require(script.Parent.Stroke)
local heartbeat = RunService.Heartbeat
local color = Color3.fromRGB(255, 255, 255)
local v = { 0, 0.5, 1 }
local v2 = {
	TextButton = "BackgroundColor3",
	TextLabel = "TextColor3",
	ImageLabel = "ImageColor3",
	ImageButton = "ImageColor3",
	Frame = "BackgroundColor3",
	ScrollingFrame = "BackgroundColor3",
	ViewportFrame = "BackgroundColor3"
}
local v3 = {
	{
		field = "StartPhase",
		apply = function(p, now)
			p.phase.now = now
		end
	},
	{
		field = "Rotation",
		apply = function(object, p)
			object:SetRotation(p, 1)
		end
	},
	{
		field = "Spin",
		apply = function(object, p)
			object:Spin(p, 1)
		end
	},
	{
		field = "PhaseGoal",
		apply = function(object, p)
			object:PhaseTo(p, 1)
		end
	},
	{
		field = "Drift",
		apply = function(object, p)
			object:Drift(p, 1)
		end
	},
	{
		field = "AlphaDrift",
		apply = function(object, p)
			object:AlphaDrift(p, 1)
		end
	}
}
local frozen = table.freeze({})

local function paletteOf(p)
	local palette = p.Palette

	if typeof(palette) == "string" then
		return GradientTemplates[palette].Color
	end

	return palette
end

return table.freeze({
	Paint = function(p, p2)
		local new = Gradient.new
		local palette = p2.Palette

		if typeof(palette) == "string" then
			palette = GradientTemplates[palette].Color
		end

		local v5 = new(p, palette, p2.Alpha or 0)

		for _, v6 in v3 do
			local v7 = p2[v6.field]

			if v7 then
				v6.apply(v5, v7)
			end
		end

		return v5
	end,
	Edge = function(p, p2: number)
		return Stroke.new(p, p2)
	end,
	AcceptsEdge = function(image)
		return not image:IsA("ImageLabel") or image.BackgroundTransparency ~= 1
	end,
	AlphaStops = function(p: string)
		return GradientTemplates[p].Transparency
	end,
	HostColor = function(instance)
		return instance[v2[instance.ClassName]] or color
	end,
	FlatPalette = function(color2: Color3)
		local colorSequenceKeypoints = table.create(#v)

		for k, v5 in v do
			colorSequenceKeypoints[k] = ColorSequenceKeypoint.new(v5, color2)
		end

		return ColorSequence.new(colorSequenceKeypoints)
	end,
	ShinePalette = function(color2: Color3, p: number)
		return ColorSequence.new({
			ColorSequenceKeypoint.new(0, color2),
			ColorSequenceKeypoint.new(0.5, color2:Lerp(color, p)),
			ColorSequenceKeypoint.new(1, color2)
		})
	end,
	Turn = function(object, p, p2: number, p3: number)
		local v5 = p2
		local connection = nil
		connection = heartbeat:Connect(function(p4: number)
			if p.Parent == nil then
				connection:Disconnect()
			end

			v5 += p3 * p4
			object:SetRotation(v5, 1)
		end)
		return connection
	end,
	Breathe = function(object, p: number, p2: number, p3: number, p4: number)
		local connection = nil
		connection = heartbeat:Connect(function()
			if object.outline and object.outline.Parent ~= nil then
				object:EaseWidth(p * (p2 * math.sin(tick() * p3) + 1), p4)
			else
				connection:Disconnect()
			end
		end)
		return connection
	end,
	Replay = function(p, items)
		if typeof(items) ~= "table" then
			items = frozen
		end

		for _, item in items do
			local v5 = p[item.Function]

			if not (typeof(v5) == "function" and typeof(item.Package) == "table") then
				continue
			end

			v5(p, table.unpack(item.Package))
		end
	end,
	Result = function(effects, connections)
		return {
			Effects = effects,
			Connections = connections
		}
	end
})