local createVector = vector.create
local Destruction = {
	GetBreakFace = function(self, data, p)
		if p == "XY" then
			return data.X, data.Y, data.Z
		elseif p == "XZ" then
			return data.X, data.Z, data.Y
		end

		return data.Y, data.Z, data.X
	end,
	GetSplitFaceBySize = function(self, vector2: Vector3)
		local v = vector2.X * vector2.Y
		local v2 = vector2.X * vector2.Z
		local v3 = vector2.Y * vector2.Z

		if v2 <= v and v3 <= v then
			return "XY"
		end

		if v <= v2 and v3 <= v2 then
			return "XZ"
		end

		return "YZ"
	end
}

function Destruction.GridBreak(_, instance, p: number, p2: number)
	local v = math.floor(instance.Size.Magnitude / 24)
	local v2 = p or v
	local v3 = p2 or v
	local size = instance.Size
	local splitFaceBySize = Destruction:GetSplitFaceBySize(size)
	local breakFace, v4, v5 = Destruction:GetBreakFace(size, splitFaceBySize)
	local v6 = breakFace / v3
	local v7 = v4 / v2
	local pivot = instance:GetPivot()
	local clones = {}

	for i = 0, v2 - 1 do
		for i2 = 0, v3 - 1 do
			local v8 = 0
			local v9 = 0
			local v10 = 0
			local vector2 = createVector(0, 0, 0)
			-- equivalent calls inferred from this helper; original call sites unknown
			local v13 = (i2 - (v3 - 1) * 0.5) * v6
			local v14 = ((v2 - 1) * 0.5 - i) * v7

			local function Do()
				if splitFaceBySize == "XY" then
					v8 = v13
					v9 = v14
					v10 = 0
					vector2 = Vector3.new(v6, v7, v5)
				elseif splitFaceBySize == "XZ" then
					v8 = v13
					v9 = 0
					v10 = v14
					vector2 = Vector3.new(v6, v5, v7)
				else
					v8 = 0
					v9 = v13
					v10 = v14
					vector2 = Vector3.new(v5, v6, v7)
				end
			end

			Do() -- equivalent call inferred; original call site unknown
			local cFrame = pivot * CFrame.new(v8, v9, v10)
			local clone = instance:Clone()
			clone.Size = vector2
			clone.CFrame = cFrame
			clone.Parent = workspace.Effects
			table.insert(clones, clone)
		end
	end

	return clones
end

return Destruction