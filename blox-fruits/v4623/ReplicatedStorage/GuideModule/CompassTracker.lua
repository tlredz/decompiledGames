local createVector = vector.create
require(script.Types)
local Config = require(script.Config)
local TrackerOptions = require(script.TrackerOptions)
local TrackerUi = require(script.TrackerUi)
local TargetResolver = require(script.TargetResolver)
local Projection = require(script.Projection)
local ModelPreview = require(script.ModelPreview)
local Signal = require(game.ReplicatedStorage.Packages.Signal)
local IslandDistance = require(game.ReplicatedStorage.IslandDistance)
local SideCompass = require(script.Parent.SideCompass)
local DEFAULT_TRACKER_ID = Config.DEFAULT_TRACKER_ID
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CompassTracker"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local CompassTracker = {
	PreviewModel = nil,
	TrackedPosition = nil,
	TrackedLocation = nil,
	TargetIslandData = nil,
	TargetIslandBoundingBox = nil,
	IsWithinTargetIsland = false,
	OnTrackerCreated = Signal.new(),
	OnTrackerRemoved = Signal.new()
}
local v = {}
local v2 = 0
local thread = nil
local v3 = nil
local v4 = false
local v5 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function updateScreenGuiEnabled()
	screenGui.Enabled = not v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getProjectedWorldPosition(data, flag: boolean)
	if flag and data.Options.IconSettings.ShowIsland and data.TrackedLocation then
		if data.TargetIslandData and data.TargetIslandBoundingBox then
			return data.TargetIslandBoundingBox.Position
		end

		return data.TrackedLocation.Position
	else
		return data.TrackedPosition
	end
end

local function isLocalCharacterSpawned()
	local character = game.Players.LocalPlayer.Character

	if not (character and character.Parent) then
		return false
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.Health <= 0 then
		return false
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	return humanoidRootPart ~= nil and humanoidRootPart:IsA("BasePart")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideTrackerUi(state)
	state.Ui.TrackerFrame.Visible = false
	state.Ui.SetAlertBubbleVisible(false)
	state.Ui.SetEdgeIndicatorVisible(false)
	SideCompass.setTrackerDocked(state.Id, false)
end

local function updateTrackerView(state, p, p2: number?)
	if isLocalCharacterSpawned() then
		local targetPosition = TargetResolver.getTargetPosition(state.ResolvedTarget)

		if targetPosition and targetPosition ~= createVector(0, 0, 0) then
			state.TrackedPosition = targetPosition
			local v6 = math.floor(TargetResolver.getTrackerDistance(state) / 10)

			if state.Options.DestroyOnApproach and v6 <= state.Options.DestroyOnApproach then
				hideTrackerUi(state) -- equivalent call inferred; original call site unknown
				task.defer(CompassTracker.removeTracker, state.Id)
				return
			else
				local alertIconSettings = state.Options.AlertIconSettings
				local viewportSettings = state.Options.ViewportSettings
				local ui = state.Ui
				ui.DistanceLabel.Text = `{v6}m`
				ui.DistanceLabel.Visible = v6 >= 10
				local v7 = v6 < alertIconSettings.MaxDistance
				local isWithinTargetIsland = not v7

				if isWithinTargetIsland then
					if state.PreviewModel == nil or not (viewportSettings.MinDistance <= v6) then
						isWithinTargetIsland = false
					elseif state.Options.IconSettings.ShowIsland == false then
						isWithinTargetIsland = true
					elseif p == state.TrackedLocation then
						isWithinTargetIsland = state.IsWithinTargetIsland
					else
						isWithinTargetIsland = false
					end
				end

				local v8 = not (isWithinTargetIsland or v7)
				local projectedWorldPosition = getProjectedWorldPosition(state, v8) -- equivalent call inferred; original call site unknown

				if projectedWorldPosition then
					local v9, v10 = Projection.update(state, projectedWorldPosition, p2, v7, v7)
					SideCompass.setTrackerDocked(state.Id, v10)

					if not v9 then
						return
					end

					local v11 = isWithinTargetIsland and viewportSettings.UseIconAsBackground and ui.ImageLabel.Image ~= ""
					ui.SetAlertBubbleVisible(v7)
					ui.ViewportFrame.Visible = isWithinTargetIsland
					ui.ImageLabel.Visible = v8 or v11
					TrackerUi.setIconBackgroundLayout(ui, v11)
					return
				end
			end
		end

		hideTrackerUi(state) -- equivalent call inferred; original call site unknown
	else
		hideTrackerUi(state) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function syncDefaultFields()
	local v6 = v[DEFAULT_TRACKER_ID]
	local v7 = CompassTracker
	local previewModel

	if v6 then
		previewModel = v6.PreviewModel
	end

	v7.PreviewModel = previewModel
	local v9 = CompassTracker
	local trackedPosition

	if v6 then
		trackedPosition = v6.TrackedPosition
	end

	v9.TrackedPosition = trackedPosition
	local v11 = CompassTracker
	local trackedLocation

	if v6 then
		trackedLocation = v6.TrackedLocation
	end

	v11.TrackedLocation = trackedLocation
	local v13 = CompassTracker
	local targetIslandData

	if v6 then
		targetIslandData = v6.TargetIslandData
	end

	v13.TargetIslandData = targetIslandData
	local v15 = CompassTracker
	local targetIslandBoundingBox

	if v6 then
		targetIslandBoundingBox = v6.TargetIslandBoundingBox
	end

	v15.TargetIslandBoundingBox = targetIslandBoundingBox
	local v17 = CompassTracker
	local isWithinTargetIsland

	if v6 then
		isWithinTargetIsland = v6.IsWithinTargetIsland
	else
		isWithinTargetIsland = false
	end

	v17.IsWithinTargetIsland = isWithinTargetIsland
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateSideCompassColor()
	if v[DEFAULT_TRACKER_ID] then
		SideCompass.setButtonImageColor(Color3.new(1, 0.3, 0.3))
	else
		SideCompass.setButtonImageColor(Color3.new(1, 1, 1))
	end
