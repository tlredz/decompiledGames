local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local GameUtil = require(ReplicatedStorage.Modules.Shared.Game.GameUtil)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local CharacterUtil = require(ReplicatedStorage.Modules.Shared.Utils.CharacterUtil)
local t = require(ReplicatedStorage.Packages.t)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local OnlyRunOnPropOwner = require(ReplicatedStorage.Modules.Shared.Components.Props.Extensions.OnlyRunOnPropOwner)
local PropRoot = require(ReplicatedStorage.Modules.Client.Components.Props.PropRoot)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local Signal = require(ReplicatedStorage.Packages.Signal)
local BasePartUtil = require(ReplicatedStorage.Modules.Shared.Utils.BasePartUtil)
local VehicleRoot = require(ReplicatedStorage.Modules.Client.Components.Vehicles.VehicleRoot)
local Helicopter = require(ReplicatedStorage.Modules.Client.Components.Vehicles.Helicopter)
local HotAirBalloon = require(ReplicatedStorage.Modules.Client.Components.Vehicles.HotAirBalloon)
local PropTextures = require(ReplicatedStorage.Modules.Shared.Props.PropTextures)
local v = Component.new({
	Tag = "PropEditable",
	Extensions = { OnlyRunOnPropOwner }
})
local v2 = nil
local v3 = nil
v.OnDeselected = Signal.new()
v.OnSelected = Signal.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function isWithinDistanceLimit(p)
	return CharacterUtil.distanceTo(localPlayer.Character, p.Instance, "UpperTorso") <= 90
end

function v.GetCurrentSelectedPropEditable()
	return v2
end

function v:Highlight()
	if v2 then
		v2:Deselect()
	end

	self.highlight = Instance.new("Highlight")
	self.highlight.Parent = self.Instance
	self.highlight.FillColor = Color3.fromHex("#00ff00")
	self.highlight.OutlineColor = Color3.fromHex("#00ff00")
	self.highlight.OutlineTransparency = 0.3
	self.highlight.FillTransparency = 1
	self.highlight.Parent = self.Instance
	v2 = self
end

function v:RemoveHighlight()
	if not self.highlight then
		return
	end

	self.highlight:Destroy()
	self.highlight = nil
end

function v.ChangeCollision(p, flag: boolean)
	if not t.boolean(flag) then
		return
	end

	p.controlsUsed.Collision = not p.controlsUsed.Collision and 1 or p.controlsUsed.Collision + 1
	Remotes.invokeServerComponent(p.Instance, "ChangeCollision", flag)
end

function v.ApplyTexture(p, p2: string)
	if not t.string(p2) or p2 ~= "" and not PropTextures.IsValid(p2) then
		return
	end

	p.controlsUsed.Texture = not p.controlsUsed.Texture and 1 or p.controlsUsed.Texture + 1
	Remotes.invokeServerComponent(p.Instance, "ApplyTexture", p2)
end

function v:LoadBillboardGui()
	self.billboardGui = v3:Clone()
	local playerGui = localPlayer:FindFirstChild("PlayerGui")

	if not playerGui then
		warn("PropEditable: No player gui found")
		return
	end

	self.billboardGui.Adornee = self.Instance.PrimaryPart
	self.billboardGui.Enabled = true
	self.billboardGui.Parent = playerGui
end

function v:RemoveBillboardGui()
	if not self.billboardGui then
		return
	end

	self.billboardGui:Destroy()
	self.billboardGui = nil
end

function v.Duplicate(p)
	local v4, v5 = Remotes.invokeServerComponent(p.Instance, "DuplicateProp")

	if v4 then
		return true, "Prop duplicated successfully"
	end

	return false, v5
end

function v.ChangeColor(p, color: Color3)
	if not t.Color3(color) then
		return
	end

	p.controlsUsed.Color = not p.controlsUsed.Color and 1 or p.controlsUsed.Color + 1
	Remotes.invokeServerComponent(p.Instance, "ChangePropColor", color)
end

