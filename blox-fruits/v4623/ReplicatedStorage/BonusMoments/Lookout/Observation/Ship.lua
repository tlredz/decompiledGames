local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GetWaterHeightAtLocation = require(ReplicatedStorage.Util.GetWaterHeightAtLocation)
local BoatPresentation = require(script.Parent.Parent.BoatPresentation)
local CharacterPresentation = require(script.Parent.Parent.CharacterPresentation)
require(script.Parent.Parent.Scene)
local Sound = require(ReplicatedStorage.Util.Sound)
local frozen = table.freeze({
	MinimumLaneHalfSpan = 210,
	LaneDepthJitter = 5,
	GrandBrigadeLeftSpawnClearance = 150,
	GrandBrigadeDurationMultiplier = 1.75,
	ShipEdgeMargin = 35,
	WakeSpeedAlpha = 0.7,
	DriverRootHeight = 2,
	SmugglerFaceId = "255535022429711",
	LaneDepthOffsets = {
		-80,
		-20,
		60,
		175
	},
	SailSounds = {
		Dinghy = "MiddleTownSFX.Color_Ship_Sail_By_Loop_Small_01",
		Sloop = "MiddleTownSFX.Color_Ship_Sail_By_Loop_Medium_01",
		Brigade = "MiddleTownSFX.Color_Ship_Sail_By_Loop_Large_01",
		["Grand Brigade"] = "MiddleTownSFX.Color_Ship_Sail_By_Loop_ExtraLarge_01"
	},
	SailSoundRadius = 20,
	LaneSlotOffsets = {
		Dinghy = { -12, 12, 0 },
		Sloop = { -15, 15, 0 },
		Brigade = { -22, 22, 0 },
		["Grand Brigade"] = { -30, 30, 0 }
	}
})
local localPlayer = Players.LocalPlayer
local v = nil
local v2 = {}
local v3 = {}

function v2.startWake(callback, instance, p: number)
	local primaryPart = instance.PrimaryPart

	if not primaryPart then
		return nil, "the rear-water wake has no boat root"
	end

	local boundingBox, v4 = instance:GetBoundingBox()
	local Y = v4.Y

	if Y <= 0.0001 then
		return nil, "the rear-water wake has an invalid boat height"
	end

	local Y2 = boundingBox:PointToObjectSpace(primaryPart.Position).Y
	local v5 = p * -2 / Y
	local v6 = math.clamp(1 + 2 * Y2 / Y + v5, 0, 2)

	for _, attributeName in { "FrontOffset", "BackOffset" } do
		local attribute = instance:GetAttribute(attributeName)
		local v7 = typeof(attribute) ~= "Vector3" and createVector(0, 0, 0) or attribute
		instance:SetAttribute(attributeName, (Vector3.new(v7.X, v6, v7.Z)))
	end

	local success, result = pcall(callback, instance)

	if not success or typeof(result) ~= "table" then
		return nil, "the rear-water wake failed to initialize"
	end

	local model = result.Model

	if model and typeof(model) == "Instance" then
		for _, part in model:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.CastShadow = false
		end
	end

	if pcall(function()
		result:UpdateSpeedAlpha(frozen.WakeSpeedAlpha)
		result:Enable("Front", "All", false, nil, 0.8)
		result:Enable("Back", "All", true, nil, 0.5)
	end) then
		return result, nil
	end

	return nil, "the rear-water wake failed its initial configuration"
end

function v2.routeHorizontalPosition(data, p: number)
	local lerped = data.StartPosition:Lerp(data.EndPosition, p)
	local v4 = math.sin(p * 3.141592653589793) ^ 2
	local v5 = math.sin(p * 3.141592653589793 * 2 * data.TurnCycles + data.MotionPhase) * data.SwayAmount
	return lerped + data.Forward * (v4 * (data.CurveAmount + v5))
end

function v2.routePosition(p, p2: number, p3: number)
	local routeHorizontalPosition = v2.routeHorizontalPosition(p, p2)
	local v4 = math.sin(p3 * 1.55 + p.MotionPhase) * 0.9
	return routeHorizontalPosition + createVector(0, 1, 0) * v4
end

