require(script.Parent.Types)
local Config = require(script.Parent.Config)
local SideCompass = require(script.Parent.Parent.SideCompass)
local BASE_TRACKER_SIZE = Config.BASE_TRACKER_SIZE
local MIN_TRACKER_SCALE = Config.MIN_TRACKER_SCALE
local MAX_TRACKER_SCALE = Config.MAX_TRACKER_SCALE
local MAX_TRACKER_SPRING_SCALE = Config.MAX_TRACKER_SPRING_SCALE
local MIN_TRACKER_SPRING_SCALE = Config.MIN_TRACKER_SPRING_SCALE
local CENTER_POP_RADIUS_SCREEN_WIDTH = Config.CENTER_POP_RADIUS_SCREEN_WIDTH
local SCREEN_EDGE_PADDING = Config.SCREEN_EDGE_PADDING
local EDGE_INDICATOR_SIZE = Config.EDGE_INDICATOR_SIZE
local EDGE_INDICATOR_ARROW_SIZE = Config.EDGE_INDICATOR_ARROW_SIZE
local EDGE_INDICATOR_ARROW_ORBIT_RADIUS = Config.EDGE_INDICATOR_ARROW_ORBIT_RADIUS
local TOP_VISUAL_EXTENT = Config.TOP_VISUAL_EXTENT
local BOTTOM_VISUAL_EXTENT = Config.BOTTOM_VISUAL_EXTENT
local OFF_SCREEN_REST_Y_SCALE = Config.OFF_SCREEN_REST_Y_SCALE
local OFF_SCREEN_TRACKER_SCALE_MULTIPLIER = Config.OFF_SCREEN_TRACKER_SCALE_MULTIPLIER
local SIDE_COMPASS_TRACKER_Y_OFFSET_SCALE = Config.SIDE_COMPASS_TRACKER_Y_OFFSET_SCALE
local SCALE_SPRING_STIFFNESS = Config.SCALE_SPRING_STIFFNESS
local SCALE_SPRING_DAMPING = Config.SCALE_SPRING_DAMPING
local MAX_PROJECTION_DELTA_TIME = Config.MAX_PROJECTION_DELTA_TIME

local function getProjectedScreenPosition(currentCamera, vector: Vector3)
	local viewportSize = currentCamera.ViewportSize
	local v = viewportSize * 0.5
	local worldToViewportPoint = currentCamera:WorldToViewportPoint(vector)
	local vector2 = Vector2.new(worldToViewportPoint.X, worldToViewportPoint.Y)

	if worldToViewportPoint.Z < 0 then
		local pointToObjectSpace = currentCamera.CFrame:PointToObjectSpace(vector)
		local vector3 = Vector2.new(pointToObjectSpace.X, -pointToObjectSpace.Y)

		if vector3.Magnitude < 0.001 then
			vector3 = Vector2.new(0, 1)
		end

		return v + vector3.Unit * viewportSize.Magnitude, false, true
	else
		return
			vector2,
			worldToViewportPoint.X >= 0 and worldToViewportPoint.X <= viewportSize.X and worldToViewportPoint.Y >= 0 and worldToViewportPoint.Y <= viewportSize.Y,
			false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getTrackerTargetScale(point: Vector2, point2: Vector2)
	local v = point2 * 0.5
	local v2 = point2.X * CENTER_POP_RADIUS_SCREEN_WIDTH

	if v2 <= 0 then
		return MIN_TRACKER_SCALE
	end

	if (point - v).Magnitude <= v2 then
		return MAX_TRACKER_SCALE
	end

	return MIN_TRACKER_SCALE
end

local function getProjectionTargetScale(point: Vector2, point2: Vector2, flag: boolean)
	local trackerTargetScale = getTrackerTargetScale(point, point2) -- equivalent call inferred; original call site unknown

	if not flag then
		trackerTargetScale *= OFF_SCREEN_TRACKER_SCALE_MULTIPLIER
	end

	return trackerTargetScale
end

