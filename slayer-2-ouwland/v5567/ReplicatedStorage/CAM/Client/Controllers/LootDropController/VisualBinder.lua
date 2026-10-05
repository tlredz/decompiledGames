local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer
local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local ItemModels = require(ReplicatedStorage.CAM.Global.Collectibles.ItemModels)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Rarities = require(ReplicatedStorage.CAM.Global.Rarities)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local clientEffects = ReplicatedStorage.Communication.CnC.ClientEffects

local function resolveItemModel(p: string)
	local unEquipped = ItemModels.Get(p, "UnEquipped")

	if unEquipped == nil or not unEquipped:IsA("Model") then
		return nil
	end

	return unEquipped
end

local drops_VFX = ReplicatedStorage.Assets.Drops_VFX

local function snapshotAppearance(clone)
	local result = {}

	for _, v in clone:QueryDescendants("BasePart") do
		result[v] = {
			transparency = v.Transparency,
			color = v.Color
		}
	end

	return result
end

local function applyGreyscale(object)
	for _, v in object:QueryDescendants("BasePart") do
		v.Transparency = math.clamp(v.Transparency + 0.35, 0, 1)
		v.Color = Color3.fromRGB(140, 140, 140)
	end
end

local function restoreAppearance(items)
	for k, item in items do
		if not k.Parent then
			continue
		end

		k.Transparency = item.transparency
		k.Color = item.color
	end
end

local function isHiddenFromLocal(instance)
	if instance:GetAttribute("DropPrivate") ~= true then
		return false
	end

	local dropOwnerUserId = instance:GetAttribute("DropOwnerUserId")
	return typeof(dropOwnerUserId) == "number" and dropOwnerUserId ~= localPlayer.UserId
end

local function isEligible(instance)
	local dropOwnerUserId = instance:GetAttribute("DropOwnerUserId")

	if typeof(dropOwnerUserId) == "number" and dropOwnerUserId ~= localPlayer.UserId then
		return false
	end

	local dropReservedFor = instance:GetAttribute("DropReservedFor")
	return (typeof(dropReservedFor) ~= "string" or string.find(
		dropReservedFor,
		"," .. localPlayer.UserId .. ",",
		1,
		true
	)) and true or false
end

local v = {}
local heartbeatConnection = nil

local function step(p: number)
	local character = localPlayer.Character
	local position = character and character:GetPivot().Position

	for k, v2 in v do
		if v2.phase == "flight" then
			v2.elapsed = math.min(v2.elapsed + p, v2.duration)
			v2.spin += p * 4
			local lerped = v2.startPosition:Lerp(v2.restPosition, v2.elapsed / v2.duration)
			local v3 = v2.startPosition.Y + v2.verticalVelocity * v2.elapsed - Workspace.Gravity * v2.elapsed * v2.elapsed * 0.5

			if v2.model then
				v2.model:PivotTo(CFrame.new(lerped.X, v3, lerped.Z) * CFrame.Angles(0, v2.spin, 0) * v2.baseRotation)
			end

			if v2.elapsed >= v2.duration then
				v2.phase = "idle"

				if v2.vfx then
					v2.vfx.Parent = k
				end

				if v2.prompt then
					v2.prompt.Enabled = v2.canClaim
				end
			end
		elseif v2.model ~= nil and not (position and (position - v2.restPosition).Magnitude > 150) then
			v2.spin += p * 2.5
			v2.model:PivotTo(CFrame.new(v2.restPosition) * CFrame.Angles(0, v2.spin, 0) * v2.baseRotation)
		end
	end
end

local function syncEligibility(state, parent)
	local eligible = isEligible(parent)

	if eligible == state.canClaim then
		return
	end

	state.canClaim = eligible

	if eligible then
		for k, v2 in state.appearance do
			if not k.Parent then
				continue
			end

			k.Transparency = v2.transparency
			k.Color = v2.color
		end
	elseif state.model then
		applyGreyscale(state.model)
	end

	if state.vfx then
		vfxUtility.EnableAll(state.vfx, eligible)
	end

	if state.prompt and state.phase == "idle" then
		state.prompt.Enabled = eligible
	end
end

local function retire(p, p2: number?)
	local v2 = v[p]

	if not v2 then
		return
	end

	if v2.attrConn then
		v2.attrConn:Disconnect()
	end

	v[p] = nil

	if heartbeatConnection and next(v) == nil then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	if v2.vfx then
		if v2.vfx.Parent == nil then
			v2.vfx:Destroy()
		else
			v2.vfx.Parent = Workspace.Debree
			vfxUtility.EnableAll(v2.vfx, false)
			DebrisModule:AddItem(v2.vfx, 1.3)
		end
	end

	if v2.model then
		v2.model.Parent = Workspace.Debree

		for _, v3 in v2.model:QueryDescendants("BasePart") do
			TweenService:Create(v3, tweenInfo, {
				Transparency = 1
			}):Play()
		end

		DebrisModule:AddItem(v2.model, 0.35)
	end

	if p2 == localPlayer.UserId then
		clientEffects:Fire("QuestPickup", v2.restPosition)
	end
