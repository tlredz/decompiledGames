local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CameraController = require(ReplicatedStorage.Controllers.CameraController)
require(ReplicatedStorage.Controllers.BonusMomentsController.Types)
local BoatPresentation = require(script.Parent.BoatPresentation)
local Scene = require(script.Parent.Scene)
local Ship = require(script.Ship)
local frozen = table.freeze({
	MaximumVisibleShips = 5,
	CameraSettleTime = 0.55,
	FieldOfView = 40,
	BaseTransitTime = 9.25,
	BaseSpawnCadence = 1.35,
	MinimumSpawnGapByBoat = {
		Dinghy = 1.25,
		Sloop = 1.5,
		Brigade = 2.25,
		["Grand Brigade"] = 3.5
	},
	RoundSpeed = {
		1,
		1.25,
		1.55,
		1.9
	},
	RoundShipCounts = {
		3,
		5,
		8,
		11
	}
})
local localPlayer = Players.LocalPlayer
local count = 0
local v = nil
local v2 = nil
local object = setmetatable({}, {
	__mode = "k"
})
local v3 = {}
local v4 = {}

function v3.restoreCamera(p, cframe: CFrame)
	local success, result = pcall(p.TeleportBack, p, cframe)

	if not success then
		warn((`[Lookout] Observation camera restoration failed: {tostring(result)}`))
	end
end

function v3.takeHeldCamera(p)
	local v5 = v2

	if not v5 or v5.Moment ~= p then
		return nil
	end

	v2 = nil
	object[p] = nil
	return {
		Camera = v5.Camera,
		ReturnCFrame = v5.ReturnCFrame
	}
end

function v3:cleanup(flag: boolean)
	if self.Cleaned then
		return
	end

	self.Cleaned = true

	if self.Connection then
		self.Connection:Disconnect()
		self.Connection = nil
	end

	for _, ship in self.Ships do
		Ship.destroy(ship)
	end

	table.clear(self.Ships)
	self.Folder:Destroy()
	local camera = self.Camera
	self.Camera = nil

	if camera then
		if flag then
			local v5 = v2

			if v5 and v5.Camera ~= camera then
				v3.restoreCamera(v5.Camera, v5.ReturnCFrame)
			end

			v2 = {
				Moment = self.Moment,
				Camera = camera,
				ReturnCFrame = self.ReturnCFrame
			}
		else
			v3.restoreCamera(camera, self.ReturnCFrame)
		end
	end

	if v == self then
		v = nil
	end
end

function v3:update(p: number)
	if self.Done or self.Cancelled or self.Cleaned or self.Generation ~= count then
		return
	end

	self.Elapsed += p

	while self.NextShip <= #self.Manifest and #self.Ships < frozen.MaximumVisibleShips do
		local v5 = self.Manifest[self.NextShip]
		local v6 = (self.NextShip - 1) * self.SpawnCadence
		local v7 = self.LastSpawnAtByBoat[v5.Boat]

		if v7 then
			v6 = math.max(v6, v7 + frozen.MinimumSpawnGapByBoat[v5.Boat])
		end

		if self.Elapsed < v6 then
			break
		end

		local v8, failureReason = Ship.spawn(self, v5)

		if v8 then
			table.insert(self.Ships, v8)
			self.LastSpawnAtByBoat[v5.Boat] = self.Elapsed
			self.NextShip += 1
		else
			self.Failed = true
			self.FailureReason = failureReason
			self.Done = true
			return
		end
	end

	for i = #self.Ships, 1, -1 do
		local ship = self.Ships[i]

		if not Ship.step(ship, p) then
			continue
		end

		table.remove(self.Ships, i)
		self.ClearedShips += 1
	end

	if self.ClearedShips >= #self.Manifest then
		self.Done = true
	end
end

function v3.validatePayload(data)
	if typeof(data) ~= "table" then
		return nil, "the server returned no observation payload"
	end

	if typeof(data.Token) ~= "string" or data.Token == "" then
		return nil, "the observation payload has no attempt token"
	end

	if typeof(data.Round) ~= "number" or frozen.RoundSpeed[data.Round] == nil then
		return nil, "the observation payload has an invalid round"
	end

	local roundShipCount = frozen.RoundShipCounts[data.Round]

	if typeof(data.Manifest) ~= "table" or #data.Manifest ~= roundShipCount then
		return nil, (`round {data.Round} must contain exactly {roundShipCount} ships`)
	end

	for i = 1, roundShipCount do
		if not BoatPresentation.validateEntry(data.Manifest[i], true) then
			return nil, (`ship {i} has invalid presentation data`)
		end
	end

	return data, nil
end

function v4.cancel(p)
	local v5 = v
	local v6

	if v5 == nil then
		v6 = false
	else
		v6 = p == nil or v5.Moment == p
	end

	local v7 = v2
	local v8

	if v7 == nil then
		v8 = false
	else
		v8 = p == nil or v7.Moment == p
	end

	if not (v6 or v8) then
		return
	end

	count += 1

	if v6 then
		local assert_2 = assert(v5)
		assert_2.Cancelled = true
		v3.cleanup(assert(v5), false)
	end

	if v8 then
		v2 = nil
		v3.restoreCamera(assert(v7).Camera, assert(v7).ReturnCFrame)
	end

	if p then
		object[p] = nil
	else
		table.clear(object)
	end
