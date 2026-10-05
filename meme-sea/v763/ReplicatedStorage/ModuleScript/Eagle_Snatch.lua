local createVector = vector.create
local EagleSnatch = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local visuals = workspace:WaitForChild("Visuals")
local visualFX = ReplicatedStorage:WaitForChild("VisualFX")
local sound_Effect = ReplicatedStorage:WaitForChild("Sound_Effect")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local PlaySound = require(moduleScript:WaitForChild("PlaySound"))
local eagle = visualFX:WaitForChild("Eagle")
local bomb = sound_Effect:WaitForChild("Bomb")
local v = {
	Glide = {
		Base = 0.4,
		Amp = 0.06,
		Freq = 0.8
	},
	Flap = {
		Base = 0.42,
		Amp = 0.42,
		Freq = 3.5
	},
	Tuck = {
		Base = 0.84,
		Amp = 0,
		Freq = 0
	},
	Hover = {
		Base = 0.42,
		Amp = 0.42,
		Freq = 2.5
	}
}
local v2 = { createVector(1, 0, 0), createVector(1, 1, 1), createVector(0, 0, 1) }
local tweenInfo = TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v3 = {}
local v4 = false
local v5 = {}
local v6 = false
local controls = nil
EagleSnatch.Scale = 3
EagleSnatch.Lead = 0.3
EagleSnatch.Vehicle_Tag = "Eagle_Vehicle"
local v7 = createVector(0, 5.5, -1.16) * EagleSnatch.Scale
local v8 = v7.Y - 0.07000000029802322
local H0 = -v7.Z - -1.0499999523162842

-- equivalent calls inferred from this helper; original call sites unknown
local function Horizontal(p: number)
	return (Vector3.new(math.cos(p), 0, (math.sin(p))))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Hold_CFrame(cframe: CFrame)
	local pointToWorldSpace = cframe:PointToWorldSpace(v7)
	local v10 = cframe.UpVector * createVector(1, 0, 1)

	if v10.Magnitude < 0.01 then
		return (CFrame.new(pointToWorldSpace))
	end

	return (CFrame.lookAt(pointToWorldSpace, pointToWorldSpace + v10.Unit))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Hold_Position(cframe: CFrame)
	local cframe2 = Hold_CFrame(cframe) -- equivalent call inferred; original call site unknown
	return cframe2:PointToWorldSpace(createVector(0, -1.05, 0.07))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Bezier(data, p: number)
	local v10 = 1 - p
	return data.P0 * (v10 * v10 * v10) + data.P1 * (v10 * 3 * v10 * p) + data.P2 * (v10 * 3 * p * p) + data.P3 * (p * p * p)
end

local function Segment_Position(data, p: number)
	if data.Kind == "Bezier" then
		return Bezier(data, p)
	end

	if data.Kind == "Orbit" then
		local v10 = data.A0 + (data.A1 - data.A0) * p
		return data.Center + Vector3.new(math.cos(v10), 0, (math.sin(v10))) * data.Radius + createVector(0, 1, 0) * (data.H0 + (data.H1 - data.H0) * p)
	end

	if data.Kind == "Helix" then
		local v10 = data.A0 + data.Turn * p
		local v11 = 1 - (1 - p) * (1 - p)
		local v12 = data.Radius * math.sin(p * 3.141592653589793 / 2)
		return data.Center + Vector3.new(math.cos(v10), 0, (math.sin(v10))) * v12 + createVector(0, 1, 0) * (data.H0 + (data.H1 - data.H0) * v11)
	elseif data.Kind == "Line" then
		return data.P0 + data.Velocity * (p * data.Duration)
	else
		return data.P0 + createVector(0, 1, 0) * (math.sin(p * 3.141592653589793 * 2) * 0.8)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Add_Segment(state, p, duration: number)
	p.Start = state.Time
	p.Duration = duration
	table.insert(state.Segments, p)
	state.Time += duration
end