local function clampToViewport(projectedScreenPosition: Vector2, point: Vector2, viewportSize: Vector2)
	local v = point.X * 0.5 + SCREEN_EDGE_PADDING
	local v2 = viewportSize.X - v
	local v3 = point.Y * TOP_VISUAL_EXTENT + SCREEN_EDGE_PADDING
	local v4 = viewportSize.Y - point.Y * BOTTOM_VISUAL_EXTENT - SCREEN_EDGE_PADDING
	local v5 = viewportSize.X * 0.5

	if v <= v2 then
		v5 = math.clamp(projectedScreenPosition.X, v, v2)
	end

	local v6 = viewportSize.Y * 0.5

	if v3 <= v4 then
		v6 = math.clamp(projectedScreenPosition.Y, v3, v4)
	end

	return Vector2.new(v5, v6)
end

local function getSideCompassGuiObject()
	local _instance = SideCompass._instance

	if typeof(_instance) ~= "Instance" then
		return nil
	end

	local frame = _instance:FindFirstChild("Frame")

	if frame and frame:IsA("GuiObject") then
		return frame
	end

	return nil
end

local function getCompassDockPosition(point: Vector2, viewportSize: Vector2)
	local v = point.X * 0.5 + SCREEN_EDGE_PADDING
	local v2 = viewportSize.X - v
	local v3 = point.Y * TOP_VISUAL_EXTENT + SCREEN_EDGE_PADDING
	local v4 = viewportSize.Y - point.Y * BOTTOM_VISUAL_EXTENT - SCREEN_EDGE_PADDING

	if v2 < v or v4 < v3 then
		return viewportSize * 0.5
	end

	local v5 = math.clamp(viewportSize.Y * OFF_SCREEN_REST_Y_SCALE, v3, v4)
	local vector = Vector2.new(v, v5)
	local _instance = SideCompass._instance
	local frame

	if typeof(_instance) == "Instance" then
		frame = _instance:FindFirstChild("Frame")

		if not (frame and frame:IsA("GuiObject")) then
			frame = nil
		end
	end

	if frame then
		local v6 = frame.AbsolutePosition + frame.AbsoluteSize * 0.5 + Vector2.new(
			0,
			point.Y * SIDE_COMPASS_TRACKER_Y_OFFSET_SCALE
		)
		local v7 = math.clamp(v6.Y, v3, v4)
		vector = Vector2.new(math.clamp(v6.X, v, v2), v7)
	end

	return vector
end

local function getEdgeIndicatorProjection(point: Vector2, point2: Vector2)
	local v = point2 * 0.5
	local v2 = point - v
	local vector

	if v2.Magnitude < 0.001 then
		vector = Vector2.new(1, 0)
	else
		vector = v2.Unit
	end

	local v4 = EDGE_INDICATOR_ARROW_ORBIT_RADIUS + math.max(EDGE_INDICATOR_ARROW_SIZE.X, EDGE_INDICATOR_ARROW_SIZE.Y) * 0.5 + SCREEN_EDGE_PADDING
	local v5 = point2.X - v4
	local v6 = point2.Y - v4

	if v5 < v4 or v6 < v4 then
		return v, vector
	end

	local v7 = 1e999

	if vector.X > 0 then
		v7 = math.min(v7, (v5 - v.X) / vector.X)
	elseif vector.X < 0 then
		v7 = math.min(v7, (v4 - v.X) / vector.X)
	end

	if vector.Y > 0 then
		v7 = math.min(v7, (v6 - v.Y) / vector.Y)
	elseif vector.Y < 0 then
		v7 = math.min(v7, (v4 - v.Y) / vector.Y)
	end

	local v8 = v + vector * v7
	return Vector2.new(math.clamp(v8.X, v4, v5), (math.clamp(v8.Y, v4, v6))), vector
end