end

local VisualBinder = {
	cleanup = function(p)
		retire(p, nil)
	end,
	attach = function(parent)
		if v[parent] then
			return
		end

		local v2

		if parent:GetAttribute("DropPrivate") == true then
			local dropOwnerUserId = parent:GetAttribute("DropOwnerUserId")

			if typeof(dropOwnerUserId) == "number" then
				v2 = dropOwnerUserId ~= localPlayer.UserId
			else
				v2 = false
			end
		else
			v2 = false
		end

		if v2 then
			local proximityPrompt = parent:FindFirstChildWhichIsA("ProximityPrompt")

			if proximityPrompt then
				proximityPrompt.Enabled = false
			end
		else
			local dropItemId = tostring(parent:GetAttribute("DropItemId") or "Loot")
			local dropStart = parent:GetAttribute("DropStart") or parent.Position
			local dropTarget = parent:GetAttribute("DropTarget") or parent.Position
			local duration = math.max(parent:GetAttribute("DropFlightTime") or 1, 0.1)
			local v4 = dropTarget.Y - parent.Size.Y * 0.5
			local item = Items[dropItemId]
			local v5 = Rarities.Order[item and item.Rarity or 1]
			local part = drops_VFX:FindFirstChild(v5)
			local clone = nil

			if part and part:IsA("BasePart") then
				clone = part:Clone()
				clone.Anchored = true
				clone.CanCollide = false
				clone.CanTouch = false
				clone.CanQuery = false
				clone.Massless = true
				clone.CFrame = CFrame.new(dropTarget.X, v4 + clone.Size.Y * 0.5, dropTarget.Z)
			else
				warn((`Loot drop rarity VFX '{v5}' missing from Assets.Drops_VFX`))
			end

			local unEquipped = ItemModels.Get(dropItemId, "UnEquipped")

			if unEquipped == nil or not unEquipped:IsA("Model") then
				unEquipped = nil
			end

			local identity = CFrame.identity
			local vector = Vector3.new(dropTarget.X, v4, dropTarget.Z)
			local clone2

			if unEquipped then
				clone2 = unEquipped:Clone()
				local _, v6 = clone2:GetBoundingBox()
				local v7 = math.max(v6.X, v6.Y, v6.Z)

				if v7 > 0 then
					clone2:ScaleTo(clone2:GetScale() * 2 / v7)
				end

				for _, v8 in clone2:QueryDescendants("BasePart") do
					v8.Anchored = true
					v8.CanCollide = false
					v8.CanTouch = false
					v8.CanQuery = false
				end

				local boundingBox, v8 = clone2:GetBoundingBox()
				clone2.PrimaryPart = nil
				clone2.WorldPivot = boundingBox
				identity = boundingBox.Rotation
				local v9 = (math.abs(identity.XVector.Y) * v8.X + math.abs(identity.YVector.Y) * v8.Y + math.abs(identity.ZVector.Y) * v8.Z) * 0.5
				vector = Vector3.new(dropTarget.X, v4 + v9, dropTarget.Z)
				clone2:PivotTo(CFrame.new(dropStart) * identity)
				clone2.Parent = parent
			end

			local eligible = isEligible(parent)

			if not eligible and clone then
				vfxUtility.EnableAll(clone, false)
			end

			local proximityPrompt = parent:FindFirstChildWhichIsA("ProximityPrompt")

			if proximityPrompt then
				proximityPrompt.Enabled = false
			end

			local v6 = {
				model = clone2,
				vfx = clone,
				prompt = proximityPrompt,
				appearance = not clone2 and {} or snapshotAppearance(clone2),
				canClaim = eligible,
				baseRotation = identity,
				startPosition = dropStart,
				restPosition = vector,
				verticalVelocity = (vector.Y - dropStart.Y) / duration + Workspace.Gravity * duration * 0.5,
				duration = duration,
				elapsed = 0,
				spin = math.random() * 3.141592653589793 * 2,
				phase = "flight",
				attrConn = nil
			}
			v[parent] = v6

			if not eligible and clone2 then
				applyGreyscale(clone2)
			end

			v6.attrConn = parent.AttributeChanged:Connect(function(p: string)
				if p == "DropClaimedBy" then
					retire(parent, parent:GetAttribute("DropClaimedBy"))
				elseif p == "DropOwnerUserId" or p == "DropReservedFor" then
					syncEligibility(v6, parent)
				end
			end)

			if not heartbeatConnection then
				heartbeatConnection = RunService.Heartbeat:Connect(step)
			end
		end
	end
}

function VisualBinder.teardown()
	for k in v do
		VisualBinder.cleanup(k)
	end
end

return VisualBinder