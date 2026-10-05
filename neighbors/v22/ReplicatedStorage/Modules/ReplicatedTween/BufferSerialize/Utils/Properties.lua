local v = {
	"BackSurface",
	"FrontSurface",
	"LeftSurface",
	"RightSurface",
	"BottomSurface",
	"TopSurface"
}

local function getSurfaceTypes(p)
	local result = {}

	for _, v2 in v do
		result[v2] = p[v2]
	end

	return result
end

return {
	getProperties = function(instance)
		if instance:IsA("Part") then
			local v2 = {
				Color = instance.Color,
				Size = instance.Size,
				Anchored = instance.Anchored,
				Transparency = instance.Transparency,
				Reflectance = instance.Reflectance,
				Material = instance.Material,
				Shape = instance.Shape,
				METHOD_pivotTo = instance:GetPivot(),
				METHOD_setSurfaceTypes = 0
			}
			local v3 = {}

			for _, v4 in v do
				v3[v4] = instance[v4]
			end

			v2.METHOD_setSurfaceTypes = v3
			return v2
		else
			if instance:IsA("Model") then
				return {
					PrimaryPart = instance.PrimaryPart,
					LevelOfDetail = instance.LevelOfDetail,
					METHOD_pivotTo = instance:GetPivot()
				}
			end

			error("Uncopyable Instance")
		end
	end,
	methods = {
		setSurfaceTypes = function(p, items)
			for k, item in items do
				p[k] = item
			end
		end,
		pivotTo = function(instance, cframe: CFrame)
			instance:PivotTo(cframe)
		end
	}
}