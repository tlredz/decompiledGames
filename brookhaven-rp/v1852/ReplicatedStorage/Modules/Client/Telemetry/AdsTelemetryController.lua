local createVector = vector.create
local AdsTelemetryController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local IntroController = require(ReplicatedStorage.Modules.Client.UI.IntroController)
local v = {}
local v2 = {}
local maid = Janitor.new()
local screenGui = nil
local v3 = {}
AdsTelemetryController.ImpressionGenerated = Signal.new()

local function flushTrackingDataSnapshot(p, state)
	if state.qualifyingTickCount <= 0 and state.timeSpentObserving <= 1e-6 then
		return
	end

	local v4 = {
		timeSpentObserving = state.timeSpentObserving,
		hasImpressionCooldown = false,
		timeSinceLastImpression = 0,
		isFill = state.isFill,
		fallbackId = state.fallbackId
	}
	state.timeSpentObserving = 0
	state.qualifyingTickCount = 0
	AdsTelemetryController.ImpressionGenerated:Fire(p, v4)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function flushLastQualifyingForAd(adGui)
	local v4 = v3[adGui]

	if v4 then
		flushTrackingDataSnapshot(adGui, v4)
		v3[adGui] = nil
	end
end

local function flushAllPendingForAdGui(p)
	v3[p] = nil
	local v4 = v[p]

	if not v4 then
		return
	end

	flushTrackingDataSnapshot(p, v4.Active)

	for _, v5 in v4.Inactive do
		flushTrackingDataSnapshot(p, v5)
	end
end

local function flushAllSubscribedAds()
	for k in v2 do
		flushAllPendingForAdGui(k)
	end
end

local v4 = false
local folder = nil
local textLabel = nil
local v5 = {}
local count = 0

local function EnsureDebugGui()
	if not v4 or not screenGui or folder and folder.Parent == screenGui then
		return
	end

	folder = Instance.new("Folder")
	folder.Name = "AdsTelemetryDebug"
	folder.Parent = screenGui
	textLabel = Instance.new("TextLabel")
	textLabel.Name = "Info"
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.new(1, 1, 0)
	textLabel.TextStrokeTransparency = 0.5
	textLabel.Font = Enum.Font.Code
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Top
	textLabel.TextSize = 14
	textLabel.Position = UDim2.fromOffset(8, 8)
	textLabel.Size = UDim2.fromOffset(800, 120)
	textLabel.ZIndex = 1000
	textLabel.Parent = folder
end

local function AcquireLine()
	count += 1
	local selected = v5[count]

	if not selected then
		selected = Instance.new("Frame")
		selected.Name = "Line"
		selected.AnchorPoint = Vector2.new(0.5, 0.5)
		selected.BorderSizePixel = 0
		selected.BackgroundTransparency = 0
		selected.ZIndex = 999
		selected.Parent = folder
		v5[count] = selected
	end

	selected.Visible = true
	return selected
end

local function DrawLine2D(vector2: Vector3, vector3: Vector3, backgroundColor: Color3, p: number)
	local v6 = vector3.X - vector2.X
	local v7 = vector3.Y - vector2.Y
	local v8 = math.sqrt(v6 * v6 + v7 * v7)

	if v8 <= 0 then
		return
	end

	local v9 = vector2.X + v6 / 2
	local v10 = vector2.Y + v7 / 2
	local rotation = math.deg((math.atan2(v7, v6)))
	count += 1
	local v12 = v5[count]

	if not v12 then
		v12 = Instance.new("Frame")
		v12.Name = "Line"
		v12.AnchorPoint = Vector2.new(0.5, 0.5)
		v12.BorderSizePixel = 0
		v12.BackgroundTransparency = 0
		v12.ZIndex = 999
		v12.Parent = folder
		v5[count] = v12
	end

	v12.Visible = true
	v12.BackgroundColor3 = backgroundColor
	v12.Size = UDim2.fromOffset(v8, p)
	v12.Position = UDim2.fromOffset(v9, v10)
	v12.Rotation = rotation
end

