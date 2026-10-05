local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local WearingController = require(ReplicatedStorage.Modules.Client.AvatarEditor.WearingController)
local AccessoryAdjustmentsState = require(ReplicatedStorage.Modules.Client.AvatarEditor.AccessoryAdjustments.AccessoryAdjustmentsState)
local AccessoryAdjustmentsClientPreview = require(ReplicatedStorage.Modules.Client.AvatarEditor.AccessoryAdjustments.AccessoryAdjustmentsClientPreview)
local AccessoryAdjustmentLimits = require(ReplicatedStorage.Modules.Shared.Game.AccessoryAdjustmentLimits)
local AccessoryAdjustmentsConstants = require(ReplicatedStorage.Modules.Shared.Game.AccessoryAdjustmentsConstants)
local AccessoryAdjustmentsPanel = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.AvatarEditor.AccessoryAdjustments.AccessoryAdjustmentsPanel)
local AccessoryAdjustmentsSoundManager = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.AvatarEditor.AccessoryAdjustments.AccessoryAdjustmentsSoundManager)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
require(GameSdkShared.Modules.ABTest)
local v = Component.new({
	Tag = "AccessoryAdjustmentsSlider"
})
local v2 = {
	RotateX = true,
	RotateY = true,
	RotateZ = true,
	PositionX = true,
	PositionY = true,
	PositionZ = true,
	Scale = true,
	EmissiveStrength = true
}
local v3 = {
	PositionX = true,
	RotateX = true
}

local function resolveSliderModeAndFrame(parent)
	while parent ~= nil do
		if v2[parent.Name] == true then
			return parent.Name, parent
		else
			parent = parent.Parent
		end
	end

	return nil, nil
end

local v4 = {
	RotateX = { AccessoryAdjustmentLimits.ROTATION_MIN, AccessoryAdjustmentLimits.ROTATION_MAX },
	RotateY = { AccessoryAdjustmentLimits.ROTATION_MIN, AccessoryAdjustmentLimits.ROTATION_MAX },
	RotateZ = { AccessoryAdjustmentLimits.ROTATION_MIN, AccessoryAdjustmentLimits.ROTATION_MAX },
	PositionX = { AccessoryAdjustmentLimits.POSITION_MIN, AccessoryAdjustmentLimits.POSITION_MAX },
	PositionY = { AccessoryAdjustmentLimits.POSITION_MIN, AccessoryAdjustmentLimits.POSITION_MAX },
	PositionZ = { AccessoryAdjustmentLimits.POSITION_MIN, AccessoryAdjustmentLimits.POSITION_MAX },
	Scale = { AccessoryAdjustmentLimits.SCALE_MIN, AccessoryAdjustmentLimits.SCALE_MAX },
	EmissiveStrength = { 0, 6 }
}
local SLIDER_NORMALIZED_MIN = AccessoryAdjustmentsConstants.SLIDER_NORMALIZED_MIN
local SLIDER_NORMALIZED_MAX = AccessoryAdjustmentsConstants.SLIDER_NORMALIZED_MAX
local v5 = SLIDER_NORMALIZED_MAX - SLIDER_NORMALIZED_MIN
local v6 = math.max(v5 * 0.09, 0.0001)
local v7 = math.max(v5 * 0.045, 0.0001)
local v8 = v5 * 1.5
local v9 = nil
local color = Color3.fromRGB(113, 111, 106)
local color2 = Color3.fromRGB(255, 255, 255)
local color3 = Color3.fromRGB(31, 31, 31)

local function isGamepadInputType(p)
	return p == Enum.UserInputType.Gamepad1 or p == Enum.UserInputType.Gamepad2 or p == Enum.UserInputType.Gamepad3 or p == Enum.UserInputType.Gamepad4 or p == Enum.UserInputType.Gamepad5 or p == Enum.UserInputType.Gamepad6 or p == Enum.UserInputType.Gamepad7 or p == Enum.UserInputType.Gamepad8
end

local function snapKnobUiNormalizedIfNearCenter(p: number)
	if math.abs(p) <= v7 then
		return 0
	end

	return p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function dragSoundNameForSliderMode(name: string)
	if name == "RotateX" or name == "RotateY" or name == "RotateZ" then
		return AccessoryAdjustmentsSoundManager.SOUNDS.ROTATE
	end

	return AccessoryAdjustmentsSoundManager.SOUNDS.MOVE_OR_RESIZE
end

-- equivalent calls inferred from this helper; original call sites unknown
local function vec3ToPayload(vector2: Vector3)
	return {
		X = vector2.X,
		Y = vector2.Y,
		Z = vector2.Z
	}
end

local function payloadToVec3(data)
	return (Vector3.new(data.X, data.Y, data.Z))
end

local function findAccessoryDescriptionForRead(appliedDescription, p: number)
	for _, accessoryDescription in appliedDescription:GetChildren() do
		if accessoryDescription:IsA("AccessoryDescription") and tonumber(accessoryDescription.AssetId) == p then
			return accessoryDescription
		end
	end

	return nil
end

local function readAccessoryVectors(object, p: number)
	local accessoryDescriptionForRead = findAccessoryDescriptionForRead(object:GetAppliedDescription(), p)

	if accessoryDescriptionForRead == nil then
		return createVector(0, 0, 0), createVector(0, 0, 0), createVector(1, 1, 1)
	end

	return accessoryDescriptionForRead.Position, accessoryDescriptionForRead.Rotation, accessoryDescriptionForRead.Scale
end

local function findAccessoryByAssetId(object, p: number)
	for _, v10 in object:GetAccessories() do
		if tonumber(v10:GetAttribute("AssetId")) == p then
			return v10
		end
	end

	return nil
