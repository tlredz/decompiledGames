local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local places = workspace.Places

-- equivalent calls inferred from this helper; original call sites unknown
local function getCurrentPlace()
	return localPlayer:GetAttribute("CurrentInternalMap")
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function isValidPlaceNumber(placeNumberFromPosition: number)
	return placeNumberFromPosition >= 1 and placeNumberFromPosition <= 25
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPlaceNumberFromName(currentPlace: string)
	return (tonumber(currentPlace:match("%d+")))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPositionFromPlaceNumber(placeNumberFromName: number)
	local v = math.ceil(placeNumberFromName / 5)
	local v2 = placeNumberFromName - (v - 1) * 5
	return Vector2.new(v2, v)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPlaceNumberFromPosition(point: Vector2)
	return 5 * (point.Y - 1) + point.X
end

local function getNeighboringPlaces()
	local currentPlace = getCurrentPlace() -- equivalent call inferred; original call site unknown

	if not currentPlace then
		return nil
	end

	local placeNumberFromName = getPlaceNumberFromName(currentPlace) -- equivalent call inferred; original call site unknown
	local positionFromPlaceNumber = getPositionFromPlaceNumber(placeNumberFromName) -- equivalent call inferred; original call site unknown
	local placeNumberFromPositions = {}

	for i = -1, 1 do
		for i2 = -1, 1 do
			local placeNumberFromPosition = getPlaceNumberFromPosition(positionFromPlaceNumber + Vector2.new(i, i2)) -- equivalent call inferred; original call site unknown

			if isValidPlaceNumber(placeNumberFromPosition) then
				table.insert(placeNumberFromPositions, placeNumberFromPosition)
			end
		end
	end

	return placeNumberFromPositions
end

local function makePlaceVisible(i: number, visible: boolean)
	local child = places:FindFirstChild((`Place{i}`))

	if child then
		if child:GetAttribute("Visible") == visible then
			return
		end

		if not child:GetAttribute("PlaceDefaultCFrame") then
			child:SetAttribute("PlaceDefaultCFrame", child:GetPivot())
		end

		child:SetAttribute("Visible", visible)
		local placeDefaultCFrame = child:GetAttribute("PlaceDefaultCFrame")
		child:PivotTo(visible and placeDefaultCFrame or placeDefaultCFrame + createVector(0, 50000, 0))
	end
end

local function update()
	local neighboringPlaces = getNeighboringPlaces()

	if neighboringPlaces then
		for i = 1, 25 do
			makePlaceVisible(i, table.find(neighboringPlaces, i) and true or false)
		end
	else
		for i = 1, 25 do
			makePlaceVisible(i, true)
		end
	end
end

local v = {}

for i = 1, 5 do
	v[i] = {}

	for i2 = 1, 5 do
		local v2 = v[i]
		v2[i2] = getPlaceNumberFromPosition(Vector2.new(i, i2))
	end
end

update()
localPlayer:GetAttributeChangedSignal("CurrentInternalMap"):Connect(update)