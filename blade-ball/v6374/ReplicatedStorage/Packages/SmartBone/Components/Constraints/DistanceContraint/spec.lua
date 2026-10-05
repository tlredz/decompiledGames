local createVector = vector.create
local DistanceConstraint = require(script.Parent:WaitForChild("DistanceConstraint"))

local function CreateBone(position, freeLength, parentIndex)
	return {
		Position = position,
		FreeLength = freeLength,
		ParentIndex = parentIndex
	}
end

return function()
	local v = {
		Bones = {
			{
				Position = createVector(0, 0, 0),
				FreeLength = 3,
				ParentIndex = 0
			},
			{
				Position = createVector(0, 1, 0),
				FreeLength = 3,
				ParentIndex = 1
			}
		}
	}
	describe("Distance Constraint", function()
		local bone = v.Bones[2]

		local function Callback()
			local position = DistanceConstraint(bone, bone.Position, v)
			expect(position.Magnitude).to.equal(bone.FreeLength)
			bone.Position = position
		end

		for i = 1, 10 do
			it(`Should limit to {bone.FreeLength} studs #{i}`, Callback)
			bone.FreeLength = math.random(1, 20)
		end
	end)
end