function v2.routeCFrame(data, p: number)
	local age = data.Age
	local routePosition = v2.routePosition(data, p, age)
	local routeHorizontalPosition = v2.routeHorizontalPosition(data, p)
	local v4

	if p >= 0.998 then
		local v5 = math.max(p - 0.002, 0)
		v4 = routeHorizontalPosition - v2.routeHorizontalPosition(data, v5)
	else
		local v5 = math.min(p + 0.002, 1)
		v4 = v2.routeHorizontalPosition(data, v5) - routeHorizontalPosition
	end

	local vector2 = Vector3.new(v4.X, 0, v4.Z)

	if vector2.Magnitude < 0.0001 then
		local v5 = data.EndPosition - data.StartPosition
		vector2 = Vector3.new(v5.X, 0, v5.Z)
	end

	local v5 = p * 3.141592653589793 * 2 * data.TurnCycles + data.MotionPhase
	local v6 = math.sin(p * 3.141592653589793)
	local v7 = math.cos(v5) * v6
	local v8 = math.sin(v5 * 1.75 + data.MotionPhase * 0.65) * v6
	local v9 = math.clamp(v7 * 0.82 + v8 * 0.18, -1, 1)
	local v10 = math.sin(age * 1.35 + data.MotionPhase * 0.7) * 0.048869219055841226
	local v11 = v9 * 0.17453292519943295 + v8 * 0.03490658503988659
	local v12 = v9 * 0.09599310885968812
	return
		CFrame.lookAt(routePosition, routePosition + vector2.Unit, createVector(0, 1, 0)) * CFrame.Angles(v10, v12, v11),
		v9
end

function v2.horizontalFrameHalfSpan(p, vector2: Vector3)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return frozen.MinimumLaneHalfSpan
	end

	local v4 = math.max(-p.Scene.CameraCFrame:PointToObjectSpace(vector2).Z, 1)
	local viewportSize = currentCamera.ViewportSize
	local v5 = not (viewportSize.Y > 0) and 1.7777777777777777 or viewportSize.X / viewportSize.Y
	return (math.max(v4 * math.tan((math.rad(p.FieldOfView * 0.5))) * v5, frozen.MinimumLaneHalfSpan))
end

function v2:updateWake(p: number)
	local wake = self.Wake

	if not wake then
		return
	end

	wake:UpdateSpeedAlpha(frozen.WakeSpeedAlpha)
	local wakeSide = p > 0.5 and "Left" or p < -0.5 and "Right" or nil

	if wakeSide == self.WakeSide then
		return
	end

	self.WakeSide = wakeSide

	if not wakeSide then
		wake:Enable("Back", "All", true, nil, 0.5)
		return
	end

	local v5 = wakeSide == "Left" and "Right" or "Left"
	wake:Enable("Back", wakeSide, true, nil, 0.5)
	wake:Enable("Back", v5, false, nil, 0.5)
end

function v2.driverCFrame(p, cframe: CFrame)
	return cframe * p.DriverSeatOffset * CFrame.new(0, frozen.DriverRootHeight, 0)
end

function v2.updatePirate(p, cframe: CFrame)
	p.Pirate:PivotTo(v2.driverCFrame(p, cframe))
end

function v3.resolveWaterEffect()
	if v then
		return v, nil
	end

	local playerScripts = localPlayer:FindFirstChildOfClass("PlayerScripts") or localPlayer:WaitForChild(
		"PlayerScripts",
		5
	)

	if not playerScripts then
		return nil, "PlayerScripts is unavailable"
	end

	local shipController = playerScripts:FindFirstChild("ShipController") or playerScripts:WaitForChild(
		"ShipController",
		5
	)

	if not shipController then
		return nil, "the runtime ShipController is unavailable"
	end

	local controllers = shipController:FindFirstChild("Controllers") or shipController:WaitForChild("Controllers", 5)

	if not controllers then
		return nil, "the runtime ship controllers are unavailable"
	end

	local effect = controllers:FindFirstChild("Effect") or controllers:WaitForChild("Effect", 5)

	if not effect then
		return nil, "the runtime ship effect controller is unavailable"
	end

	local waterEffect = effect:FindFirstChild("WaterEffect") or effect:WaitForChild("WaterEffect", 5)

	if not (waterEffect and waterEffect:IsA("ModuleScript")) then
		return nil, "the runtime WaterEffect module is unavailable"
	end

	local success, result = pcall(require, waterEffect)

	if not success or typeof(result) ~= "function" then
		return nil, "the runtime WaterEffect module failed to load"
	end

	v = result
	return result, nil
end

function v3.createWake(p, p2: number)
	local waterEffect, v4 = v3.resolveWaterEffect()

	if waterEffect then
		return v2.startWake(waterEffect, p, p2)
	end

	return nil, v4
end

function v2.startSailSound(instance, p: string)
	local sailSound = frozen.SailSounds[p]
	local primaryPart = instance.PrimaryPart

	if sailSound and primaryPart then
		local play = Sound:Play(sailSound, primaryPart, {
			radius = frozen.SailSoundRadius
		})
		play.Looped = true
	end