local function getModelBaseY(instance)
	local boundingBox, v4 = instance:GetBoundingBox()
	local v5 = v4.X / 2
	local v6 = v4.Y / 2
	local v7 = v4.Z / 2
	local Y = 1e999

	for i = -1, 1, 2 do
		for i2 = -1, 1, 2 do
			for i3 = -1, 1, 2 do
				local position = (boundingBox * CFrame.new(i * v5, i2 * v6, i3 * v7)).Position

				if position.Y < Y then
					Y = position.Y
				end
			end
		end
	end

	return Y
end

function v:PreviewScale(p: number, p2: number)
	if not GameUtil.IsPrivateServer() then
		return false, "Resizing is only available on private servers"
	end

	if not (t.number(p) and t.number(p2)) then
		return
	end

	local instance = self.Instance

	if not instance.PrimaryPart then
		return
	end

	instance:ScaleTo(p)

	if instance:GetAttribute("PropScaleFromPivot") ~= true then
		local v4 = p2 - getModelBaseY(instance)

		if v4 ~= 0 then
			instance:PivotTo(instance:GetPivot() + Vector3.new(0, v4, 0))
		end
	end

	self:syncBillboardPreviewAnchor()
end

function v:SetCurrentScale(p2: number)
	if not t.number(p2) then
		return false, "Invalid scale"
	end

	if self.Instance and self.Instance:FindFirstChild("SetCurrentScale") then
		if self.controlsUsed then
			self.controlsUsed.Scale = not self.controlsUsed.Scale and 1 or self.controlsUsed.Scale + 1
		end

		return Remotes.invokeServerComponent(self.Instance, "SetCurrentScale", p2)
	else
		return false, "No set current scale remote"
	end
end

function v:CheckDistanceLimitRoutine()
	self._Janitor:Add(task.defer(function()
		while true do
			if not isWithinDistanceLimit(self) or v2 ~= self then
				break
			end

			task.wait(1)
		end

		self:Deselect()
	end))
end

function v:IsSelectable()
	return isWithinDistanceLimit(self) and v2 ~= self
end

function v:Select()
	if self:IsSelectable() then
		local instance = self.Instance
		self.disabledSeats = {}

		for _, seat in instance:GetDescendants() do
			if not seat:IsA("Seat") then
				continue
			end

			seat.Disabled = true
			table.insert(self.disabledSeats, seat)
		end

		self.startTime = os.clock()
		self.controlsUsed = {}
		self:Highlight()
		self:LoadBillboardGui()
		self:CheckDistanceLimitRoutine()
		v.OnSelected:Fire(self)
	elseif v2 and v2 ~= self then
		v2:Deselect()
	end
end

function v:Deselect(p: string?)
	if not (v2 == self and self.Instance) then
		return
	end

	if p ~= "Delete" and self.previewActive == true then
		local instance = self.Instance

		if instance.PrimaryPart ~= nil then
			self:RestorePrimaryPartAnchorAfterPreview()
			self:SetCurrentScale(instance:GetScale())
			self:SetCurrentCFrame("Deselect")
		end
	end

	self:EndPreview()
	local duration = os.clock() - self.startTime
	pcall(function()
		local v5 = {
			duration = duration,
			controlsUsed = self.controlsUsed,
			propDeleted = false,
			propName = self.propRoot:GetName()
		}

		if p then
			v5.propDeleted = p == "Delete"
		end

		TelemetryController.SendClientInteraction("propAdjusted", v5)
	end)
	self.controlsUsed = {}
	self.controlsUsed = nil
	v2 = nil
	self:RemoveHighlight()
	self:RemoveBillboardGui()

	if self.Instance and self.Instance:FindFirstChild("ResumePropBehavior") then
		Remotes.invokeServerComponent(self.Instance, "ResumePropBehavior")
	end

	v.OnDeselected:Fire()
end

function v:SetPartAttachedToVehicle(partAttached)
	self.partAttached = partAttached
end

function v:GetPartAttachedToVehicle()
	return self.partAttached
end