end

local function getNumberAttr(instance, attributeName: string)
	if instance == nil then
		return nil
	end

	local attribute = instance:GetAttribute(attributeName)

	if type(attribute) == "number" then
		return attribute
	end

	return nil
end

local function getAdjustRange(name: string, instance, parent, parent2)
	local v10 = v4[name]
	local v11 = v10 == nil and 0 or v10[1]
	local v12 = v10 == nil and 1 or v10[2]
	local adjustMin

	if instance ~= nil then
		adjustMin = instance:GetAttribute("AdjustMin")

		if type(adjustMin) ~= "number" then
			adjustMin = nil
		end
	end

	if not adjustMin then
		if parent == nil then
			adjustMin = nil
		else
			adjustMin = parent:GetAttribute("AdjustMin")

			if type(adjustMin) ~= "number" then
				adjustMin = nil
			end
		end

		if not adjustMin then
			local adjustMin2

			if parent2 ~= nil then
				adjustMin2 = parent2:GetAttribute("AdjustMin")

				if type(adjustMin2) ~= "number" then
					adjustMin2 = nil
				end
			end

			adjustMin = adjustMin2 or v11
		end
	end

	local adjustMax

	if instance ~= nil then
		adjustMax = instance:GetAttribute("AdjustMax")

		if type(adjustMax) ~= "number" then
			adjustMax = nil
		end
	end

	if not adjustMax then
		if parent == nil then
			adjustMax = nil
		else
			adjustMax = parent:GetAttribute("AdjustMax")

			if type(adjustMax) ~= "number" then
				adjustMax = nil
			end
		end

		if not adjustMax then
			local adjustMax2

			if parent2 ~= nil then
				adjustMax2 = parent2:GetAttribute("AdjustMax")

				if type(adjustMax2) ~= "number" then
					adjustMax2 = nil
				end
			end

			adjustMax = adjustMax2 or v12
		end
	end

	if adjustMax < adjustMin then
		return adjustMax, adjustMin
	end

	return adjustMin, adjustMax
end

