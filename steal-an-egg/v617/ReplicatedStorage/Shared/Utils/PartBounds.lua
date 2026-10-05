local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local strict = t.strict(t.table)

local function corner(vector2: Vector3, p: number)
	local X

	if p % 2 == 0 then
		X = -vector2.X
	else
		X = vector2.X
	end

	local Y

	if p // 2 % 2 == 0 then
		Y = -vector2.Y
	else
		Y = vector2.Y
	end

	local v

	if p // 4 == 0 then
		v = -vector2.Z
	else
		v = vector2.Z
	end

	return (Vector3.new(X, Y, v))
end

return function(list, cframe: CFrame?)
	strict(list)
	assert(#list > 0, "PartBounds needs at least one part")
	local cframe2 = cframe or CFrame.identity
	local v = createVector(1, 1, 1) * 1e999
	local v2 = -v

	for _, part in list do
		if not part:IsA("BasePart") then
			continue
		end

		local objectSpace = cframe2:ToObjectSpace(part.CFrame)
		local halfSize = part.Size / 2

		for i = 0, 7 do
			local X

			if i % 2 == 0 then
				X = -halfSize.X
			else
				X = halfSize.X
			end

			local Y

			if i // 2 % 2 == 0 then
				Y = -halfSize.Y
			else
				Y = halfSize.Y
			end

			local v4

			if i // 4 == 0 then
				v4 = -halfSize.Z
			else
				v4 = halfSize.Z
			end

			local v5 = objectSpace * Vector3.new(X, Y, v4)
			v = v:Min(v5)
			v2 = v2:Max(v5)
		end
	end

	return cframe2 * CFrame.new((v + v2) / 2), v2 - v
end