function v:IsWithinVehicleBounds(cframe: CFrame)
	if not t.CFrame(cframe) then
		return false
	end

	if not self.weldConstraint then
		return true
	end

	if not self.vehicleBoundsPart then
		local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
			self:GetPartAttachedToVehicle(),
			"VehicleRoot",
			VehicleRoot
		)
		local waitForAncestorComponent2 = ComponentUtil.FindAndWaitForAncestorComponent(
			self:GetPartAttachedToVehicle(),
			"Helicopter",
			Helicopter
		)
		local waitForAncestorComponent3 = ComponentUtil.FindAndWaitForAncestorComponent(
			self:GetPartAttachedToVehicle(),
			"HotAirBalloon",
			HotAirBalloon
		)

		if not (waitForAncestorComponent or waitForAncestorComponent2 or waitForAncestorComponent3) then
			return false, "VehicleRoot, Helicopter, or HotAirBalloon not found"
		end

		local v4 = waitForAncestorComponent2 or waitForAncestorComponent3 or waitForAncestorComponent

		if not v4 then
			return false, "VehicleRoot not found"
		end

		local instance = v4.Instance
		local extentsSize = instance:GetExtentsSize()
		local part = Instance.new("Part")
		part.Size = extentsSize
		part.CFrame = instance.PrimaryPart.CFrame
		part.Transparency = 1
		part.Anchored = true
		part.CanCollide = false
		part.Parent = workspace
		self.vehicleBoundsPart = part
	end

	if BasePartUtil.isPointInPart(self.vehicleBoundsPart, cframe.Position) then
		return true
	end

	return false
end

function v:captureBillboardPreviewAnchor()
	if self.billboardGui == nil then
		return
	end

	local primaryPart = self.Instance.PrimaryPart

	if primaryPart == nil then
		return
	end

	self._billboardStudsOffsetAtPreviewStart = self.billboardGui.StudsOffset
	self._billboardStudsOffsetWorldSpaceAtPreviewStart = self.billboardGui.StudsOffsetWorldSpace
	self._billboardWorldAnchorPosition = primaryPart.CFrame:PointToWorldSpace(self.billboardGui.StudsOffset) + self.billboardGui.StudsOffsetWorldSpace
end

function v:syncBillboardPreviewAnchor()
	if self._billboardWorldAnchorPosition == nil or self.billboardGui == nil then
		return
	end

	local primaryPart = self.Instance.PrimaryPart

	if primaryPart == nil then
		return
	end

	self.billboardGui.StudsOffset = createVector(0, 0, 0)
	self.billboardGui.StudsOffsetWorldSpace = self._billboardWorldAnchorPosition - primaryPart.Position
end

function v:restoreBillboardPreviewAnchor()
	if self.billboardGui ~= nil then
		if self._billboardStudsOffsetAtPreviewStart ~= nil then
			self.billboardGui.StudsOffset = self._billboardStudsOffsetAtPreviewStart
		end

		if self._billboardStudsOffsetWorldSpaceAtPreviewStart ~= nil then
			self.billboardGui.StudsOffsetWorldSpace = self._billboardStudsOffsetWorldSpaceAtPreviewStart
		end
	end

	self._billboardWorldAnchorPosition = nil
	self._billboardStudsOffsetAtPreviewStart = nil
	self._billboardStudsOffsetWorldSpaceAtPreviewStart = nil
end

function v:BeginPreview()
	if self.previewActive then
		return
	end

	self.previewActive = true
	self:captureBillboardPreviewAnchor()

	if self.Instance and self.Instance:FindFirstChild("BeginPreview") then
		Remotes.invokeServerComponent(self.Instance, "BeginPreview")
	end
end

function v:EndPreview()
	if not self.previewActive then
		return
	end

	self.previewActive = false
	self:restoreBillboardPreviewAnchor()

	if self.Instance and self.Instance:FindFirstChild("EndPreview") then
		Remotes.invokeServerComponent(self.Instance, "EndPreview")
	end
end

function v:RestorePrimaryPartAnchorAfterPreview()
	local instance = self.Instance

	if not instance.PrimaryPart then
		return
	end

	instance.PrimaryPart.Anchored = self.weldConstraint == nil
