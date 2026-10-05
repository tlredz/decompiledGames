local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local SharedCrabCage = {}
local crabcages = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("library"):WaitForChild("crabcages"))
local crabzone = require(ReplicatedStorage.shared.modules.library.fish.zones.crabzone)
require(ReplicatedStorage.shared.modules.fishing.BiteTypes)
SharedCrabCage.CageState = table.freeze({
	Waiting = 1,
	Claimable = 2
})
SharedCrabCage.Constants = {
	PLACE_RANGE = 16,
	PLACE_INTERVAL = 0.25,
	BASE_LURE_MIN = 190,
	BASE_LURE_MAX = 252,
	CHUNK_UPDATE_RATE = 0.5,
	CHUNK_SIZE = 128,
	CHUNK_LOAD_RADIUS = 1,
	CHUNK_MAX_TIME = 0.002,
	BOBBING_TIME = 3,
	BOBBING_HEIGHT = 0.5,
	ALLOWED_STATES = {
		[Enum.HumanoidStateType.Running] = true,
		[Enum.HumanoidStateType.RunningNoPhysics] = true,
		[Enum.HumanoidStateType.FallingDown] = true,
		[Enum.HumanoidStateType.Landed] = true
	}
}

function SharedCrabCage.GetStatsTemplate(_)
	return {
		Luck = 0,
		LuckMultiply = 1,
		Strength = 0,
		Lure = 0,
		XpMultiply = 0.5,
		Durability = 0,
		Scavenging = 0,
		BaitEffectiveness = 1,
		TimeEffectiveness = 0.5,
		WeatherEffectiveness = 0.5,
		SeasonEffectiveness = 1,
		WeightBoost = 0,
		NaturalMutationChance = 8,
		MutationChanceBoost = 0,
		ShinyChance = 1,
		SparklingChance = 1
	}
end

function SharedCrabCage:CFrameFromSerialized(list)
	return CFrame.new(list[1], list[2], list[3]) * CFrame.fromOrientation(0, math.rad(list[4]), 0)
end

function SharedCrabCage.CFrameToSerialized(_, cframe: CFrame, flag: boolean)
	if flag then
		cframe = SharedCrabCage:RoundCFrame(cframe)
	end

	local _, v3, _ = cframe:ToEulerAnglesYXZ()
	return {
		cframe.X,
		cframe.Y,
		cframe.Z,
		(math.round((math.deg(v3))))
	}
end

function SharedCrabCage:RoundCFrame(data, identity: CFrame?)
	if not identity then
		if typeof(data) == "CFrame" then
			identity = data
		else
			identity = CFrame.identity
		end
	end

	local _, v3, _ = identity:ToEulerAnglesYXZ()
	return CFrame.new(math.round(data.X * 10) / 10, math.round(data.Y * 10) / 10, math.round(data.Z * 10) / 10) * CFrame.fromOrientation(
		0,
		math.rad((math.round((math.deg(v3))))),
		0
	)
end

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { workspace:WaitForChild("zones"):WaitForChild("fishing", 1e999) }
local overlapParams2 = OverlapParams.new()
overlapParams2.RespectCanCollide = true
overlapParams2.CollisionGroup = "Players"
overlapParams2.MaxParts = 1
overlapParams2.FilterType = Enum.RaycastFilterType.Exclude
overlapParams2.FilterDescendantsInstances = { workspace:WaitForChild("active") }
local part = Instance.new("Part")
part.Size = createVector(2.25, 2.25, 3.25)
part.Anchored = true
part.CanCollide = false
part.CanTouch = false
part.CanQuery = false
part.CastShadow = false
part.Locked = true
part.Transparency = 1
part.Name = "OccupancyCheck"
part.Parent = workspace.CurrentCamera
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	part.Parent = workspace.CurrentCamera
end)

function SharedCrabCage.FindZone(_, p, p2: number)
	local v3 = typeof(p) == "CFrame" and p or SharedCrabCage:CFrameFromSerialized(p)
	local partBoundsInBox = workspace:GetPartBoundsInBox(v3, createVector(2.25, 2.25, 3.25), overlapParams)
	local v4 = nil
	local v5 = nil

	for _, v6 in partBoundsInBox do
		local crabZone = v6:FindFirstChild("CrabZone")

		if not (v6.Parent == workspace.zones.fishing and crabZone) then
			continue
		end

		local v7 = crabzone[crabZone.Value]

		if not v7 then
			continue
		end

		if (v7.RequiredDurability or 0) > (crabcages.byId[p2].Durability or 0) then
			return nil, "You'll need a stronger Crab Cage for these waters."
		end

		if v4 == nil then
			v5 = v7
			v4 = v6
		elseif v7.Priority > v5.Priority or v6:FindFirstChild("Abundance") and not v4:FindFirstChild("Abundance") then
			v5 = v7
			v4 = v6
		end
	end

	if v4 then
		return v4, nil
	end

	return nil, "Your Crab Cage can't catch anything here."
end

function SharedCrabCage.OccupancyCheck(_, p)
	part.CFrame = typeof(p) == "CFrame" and p or SharedCrabCage:CFrameFromSerialized(p)

	if #workspace:GetPartsInPart(part, overlapParams2) == 0 then
		return true, nil
	end

	return false, "You can't place a Crab Cage here."
end

return SharedCrabCage