end

function v3:destroy()
	if self.Pirate then
		self.Pirate:Destroy()
	end

	if self.Boat then
		self.Boat:Destroy()
	end

	self.Wake = nil
end

function v3.spawn(data, data2)
	local cloneFromCache, v4 = BoatPresentation.cloneFromCache(data.Cache, data2, "Observation")

	if not cloneFromCache then
		return nil, v4
	end

	local driverSeatOffset = BoatPresentation.getDriverSeatOffset(cloneFromCache)

	if not driverSeatOffset then
		cloneFromCache:Destroy()
		return nil, (`{data2.Boat} has no driver-seat transform`)
	end

	local lane = BoatPresentation.getLane(data2.Boat)

	if not lane then
		cloneFromCache:Destroy()
		return nil, (`unsupported lane for boat type {tostring(data2.Boat)}`)
	end

	local v5 = math.floor((math.abs(typeof(data2.MotionSeed) ~= "number" and 0 or data2.MotionSeed))) % 2147483647
	local random = Random.new(v5)
	local v6 = data2.Boat == "Grand Brigade"
	local verticalOffset = BoatPresentation.getVerticalOffset(data2.Boat)
	local laneSlotOffset = frozen.LaneSlotOffsets[data2.Boat]
	local v7 = typeof(data2.LaneSlot) ~= "number" and 1 or data2.LaneSlot
	local v8 = laneSlotOffset and laneSlotOffset[v7] or 0
	local v9 = frozen.LaneDepthOffsets[lane] + v8 + random:NextNumber(-frozen.LaneDepthJitter, frozen.LaneDepthJitter)
	local v10 = data.Scene.Center + data.Scene.Forward * v9
	local waterY = GetWaterHeightAtLocation(v10)

	if typeof(waterY) ~= "number" then
		cloneFromCache:Destroy()
		return nil, "the scenic lane water height is unavailable"
	end

	local extentsSize = cloneFromCache:GetExtentsSize()
	local v12 = v2.horizontalFrameHalfSpan(data, v10) + math.max(extentsSize.X, extentsSize.Z) * 0.5 + frozen.ShipEdgeMargin
	local v13 = not v6 and 0 or frozen.GrandBrigadeLeftSpawnClearance
	local v14 = v10 - data.Scene.Right * (v12 + v13)
	local v15 = v10 + data.Scene.Right * v12
	local vector2 = Vector3.new(v14.X, waterY + verticalOffset, v14.Z)
	local vector3 = Vector3.new(v15.X, waterY + verticalOffset, v15.Z)
	local clone = CharacterPresentation.clone("Pirate", nil)
	CharacterPresentation.setFace(clone, frozen.SmugglerFaceId)
	local v16 = {
		Boat = cloneFromCache,
		Pirate = clone,
		DriverSeatOffset = driverSeatOffset,
		Wake = nil,
		WakeSide = nil,
		StartPosition = vector2,
		EndPosition = vector3,
		Forward = data.Scene.Forward,
		WaterY = waterY,
		CurveAmount = random:NextNumber(-10, 10),
		SwayAmount = random:NextNumber(22, 32),
		TurnCycles = random:NextNumber(1.15, 1.55),
		MotionPhase = random:NextNumber(0, 6.283185307179586),
		Age = 0,
		Duration = data.TransitTime * (not v6 and 1 or frozen.GrandBrigadeDurationMultiplier)
	}
	local routeCFrame = v2.routeCFrame(v16, 0)
	cloneFromCache:PivotTo(routeCFrame)
	cloneFromCache.Parent = data.Folder
	clone:PivotTo(v2.driverCFrame(v16, routeCFrame))
	clone.Parent = data.Folder

	if not CharacterPresentation.playDriverIdle(clone) then
		warn("[Lookout] A sailing pirate could not play the steering idle")
	end

	v2.startSailSound(cloneFromCache, data2.Boat)
	local wake, v18 = v2.startWake(data.WaterEffect, cloneFromCache, verticalOffset)

	if wake then
		v16.Wake = wake
		return v16, nil
	end

	v3.destroy(v16)
	return nil, v18
end

function v3:step(p: number)
	self.Age += p
	local v4 = math.clamp(self.Age / self.Duration, 0, 1)
	local routeCFrame, v5 = v2.routeCFrame(self, v4)
	self.Boat:PivotTo(routeCFrame)
	v2.updatePirate(self, routeCFrame)
	v2.updateWake(self, v5)

	if v4 >= 1 then
		v3.destroy(self)
		return true
	else
		return false
	end
end

return table.freeze(v3)