-- equivalent calls inferred from this helper; original call sites unknown
local function componentFromNormalized(p: number, p2: number, p3: number)
	return p2 + (p - SLIDER_NORMALIZED_MIN) / v5 * (p3 - p2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function normalizedFromTrackPointer(p, vector2: Vector2, p2: string)
	local absolutePosition = p.AbsolutePosition
	local absoluteSize = p.AbsoluteSize

	if absoluteSize.X < 1 or absoluteSize.Y < 1 then
		return nil
	end

	local v10

	if p2 == "Y" then
		v10 = (vector2.Y - absolutePosition.Y) / absoluteSize.Y
	else
		v10 = (vector2.X - absolutePosition.X) / absoluteSize.X
	end

	return SLIDER_NORMALIZED_MIN + math.clamp(v10, 0, 1) * v5
end

-- equivalent calls inferred from this helper; original call sites unknown
local function normalizedFromComponent(p: number, p2: number, p3: number)
	if p3 == p2 then
		return 0
	end

	local v10 = p3 - p2
	local v11 = math.max(1e-6, math.abs(v10) * 1e-7)

	if p <= p2 + v11 then
		return SLIDER_NORMALIZED_MIN
	end

	if p3 - v11 <= p then
		return SLIDER_NORMALIZED_MAX
	end

	return SLIDER_NORMALIZED_MIN + math.clamp((p - p2) / v10, 0, 1) * v5
end

local function getSliderComponentValue(p: string, vector2: Vector3, vector3: Vector3, vector4: Vector3)
	if p == "RotateX" then
		return vector3.X
	elseif p == "RotateY" then
		return vector3.Y
	elseif p == "RotateZ" then
		return vector3.Z
	elseif p == "PositionX" then
		return vector2.X
	elseif p == "PositionY" then
		return vector2.Y
	elseif p == "PositionZ" then
		return vector2.Z
	elseif p == "Scale" then
		return (vector4.X + vector4.Y + vector4.Z) / 3
	end

	return 0
end

local function getDefaultComponentValue(p: string)
	if p == "Scale" then
		return 1
	end

	return 0
end

local function getAccessorySurfaceAppearance(instance)
	local surfaceAppearance = instance:FindFirstChild(AccessoryAdjustmentsConstants.ACCESSORY_COLOR_SURFACE_APPEARANCE_NAME)

	if surfaceAppearance == nil or not surfaceAppearance:IsA("SurfaceAppearance") then
		return nil
	end

	return surfaceAppearance
end

local function ensureAccessorySurfaceAppearanceForPreview(parent)
	local surfaceAppearance = parent:FindFirstChild(AccessoryAdjustmentsConstants.ACCESSORY_COLOR_SURFACE_APPEARANCE_NAME)

	if surfaceAppearance == nil or not surfaceAppearance:IsA("SurfaceAppearance") then
		surfaceAppearance = nil
	end

	if surfaceAppearance ~= nil then
		return surfaceAppearance
	end

	local surfaceAppearance2 = Instance.new("SurfaceAppearance")
	surfaceAppearance2.Name = AccessoryAdjustmentsConstants.ACCESSORY_COLOR_SURFACE_APPEARANCE_NAME
	surfaceAppearance2.Parent = parent
	surfaceAppearance2.AlphaMode = Enum.AlphaMode.TintMask
	return surfaceAppearance2
end

local function findAccessoryHandleByAssetId(p, p2: number)
	local accessoryByAssetId = findAccessoryByAssetId(p, p2)

	if accessoryByAssetId == nil then
		return nil
	end

	local handle = accessoryByAssetId:FindFirstChild("Handle")

	if handle == nil or not handle:IsA("BasePart") then
		return nil
	end

	return handle
end

local function buildSnapshot(p: string, p2: number, p3: number, p4: number, vector2: Vector3, vector3: Vector3, vector4: Vector3)
	local v10 = componentFromNormalized(p4, p2, p3) -- equivalent call inferred; original call site unknown

	if p == "RotateX" then
		vector3 = Vector3.new(v10, vector3.Y, vector3.Z)
	elseif p == "RotateY" then
		vector3 = Vector3.new(vector3.X, v10, vector3.Z)
	elseif p == "RotateZ" then
		vector3 = Vector3.new(vector3.X, vector3.Y, v10)
	elseif p == "PositionX" then
		vector2 = Vector3.new(v10, vector2.Y, vector2.Z)
	elseif p == "PositionY" then
		vector2 = Vector3.new(vector2.X, v10, vector2.Z)
	elseif p == "PositionZ" then
		vector2 = Vector3.new(vector2.X, vector2.Y, v10)
	elseif p == "Scale" then
		vector4 = Vector3.new(v10, v10, v10)
	end

	return vec3ToPayload(vector2), vec3ToPayload(vector3), vec3ToPayload(vector4)
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._detachActiveBindings = nil
end

function v:Start()
	local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"AccessoryAdjustmentsPanel",
		AccessoryAdjustmentsPanel
	)
	self.Instance.SelectionModeDragSpeed = UDim2.fromScale(0.7, 0)
	local instance = self.Instance
	local dragAxis = instance:GetAttribute("DragAxis") or "X"

	if dragAxis ~= "X" and dragAxis ~= "Y" and dragAxis ~= "Z" then
		warn("AvatarEditorAccessorySlider: Invalid DragAxis attribute:", dragAxis)
		return
	end

	local parent = instance.Parent

	if parent == nil or not parent:IsA("GuiObject") then
		return
	end

	local function getButtonVisualColor()
		return parent.BackgroundColor3
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setButtonVisualColor(backgroundColor: Color3, textColor: Color3)
		parent.BackgroundColor3 = backgroundColor
		local textLabel = parent:FindFirstChild("TextLabel")

		if textLabel then
			textLabel.TextColor3 = textColor
		end
	end

	if typeof(parent:GetAttribute("NoSelectionColor")) ~= "Color3" then
		parent:SetAttribute("NoSelectionColor", color)
	end

	if typeof(parent:GetAttribute("SelectedColor")) ~= "Color3" then
		parent:SetAttribute("SelectedColor", parent.BackgroundColor3)
	end

	local function applyButtonSelectionVisualState(flag: boolean)
		local noSelectionColor = parent:GetAttribute("NoSelectionColor")
		local selectedColor = parent:GetAttribute("SelectedColor")

		if typeof(noSelectionColor) ~= "Color3" then
			noSelectionColor = color
		end

		if typeof(selectedColor) ~= "Color3" then
			selectedColor = parent.BackgroundColor3
		end

		if flag == true then
			if parent:IsA("GuiButton") then
				parent.Interactable = true
			end

			setButtonVisualColor(selectedColor, color2) -- equivalent call inferred; original call site unknown
		else
			if parent:IsA("GuiButton") then
				parent.Interactable = false
			end

			setButtonVisualColor(noSelectionColor, color3) -- equivalent call inferred; original call site unknown
		end
	end

	local size = parent.Size

	-- equivalent calls inferred from this helper; original call sites unknown
	local function udim2ScaledUniform(udim: UDim2, sizeMultiplier: number)
		return UDim2.new(
			udim.X.Scale * sizeMultiplier,
			udim.X.Offset * sizeMultiplier,
			udim.Y.Scale * sizeMultiplier,
			udim.Y.Offset * sizeMultiplier
		)
	end

	local count = 0
	local v10 = nil
	local v11 = {
		{
			sizeMultiplier = 1.07,
			duration = 0.035
		},
		{
			sizeMultiplier = 1,
			duration = 0.065
		}
	}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stopKnobBounceImmediate()
		count += 1

		if v10 ~= nil then
			v10:Cancel()
			v10 = nil
		end

		parent.Size = size
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function playKnobBounce(list)
		count += 1
		local v12 = count

		if v10 ~= nil then
			v10:Cancel()
			v10 = nil
		end

		parent.Size = size
		local runStep

		runStep = function(p: number)
			if v12 ~= count then
				return
			end

			if #list < p then
				parent.Size = size
				return
			end

			local v13 = list[p]
			local size2 = udim2ScaledUniform(size, v13.sizeMultiplier) -- equivalent call inferred; original call site unknown
			local tween = TweenService:Create(
				parent,
				TweenInfo.new(v13.duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Size = size2
				}
			)
			v10 = tween
			tween.Completed:Once(function()
				v10 = nil

				if v12 ~= count then
					return
				end

				runStep(p + 1)
			end)
			tween:Play()
		end

		runStep(1)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function playKnobBounceAfterClick()
		playKnobBounce(v11) -- equivalent call inferred; original call site unknown
	end

	local parent2 = parent.Parent
	local name

	while true do
		if parent2 == nil then
			name = nil
			parent2 = nil
			break
		end

		if v2[parent2.Name] == true then
			name = parent2.Name
			break
		else
			parent2 = parent2.Parent
		end
	end

	if name == nil or parent2 == nil then
		warn(
			"AvatarEditorAccessorySlider: No ancestor named RotateX, PositionY, Scale, ... under",
			parent:GetFullName()
		)
		return
	end

	local adjustRange, v12 = getAdjustRange(name, instance, parent2, parent)
	local v13 = name == "EmissiveStrength"

	local function usesInvertedComponentValue()
		return v3[name] == true
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function knobUiToPayloadNormalized(p: number)
		if v3[name] == true == true then
			return -p
		end

		return p
	end

	local function componentValueToKnobUiNormalized(p: number)
		local v16 = normalizedFromComponent(p, adjustRange, v12) -- equivalent call inferred; original call site unknown

		if v3[name] == true == true then
			return -v16
		end

		return v16
	end

	local function clampSnapshotLikeServer(p, p2, p3)
		return
			AccessoryAdjustmentLimits.clampPosition(p),
			AccessoryAdjustmentLimits.clampRotation(p2),
			AccessoryAdjustmentLimits.clampScale(p3)
	end

	local v14 = nil
	local v15 = false
	local flag = false
	local v16 = nil
	local v17 = nil
	local v18 = nil
	local v19 = nil
	local v20 = nil
	local v21 = nil
	local v22 = nil
	local v23 = false
	local v24 = v13 ~= true
	local v25 = false
	local v26 = false
	local v27 = false
	local v28 = dragSoundNameForSliderMode(name) -- equivalent call inferred; original call site unknown
	local v29 = nil

	local function resetDragSoundMoveAnchor()
		v29 = nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function tryPlayDragSound(p: number)
		if v29 ~= nil and math.abs(p - v29) < v6 then
			return
		end

		v29 = p
		waitForAncestorComponent:PlaySoundDragPreview(AccessoryAdjustmentsSoundManager.SOUNDS.MOVE_OR_RESIZE, 1)
	end

	local function applyKnobVisual(value: number)
		local v30 = math.clamp(value, SLIDER_NORMALIZED_MIN, SLIDER_NORMALIZED_MAX)

		if dragAxis == "X" then
			instance.DragUDim2 = UDim2.fromScale(v30, 0)
			parent.Position = UDim2.fromScale(v30 + 0.5, 0.5)
		elseif dragAxis == "Y" then
			instance.DragUDim2 = UDim2.fromScale(0, v30)
			parent.Position = UDim2.fromScale(0.5, v30 + 0.5)
		else
			instance.DragUDim2 = UDim2.fromScale(v30, 0)
			parent.Position = UDim2.fromScale(v30 + 0.5, 0.5)
		end
	end

	local function syncKnobFromSelection()
		if flag then
			return
		end

		local selectedAssetId = AccessoryAdjustmentsState.GetSelectedAssetId()
		applyButtonSelectionVisualState(selectedAssetId ~= nil)

		if selectedAssetId == nil then
			stopKnobBounceImmediate() -- equivalent call inferred; original call site unknown
			local v34 = normalizedFromComponent(name == "Scale" and 1 or 0, adjustRange, v12) -- equivalent call inferred; original call site unknown

			if v3[name] == true == true then
				v34 = -v34
			end

			applyKnobVisual(v34)
			size = parent.Size
		else
			local character = Players.LocalPlayer.Character
			local humanoid = character and character:FindFirstChild("Humanoid")

			if humanoid == nil then
				local v34 = normalizedFromComponent(name == "Scale" and 1 or 0, adjustRange, v12) -- equivalent call inferred; original call site unknown

				if v3[name] == true == true then
					v34 = -v34
				end

				applyKnobVisual(v34)
				size = parent.Size
			else
				local X = name == "Scale" and 1 or 0

				if v13 == true then
					local accessoryByAssetId = findAccessoryByAssetId(humanoid, selectedAssetId)
					local handle

					if accessoryByAssetId ~= nil then
						handle = accessoryByAssetId:FindFirstChild("Handle")

						if handle == nil or not handle:IsA("BasePart") then
							handle = nil
						end
					end

					if handle ~= nil then
						local surfaceAppearance = handle:FindFirstChild(AccessoryAdjustmentsConstants.ACCESSORY_COLOR_SURFACE_APPEARANCE_NAME)

						if surfaceAppearance == nil or not surfaceAppearance:IsA("SurfaceAppearance") then
							surfaceAppearance = nil
						end

						if surfaceAppearance ~= nil then
							X = math.clamp(
								surfaceAppearance.EmissiveStrength,
								AccessoryAdjustmentsConstants.EMISSIVE_STRENGTH_MIN,
								AccessoryAdjustmentsConstants.EMISSIVE_STRENGTH_MAX
							)
						end
					end
				else
					local accessoryDescriptionForRead = findAccessoryDescriptionForRead(
						humanoid:GetAppliedDescription(),
						selectedAssetId
					)
					local scale, position, rotation

					if accessoryDescriptionForRead == nil then
						scale = createVector(1, 1, 1)
						position = createVector(0, 0, 0)
						rotation = createVector(0, 0, 0)
					else
						position = accessoryDescriptionForRead.Position
						rotation = accessoryDescriptionForRead.Rotation
						scale = accessoryDescriptionForRead.Scale
					end

					local v30 = name

					if v30 == "RotateX" then
						X = rotation.X
					elseif v30 == "RotateY" then
						X = rotation.Y
					elseif v30 == "RotateZ" then
						X = rotation.Z
					elseif v30 == "PositionX" then
						X = position.X
					elseif v30 == "PositionY" then
						X = position.Y
					elseif v30 == "PositionZ" then
						X = position.Z
					else
						X = v30 ~= "Scale" and 0 or (scale.X + scale.Y + scale.Z) / 3
					end
				end

				local v33 = normalizedFromComponent(X, adjustRange, v12) -- equivalent call inferred; original call site unknown

				if v3[name] == true == true then
					v33 = -v33
				end

				applyKnobVisual(v33)
				size = parent.Size
			end
		end
	end

	local function computePayloadTables(p: number)
		local v30 = v17
		local v31 = v18
		local v32 = v19

		if v30 == nil or v31 == nil or v32 == nil then
			return clampSnapshotLikeServer({
				X = 0,
				Y = 0,
				Z = 0
			}, {
				X = 0,
				Y = 0,
				Z = 0
			}, {
				X = 1,
				Y = 1,
				Z = 1
			})
		end

		if v3[name] == true == true then
			p = -p
		end

		local v37, v38, v39 = buildSnapshot(name, adjustRange, v12, p, v30, v31, v32)
		return clampSnapshotLikeServer(v37, v38, v39)
	end

	local function applyClientPreview(p: number)
		if v13 == true then
			if v22 == nil then
				return
			end

			if v3[name] == true == true then
				p = -p
			end

			local v32 = componentFromNormalized(p, adjustRange, v12) -- equivalent call inferred; original call site unknown
			v22.EmissiveStrength = math.clamp(
				v32,
				AccessoryAdjustmentsConstants.EMISSIVE_STRENGTH_MIN,
				AccessoryAdjustmentsConstants.EMISSIVE_STRENGTH_MAX
			)
		else
			if v20 == nil then
				return
			end

			local v30, v31, v32 = computePayloadTables(p)
			AccessoryAdjustmentsClientPreview.apply(
				v20,
				Vector3.new(v30.X, v30.Y, v30.Z),
				Vector3.new(v31.X, v31.Y, v31.Z),
				(Vector3.new(v32.X, v32.Y, v32.Z))
			)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function readKnobNormalized()
		if dragAxis == "Y" then
			return (math.clamp(parent.Position.Y.Scale - 0.5, SLIDER_NORMALIZED_MIN, SLIDER_NORMALIZED_MAX))
		end

		return (math.clamp(parent.Position.X.Scale - 0.5, SLIDER_NORMALIZED_MIN, SLIDER_NORMALIZED_MAX))
	end

	local parent3 = parent.Parent

	local function commitJumpToNormalized(p: number)
		local v30 = isGamepadInputType(UserInputService:GetLastInputType()) == false and math.abs(p) <= v7 and 0 or p
		stopKnobBounceImmediate() -- equivalent call inferred; original call site unknown
		local selectedAssetId = AccessoryAdjustmentsState.GetSelectedAssetId()

		if selectedAssetId == nil then
			return
		end

		local character = Players.LocalPlayer.Character
		local humanoid = character and character:FindFirstChild("Humanoid")

		if humanoid == nil then
			return
		end

		if v24 == true then
			AccessoryAdjustmentsState.BeginLiveAdjustmentHighlight()
		end

		applyKnobVisual(v30)

		if v13 == true then
			local accessoryByAssetId = findAccessoryByAssetId(humanoid, selectedAssetId)
			local handle

			if accessoryByAssetId ~= nil then
				handle = accessoryByAssetId:FindFirstChild("Handle")

				if handle == nil or not handle:IsA("BasePart") then
					handle = nil
				end
			end

			local v31 = false
			local v32, emissiveStrength

			if handle == nil then
				emissiveStrength = 0
			else
				v32 = handle:FindFirstChild(AccessoryAdjustmentsConstants.ACCESSORY_COLOR_SURFACE_APPEARANCE_NAME)

				if v32 == nil or not v32:IsA("SurfaceAppearance") then
					v32 = nil
				end

				if v32 == nil then
					v32 = handle:FindFirstChild(AccessoryAdjustmentsConstants.ACCESSORY_COLOR_SURFACE_APPEARANCE_NAME)

					if v32 == nil or not v32:IsA("SurfaceAppearance") then
						v32 = nil
					end

					if v32 == nil then
						v32 = Instance.new("SurfaceAppearance")
						v32.Name = AccessoryAdjustmentsConstants.ACCESSORY_COLOR_SURFACE_APPEARANCE_NAME
						v32.Parent = handle
						v32.AlphaMode = Enum.AlphaMode.TintMask
					end

					v31 = v32 ~= nil
					emissiveStrength = 0
				else
					emissiveStrength = math.clamp(
						v32.EmissiveStrength,
						AccessoryAdjustmentsConstants.EMISSIVE_STRENGTH_MIN,
						AccessoryAdjustmentsConstants.EMISSIVE_STRENGTH_MAX
					)
				end
			end

			if v3[name] == true == true then
				v30 = -v30
			end

			local v34 = adjustRange
			local emissiveStrength2 = math.clamp(
				v34 + (v30 - SLIDER_NORMALIZED_MIN) / v5 * (v12 - v34),
				AccessoryAdjustmentsConstants.EMISSIVE_STRENGTH_MIN,
				AccessoryAdjustmentsConstants.EMISSIVE_STRENGTH_MAX
			)

			if v32 ~= nil then
				v32.EmissiveStrength = emissiveStrength2
			end

			if WearingController.SetAccessoryEmissiveStrength(selectedAssetId, emissiveStrength2) ~= true and v32 ~= nil then
				v32.EmissiveStrength = emissiveStrength

				if v31 == true then
					v32:Destroy()
				end
			end
		else
			local accessoryDescriptionForRead = findAccessoryDescriptionForRead(
				humanoid:GetAppliedDescription(),
				selectedAssetId
			)
			local position, rotation, scale

			if accessoryDescriptionForRead == nil then
				position = createVector(0, 0, 0)
				rotation = createVector(0, 0, 0)
				scale = createVector(1, 1, 1)
			else
				position = accessoryDescriptionForRead.Position
				rotation = accessoryDescriptionForRead.Rotation
				scale = accessoryDescriptionForRead.Scale
			end

			local v31 = AccessoryAdjustmentsState.GetSelectedAccessoryInstance() or findAccessoryByAssetId(
				humanoid,
				selectedAssetId
			)
			local v32

			if v31 ~= nil then
				v32 = AccessoryAdjustmentsClientPreview.tryCapture(v31, position, rotation, scale)
			end

			if v3[name] == true == true then
				v30 = -v30
			end

			local v37, v38, v39 = buildSnapshot(name, adjustRange, v12, v30, position, rotation, scale)
			local clampPosition = AccessoryAdjustmentLimits.clampPosition(v37)
			local clampRotation = AccessoryAdjustmentLimits.clampRotation(v38)
			local clampScale = AccessoryAdjustmentLimits.clampScale(v39)

			if v32 ~= nil then
				AccessoryAdjustmentsClientPreview.apply(
					v32,
					Vector3.new(clampPosition.X, clampPosition.Y, clampPosition.Z),
					Vector3.new(clampRotation.X, clampRotation.Y, clampRotation.Z),
					(Vector3.new(clampScale.X, clampScale.Y, clampScale.Z))
				)
			end

			local v40 = WearingController.SetAccessoryAdjustment(selectedAssetId, {
				position = clampPosition,
				rotation = clampRotation,
				scale = clampScale
			})

			if v32 ~= nil then
				if v40 == true then
					local v41

					if name == "Scale" then
						v41 = Vector3.new(clampScale.X, clampScale.Y, clampScale.Z)
					end

					AccessoryAdjustmentsClientPreview.cleanupAfterApply(v32, name == "Scale", v41)
				else
					AccessoryAdjustmentsClientPreview.restore(v32)
				end
			end
		end

		if v24 == true then
			AccessoryAdjustmentsState.EndLiveAdjustmentHighlight()
		end

		waitForAncestorComponent:PlaySound(v28, 1)
		size = parent.Size
		playKnobBounceAfterClick() -- equivalent call inferred; original call site unknown
	end

	local function clickTopIsTrackNotKnob(vector2: Vector2)
		local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

		if playerGui == nil then
			return false
		end

		local v30 = playerGui:GetGuiObjectsAtPosition(vector2.X, vector2.Y)[1]

		if v30 == nil or (v30 == parent or v30:IsDescendantOf(parent) == true) then
			return false
		end

		return v30 == parent3 or v30:IsDescendantOf(parent3) == true
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function screenPointIsOnKnob(vector2: Vector2)
		local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

		if playerGui == nil then
			return false
		end

		local v30 = playerGui:GetGuiObjectsAtPosition(vector2.X, vector2.Y)[1]
		return v30 ~= nil and (v30 == parent or v30:IsDescendantOf(parent) == true)
	end

	local function cancelActiveDragAndReleasePreview(flag2: boolean?)
		local v30 = v20

		if v14 ~= nil and v15 == true then
			if v13 == true then
				if v22 ~= nil then
					v22.EmissiveStrength = v21 or AccessoryAdjustmentsConstants.EMISSIVE_STRENGTH_MIN

					if v23 == true then
						v22:Destroy()
					end
				end
			elseif flag2 ~= false and v30 ~= nil then
				AccessoryAdjustmentsClientPreview.restore(v30)
			end
		end

		if v24 == true then
			AccessoryAdjustmentsState.EndLiveAdjustmentHighlight()
		end

		flag = false
		v15 = false
		v14 = nil
		v16 = nil
		v17 = nil
		v18 = nil
		v19 = nil
		v21 = nil
		v22 = nil
		v23 = false
		v20 = nil

		if v9 == parent then
			v9 = nil
		end

		v25 = false
		v26 = false
		v27 = false
		v29 = nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isGamepadHoldPressInput(p)
		if isGamepadInputType(p.UserInputType) == true and p.KeyCode == Enum.KeyCode.ButtonA then
			return true
		end

		return p.UserInputType == Enum.UserInputType.MouseButton1 and isGamepadInputType(UserInputService:GetLastInputType()) == true
	end

	local function beginPreviewSessionFromCurrentKnob()
		if v9 ~= nil and v9 ~= parent then
			return false
		end

		v9 = parent
		stopKnobBounceImmediate() -- equivalent call inferred; original call site unknown
		flag = false
		v15 = false
		v14 = nil
		v20 = nil
		v17 = nil
		v18 = nil
		v19 = nil
		v21 = nil
		v22 = nil
		v23 = false
		local selectedAssetId = AccessoryAdjustmentsState.GetSelectedAssetId()

		if selectedAssetId == nil then
			if v9 == parent then
				v9 = nil
			end

			return false
		else
			local character = Players.LocalPlayer.Character
			local humanoid = character and character:FindFirstChild("Humanoid")

			if humanoid == nil then
				if v9 == parent then
					v9 = nil
				end

				return false
			else
				v14 = selectedAssetId
				v15 = true
				flag = true

				if v24 == true then
					AccessoryAdjustmentsState.BeginLiveAdjustmentHighlight()
				end

				local knobNormalized = readKnobNormalized() -- equivalent call inferred; original call site unknown
				v16 = knobNormalized

				if v13 == true then
					local accessoryByAssetId = findAccessoryByAssetId(humanoid, selectedAssetId)
					local handle

					if accessoryByAssetId ~= nil then
						handle = accessoryByAssetId:FindFirstChild("Handle")

						if handle == nil or not handle:IsA("BasePart") then
							handle = nil
						end
					end

					if handle ~= nil then
						local surfaceAppearance = handle:FindFirstChild(AccessoryAdjustmentsConstants.ACCESSORY_COLOR_SURFACE_APPEARANCE_NAME)

						if surfaceAppearance == nil or not surfaceAppearance:IsA("SurfaceAppearance") then
							surfaceAppearance = nil
						end

						if surfaceAppearance == nil then
							local v31 = handle:FindFirstChild(AccessoryAdjustmentsConstants.ACCESSORY_COLOR_SURFACE_APPEARANCE_NAME)

							if v31 == nil or not v31:IsA("SurfaceAppearance") then
								v31 = nil
							end

							if v31 == nil then
								v31 = Instance.new("SurfaceAppearance")
								v31.Name = AccessoryAdjustmentsConstants.ACCESSORY_COLOR_SURFACE_APPEARANCE_NAME
								v31.Parent = handle
								v31.AlphaMode = Enum.AlphaMode.TintMask
							end

							v22 = v31
							v23 = v31 ~= nil
							v21 = 0
						else
							v22 = surfaceAppearance
							v21 = math.clamp(
								surfaceAppearance.EmissiveStrength,
								AccessoryAdjustmentsConstants.EMISSIVE_STRENGTH_MIN,
								AccessoryAdjustmentsConstants.EMISSIVE_STRENGTH_MAX
							)
						end
					end
				else
					local accessoryDescriptionForRead = findAccessoryDescriptionForRead(
						humanoid:GetAppliedDescription(),
						selectedAssetId
					)
					local position, rotation, scale

					if accessoryDescriptionForRead == nil then
						position = createVector(0, 0, 0)
						rotation = createVector(0, 0, 0)
						scale = createVector(1, 1, 1)
					else
						position = accessoryDescriptionForRead.Position
						rotation = accessoryDescriptionForRead.Rotation
						scale = accessoryDescriptionForRead.Scale
					end

					v17 = position
					v18 = rotation
					v19 = scale
					local v31 = AccessoryAdjustmentsState.GetSelectedAccessoryInstance() or findAccessoryByAssetId(
						humanoid,
						selectedAssetId
					)

					if v31 ~= nil then
						v20 = AccessoryAdjustmentsClientPreview.tryCapture(v31, position, rotation, scale)
					end
				end

				applyClientPreview(knobNormalized)
				return true
			end
		end
	end

	local function endPreviewSessionAndCommit(flag2: boolean)
		local v30 = v20

		if v14 ~= nil and v15 == true then
			local v31 = v16

			if v31 == nil then
				if dragAxis == "Y" then
					v31 = math.clamp(parent.Position.Y.Scale - 0.5, SLIDER_NORMALIZED_MIN, SLIDER_NORMALIZED_MAX)
				else
					v31 = math.clamp(parent.Position.X.Scale - 0.5, SLIDER_NORMALIZED_MIN, SLIDER_NORMALIZED_MAX)
				end
			end

			local v32 = flag2 ~= true and isGamepadInputType(UserInputService:GetLastInputType()) == false and math.abs(v31) <= v7 and 0 or v31

			if v13 == true then
				local v33 = knobUiToPayloadNormalized(v32) -- equivalent call inferred; original call site unknown
				local v34 = adjustRange
				local v36 = math.clamp(
					v34 + (v33 - SLIDER_NORMALIZED_MIN) / v5 * (v12 - v34),
					AccessoryAdjustmentsConstants.EMISSIVE_STRENGTH_MIN,
					AccessoryAdjustmentsConstants.EMISSIVE_STRENGTH_MAX
				)

				if WearingController.SetAccessoryEmissiveStrength(v14, v36) ~= true and v22 ~= nil then
					v22.EmissiveStrength = v21 or AccessoryAdjustmentsConstants.EMISSIVE_STRENGTH_MIN

					if v23 == true then
						v22:Destroy()
					end
				end
			else
				local position, rotation, scale = computePayloadTables(v32)
				local v36 = WearingController.SetAccessoryAdjustment(v14, {
					position = position,
					rotation = rotation,
					scale = scale
				})

				if v30 ~= nil then
					if v36 == true then
						local v37

						if name == "Scale" then
							v37 = Vector3.new(scale.X, scale.Y, scale.Z)
						end

						AccessoryAdjustmentsClientPreview.cleanupAfterApply(v30, name == "Scale", v37)
					else
						AccessoryAdjustmentsClientPreview.restore(v30)
					end
				end
			end

			applyKnobVisual(v32)
			waitForAncestorComponent:PlaySound(v28, 1)
			size = parent.Size
			playKnobBounceAfterClick() -- equivalent call inferred; original call site unknown
		end

		cancelActiveDragAndReleasePreview(false)
	end

	local v30 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function detachActiveBindings()
		if v30 == nil then
			return
		end

		stopKnobBounceImmediate() -- equivalent call inferred; original call site unknown
		cancelActiveDragAndReleasePreview()
		v30:Destroy()
		v30 = nil
	end

	local function attachActiveBindings()
		local maid = Janitor.new()
		maid:Add(UserInputService.InputBegan:Connect(function(input, _: boolean)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch or AccessoryAdjustmentsState.GetSelectedAssetId() == nil then
				return
			end

			local v31 = screenPointIsOnKnob(Vector2.new(input.Position.X, input.Position.Y)) -- equivalent call inferred; original call site unknown

			if v31 ~= true then
				return
			end

			local knobNormalized = readKnobNormalized() -- equivalent call inferred; original call site unknown
			tryPlayDragSound(knobNormalized) -- equivalent call inferred; original call site unknown
		end))

		if parent3 ~= nil and parent3:IsA("GuiObject") then
			maid:Add(UserInputService.InputBegan:Connect(function(input, _: boolean)
				if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch or flag == true then
					return
				end

				local vector2 = Vector2.new(input.Position.X, input.Position.Y)

				if clickTopIsTrackNotKnob(vector2) ~= true then
					return
				end

				local v33 = normalizedFromTrackPointer(parent3, vector2, dragAxis) -- equivalent call inferred; original call site unknown

				if v33 == nil then
					return
				end

				commitJumpToNormalized(v33)
			end))
		end

		maid:Add(instance.DragStart:Connect(function(_)
			beginPreviewSessionFromCurrentKnob()
		end))
		maid:Add(instance.DragContinue:Connect(function(_)
			if v14 == nil or flag ~= true then
				return
			end

			local knobNormalized = readKnobNormalized() -- equivalent call inferred; original call site unknown
			local v32 = isGamepadInputType(UserInputService:GetLastInputType()) == false and math.abs(knobNormalized) <= v7 and 0 or knobNormalized

			if v32 ~= knobNormalized then
				applyKnobVisual(v32)
			end

			v16 = v32
			tryPlayDragSound(v32) -- equivalent call inferred; original call site unknown
			applyClientPreview(v32)
		end))
		maid:Add(instance.DragEnd:Connect(function(_)
			endPreviewSessionAndCommit(false)
		end))
		maid:Add(parent.InputBegan:Connect(function(input, _: boolean)
			if not (isGamepadHoldPressInput(input) == true and v25 ~= true) then
				return
			end

			if beginPreviewSessionFromCurrentKnob() == true then
				v25 = true
				local knobNormalized = readKnobNormalized() -- equivalent call inferred; original call site unknown
				tryPlayDragSound(knobNormalized) -- equivalent call inferred; original call site unknown
			end
		end))
		maid:Add(parent.InputEnded:Connect(function(input, _: boolean)
			if not (isGamepadHoldPressInput(input) == true and v25 == true) then
				return
			end

			endPreviewSessionAndCommit(true)
		end))
		maid:Add(UserInputService.InputBegan:Connect(function(input, _: boolean)
			if isGamepadInputType(input.UserInputType) ~= true then
				return
			end

			if input.KeyCode == Enum.KeyCode.DPadLeft then
				v26 = true
			elseif input.KeyCode == Enum.KeyCode.DPadRight then
				v27 = true
			end
		end))
		maid:Add(UserInputService.InputEnded:Connect(function(input, _: boolean)
			if isGamepadInputType(input.UserInputType) ~= true then
				return
			end

			if input.KeyCode == Enum.KeyCode.DPadLeft then
				v26 = false
			elseif input.KeyCode == Enum.KeyCode.DPadRight then
				v27 = false
			end
		end))
		maid:Add(RunService.RenderStepped:Connect(function(dt: number)
			if v25 ~= true then
				return
			end

			local v31 = 0

			if v26 == true then
				v31 -= 1
			end

			if v27 == true then
				v31 += 1
			end

			if v31 == 0 then
				return
			end

			local v32 = v16

			if v32 == nil then
				if dragAxis == "Y" then
					v32 = math.clamp(parent.Position.Y.Scale - 0.5, SLIDER_NORMALIZED_MIN, SLIDER_NORMALIZED_MAX)
				else
					v32 = math.clamp(parent.Position.X.Scale - 0.5, SLIDER_NORMALIZED_MIN, SLIDER_NORMALIZED_MAX)
				end
			end

			local v33 = math.clamp(v32 + v31 * v8 * dt, SLIDER_NORMALIZED_MIN, SLIDER_NORMALIZED_MAX)

			if v33 == v32 then
				return
			end

			applyKnobVisual(v33)
			v16 = v33
			tryPlayDragSound(v33) -- equivalent call inferred; original call site unknown
			applyClientPreview(v33)
		end))
		maid:Add(AccessoryAdjustmentsState.SelectionChanged:Connect(function()
			task.defer(function()
				syncKnobFromSelection()
			end)
		end))
		task.defer(function()
			syncKnobFromSelection()
		end)
		maid:Add(WearingController.OnWearingUpdated:Connect(function()
			task.defer(function()
				syncKnobFromSelection()
			end)
		end))
		maid:Add(AccessoryAdjustmentsState.ResetRequested:Connect(function(p: number)
			if p ~= AccessoryAdjustmentsState.GetSelectedAssetId() then
				return
			end

			task.defer(function()
				if flag == true or v15 == true then
					cancelActiveDragAndReleasePreview(false)
				end

				stopKnobBounceImmediate() -- equivalent call inferred; original call site unknown
				local v35 = normalizedFromComponent(name == "Scale" and 1 or 0, adjustRange, v12) -- equivalent call inferred; original call site unknown

				if v3[name] == true == true then
					v35 = -v35
				end

				applyKnobVisual(v35)
				size = parent.Size
			end)
		end))
		return maid
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onPanelViewChanged(visible: boolean)
		if visible == true then
			detachActiveBindings() -- equivalent call inferred; original call site unknown
			v30 = attachActiveBindings()
		else
			detachActiveBindings() -- equivalent call inferred; original call site unknown
		end
	end

	self._Janitor:Add(waitForAncestorComponent.OnViewChanged:Connect(onPanelViewChanged))
	onPanelViewChanged(waitForAncestorComponent.Instance.Visible) -- equivalent call inferred; original call site unknown
	self._detachActiveBindings = detachActiveBindings
end

function v:Stop()
	if self._detachActiveBindings ~= nil then
		self._detachActiveBindings()
		self._detachActiveBindings = nil
	end

	AccessoryAdjustmentsState.EndLiveAdjustmentHighlight()
	self._Janitor:Destroy()
end

return v