end

local function slowUpdate()
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		local position = currentCamera.CFrame.Position
		local v6, v7 = IslandDistance(position)
		v3 = TargetResolver.getNearestLocation(position)

		for _, v8 in pairs(v) do
			TargetResolver.refreshTrackerTarget(v8)
			v8.IsWithinTargetIsland = v7 == v8.TargetIslandData and v6 <= 0
		end

		syncDefaultFields() -- equivalent call inferred; original call site unknown
	else
		v3 = nil

		for _, v6 in pairs(v) do
			v6.IsWithinTargetIsland = false
		end

		syncDefaultFields() -- equivalent call inferred; original call site unknown
	end
end

local function startTrackingLoop()
	if thread then
		return
	end

	updateScreenGuiEnabled() -- equivalent call inferred; original call site unknown
	screenGui.Parent = game.Players.LocalPlayer.PlayerGui
	updateSideCompassColor() -- equivalent call inferred; original call site unknown
	slowUpdate()
	thread = task.spawn(function()
		local RunService = game:GetService("RunService")
		local renderStepped = RunService.RenderStepped
		local lastTime = tick()

		while v2 > 0 do
			local v6 = renderStepped:Wait()

			for _, v7 in pairs(v) do
				updateTrackerView(v7, v3, v6)
			end

			syncDefaultFields() -- equivalent call inferred; original call site unknown

			if not (tick() - lastTime > 1) then
				continue
			end

			lastTime = tick()
			slowUpdate()
		end

		thread = nil
	end)
end

local function createTrackerRecord(id, p2)
	local v6 = {
		Id = id,
		Options = TrackerOptions.normalize(p2),
		Ui = TrackerUi.create(screenGui, id),
		PreviewModel = nil,
		ResolvedTarget = nil,
		TrackedPosition = nil,
		TrackedLocation = nil,
		TargetIslandData = nil,
		TargetIslandBoundingBox = nil,
		IsWithinTargetIsland = false,
		SpringScale = nil,
		SpringScaleVelocity = 0
	}
	TrackerUi.applyOptions(v6.Ui, v6.Options)
	ModelPreview.set(v6, v6.Options.ViewportSettings.Model, nil)
	TargetResolver.refreshTrackerTarget(v6)
	return v6
end

