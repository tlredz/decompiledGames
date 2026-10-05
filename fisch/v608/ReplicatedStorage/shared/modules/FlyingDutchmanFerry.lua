local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local FlyingDutchmanFerry = {
	SHIP_TAG = "FlyingDutchmanFerry",
	CAPTAIN_NPC_TYPE = "Dutchman Captain",
	CUTSCENE_NAME = "FlyingDutchmanVoyage",
	HOME_ATTRIBUTE = "FerryHome",
	ROUTE_FOLDER = "FerryRoute",
	DEMO_PATH = { "FischFright Cutscene Demo", "Flying Dutchman" },
	Enabled = false,
	LegDuration = 12,
	FadeTime = 2,
	CrossingBlackout = 1.5,
	DwellSeconds = 180,
	BobAmplitude = 0.6,
	BobPeriod = 4,
	RollDegrees = 1.5,
	Attributes = table.freeze({
		State = "FerryState",
		Dock = "FerryDock",
		LegStart = "FerryLegStart",
		LegDuration = "FerryLegDuration",
		Voyage = "FerryVoyage"
	})
}
local v = {
	Moosewood = {
		DisplayName = "Moosewood",
		Offset = CFrame.identity
	},
	Fischfright = {
		DisplayName = "Fischfright Isle",
		Offset = CFrame.new(-800, 0, -800)
	}
}
local cframe = CFrame.new(0, 0, -260)
local cframe2 = CFrame.new(0, 0, 260)
local cframe3 = CFrame.new(70, 22, 30)

function FlyingDutchmanFerry.OtherDock(p: string)
	if p == "Moosewood" then
		return "Fischfright"
	end

	return "Moosewood"
end

function FlyingDutchmanFerry.IsDockName(p)
	return p == "Moosewood" or p == "Fischfright"
end

function FlyingDutchmanFerry.GetDock(childName: string, instance)
	local v2 = v[childName]

	if not v2 then
		return nil
	end

	local child = instance.Parent and instance.Parent:FindFirstChild(FlyingDutchmanFerry.ROUTE_FOLDER)
	local child2 = child and child:FindFirstChild(childName)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function authored(childName2: string)
		local part = child2 and child2:FindFirstChild(childName2)

		if part and part:IsA("BasePart") then
			return part.CFrame
		end

		return nil
	end

	local docked = authored("Docked") -- equivalent call inferred; original call site unknown

	if not docked then
		local attribute = instance:GetAttribute(FlyingDutchmanFerry.HOME_ATTRIBUTE)

		if typeof(attribute) ~= "CFrame" then
			return nil
		end

		docked = attribute * v2.Offset
	end

	assert(docked)
	local v4 = {
		Name = childName,
		DisplayName = v2.DisplayName,
		Docked = docked,
		DepartTo = 0,
		ArriveFrom = 0,
		Camera = 0
	}
	local v5 = authored("DepartTo") -- equivalent call inferred; original call site unknown
	v4.DepartTo = v5 or docked * cframe
	local v6 = authored("ArriveFrom") -- equivalent call inferred; original call site unknown
	v4.ArriveFrom = v6 or docked * cframe2
	local v7 = authored("Camera") -- equivalent call inferred; original call site unknown
	v4.Camera = v7 or docked * cframe3
	return v4
end

local function ease(p: number, p2: string)
	if p2 == "Departing" then
		return TweenService:GetValue(p, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
	end

	return TweenService:GetValue(p, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
end

function FlyingDutchmanFerry.GetLegCFrame(data, p: string, value: number, p2: number)
	local v2 = math.clamp(value, 0, 1)
	local docked, departTo

	if p == "Departing" then
		docked = data.Docked
		departTo = data.DepartTo
	else
		docked = data.ArriveFrom
		departTo = data.Docked
	end

	local lerped = docked:Lerp(departTo, ease(v2, p))

	if p ~= "Departing" then
		v2 = 1 - v2
	end

	local v3 = p2 * (6.283185307179586 / FlyingDutchmanFerry.BobPeriod)
	local v4 = math.sin(v3) * FlyingDutchmanFerry.BobAmplitude * v2
	local v5 = math.rad(math.sin(v3 * 0.7) * FlyingDutchmanFerry.RollDegrees * v2)
	return lerped * CFrame.new(0, v4, 0) * CFrame.Angles(0, 0, v5)
end

function FlyingDutchmanFerry.GetShipCFrame(instance, p: number)
	local attributes = FlyingDutchmanFerry.Attributes
	local attribute = instance:GetAttribute(attributes.State)

	if attribute ~= "Departing" and attribute ~= "Arriving" then
		return nil, nil
	end

	local attribute2 = instance:GetAttribute(attributes.Dock)
	local attribute3 = instance:GetAttribute(attributes.LegStart)
	local attribute4 = instance:GetAttribute(attributes.LegDuration)

	if not FlyingDutchmanFerry.IsDockName(attribute2) or type(attribute3) ~= "number" then
		return nil, nil
	end

	if type(attribute4) ~= "number" or attribute4 <= 0 then
		attribute4 = FlyingDutchmanFerry.LegDuration
	end

	local dock = FlyingDutchmanFerry.GetDock(attribute2, instance)

	if not dock then
		return nil, nil
	end

	local v2 = (p - attribute3) / attribute4
	return FlyingDutchmanFerry.GetLegCFrame(dock, attribute, v2, p), v2
end

function FlyingDutchmanFerry.IsSeatedOnShip(instance, ancestor)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local seatPart = humanoid and humanoid.SeatPart
	return seatPart ~= nil and seatPart:IsDescendantOf(ancestor)
end

function FlyingDutchmanFerry.GetRiders(instance)
	local result = {}
	local hitBox = instance:FindFirstChild("HitBox")
	local cFrame, size

	if hitBox and hitBox:IsA("BasePart") then
		cFrame = hitBox.CFrame
		size = hitBox.Size
	else
		cFrame, size = instance:GetBoundingBox()
	end

	local midpoint = (size + createVector(4, 8, 4)) / 2

	for _, v3 in Players:GetPlayers() do
		local character = v3.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not (character and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			continue
		end

		if FlyingDutchmanFerry.IsSeatedOnShip(character, instance) then
			table.insert(result, v3)
		else
			local pointToObjectSpace = cFrame:PointToObjectSpace(humanoidRootPart.Position)

			if math.abs(pointToObjectSpace.X) <= midpoint.X and math.abs(pointToObjectSpace.Y) <= midpoint.Y and math.abs(pointToObjectSpace.Z) <= midpoint.Z then
				table.insert(result, v3)
			end
		end
	end

	return result
end

function FlyingDutchmanFerry.FindDemoShip()
	local workspace2 = workspace

	for _, childName in FlyingDutchmanFerry.DEMO_PATH do
		workspace2 = workspace2 and workspace2:FindFirstChild(childName)
	end

	if workspace2 and workspace2:IsA("Model") then
		return workspace2
	end

	return nil
end

function FlyingDutchmanFerry.FindShips()
	local result = {}

	for _, model in CollectionService:GetTagged(FlyingDutchmanFerry.SHIP_TAG) do
		if model:IsA("Model") and model:IsDescendantOf(workspace) then
			table.insert(result, model)
		end
	end

	local v2 = #result == 0 and FlyingDutchmanFerry.FindDemoShip()

	if v2 then
		table.insert(result, v2)
	end

	return result
end

return FlyingDutchmanFerry