local function DrawTriangle2D(vector2: Vector3, vector3: Vector3, vector4: Vector3, color: Color3, p: number)
	DrawLine2D(vector2, vector3, color, p)
	DrawLine2D(vector3, vector4, color, p)
	DrawLine2D(vector4, vector2, color, p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HideUnusedLines()
	for i = count + 1, #v5 do
		local v6 = v5[i]

		if v6 then
			v6.Visible = false
		end
	end
end

function AdsTelemetryController.SetDebugEnabled(flag: boolean)
	v4 = flag and true or false

	if not v4 then
		for i = 1, #v5 do
			local v6 = v5[i]

			if v6 then
				v6:Destroy()
			end
		end

		table.clear(v5)
		count = 0

		if textLabel then
			textLabel:Destroy()
			textLabel = nil
		end

		if folder then
			folder:Destroy()
			folder = nil
		end
	end
end

function AdsTelemetryController.FrameworkInit() end

local function GetFaceNormalVector(parent, face)
	if face == Enum.NormalId.Top then
		return parent.CFrame.UpVector
	end

	if face == Enum.NormalId.Bottom then
		return -parent.CFrame.UpVector
	end

	if face == Enum.NormalId.Front then
		return parent.CFrame.LookVector
	end

	if face == Enum.NormalId.Back then
		return -parent.CFrame.LookVector
	end

	if face == Enum.NormalId.Left then
		return parent.CFrame.RightVector
	end

	if face == Enum.NormalId.Right then
		return -parent.CFrame.RightVector
	end
end

local function GetFaceNormalCrossVector(p, p2)
	if p2 == Enum.NormalId.Top or p2 == Enum.NormalId.Bottom then
		return p.CFrame.RightVector
	end

	if p2 == Enum.NormalId.Front or p2 == Enum.NormalId.Back then
		return p.CFrame.UpVector
	end

	if p2 == Enum.NormalId.Left or p2 == Enum.NormalId.Right then
		return p.CFrame.LookVector
	end
end

local function GetFaceNormalSize(parent, face)
	if face == Enum.NormalId.Top or face == Enum.NormalId.Bottom then
		return parent.Size.Y
	end

	if face == Enum.NormalId.Front or face == Enum.NormalId.Back then
		return parent.Size.Z
	end

	if face == Enum.NormalId.Left or face == Enum.NormalId.Right then
		return parent.Size.X
	end
end

local function GetFaceSizeVector(parent, face)
	if face == Enum.NormalId.Top or face == Enum.NormalId.Bottom then
		return (Vector3.new(parent.Size.X, 0, parent.Size.Z))
	end

	if face == Enum.NormalId.Front or face == Enum.NormalId.Back then
		return (Vector3.new(parent.Size.X, parent.Size.Y, 0))
	end

	if face == Enum.NormalId.Left or face == Enum.NormalId.Right then
		return (Vector3.new(0, parent.Size.Y, parent.Size.Z))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StartTrackingRoutine()
	maid:Cleanup()
	local total = 0
	maid:Add(RunService.RenderStepped:Connect(function(dt)
		total += dt

		if total < 0.1 then
			return
		end

		total = 0
		local v6 = 0.1
		local currentCamera = workspace.CurrentCamera
		local X = screenGui.AbsoluteSize.X
		local Y = screenGui.AbsoluteSize.Y

		if v4 then
			EnsureDebugGui()
			count = 0

			if textLabel then
				textLabel.Text = ""
			end
		end

		for adGui, v7 in v2 do
			local v8 = math.deg((math.acos(((-v7.adNormal):Dot(currentCamera.CFrame.LookVector)))))

			if v8 > 55 then
				flushLastQualifyingForAd(adGui) -- equivalent call inferred; original call site unknown
			else
				local v9 = nil
				local v10 = false
				local v11 = nil
				local v12 = false
				local total2 = 0
				local total3 = 0
				local count2 = 0

				for _, v13 in { v7.topRightTriangle, v7.bottomLeftTriangle } do
					local v14, v15

					if v9 then
						v14 = v10
						v15 = v9
					else
						v15, v14 = currentCamera:WorldToScreenPoint(v13[1])
						v10 = v14
						v9 = v15
					end

					local worldToScreenPoint, v16 = currentCamera:WorldToScreenPoint(v13[2])
					local v17, v18

					if v11 then
						v17 = v12
						v18 = v11
					else
						v18, v17 = currentCamera:WorldToScreenPoint(v13[3])
						v12 = v17
						v11 = v18
					end

					local v19 = math.abs(v15.X * (worldToScreenPoint.Y - v18.Y) + worldToScreenPoint.X * (v18.Y - v15.Y) + v18.X * (v15.Y - worldToScreenPoint.Y)) * 0.5
					local v20 = v7

					local function findClosestValidPoint(data, adPart, adNormal, adFaceSize, adFace)
						local v21 = adPart.Position + adNormal * v20.adNormalSize / 2
						local rightVector = v20.adFacePartCFrame.RightVector
						local upVector = v20.adFacePartCFrame.UpVector
						local right = adFaceSize.X / 2
						local up = adFaceSize.Y / 2
						local v24 = {
							start = {
								right = -right,
								up = up
							},
							["end"] = {
								right = right,
								up = up
							}
						}
						local v25 = {
							start = {
								right = -right,
								up = -up
							},
							["end"] = {
								right = right,
								up = -up
							}
						}
						local v26 = {
							start = {
								right = -right,
								up = -up
							},
							["end"] = {
								right = -right,
								up = up
							}
						}
						local v27 = {
							start = {
								right = right,
								up = -up
							},
							["end"] = {
								right = right,
								up = up
							}
						}
						local v28 = 1e999
						local v29 = nil

						for i, v30 in ipairs({
							v24,
							v25,
							v26,
							v27
						}) do
							local v31 = v21 + rightVector * v30.start.right + upVector * v30.start.up
							local v32 = v21 + rightVector * v30["end"].right + upVector * v30["end"].up
							local worldToScreenPoint2 = currentCamera:WorldToScreenPoint(v31)
							local worldToScreenPoint3 = currentCamera:WorldToScreenPoint(v32)
							local v33

							if worldToScreenPoint2.X >= 0 and worldToScreenPoint2.X <= X and worldToScreenPoint2.Y >= 0 then
								v33 = worldToScreenPoint2.Y <= Y
							else
								v33 = false
							end

							local v34

							if worldToScreenPoint3.X >= 0 and worldToScreenPoint3.X <= X and worldToScreenPoint3.Y >= 0 then
								v34 = worldToScreenPoint3.Y <= Y
							else
								v34 = false
							end

							if not (v33 or v34) then
								continue
							end

							local v35

							if v33 then
								v35 = worldToScreenPoint2
							else
								local v36 = 0

								if worldToScreenPoint2.X < 0 then
									v36 = math.max(
										v36,
										(0 - worldToScreenPoint2.X) / (worldToScreenPoint3.X - worldToScreenPoint2.X)
									)
								elseif X < worldToScreenPoint2.X then
									v36 = math.max(
										v36,
										(X - worldToScreenPoint2.X) / (worldToScreenPoint3.X - worldToScreenPoint2.X)
									)
								end

								if worldToScreenPoint2.Y < 0 then
									v36 = math.max(
										v36,
										(0 - worldToScreenPoint2.Y) / (worldToScreenPoint3.Y - worldToScreenPoint2.Y)
									)
								elseif Y < worldToScreenPoint2.Y then
									v36 = math.max(
										v36,
										(Y - worldToScreenPoint2.Y) / (worldToScreenPoint3.Y - worldToScreenPoint2.Y)
									)
								end

								v35 = worldToScreenPoint2 + (worldToScreenPoint3 - worldToScreenPoint2) * v36
							end

							if not v34 then
								local v36 = 1

								if worldToScreenPoint3.X < 0 then
									v36 = math.min(
										v36,
										(0 - worldToScreenPoint2.X) / (worldToScreenPoint3.X - worldToScreenPoint2.X)
									)
								elseif X < worldToScreenPoint3.X then
									v36 = math.min(
										v36,
										(X - worldToScreenPoint2.X) / (worldToScreenPoint3.X - worldToScreenPoint2.X)
									)
								end

								if worldToScreenPoint3.Y < 0 then
									v36 = math.min(
										v36,
										(0 - worldToScreenPoint2.Y) / (worldToScreenPoint3.Y - worldToScreenPoint2.Y)
									)
								elseif Y < worldToScreenPoint3.Y then
									v36 = math.min(
										v36,
										(Y - worldToScreenPoint2.Y) / (worldToScreenPoint3.Y - worldToScreenPoint2.Y)
									)
								end

								worldToScreenPoint3 = worldToScreenPoint2 + (worldToScreenPoint3 - worldToScreenPoint2) * v36
							end

							local vector2 = worldToScreenPoint3 - v35
							local v36 = v35 + vector2 * math.clamp(
								(data - v35):Dot(vector2) / vector2:Dot(vector2),
								0,
								1
							)
							local magnitude = (v36 - data).Magnitude

							if not (magnitude < v28) then
								continue
							end

							v29 = v36
							v28 = magnitude
						end

						if v29 then
							return (Vector3.new(v29.X, v29.Y, v29.Z))
						end

						local screenPointToRay = currentCamera:ScreenPointToRay(data.X, data.Y)
						local dot = screenPointToRay.Direction:Dot(adNormal)
						local v30 = nil

						if math.abs(dot) > 0.0001 then
							local v31 = (v21 - screenPointToRay.Origin):Dot(adNormal) / dot

							if v31 > 0 then
								v30 = screenPointToRay.Origin + screenPointToRay.Direction * v31
							end
						end

						if not v30 then
							local dot2 = (screenPointToRay.Origin - v21):Dot(adNormal)
							v30 = screenPointToRay.Origin - adNormal * dot2
						end

						local vector2 = v30 - v21
						local dot2 = vector2:Dot(rightVector)
						local dot3 = vector2:Dot(upVector)
						local v31 = math.clamp(dot2, -right, right)
						local v32 = math.clamp(dot3, -up, up)
						local worldToScreenPoint2 = currentCamera:WorldToScreenPoint(v21 + rightVector * v31 + upVector * v32)

						if worldToScreenPoint2.X >= 0 and worldToScreenPoint2.X <= X and worldToScreenPoint2.Y >= 0 and worldToScreenPoint2.Y <= Y then
							return (Vector3.new(worldToScreenPoint2.X, worldToScreenPoint2.Y, worldToScreenPoint2.Z))
						end

						local v34 = {
							{
								start = createVector(0, 0, 0),
								["end"] = Vector3.new(X, 0, 0)
							},
							{
								start = Vector3.new(0, Y, 0),
								["end"] = Vector3.new(X, Y, 0)
							},
							{
								start = createVector(0, 0, 0),
								["end"] = Vector3.new(0, Y, 0)
							},
							{
								start = Vector3.new(X, 0, 0),
								["end"] = Vector3.new(X, Y, 0)
							}
						}

						for i, v35 in ipairs(v34) do
							local start = v35.start
							local v36 = v35["end"]
							local screenPointToRay2 = currentCamera:ScreenPointToRay(start.X, start.Y)
							local screenPointToRay3 = currentCamera:ScreenPointToRay(v36.X, v36.Y)
							local v37 = nil
							local v38 = nil
							local dot4 = screenPointToRay2.Direction:Dot(adNormal)

							if math.abs(dot4) > 0.0001 then
								local v39 = (v21 - screenPointToRay2.Origin):Dot(adNormal) / dot4

								if v39 > 0 then
									v37 = screenPointToRay2.Origin + screenPointToRay2.Direction * v39
								end
							end

							local dot5 = screenPointToRay3.Direction:Dot(adNormal)

							if math.abs(dot5) > 0.0001 then
								local v39 = (v21 - screenPointToRay3.Origin):Dot(adNormal) / dot5

								if v39 > 0 then
									v38 = screenPointToRay3.Origin + screenPointToRay3.Direction * v39
								end
							end

							if not (v37 and v38) then
								continue
							end

							local vector3 = v37 - v21
							local vector4 = v38 - v21
							local dot6 = vector3:Dot(rightVector)
							local dot7 = vector3:Dot(upVector)
							local dot8 = vector4:Dot(rightVector)
							local dot9 = vector4:Dot(upVector)
							local v39

							if math.abs(dot6) <= right then
								v39 = math.abs(dot7) <= up
							else
								v39 = false
							end

							local v40

							if math.abs(dot8) <= right then
								v40 = math.abs(dot9) <= up
							else
								v40 = false
							end

							if not (v39 or v40) then
								continue
							end

							if not v39 then
								local v41 = math.clamp(dot6, -right, right)
								local v42 = math.clamp(dot7, -up, up)
								v37 = v21 + rightVector * v41 + upVector * v42
							end

							if not v40 then
								local v41 = math.clamp(dot8, -right, right)
								local v42 = math.clamp(dot9, -up, up)
								v38 = v21 + rightVector * v41 + upVector * v42
							end

							local worldToScreenPoint3 = currentCamera:WorldToScreenPoint(v37)
							local vector5 = currentCamera:WorldToScreenPoint(v38) - worldToScreenPoint3
							local v41 = worldToScreenPoint3 + vector5 * math.clamp(
								(data - worldToScreenPoint3):Dot(vector5) / vector5:Dot(vector5),
								0,
								1
							)
							local magnitude = (v41 - data).Magnitude

							if not (magnitude < v28) then
								continue
							end

							v29 = v41
							v28 = magnitude
						end

						if v29 then
							return (Vector3.new(v29.X, v29.Y, v29.Z))
						end

						local v35 = {
							{
								right = -right,
								up = -up
							},
							{
								right = right,
								up = -up
							},
							{
								right = -right,
								up = up
							},
							{
								right = right,
								up = up
							}
						}

						for i, v36 in ipairs(v35) do
							local worldToScreenPoint3 = currentCamera:WorldToScreenPoint(v21 + rightVector * v36.right + upVector * v36.up)

							if not (worldToScreenPoint3.X >= 0 and worldToScreenPoint3.X <= X and worldToScreenPoint3.Y >= 0 and worldToScreenPoint3.Y <= Y) then
								continue
							end

							local magnitude = (worldToScreenPoint3 - data).Magnitude

							if not (magnitude < v28) then
								continue
							end

							v29 = worldToScreenPoint3
							v28 = magnitude
						end

						if v29 then
							return (Vector3.new(v29.X, v29.Y, v29.Z))
						end

						return (Vector3.new(math.clamp(data.X, 0, X), math.clamp(data.Y, 0, Y), data.Z))
					end

					local v21

					if v14 then
						v21 = v15
					else
						v21 = findClosestValidPoint(v15, v7.adPart, v7.adNormal, v7.adFaceSize, v7.adFace)
					end

					local v22

					if v16 then
						v22 = worldToScreenPoint
					else
						v22 = findClosestValidPoint(
							worldToScreenPoint,
							v7.adPart,
							v7.adNormal,
							v7.adFaceSize,
							v7.adFace
						)
					end

					local v23

					if v17 then
						v23 = v18
					else
						v23 = findClosestValidPoint(v18, v7.adPart, v7.adNormal, v7.adFaceSize, v7.adFace)
					end

					v9 = v9 or v21
					v11 = v11 or v23
					local v24 = math.abs(v21.X * (v22.Y - v23.Y) + v22.X * (v23.Y - v21.Y) + v23.X * (v21.Y - v22.Y)) * 0.5
					total2 += v19

					if v14 or v16 or v17 then
						total3 += v24
						count2 += 1
					else
						total3 += v24
					end

					if not (v4 and folder) then
						continue
					end

					local color = Color3.fromRGB(255, 215, 0)
					DrawLine2D(v15, worldToScreenPoint, color, 2)
					DrawLine2D(worldToScreenPoint, v18, color, 2)
					DrawLine2D(v18, v15, color, 2)
					local color2 = Color3.fromRGB(0, 255, 0)
					DrawLine2D(v21, v22, color2, 2)
					DrawLine2D(v22, v23, color2, 2)
					DrawLine2D(v23, v21, color2, 2)
					DrawLine2D(v15, v21, Color3.fromRGB(255, 64, 64), 1)
					DrawLine2D(worldToScreenPoint, v22, Color3.fromRGB(255, 64, 64), 1)
					DrawLine2D(v18, v23, Color3.fromRGB(255, 64, 64), 1)
				end

				local v13 = total3 / (X * Y) * 100
				local v14 = not (total2 > 0) and 0 or (total2 - total3) / total2 * 100

				if v13 < 0.5 then
					flushLastQualifyingForAd(adGui) -- equivalent call inferred; original call site unknown
				elseif v14 > 75 then
					flushLastQualifyingForAd(adGui) -- equivalent call inferred; original call site unknown
				else
					local status = adGui:IsA("AdGui") and adGui.Status or Enum.AdUnitStatus.Active
					local name = adGui:IsA("AdGui") and status.Name or "Active"

					if v4 and textLabel then
						textLabel.Text = string.format([[
Ad: %s (%s)
Angle: %.1f deg
Coverage: %.2f%%   Obstruction: %.1f%%   Triangles: %d]], adGui.Name, name, v8, v13, v14, count2)
					end

					if not v[adGui] then
						v[adGui] = {
							Active = {
								timeSpentObserving = 0,
								qualifyingTickCount = 0,
								isFill = true,
								isActive = true,
								hasImpressionCooldown = false,
								timeSinceLastImpression = 0
							},
							Inactive = {}
						}
					end

					local fallbackId = not adGui:IsA("AdGui") and "NonAdGui" or adGui.FallbackImage or "NonAdGui"

					if not v[adGui].Inactive[fallbackId] then
						v[adGui].Inactive[fallbackId] = {
							timeSpentObserving = 0,
							qualifyingTickCount = 0,
							isFill = false,
							isActive = false,
							hasImpressionCooldown = false,
							timeSinceLastImpression = 0,
							fallbackId = fallbackId
						}
					end

					local v16 = v[adGui][name]

					if name == "Inactive" then
						v16 = v[adGui].Inactive[fallbackId]
					end

					local v17 = v3[adGui]

					if v17 ~= v16 then
						if v17 then
							flushTrackingDataSnapshot(adGui, v17)
						end

						v3[adGui] = v16
					end

					v16.qualifyingTickCount += 1
					v16.timeSpentObserving += v6

					if v4 and textLabel then
						textLabel.Text = string.format([[
Ad: %s (%s)
Angle: %.1f deg
Coverage: %.2f%%   Obstruction: %.1f%%   Triangles: %d
time=%.3f ticks=%d]], adGui.Name, name, v8, v13, v14, count2, v16.timeSpentObserving, v16.qualifyingTickCount)
					end
				end
			end
		end

		if v4 and folder then
			HideUnusedLines() -- equivalent call inferred; original call site unknown
		end
	end))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function AttemptStopTrackingRoutine()
	if next(v2) then
		return
	end

	maid:Cleanup()
end

function AdsTelemetryController.SubscribeImpressionTracking(p)
	if p == nil or p.Parent == nil or v2[p] then
		return
	end

	v2[p] = {
		timeSpentObserving = 0,
		adPart = p.Parent,
		adNormal = GetFaceNormalVector(p.Parent, p.Face),
		adNormalSize = GetFaceNormalSize(p.Parent, p.Face),
		adFaceSize = GetFaceSizeVector(p.Parent, p.Face),
		adFace = p.Face
	}
	local v6 = v2[p]
	local adPart = v6.adPart
	local cframe = CFrame.new(adPart.Position, adPart.Position + v6.adNormal * v6.adNormalSize)
	local topRightTriangle = {
		CFrame.new(cframe.Position + cframe.RightVector * v6.adFaceSize.X / 2 + cframe.UpVector * v6.adFaceSize.Y / 2).Position,
		CFrame.new(cframe.Position + -cframe.RightVector * v6.adFaceSize.X / 2 + cframe.UpVector * v6.adFaceSize.Y / 2).Position,
		CFrame.new(cframe.Position + -cframe.RightVector * v6.adFaceSize.X / 2 + -cframe.UpVector * v6.adFaceSize.Y / 2).Position
	}
	local bottomLeftTriangle = {
		CFrame.new(cframe.Position + cframe.RightVector * v6.adFaceSize.X / 2 + cframe.UpVector * v6.adFaceSize.Y / 2).Position,
		CFrame.new(cframe.Position + cframe.RightVector * v6.adFaceSize.X / 2 + -cframe.UpVector * v6.adFaceSize.Y / 2).Position,
		CFrame.new(cframe.Position + -cframe.RightVector * v6.adFaceSize.X / 2 + -cframe.UpVector * v6.adFaceSize.Y / 2).Position
	}
	v2[p].topRightTriangle = topRightTriangle
	v2[p].bottomLeftTriangle = bottomLeftTriangle
	v2[p].adFacePartCFrame = cframe
	StartTrackingRoutine() -- equivalent call inferred; original call site unknown
end

function AdsTelemetryController.UnsubscribeImpressionTracking(p)
	flushAllPendingForAdGui(p)
	v2[p] = nil
	AttemptStopTrackingRoutine() -- equivalent call inferred; original call site unknown
end

function AdsTelemetryController.FrameworkStart()
	screenGui = Instance.new("ScreenGui")
	screenGui.ResetOnSpawn = false
	Players.LocalPlayer:WaitForChild("PlayerGui")
	screenGui.Parent = Players.LocalPlayer.PlayerGui
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	AdsTelemetryController.ImpressionGenerated:Connect(function(p, trackingData)
		local v6 = {
			trackingData = trackingData,
			location = p.Name
		}

		if not IntroController.HasPassedIntro() then
			v6.isIntro = true
		end

		if trackingData.timeSpentObserving < 1 then
			return
		end

		Remotes.fireServer("TelemetryClientInteraction", "complexAdImpression", v6)
	end)
	Remotes.connect("SubscribeImpressionTracking", AdsTelemetryController.SubscribeImpressionTracking)
	Remotes.connect("UnsubscribeImpressionTracking", AdsTelemetryController.UnsubscribeImpressionTracking)
end

return AdsTelemetryController