local Graph = require(script.Parent.Graph)
local v = {
	Part = {
		{ "Speed", "_staticSpeed", 0 },
		{ "Brightness", "_staticBrightness", 1 },
		{ "Transparency", "_staticTransparency", 0 },
		{ "SizeX", "_staticSizeX", 1 },
		{ "SizeY", "_staticSizeY", 1 },
		{ "SizeZ", "_staticSizeZ", 1 },
		{ "RotSpeedX", "_staticRotSpeedX", 0 },
		{ "RotSpeedY", "_staticRotSpeedY", 0 },
		{ "RotSpeedZ", "_staticRotSpeedZ", 0 },
		{ "PosOffsetX", "_staticPosOffsetX", 0 },
		{ "PosOffsetY", "_staticPosOffsetY", 0 },
		{ "PosOffsetZ", "_staticPosOffsetZ", 0 },
		{ "AccelStrength", "_staticAccelStrength", 0 }
	},
	Attachment = {
		{ "Speed", "_staticSpeed", 0 },
		{ "RotSpeedX", "_staticRotSpeedX", 0 },
		{ "RotSpeedY", "_staticRotSpeedY", 0 },
		{ "RotSpeedZ", "_staticRotSpeedZ", 0 },
		{ "PosOffsetX", "_staticPosOffsetX", 0 },
		{ "PosOffsetY", "_staticPosOffsetY", 0 },
		{ "PosOffsetZ", "_staticPosOffsetZ", 0 }
	},
	Model = {
		{ "Speed", "_staticSpeed", 0 },
		{ "Scale", "_staticScale", 1 },
		{ "RotSpeedX", "_staticRotSpeedX", 0 },
		{ "RotSpeedY", "_staticRotSpeedY", 0 },
		{ "RotSpeedZ", "_staticRotSpeedZ", 0 },
		{ "PosOffsetX", "_staticPosOffsetX", 0 },
		{ "PosOffsetY", "_staticPosOffsetY", 0 },
		{ "PosOffsetZ", "_staticPosOffsetZ", 0 }
	},
	ImageLabel = {
		{ "ImageTransparency", "_staticImageTransparency", 0 },
		{ "BackgroundTransparency", "_staticBackgroundTransparency", 0 },
		{ "ImgSpeed", "_staticImgSpeed", 0 },
		{ "ImgRotSpeed", "_staticImgRotSpeed", 0 },
		{ "SizeScaleX", "_staticSizeScaleX", 1 },
		{ "SizeScaleY", "_staticSizeScaleY", 1 }
	}
}
local StaticPass = {}

function StaticPass:apply()
	if not (self and self.Type) then
		return
	end

	local v2 = v[self.Type]

	if not v2 then
		return
	end

	local graphs = self.Graphs

	if not graphs then
		return
	end

	for _, v3 in ipairs(v2) do
		local v4 = v3[1]
		local v5 = v3[2]
		local v6 = v3[3]
		local graph = graphs[v4]

		if graph and Graph.IsStatic(graph) then
			self[v5] = Graph.GetStaticValue(graph, v6)
			graphs[v4] = nil
		else
			self[v5] = nil
		end
	end
end

function StaticPass.restoreFromFreshData(p, p2)
	if not (p and p2 and p.Type) then
		return
	end

	local v2 = v[p.Type]

	if not v2 then
		return
	end

	local graphs = p.Graphs

	if not graphs then
		return
	end

	for _, v3 in ipairs(v2) do
		local v4 = v3[1]

		if graphs[v4] == nil and p2[v4] then
			graphs[v4] = p2[v4]
		end
	end
end

return StaticPass