local function Find_Segment(p, p2: number)
	local segments = p.Segments

	if p2 <= 0 then
		return segments[1], 0
	end

	for _, segment in ipairs(segments) do
		if p2 < segment.Start + segment.Duration then
			return segment, (p2 - segment.Start) / segment.Duration
		end
	end

	local segment = segments[#segments]
	return segment, (p2 - segment.Start) / segment.Duration
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Fall_Time(p: number)
	return (math.max(0.3, (math.sqrt(math.max(p, 0) * 2 / 196.2))))
end

local function Add_Swoop(state, vector2: Vector3, vector3: Vector3)
	local P0 = vector2 - vector3 * 240 + createVector(0, 130, 0)
	local v11 = {
		Kind = "Bezier",
		Wing = "Tuck",
		P0 = P0,
		P1 = P0 + vector3 * 70 - createVector(0, 25, 0),
		P2 = vector2 - vector3 * 60,
		P3 = vector2,
		Start = state.Time,
		Duration = 1.2
	}
	table.insert(state.Segments, v11)
	state.Time += 1.2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Add_Settle(state, vector2: Vector3, vector3: Vector3, vector4: Vector3)
	local v10 = {
		Kind = "Bezier",
		Wing = "Hover",
		Face = vector4,
		P0 = vector2,
		P1 = vector2 + vector4 * 10.666666666666666,
		P2 = vector3 - vector4 * 2.5 + createVector(0, 0.5, 0),
		P3 = vector3,
		Start = state.Time,
		Duration = 0.8
	}
	table.insert(state.Segments, v10)
	state.Time += 0.8
end

local function Add_Arrival(state, impact_Position: Vector3, vector2: Vector3, vector3: Vector3, unit: Vector3)
	state.Release = state.Time
	state.Impact_Time = state.Time
	state.Impact_Position = impact_Position
	state.Arrive = CFrame.lookAt(impact_Position, (Vector3.new(vector2.X, impact_Position.Y, vector2.Z)))
	local v10 = {
		Kind = "Bezier",
		Wing = "Flap",
		P0 = vector3,
		P1 = vector3 + unit * 8 + createVector(0, 8, 0),
		P2 = vector3 + unit * 90 + createVector(0, 50, 0),
		P3 = vector3 + unit * 240 + createVector(0, 110, 0),
		Start = state.Time,
		Duration = 3
	}
	table.insert(state.Segments, v10)
	state.Time += 3
	state.End_Time = state.Time
end

local function Build_Cruise(state, p)
	local origin = p.Origin
	local horizontal = Horizontal(p.Angle) -- equivalent call inferred; original call site unknown
	local P0 = origin + createVector(0, 1, 0) * H0 - horizontal * v8
	Add_Swoop(state, P0, horizontal)
	state.Grab_Time = state.Time
	local v12 = P0 + horizontal * 420 + createVector(0, 1, 0) * (135 - H0)
	local P02 = v12 + horizontal * 260 * 3
	local v14 = {
		Kind = "Bezier",
		Wing = "Flap",
		P0 = P0,
		P1 = P0 + horizontal * 100,
		P2 = v12 - horizontal * 173.33333333333334,
		P3 = v12,
		Start = state.Time,
		Duration = 2
	}
	table.insert(state.Segments, v14)
	state.Time += 2
	local v15 = {
		Kind = "Line",
		Wing = "Glide",
		P0 = v12,
		Velocity = horizontal * 260,
		Start = state.Time,
		Duration = 3
	}
	table.insert(state.Segments, v15)
	state.Time += 3
	state.Release = state.Time
	state.Drop_From = P02 + horizontal * v8 - createVector(0, 1, 0) * H0
	state.Drop_Drift = horizontal * 260
	local v16 = {
		Kind = "Bezier",
		Wing = "Flap",
		P0 = P02,
		P1 = P02 + horizontal * 260,
		P2 = P02 + horizontal * 514.8000000000001 + createVector(0, 40, 0),
		P3 = P02 + horizontal * 780 + createVector(0, 90, 0),
		Start = state.Time,
		Duration = 3
	}
	table.insert(state.Segments, v16)
	state.Time += 3
	state.Screech = { 0, state.Grab_Time, state.Release }
end

local function Build_Travel(state, data)
	local origin = data.Origin
	local destination = data.Destination
	local v10 = (destination - origin) * createVector(1, 0, 1)
	local unit

	if v10.Magnitude > 1 then
		unit = v10.Unit
	else
		local angle = data.Angle
		unit = Vector3.new(math.cos(angle), 0, (math.sin(angle)))
	end

	local P0 = origin + createVector(0, 1, 0) * H0 - unit * v8
	Add_Swoop(state, P0, unit)
	state.Grab_Time = state.Time
	local v12 = destination + createVector(0, 1, 0) * H0 - unit * v8
	local P3 = v12 - unit * 30 + createVector(0, 8, 0)
	local v14 = (P3 - P0) * createVector(0.5, 0, 0.5)
	local vector2 = Vector3.new(P0.X + v14.X, math.max(P0.Y, P3.Y) + math.min(400, v14.Magnitude * 0.35), P0.Z + v14.Z)
	local v15 = v14.Magnitude * 0.3
	local v16 = math.clamp(v14.Magnitude * 2 / 600, math.min(3, v15 * 6 / 150), 8)
	local v17 = v14.Magnitude * 0.6
	Add_Segment(state, {
		Kind = "Bezier",
		Wing = "Flap",
		P0 = P0,
		P1 = P0 + unit * math.min(v16 * 150 / 6, v15),
		P2 = vector2 - unit * v17,
		P3 = vector2
	}, v16 / 2) -- equivalent call inferred; original call site unknown
	Add_Segment(state, {
		Kind = "Bezier",
		Wing = "Glide",
		P0 = vector2,
		P1 = vector2 + unit * v17,
		P2 = P3 - unit * math.min(v16 * 40 / 6, v15),
		P3 = P3
	}, v16 / 2) -- equivalent call inferred; original call site unknown
	Add_Settle(state, P3, v12, unit) -- equivalent call inferred; original call site unknown
	Add_Arrival(state, destination, data.Look_At or destination + unit, v12, unit)
	state.Screech = { 0, state.Grab_Time }
end

local function Build_Tour(state, data)
	local origin = data.Origin
	local stops = data.Stops
	local v10 = (stops[1] - origin) * createVector(1, 0, 1)
	local unit

	if v10.Magnitude > 1 then
		unit = v10.Unit
	else
		local angle = data.Angle
		unit = Vector3.new(math.cos(angle), 0, (math.sin(angle)))
	end

	local P3 = origin + createVector(0, 1, 0) * H0 - unit * v8
	Add_Swoop(state, P3, unit)
	state.Grab_Time = state.Time
	local v12 = (origin - stops[#stops]) * createVector(1, 0, 1)
	local unit2

	if v12.Magnitude > 1 then
		unit2 = v12.Unit
	else
		unit2 = unit
	end

	local v13 = origin + createVector(0, 1, 0) * H0 - unit2 * v8
	local P0 = v13 - unit2 * 30 + createVector(0, 8, 0)
	local v15 = { P3 }

	for _, stop in ipairs(stops) do
		table.insert(v15, stop + createVector(0, 250, 0))
	end

	table.insert(v15, P0)
	local v16 = { unit * 150 }

	for i = 2, #v15 - 1 do
		v16[i] = (v15[i + 1] - v15[i - 1]).Unit * 900
	end

	v16[#v15] = unit2 * 40

	for i = 1, #v15 - 1 do
		local duration = (v15[i + 1] - v15[i]).Magnitude * 2 / (v16[i].Magnitude + v16[i + 1].Magnitude)
		local v18 = {
			Kind = "Bezier",
			Wing = i == 1 and "Flap" or "Glide",
			P0 = v15[i],
			P1 = v15[i] + v16[i] * (duration / 3),
			P2 = v15[i + 1] - v16[i + 1] * (duration / 3),
			P3 = v15[i + 1],
			Start = state.Time,
			Duration = duration
		}
		table.insert(state.Segments, v18)
		state.Time += duration
	end

	Add_Settle(state, P0, v13, unit2) -- equivalent call inferred; original call site unknown
	Add_Arrival(state, origin, origin + unit2, v13, unit2)
	state.Screech = { 0, state.Grab_Time }
end

local function Build_Gift(state, p)
	local horizontal = Horizontal(p.Angle) -- equivalent call inferred; original call site unknown
	local P0 = p.Drop - horizontal * v7.Y - createVector(0, 1, 0) * v7.Z
	Add_Swoop(state, P0, horizontal)
	state.Drop_Time = state.Time
	state.Grab_Time = 1e999
	state.Impact_Time = 1e999
	local v12 = {
		Kind = "Bezier",
		Wing = "Flap",
		P0 = P0,
		P1 = P0 + horizontal * 125,
		P2 = P0 + horizontal * 230 + createVector(0, 50, 0),
		P3 = P0 + horizontal * 400 + createVector(0, 130, 0),
		Start = state.Time,
		Duration = 2.5
	}
	table.insert(state.Segments, v12)
	state.Time += 2.5
	state.End_Time = state.Time
	state.Screech = { 0 }
end

local function Build_Show(player, i: number)
	local horizontal = Horizontal(player.Angle) -- equivalent call inferred; original call site unknown
	local vector2 = Vector3.new(-horizontal.Z, 0, horizontal.X)
	local v11 = i // 2
	local v12 = {
		Segments = {},
		Fakes = {},
		Time = 0,
		Grab_Time = 1e999,
		Impact_Time = 1e999
	}
	local v14 = player.Origin - horizontal * (v11 * 28 + 900)

	if i % 2 ~= 0 then
		v11 = -v11
	end

	Add_Segment(v12, {
		Kind = "Line",
		Wing = "Flap",
		P0 = v14 + vector2 * v11 * 34 + createVector(0, 120, 0),
		Velocity = horizontal * 220
	}, 8.181818181818182) -- equivalent call inferred; original call site unknown
	v12.End_Time = v12.Time
	v12.Screech = i == 1 and { 0, v12.Time / 2 } or {}
	return v12
end

local function Add_Fake(state, origin: Vector3, p: number)
	local eagle_Position = EagleSnatch.Eagle_Position(state, state.Time)
	local drift = (eagle_Position - EagleSnatch.Eagle_Position(state, state.Time - 0.016666666666666666)) / 0.016666666666666666 * createVector(
		1,
		0,
		1
	)
	local unit = drift.Unit
	local cframe = Hold_Position(EagleSnatch.Eagle_CFrame(state, state.Time - 0.03333333333333333)) -- equivalent call inferred; original call site unknown
	local duration = Fall_Time(cframe.Y - (origin.Y + p)) -- equivalent call inferred; original call site unknown
	local P3 = Vector3.new(cframe.X, origin.Y + p, cframe.Z) + drift * duration + createVector(0, 1, 0) * H0 - unit * v8
	local v13 = {
		Release = state.Time,
		From = cframe,
		Drift = drift
	}
	local v14 = {
		Kind = "Bezier",
		Wing = "Tuck",
		P0 = eagle_Position,
		P1 = eagle_Position + unit * 16 + createVector(0, 14, 0),
		P2 = P3 - unit * 22,
		P3 = P3,
		Start = state.Time,
		Duration = duration
	}
	table.insert(state.Segments, v14)
	state.Time += duration
	v13.Catch = state.Time
	table.insert(state.Fakes, v13)
	return P3, unit
end

local function Build_Troll(state, p)
	local origin = p.Origin
	local angle = p.Angle
	local P3 = origin + Vector3.new(math.cos(angle), 0, (math.sin(angle))) * 26 + createVector(0, 30, 0)
	local horizontal = Horizontal(angle + 1.5707963267948966) -- equivalent call inferred; original call site unknown
	local v13 = angle - 0.9
	local P0 = origin + Vector3.new(math.cos(v13), 0, (math.sin(v13))) * 170 + createVector(0, 80, 0)
	local lerped = P0:Lerp(P3, 0.45)
	local v16 = angle - 0.9 + 1.5707963267948966
	Add_Segment(state, {
		Kind = "Bezier",
		Wing = "Glide",
		P0 = P0,
		P1 = lerped + Vector3.new(math.cos(v16), 0, (math.sin(v16))) * 45 + createVector(0, 20, 0),
		P2 = P3 - horizontal * 26 * 1.2 + createVector(0, 4, 0),
		P3 = P3
	}, 1.7) -- equivalent call inferred; original call site unknown
	local A1 = angle + 4.084070449666731
	local v18 = {
		Kind = "Orbit",
		Wing = "Glide",
		Center = origin,
		Radius = 26,
		A0 = angle,
		A1 = A1,
		H0 = 30,
		H1 = 24,
		Start = state.Time,
		Duration = 1.6
	}
	table.insert(state.Segments, v18)
	state.Time += 1.6
	local P02 = origin + Vector3.new(math.cos(A1), 0, (math.sin(A1))) * 26 + createVector(0, 24, 0)
	local v20 = A1 + 1.5707963267948966
	local P1 = P02 + Vector3.new(math.cos(v20), 0, (math.sin(v20))) * 18 - createVector(0, 8, 0)
	local v22 = (origin - P1) * createVector(1, 0, 1)
	local unit

	if v22.Magnitude > 0.01 then
		unit = v22.Unit
	else
		unit = Vector3.new(math.cos(angle), 0, (math.sin(angle)))
	end

	local P32 = origin + createVector(0, 1, 0) * H0 - unit * v8
	local v24 = {
		Kind = "Bezier",
		Wing = "Tuck",
		P0 = P02,
		P1 = P1,
		P2 = P32 - unit * 18,
		P3 = P32,
		Start = state.Time,
		Duration = 0.85
	}
	table.insert(state.Segments, v24)
	state.Time += 0.85
	state.Grab_Time = state.Time
	local v25 = {
		Kind = "Helix",
		Wing = "Flap",
		Center = origin - unit * v8,
		Radius = 14,
		A0 = math.atan2(unit.Z, unit.X),
		Turn = 6.911503837897546,
		H0 = H0,
		H1 = 80,
		Start = state.Time,
		Duration = 2
	}
	table.insert(state.Segments, v25)
	state.Time += 2
	local P03, v27 = Add_Fake(state, origin, 7)
	local vector2 = Vector3.new(-v27.Z, 0, v27.X)
	local P33 = P03 + v27 * 60 + vector2 * 45 + createVector(0, 60, 0)
	local v29 = {
		Kind = "Bezier",
		Wing = "Flap",
		P0 = P03,
		P1 = P03 + v27 * 37,
		P2 = P33 - vector2 * 35,
		P3 = P33,
		Start = state.Time,
		Duration = 1.4
	}
	table.insert(state.Segments, v29)
	state.Time += 1.4
	local P04, v31 = Add_Fake(state, origin, 2)
	local face = -v31
	local v33 = origin + createVector(0, 1, 0) * H0 - face * v8
	local P34 = v33 - face * 30 + createVector(0, 8, 0)
	local v35 = {
		Kind = "Bezier",
		Wing = "Glide",
		P0 = P04,
		P1 = P04 + v31 * 43 + createVector(0, 14, 0),
		P2 = P34 - face * 21.333333333333332,
		P3 = P34,
		Start = state.Time,
		Duration = 1.6
	}
	table.insert(state.Segments, v35)
	state.Time += 1.6
	Add_Settle(state, P34, v33, face) -- equivalent call inferred; original call site unknown
	local v36 = v33 - face * 14 + createVector(0, 16, 0)
	state.Rest = {
		Start = state.Time,
		CFrame = CFrame.lookAt(origin, origin + face)
	}
	local v37 = {
		Kind = "Bezier",
		Wing = "Hover",
		Face = face,
		P0 = v33,
		P1 = v33 + createVector(0, 5, 0),
		P2 = v36 - createVector(0, 3, 0),
		P3 = v36,
		Start = state.Time,
		Duration = 0.5
	}
	table.insert(state.Segments, v37)
	state.Time += 0.5
	local v38 = {
		Kind = "Hover",
		Wing = "Hover",
		P0 = v36,
		Face = face,
		Start = state.Time,
		Duration = 0.5
	}
	table.insert(state.Segments, v38)
	state.Time += 0.5
	state.Regrab_Time = state.Time
	local v39 = {
		Kind = "Bezier",
		Wing = "Tuck",
		Face = face,
		P0 = v36,
		P1 = v36 - createVector(0, 6, 0),
		P2 = v33 - face * 10,
		P3 = v33,
		Start = state.Time,
		Duration = 0.35
	}
	table.insert(state.Segments, v39)
	state.Time += 0.35
	state.Rest.End = state.Time
	local v40 = origin + createVector(0, 105, 0) + face * v8
	local v41 = {
		Kind = "Bezier",
		Wing = "Flap",
		P0 = v33,
		P1 = v33 + face * 43,
		P2 = v40 + face * 45 + createVector(0, 5, 0),
		P3 = v40,
		Start = state.Time,
		Duration = 1.5
	}
	table.insert(state.Segments, v41)
	state.Time += 1.5
	state.Stare_Time = state.Time
	local v42 = {
		Kind = "Hover",
		Wing = "Hover",
		P0 = v40,
		Face = -face,
		Start = state.Time,
		Duration = 0.9
	}
	table.insert(state.Segments, v42)
	state.Time += 0.9
	local A0 = math.atan2(-face.Z, -face.X)
	local v44 = {
		Kind = "Spin",
		Wing = "Glide",
		P0 = v40,
		A0 = A0,
		Turn = 16.8,
		Start = state.Time,
		Duration = 2.4
	}
	table.insert(state.Segments, v44)
	state.Time += 2.4
	local horizontal2 = Horizontal(A0 + 16.8) -- equivalent call inferred; original call site unknown
	state.Release = state.Time
	state.Drop_From = Hold_Position(EagleSnatch.Eagle_CFrame(state, state.Time))
	local v47 = A0 + 16.8 + 1.5707963267948966
	state.Drop_Drift = Vector3.new(math.cos(v47), 0, (math.sin(v47))) * (14.000000000000002 * v8)
	local v48 = {
		Kind = "Bezier",
		Wing = "Flap",
		P0 = v40,
		P1 = v40 + horizontal2 * 10 + createVector(0, 16, 0),
		P2 = v40 + horizontal2 * 110 + createVector(0, 45, 0),
		P3 = v40 + horizontal2 * 260 + createVector(0, 95, 0),
		Start = state.Time,
		Duration = 3
	}
	table.insert(state.Segments, v48)
	state.Time += 3
	state.Screech = {
		0,
		state.Grab_Time,
		state.Regrab_Time,
		state.Stare_Time
	}
end

function EagleSnatch.Drop_Position(p, p2: number)
	return p.Drop_From + p.Drop_Drift * p2 - createVector(0, 1, 0) * (p2 * 98.1 * p2)
end

function EagleSnatch:Set_Fall(p: number)
	self.Impact_Time = self.Release + p
	self.Impact_Position = EagleSnatch.Drop_Position(self, p)
	self.End_Time = math.max(self.Time, self.Impact_Time + 1.5)
end

local v10 = {
	Troll = Build_Troll,
	Cruise = Build_Cruise,
	Travel = Build_Travel,
	Tour = Build_Tour,
	Gift = Build_Gift
}

function EagleSnatch.Build(p)
	local v11 = {
		Segments = {},
		Fakes = {},
		Time = 0
	}
	v10[p.Pattern](v11, p)

	if p.Fall then
		EagleSnatch.Set_Fall(v11, p.Fall)
	end

	return v11
end

EagleSnatch.Build_Show = Build_Show

function EagleSnatch.Eagle_Position(p, p2: number)
	local v11, v12 = Find_Segment(p, p2)
	return (Segment_Position(v11, v12))
end

function EagleSnatch.Eagle_CFrame(p, p2: number)
	local v11, v12 = Find_Segment(p, p2)
	local vector2

	if v11.Kind == "Spin" then
		local v13 = v11.A0 + v11.Turn * v12 * v12
		vector2 = Vector3.new(math.cos(v13), 0, (math.sin(v13)))
	else
		vector2 = v11.Face
	end

	local eagle_Position = EagleSnatch.Eagle_Position(p, p2)
	local eagle_Position2 = EagleSnatch.Eagle_Position(p, p2 + 0.016666666666666666)
	local eagle_Position3 = EagleSnatch.Eagle_Position(p, p2 - 0.016666666666666666)
	local v13 = (eagle_Position2 - eagle_Position3) / 0.03333333333333333
	local segment = p.Segments[1]
	local unit

	if vector2 then
		unit = vector2
	elseif v13.Magnitude > 1 then
		unit = v13.Unit
	else
		unit = segment.Velocity or segment.P3 - segment.P0
	end

	local unit2 = unit.Unit
	local vector3 = vector2 and createVector(0, 0, 0) or (eagle_Position2 - eagle_Position * 2 + eagle_Position3) / 0.0002777777777777778
	local v14 = createVector(0, 1, 0) - unit2 * (createVector(0, 1, 0)):Dot(unit2)

	if v14.Magnitude < 0.2 then
		local A0 = v11.A0 or 0
		local horizontal = Horizontal(A0) -- equivalent call inferred; original call site unknown
		local A02 = v11.A0 or 0
		v14 = horizontal - unit2 * Vector3.new(math.cos(A02), 0, (math.sin(A02))):Dot(unit2)
	end

	local unit3 = v14.Unit
	local cross = unit2:Cross(unit3)
	local v15 = math.clamp(math.atan2(vector3:Dot(cross), 196.2), -1.1344640137963142, 1.1344640137963142)
	local v16 = unit3 * math.cos(v15) + cross * math.sin(v15)
	return CFrame.fromMatrix(eagle_Position, unit2:Cross(v16), unit2, v16)
end

function EagleSnatch.Target_CFrame(data, p: number, cframe: CFrame?)
	if p < data.Grab_Time or data.Impact_Time <= p then
		return nil, nil
	end

	if data.Release <= p then
		local v11 = p - data.Release
		return CFrame.new(EagleSnatch.Drop_Position(data, v11)) * CFrame.Angles(v11 * 7, v11 * 2, v11 * 4), "Drop"
	end

	for _, fake in ipairs(data.Fakes) do
		if not (fake.Release <= p and p < fake.Catch) then
			continue
		end

		local v11 = p - fake.Release
		return
			CFrame.new(fake.From + fake.Drift * v11 - createVector(0, 1, 0) * (98.1 * v11 * v11)) * CFrame.Angles(
				v11 * 7,
				v11 * 2,
				v11 * 4
			),
			"Fake_Drop"
	end

	if data.Rest and data.Rest.Start <= p and p < data.Rest.End then
		return data.Rest.CFrame, "Rest"
	end

	local v11, v12 = Find_Segment(data, p)
	local v13

	if v11.Kind == "Spin" then
		local v14 = 2 * v11.Turn * v12 / v11.Duration
		v13 = math.atan(v14 * v14 * v8 / 196.2)
	else
		v13 = 0
	end

	local cframe2 = CFrame.Angles(math.sin(p * 6) * 0.12 + v13, 0, math.sin(p * 4.3) * 0.08)
	local hold_CFrame = Hold_CFrame(cframe or EagleSnatch.Eagle_CFrame(data, p)) -- equivalent call inferred; original call site unknown
	return hold_CFrame * cframe2 * CFrame.new(createVector(0, -1.05, 0.07)), "Held"
end

local function Explode(impact_Position: Vector3)
	local explosion = Instance.new("Explosion")
	explosion.Position = impact_Position
	explosion.BlastRadius = 6
	explosion.BlastPressure = 0
	explosion.DestroyJointRadiusPercent = 0
	explosion.ExplosionType = Enum.ExplosionType.NoCraters
	explosion.Parent = visuals
	task.delay(2, game.Destroy, explosion)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.Position = impact_Position
	part.Parent = visuals
	PlaySound.PlaySound_RootPart(part, bomb)
	task.delay(3, game.Destroy, part)
end

local function Burst_Stars(impact_Position: Vector3)
	for i = 1, 9 do
		local v11 = i / 9 * 2 * 3.141592653589793
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Size = createVector(2, 2, 0.4)
		part.CFrame = CFrame.new(impact_Position) * CFrame.Angles(0, v11, 0)
		local specialMesh = Instance.new("SpecialMesh")
		specialMesh.MeshType = Enum.MeshType.FileMesh
		specialMesh.MeshId = "rbxassetid://120647846"
		specialMesh.TextureId = "rbxassetid://120647378"
		specialMesh.Scale = createVector(2, 2, 2)
		specialMesh.VertexColor = v2[(i - 1) % #v2 + 1]
		specialMesh.Parent = part
		part.Parent = visuals
		TweenService:Create(part, tweenInfo, {
			CFrame = CFrame.new(impact_Position + Vector3.new(math.cos(v11), 0, (math.sin(v11))) * 14 + Vector3.new(
				0,
				6 + math.random() * 6,
				0
			)) * CFrame.Angles(0, v11 + 3.141592653589793, math.random() * 2 * 3.141592653589793),
			Transparency = 1
		}):Play()
		task.delay(tweenInfo.Time, game.Destroy, part)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Set_Wings(data, p: number)
	data.Left_Weld.C1 = data.Left_C1 * CFrame.Angles(0, -p, 0)
	data.Right_Weld.C1 = data.Right_C1 * CFrame.Angles(0, p, 0)
end

local function Update_Wings(state, p: string, p2: number)
	local v11 = v[p] or v.Glide
	local v12 = 1 - math.exp(-p2 * 14)
	state.Wing_Base += (v11.Base - state.Wing_Base) * v12
	state.Wing_Amp += (v11.Amp - state.Wing_Amp) * v12
	state.Wing_Freq += (v11.Freq - state.Wing_Freq) * v12
	state.Wing_Phase += p2 * state.Wing_Freq * 2 * 3.141592653589793
	Set_Wings(state, state.Wing_Base + state.Wing_Amp * math.sin(state.Wing_Phase)) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function End_Snatch(instance)
	if instance.Eagle then
		instance.Eagle:Destroy()
		instance.Eagle = nil
	end
end

local function Update_Snatch(instance, p: number)
	local plan = instance.Plan
	local blend_Start = workspace:GetServerTimeNow() - instance.Start

	if plan.End_Time < blend_Start or not instance.Eagle then
		End_Snatch(instance) -- equivalent call inferred; original call site unknown
		return false
	else
		local find_Segment = Find_Segment(plan, blend_Start)
		local eagle_CFrame = EagleSnatch.Eagle_CFrame(plan, blend_Start)
		local v13 = find_Segment.Kind == "Spin" and 1 or 1 - math.exp(-p * 10)
		instance.Rotation = instance.Rotation:Lerp(eagle_CFrame.Rotation, v13)
		instance.Torso.CFrame = CFrame.new(eagle_CFrame.Position) * instance.Rotation
		Update_Wings(instance, find_Segment.Wing, p)
		local gift = instance.Gift

		if gift and blend_Start < plan.Drop_Time then
			gift.CFrame = instance.Torso.CFrame * CFrame.new(v7)
		elseif gift then
			gift:Destroy()
			instance.Gift = nil
		end

		while instance.Screech_Index <= #plan.Screech and plan.Screech[instance.Screech_Index] <= blend_Start do
			instance.Sound:Play()
			instance.Screech_Index += 1
		end

		local root = instance.Root
		local target_CFrame, target_Phase = EagleSnatch.Target_CFrame(plan, blend_Start, instance.Torso.CFrame)

		if target_CFrame and root and root.Parent and root.Anchored then
			if target_Phase ~= instance.Target_Phase then
				instance.Target_Phase = target_Phase
				instance.Blend_From = root.CFrame
				instance.Blend_Start = blend_Start

				if target_Phase == "Rest" and instance.Humanoid then
					instance.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
				end
			end

			local v15 = (blend_Start - instance.Blend_Start) / 0.2

			if v15 < 1 then
				target_CFrame = instance.Blend_From:Lerp(target_CFrame, v15)
			end

			root.CFrame = target_CFrame
		end

		if not instance.Impacted and plan.Impact_Time <= blend_Start then
			instance.Impacted = true

			if not plan.Arrive then
				Explode(plan.Impact_Position)
				Burst_Stars(plan.Impact_Position)
			end
		end

		return true
	end
end

local function Step(p: number)
	for i = #v3, 1, -1 do
		if not Update_Snatch(v3[i], p) then
			table.remove(v3, i)
		end
	end

	if #v3 == 0 and v4 then
		v4 = false
		RunService:UnbindFromRenderStep("Eagle_Snatch")
	end
end

local function Update_Ride(state, p: number)
	if not state.Eagle.Parent then
		return false
	end

	local occupant = state.Seat.Occupant
	local driving

	if occupant == nil then
		driving = false
	else
		driving = occupant.Parent == Players.LocalPlayer.Character
	end

	if driving then
		if not controls then
			local PlayerModule = require(Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
			controls = PlayerModule:GetControls()
		end

		if not state.Driving then
			local upVector = state.Torso.CFrame.UpVector
			state.Yaw = math.atan2(-upVector.X, -upVector.Z)
			state.Pitch = 0
		end

		local vectorVelocity = workspace.CurrentCamera.CFrame:VectorToWorldSpace(controls:GetMoveVector()) * 160
		local v13 = 1 - math.exp(-p * 8)

		if vectorVelocity.X ^ 2 + vectorVelocity.Z ^ 2 > 1 then
			state.Yaw += ((math.atan2(-vectorVelocity.X, -vectorVelocity.Z) - state.Yaw + 3.141592653589793) % 6.283185307179586 - 3.141592653589793) * v13
		end

		state.Pitch += (vectorVelocity.Y / 160 * 0.5 - state.Pitch) * v13
		state.Drive.VectorVelocity = vectorVelocity
		state.Steer.CFrame = CFrame.Angles(0, state.Yaw, 0) * CFrame.Angles(state.Pitch, 0, 0)
	elseif state.Driving then
		state.Drive.VectorVelocity = createVector(0, 0, 0)
	end

	state.Driving = driving
	Update_Wings(state, state.Torso.AssemblyLinearVelocity.Magnitude > 5 and "Flap" or "Hover", p)
	return true
end

local function Ride_Step(p: number)
	for i = #v5, 1, -1 do
		if not Update_Ride(v5[i], p) then
			table.remove(v5, i)
		end
	end

	if #v5 == 0 and v6 then
		v6 = false
		RunService:UnbindFromRenderStep("Eagle_Ride")
	end
end

local function Add_Vehicle(instance)
	local torso = instance:WaitForChild("Torso", 5)
	local driver = instance:WaitForChild("Driver", 5)
	local leftWingWeld

	if torso then
		leftWingWeld = torso:WaitForChild("LeftWingWeld", 5)
	end

	local rightWingWeld

	if torso then
		rightWingWeld = torso:WaitForChild("RightWingWeld", 5)
	end

	local drive

	if torso then
		drive = torso:WaitForChild("Drive", 5)
	end

	local steer

	if torso then
		steer = torso:WaitForChild("Steer", 5)
	end

	if not (driver and leftWingWeld and rightWingWeld and drive and steer) then
		return
	end

	table.insert(v5, {
		Eagle = instance,
		Torso = torso,
		Seat = driver,
		Drive = drive,
		Steer = steer,
		Driving = false,
		Left_Weld = leftWingWeld,
		Right_Weld = rightWingWeld,
		Left_C1 = leftWingWeld.C1,
		Right_C1 = rightWingWeld.C1,
		Wing_Base = 0.4,
		Wing_Amp = 0,
		Wing_Freq = 0,
		Wing_Phase = 0
	})

	if not v6 then
		v6 = true
		RunService:BindToRenderStep("Eagle_Ride", Enum.RenderPriority.Camera.Value - 1, Ride_Step)
	end
end

local function Add_Eagle(plan, player, instance)
	local clone = eagle:Clone()

	for _, seat in ipairs(clone:GetChildren()) do
		if seat:IsA("Seat") then
			seat:Destroy()
		end
	end

	clone:ScaleTo(EagleSnatch.Scale)
	local torso = clone.Torso
	local eagle_CFrame = EagleSnatch.Eagle_CFrame(plan, 0)
	torso.CFrame = eagle_CFrame
	local part

	if plan.Drop_Time then
		part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Material = Enum.Material.Neon
		part.Color = player.Color
		part.Size = createVector(2, 2, 2)
		part.CFrame = eagle_CFrame * CFrame.new(v7)
		part.Parent = clone
	end

	clone.Parent = visuals
	local v12 = {
		Plan = plan,
		Start = player.Start,
		Eagle = clone,
		Torso = torso,
		Gift = part,
		Sound = torso.Sound,
		Left_Weld = torso.LeftWingWeld,
		Right_Weld = torso.RightWingWeld,
		Left_C1 = torso.LeftWingWeld.C1,
		Right_C1 = torso.RightWingWeld.C1,
		Root = 0,
		Humanoid = 0,
		Rotation = 0,
		Wing_Base = 0.4,
		Wing_Amp = 0,
		Wing_Freq = 0,
		Wing_Phase = 0,
		Screech_Index = 1,
		Impacted = false
	}
	local root

	if instance then
		root = instance:FindFirstChild("HumanoidRootPart")
	end

	v12.Root = root
	local humanoid

	if instance and instance == Players.LocalPlayer.Character then
		humanoid = instance:FindFirstChildOfClass("Humanoid")
	end

	v12.Humanoid = humanoid
	v12.Rotation = eagle_CFrame.Rotation
	table.insert(v3, v12)

	if not v4 then
		v4 = true
		RunService:BindToRenderStep("Eagle_Snatch", Enum.RenderPriority.Camera.Value - 1, Step)
	end
end

function EagleSnatch:Play()
	local character = self.Character
	local position = workspace.CurrentCamera.CFrame.Position

	if not ((position - self.Origin).Magnitude <= 1500 or self.Destination and (position - self.Destination).Magnitude <= 1500) and character ~= Players.LocalPlayer.Character then
		return
	end

	if self.Pattern ~= "Show" then
		Add_Eagle(EagleSnatch.Build(self), self, character)
		return
	end

	for i = 1, self.Count do
		Add_Eagle(Build_Show(self, i), self)
	end
end

if RunService:IsClient() then
	CollectionService:GetInstanceAddedSignal(EagleSnatch.Vehicle_Tag):Connect(Add_Vehicle)

	for _, v11 in ipairs(CollectionService:GetTagged(EagleSnatch.Vehicle_Tag)) do
		task.spawn(Add_Vehicle, v11)
	end
end

return EagleSnatch