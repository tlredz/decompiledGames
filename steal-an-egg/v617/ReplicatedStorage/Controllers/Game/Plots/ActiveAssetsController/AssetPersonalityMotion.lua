local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetWanderArea = require(script.Parent.AssetWanderArea)
require(ReplicatedStorage.Data.Assets)
local Player = require(ReplicatedStorage.Shared.Player)
local AssetPersonalityMotion = {}

local function isolatedPointFromOwner(p, object, vector: Vector3)
	local halfExtents, v = AssetWanderArea.HalfExtents(p)
	local pointToObjectSpace = p.CFrame:PointToObjectSpace(vector)
	local v2

	if pointToObjectSpace.X >= 0 then
		v2 = object:NextNumber(-halfExtents, 0)
	else
		v2 = object:NextNumber(0, halfExtents)
	end

	local v3

	if pointToObjectSpace.Z >= 0 then
		v3 = object:NextNumber(-v, 0)
	else
		v3 = object:NextNumber(0, v)
	end

	return (p.CFrame * CFrame.new(v2, 0, v3)).Position
end

function AssetPersonalityMotion.StepIdle(p: number, p2: number, p3: number, cframe: CFrame, p4)
	local v = math.max(p2 - p, 0)
	local v2 = p3 + p

	if p4 == nil or not (v > 0) then
		return cframe, v, v2, v <= 0
	end

	local v3 = math.clamp(v2 / 0.2, 0, 1)
	local v4 = math.clamp(v / 0.2, 0, 1)
	local v5 = p4.Amplitude * math.min(v3, v4)
	local v6 = v2 * p4.CyclesPerSecond * 3.141592653589793 * 2
	local v7 = math.sin(v6) * v5
	local v8 = math.sin(v6 * 1.37 + 1.0471975511965976) * v5
	cframe *= CFrame.new(v7, 0, v8)
	return cframe, v, v2, v <= 0
end

function AssetPersonalityMotion.ChooseDestination(p, object, p2, vector: Vector3?)
	if vector ~= nil and object:NextNumber() < p2.IsolationPreference then
		return (isolatedPointFromOwner(p, object, vector))
	end

	if vector == nil or not (object:NextNumber() < p2.NearOwnerPreference) then
		return AssetWanderArea.RandomPoint(p, object)
	end

	return AssetWanderArea.ClampedPointToward(p, vector)
end

function AssetPersonalityMotion.RandomOwnerOffset(p, object, p2: number)
	local number = object:NextNumber(0, 6.283185307179586)
	local vector = Vector3.new(math.cos(number) * p2, 0, math.sin(number) * p2)
	return p.CFrame:VectorToWorldSpace(vector)
end

function AssetPersonalityMotion.RollChance(object, p: number)
	return not (p <= 0) and (p >= 1 or object:NextNumber() <= p)
end

function AssetPersonalityMotion.RandomConfiguredText(object, list, p, p2: string)
	assert(#list > 0, (`Personality {p} requires at least one {p2} text`))
	return list[object:NextInteger(1, #list)]
end

function AssetPersonalityMotion.OwnerRootPosition(p)
	local primaryPart = Player.FindPrimaryPart(p)

	if primaryPart == nil then
		return nil
	end

	return primaryPart.Position
end

function AssetPersonalityMotion.DistanceFromPlayerToAreaCenter(p, p2)
	local ownerRootPosition = AssetPersonalityMotion.OwnerRootPosition(p)

	if ownerRootPosition == nil then
		return nil
	end

	return (ownerRootPosition - p2.Position).Magnitude
end

function AssetPersonalityMotion.ShouldStartAmbientJump(object, p: number, p2: number, flag: boolean)
	return not (p <= 0 or flag) and 1 - math.exp(-p * p2) >= object:NextNumber()
end

return AssetPersonalityMotion