local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StagingMarks = require(ReplicatedStorage.NPCManager.StagingMarks)
require(ReplicatedStorage.NPCManager.Types)
local Staging = {}

local function flatDirection(vector2: Vector3, vector3: Vector3)
	local v = vector2 * createVector(1, 0, 1)

	if v.Magnitude > 0.05 then
		return v.Unit
	end

	local v2 = vector3 * createVector(1, 0, 1)

	if v2.Magnitude > 0.05 then
		return v2.Unit
	end

	return createVector(0, 0, 1)
end

function Staging.getMarkCFrame(p)
	local mark

	if p then
		mark = p.Mark
	end

	if not mark then
		return nil
	end

	local markForward

	if p then
		markForward = p.MarkForward
	end

	if not markForward or markForward == 0 then
		return mark
	end

	local v = mark.LookVector * createVector(1, 0, 1)
	local v2

	if v.Magnitude > 0.05 then
		v2 = v.Unit
	else
		v2 = not ((createVector(0, 0, 1)).Magnitude > 0.05) and createVector(0, 0, 1) or (createVector(0, 0, 1)).Unit
	end

	return mark + v2 * markForward
end

function Staging.getMarkCFrameForNPC(p: string)
	return Staging.getMarkCFrame(StagingMarks[p])
end

return Staging