local function updateEdgeIndicator(state, projectedScreenPosition: Vector2, viewportSize: Vector2, flag: boolean)
	local ui = state.Ui

	if flag or not state.Options.ShowOffScreenAlert then
		ui.SetEdgeIndicatorVisible(false)
		return
	end

	local edgeIndicatorProjection, v = getEdgeIndicatorProjection(projectedScreenPosition, viewportSize)
	local uDim = UDim2.fromOffset(
		EDGE_INDICATOR_SIZE * 0.5 + v.X * EDGE_INDICATOR_ARROW_ORBIT_RADIUS,
		EDGE_INDICATOR_SIZE * 0.5 + v.Y * EDGE_INDICATOR_ARROW_ORBIT_RADIUS
	)
	ui.SetEdgeIndicatorVisible(true)
	ui.SetEdgeIndicatorPosition(UDim2.fromOffset(edgeIndicatorProjection.X, edgeIndicatorProjection.Y))
	ui.SetEdgeIndicatorArrowPosition(uDim)
	ui.SetEdgeIndicatorArrowAngle(math.deg((math.atan2(v.Y, v.X))) + 180)
end

local function getSprungScale(state, springScale: number, value: number)
	local springScale2 = state.SpringScale

	if springScale2 then
		local v = math.clamp(value, 0, MAX_PROJECTION_DELTA_TIME)
		local v2 = (springScale - springScale2) * SCALE_SPRING_STIFFNESS - state.SpringScaleVelocity * SCALE_SPRING_DAMPING
		state.SpringScaleVelocity += v2 * v
		state.SpringScale = math.clamp(
			springScale2 + state.SpringScaleVelocity * v,
			MIN_TRACKER_SPRING_SCALE,
			MAX_TRACKER_SPRING_SCALE
		)
		return state.SpringScale
	else
		state.SpringScale = springScale
		state.SpringScaleVelocity = 0
		return springScale
	end
end

return {
	update = function(self, vector: Vector3, value: number?, flag: boolean?, flag2: boolean?)
		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			local viewportSize = currentCamera.ViewportSize
			local projectedScreenPosition, v = getProjectedScreenPosition(currentCamera, vector)
			updateEdgeIndicator(self, projectedScreenPosition, viewportSize, v)

			if v or not flag then
				local springScale

				if flag2 then
					springScale = MIN_TRACKER_SCALE
				else
					local v2 = viewportSize * 0.5
					local v3 = viewportSize.X * CENTER_POP_RADIUS_SCREEN_WIDTH

					if v3 <= 0 then
						springScale = MIN_TRACKER_SCALE
					elseif (projectedScreenPosition - v2).Magnitude <= v3 then
						springScale = MAX_TRACKER_SCALE
					else
						springScale = MIN_TRACKER_SCALE
					end

					if not v then
						springScale *= OFF_SCREEN_TRACKER_SCALE_MULTIPLIER
					end
				end

				local v2 = value or 0.016666666666666666
				local springScale2 = self.SpringScale

				if springScale2 then
					local v3 = math.clamp(v2, 0, MAX_PROJECTION_DELTA_TIME)
					local v4 = (springScale - springScale2) * SCALE_SPRING_STIFFNESS - self.SpringScaleVelocity * SCALE_SPRING_DAMPING
					self.SpringScaleVelocity += v4 * v3
					self.SpringScale = math.clamp(
						springScale2 + self.SpringScaleVelocity * v3,
						MIN_TRACKER_SPRING_SCALE,
						MAX_TRACKER_SPRING_SCALE
					)
					springScale = self.SpringScale
				else
					self.SpringScale = springScale
					self.SpringScaleVelocity = 0
				end

				local v3 = BASE_TRACKER_SIZE * springScale
				local v4

				if v then
					v4 = clampToViewport(projectedScreenPosition, v3, viewportSize)
				else
					v4 = getCompassDockPosition(v3, viewportSize)
				end

				self.Ui.TrackerFrame.Visible = true
				self.Ui.TrackerFrame.Size = UDim2.fromOffset(v3.X, v3.Y)
				self.Ui.TrackerFrame.Position = UDim2.fromOffset(v4.X, v4.Y)
				return true, not v
			else
				self.Ui.TrackerFrame.Visible = false
				self.Ui.SetAlertBubbleVisible(false)
				return false, false
			end
		else
			self.Ui.TrackerFrame.Visible = false
			self.Ui.SetAlertBubbleVisible(false)
			self.Ui.SetEdgeIndicatorVisible(false)
			return false, false
		end
	end
}