end

function v4.start(moment, p2)
	local v5 = count
	local v6, v7 = v3.validatePayload(p2)

	if not v6 then
		return false, v7
	end

	local resolved, v8 = Scene.resolve()

	if not resolved then
		return false, v8
	end

	if v5 ~= count then
		return false, "the observation was cancelled"
	end

	local cache, v9 = BoatPresentation.resolveCache()

	if not cache then
		return false, v9
	end

	if v5 ~= count then
		return false, "the observation was cancelled"
	end

	local _WorldOrigin = workspace:FindFirstChild("_WorldOrigin") or workspace:WaitForChild("_WorldOrigin", 5)

	if not _WorldOrigin then
		return false, "workspace._WorldOrigin is unavailable"
	end

	if v5 ~= count then
		return false, "the observation was cancelled"
	end

	local waterEffect, v10 = Ship.resolveWaterEffect()

	if not waterEffect then
		return false, v10
	end

	if v5 ~= count then
		return false, "the observation was cancelled"
	end

	local v11 = v3.takeHeldCamera(moment)
	v4.cancel(nil)
	local generation = count
	local child = _WorldOrigin:FindFirstChild((`LookoutShips_{localPlayer.UserId}`))

	if child then
		child:Destroy()
	end

	local folder = Instance.new("Folder")
	folder.Name = `LookoutShips_{localPlayer.UserId}`
	folder.Parent = _WorldOrigin
	local v13 = assert(frozen.RoundSpeed[v6.Round])
	local v14 = {
		Moment = moment,
		Generation = generation,
		Folder = folder,
		Camera = 0,
		ReturnCFrame = 0,
		Connection = nil,
		Ships = 0,
		Scene = 0,
		Cache = 0,
		WaterEffect = 0,
		Manifest = 0,
		TransitTime = 0,
		SpawnCadence = 0,
		FieldOfView = 0,
		Elapsed = 0,
		NextShip = 1,
		LastSpawnAtByBoat = 0,
		ClearedShips = 0,
		Done = false,
		Cancelled = false,
		Failed = false,
		FailureReason = nil,
		Cleaned = false
	}
	local camera2

	if v11 then
		camera2 = v11.Camera
	end

	v14.Camera = camera2
	local returnCFrame

	if v11 then
		returnCFrame = v11.ReturnCFrame
	else
		returnCFrame = workspace.CurrentCamera.CFrame
	end

	v14.ReturnCFrame = returnCFrame
	v14.Ships = {}
	v14.Scene = resolved
	v14.Cache = cache
	v14.WaterEffect = waterEffect
	v14.Manifest = v6.Manifest
	v14.TransitTime = frozen.BaseTransitTime / v13
	v14.SpawnCadence = frozen.BaseSpawnCadence / v13
	v14.FieldOfView = frozen.FieldOfView
	v14.LastSpawnAtByBoat = {}
	v = v14
	local success, result = pcall(function()
		local camera = v14.Camera or CameraController.new()
		v14.Camera = camera
		camera.Animations:AnimateTo(resolved.CameraCFrame, 1, 1.5)
		camera.Animations:AnimateFieldOfView(frozen.FieldOfView, 1, 1.5)
		return true
	end)

	if success then
		local v17 = os.clock() + frozen.CameraSettleTime

		while os.clock() < v17 and not v14.Cancelled and v14.Generation == count do
			RunService.Heartbeat:Wait()
		end

		if v14.Cancelled or v14.Generation ~= count then
			v3.cleanup(v14, false)
			return false, "the observation was cancelled"
		end

		v14.Connection = RunService.RenderStepped:Connect(function(dt)
			local v18, v19 = xpcall(function()
				v3.update(v14, dt)
				return nil
			end, debug.traceback)

			if not v18 then
				v14.Failed = true
				v14.FailureReason = tostring(v19)
				v14.Done = true
			end
		end)

		while not v14.Done and not v14.Cancelled and v14.Generation == count do
			task.wait()
		end

		local v18 = v14.Done and not (v14.Failed or v14.Cancelled)
		local failureReason = v14.FailureReason or v14.Cancelled and "the observation was cancelled" or nil
		v3.cleanup(v14, v18)
		return v18, failureReason
	else
		v14.Failed = true
		v14.FailureReason = tostring(result)
		v3.cleanup(v14, false)
		return false, "the sea-view camera failed to initialize"
	end
end

function v4.takeCamera(p)
	return v3.takeHeldCamera(p)
end

function v4.handleMomentComplete(p)
	if v2 and v2.Moment == p then
		object[p] = true
	else
		v4.cancel(p)
	end
end

function v4.handleMomentCleanup(p)
	if object[p] then
		return
	end

	v4.cancel(p)
end

return table.freeze(v4)