end

function v:PreviewCFrame(cframe: CFrame)
	if not t.CFrame(cframe) then
		return
	end

	if self.weldConstraint then
		self.weldConstraint.Enabled = false
	end

	self.highlight.OutlineColor = Color3.fromHex("#00ff00")

	if not self:IsWithinVehicleBounds(cframe) then
		self.highlight.OutlineColor = Color3.fromHex("#ff0000")
		return
	end

	local instance = self.Instance

	if not instance.PrimaryPart then
		return
	end

	instance:PivotTo(cframe)
end

function v:SetCurrentCFrame(p: string?)
	local instance = self.Instance

	if not instance.PrimaryPart then
		return false, "No primary part found"
	end

	if self.vehicleBoundsPart then
		self.vehicleBoundsPart:Destroy()
		self.vehicleBoundsPart = nil
	end

	self.controlsUsed[p] = not self.controlsUsed[p] and 1 or self.controlsUsed[p] + 1
	local pivot = instance:GetPivot()

	if not self.Instance then
		return false, "No instance found"
	end

	if not self.Instance:FindFirstChild("SetCurrentCFrame") then
		return false, "No set current cframe remote event found"
	end

	local v4, v5 = Remotes.invokeServerComponent(self.Instance, "SetCurrentCFrame", pivot)

	if self.weldConstraint then
		self.weldConstraint.Enabled = true
	end

	return v4, v5
end

function v.GetOriginalCFrame(p)
	return p.originalCFrame
end

function v:GetCurrentColor()
	for _, descendant in self.Instance:GetDescendants() do
		if not (descendant.className == "BoolValue" and descendant.Name == "ColorChange") then
			continue
		end

		if descendant.Parent:IsA("BasePart") then
			return descendant.Parent.Color
		end

		if not (descendant.Parent:IsA("ParticleEmitter") or descendant.Parent:IsA("Trail") or descendant.Parent:IsA("Beam")) then
			continue
		end

		local color = descendant.Parent.Color

		if color and #color.Keypoints > 0 then
			return color.Keypoints[1].Value
		end
	end

	return nil
end

function v:SetDefaultColor()
	self.defaultColor = self:GetCurrentColor()
end

function v.GetDefaultColor(p)
	return p.defaultColor or Color3.fromRGB(65, 96, 234)
end

function v:Construct()
	self._Janitor = Janitor.new()
	v3 = v3 or ReplicatedStorage:WaitForChild("PropsBillboard")
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "SelectedProp", function()
		self:Select()
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "DeselectProp", function()
		self:Deselect()
	end))
	self._Janitor:Add(Remotes.connect("Props:OnToggleEditMode", function(flag: boolean)
		if not flag then
			self:Deselect()
		end
	end))
end

function v:Start()
	self.originalCFrame = self.Instance:GetPivot()
	local propMaker = localPlayer.Character:FindFirstChild("PropMaker")

	if propMaker then
		self._Janitor:Add(propMaker.AncestryChanged:Connect(function()
			self:Deselect()
		end))
		self._Janitor:Add(propMaker.Destroying:Connect(function()
			self:Deselect()
		end))
	end

	self.weldConstraint = self.Instance:FindFirstChild("PropWeldConstraint")

	if self.weldConstraint then
		self:SetPartAttachedToVehicle(self.weldConstraint.Part1)
	end

	self.propRoot = ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "PropRoot", PropRoot)
	self:SetDefaultColor()
end

function v:Stop()
	if self.highlight then
		self.highlight:Destroy()
		self.highlight = nil
	end

	if self.billboardGui then
		self.billboardGui:Destroy()
		self.billboardGui = nil
	end

	if self.vehicleBoundsPart then
		self.vehicleBoundsPart:Destroy()
		self.vehicleBoundsPart = nil
	end

	if self.weldConstraint then
		self.weldConstraint = nil
	end

	if self.partAttached then
		self.partAttached = nil
	end

	if self.propRoot then
		self.propRoot = nil
	end

	self._Janitor:Destroy()
end

return v