function CompassTracker.createTracker(id, p2)
	assert(id ~= nil, "CompassTracker.createTracker requires an ID")

	if id == DEFAULT_TRACKER_ID and v5 then
		return v[id]
	end

	if v[id] then
		CompassTracker.removeTracker(id)
	end

	local trackerRecord = createTrackerRecord(id, p2)
	v[id] = trackerRecord
	v2 += 1
	startTrackingLoop()
	syncDefaultFields() -- equivalent call inferred; original call site unknown
	CompassTracker.OnTrackerRemoved:Fire(id)
	return trackerRecord
end

function CompassTracker.removeTracker(p)
	if p == DEFAULT_TRACKER_ID and v5 then
		return false
	end

	local v6 = v[p]

	if not v6 then
		return false
	end

	if p ~= DEFAULT_TRACKER_ID then
		local Map = require(game.ReplicatedStorage.Controllers.UI.Map)

		if Map.IsInitialized then
			Map:RemoveMarker((tostring(p)))
		end
	end

	if v6.PreviewModel then
		v6.PreviewModel:Destroy()
		v6.PreviewModel = nil
	end

	SideCompass.setTrackerDocked(p, false)
	TrackerUi.destroy(v6.Ui)
	v[p] = nil
	v2 -= 1

	if v2 <= 0 then
		v2 = 0

		if thread then
			task.cancel(thread)
			thread = nil
		end

		screenGui.Parent = nil
	end

	updateSideCompassColor() -- equivalent call inferred; original call site unknown
	syncDefaultFields() -- equivalent call inferred; original call site unknown
	CompassTracker.OnTrackerRemoved:Fire(p)
	return true
end

function CompassTracker.setModelPreview(p, p2, p3)
	local v6 = v[p3 or DEFAULT_TRACKER_ID] or CompassTracker.createTracker(p3 or DEFAULT_TRACKER_ID, {
		Target = CompassTracker.TrackedPosition
	})
	ModelPreview.set(v6, p, p2)
	syncDefaultFields() -- equivalent call inferred; original call site unknown
end

function CompassTracker.getDistance(p)
	local v6 = v[p or DEFAULT_TRACKER_ID]

	if v6 then
		return TargetResolver.getTrackerDistance(v6)
	end

	return 0
end

function CompassTracker.updateView(p, p2: number?, p3)
	local v6 = v[p3 or DEFAULT_TRACKER_ID]

	if not v6 then
		return
	end

	updateTrackerView(v6, p, p2)
	syncDefaultFields() -- equivalent call inferred; original call site unknown
end

function CompassTracker.getImageLabel(p)
	local v6 = v[p or DEFAULT_TRACKER_ID]

	if v6 then
		return v6.Ui.ImageLabel
	end

	return nil
end

function CompassTracker.isTracking(p)
	if p == nil then
		return v2 > 0
	end

	return v[p] ~= nil
end

function CompassTracker.isTrackingDefault()
	return v[DEFAULT_TRACKER_ID] ~= nil
end

function CompassTracker.getTracker(p)
	return v[p or DEFAULT_TRACKER_ID]
end

function CompassTracker.stopTracking()
	if v5 then
		return
	end

	CompassTracker.removeTracker(DEFAULT_TRACKER_ID)
end

function CompassTracker.trackPosition(vector2: Vector3?)
	if v5 then
		return
	end

	CompassTracker.removeTracker(DEFAULT_TRACKER_ID)

	if vector2 then
		CompassTracker.createTracker(DEFAULT_TRACKER_ID, {
			Target = vector2
		})
		return
	end

	syncDefaultFields() -- equivalent call inferred; original call site unknown
end

function CompassTracker.setDefaultOverride(p: string, p2)
	assert(p ~= "", "CompassTracker.setDefaultOverride requires an owner ID")
	v5 = nil
	CompassTracker.removeTracker(DEFAULT_TRACKER_ID)
	CompassTracker.createTracker(DEFAULT_TRACKER_ID, p2)
	v5 = p
end

function CompassTracker.clearDefaultOverride(p: string)
	if v5 ~= p then
		return false
	end

	v5 = nil
	return CompassTracker.removeTracker(DEFAULT_TRACKER_ID)
end

function CompassTracker.setMenuHidden(flag: boolean)
	v4 = flag
	updateScreenGuiEnabled() -- equivalent call inferred; original call site unknown
end

return CompassTracker