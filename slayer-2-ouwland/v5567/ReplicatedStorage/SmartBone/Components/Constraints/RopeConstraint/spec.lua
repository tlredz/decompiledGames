local createVector = vector.create
local RopeConstraint = require(script.Parent:WaitForChild("RopeConstraint"))

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
				Position = createVector(0, 10, 0),
				FreeLength = 3,
				ParentIndex = 1
			}
		}
	}
	describe("Rope Constraint", function()
		local bone = v.Bones[2]
		local count = 0
		local fn

		local function LimitCallback()
			local ropeConstraint = RopeConstraint(bone, bone.Position, v)
			expect(ropeConstraint.Magnitude).to.equal(bone.FreeLength)
			bone.FreeLength = math.random(1, 20)
			fn()
		end

		local function SameCallback()
			local ropeConstraint = RopeConstraint(bone, bone.Position, v)
			expect(ropeConstraint.Magnitude).to.equal(bone.Position.Magnitude)
			bone.FreeLength = math.random(1, 20)
			fn()
		end

		fn = function()
			if count >= 10 then
				return
			end

			count += 1

			if bone.Position.Magnitude < bone.FreeLength then
				it(`Should stay the same #{count}`, SameCallback)
			else
				it(`Should limit to {bone.FreeLength} studs #{count}`, LimitCallback)
			end
		end

		fn()
	end)
end