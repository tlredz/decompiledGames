local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local House

if RunService:IsClient() then
	House = require(ReplicatedStorage.Modules.Neighbors.House)
else
	House = nil
end

local localPlayer = Players.LocalPlayer
local v = {
	"RightArm",
	"LeftArm",
	"RightLeg",
	"LeftLeg"
}
local v2 = {
	RightArm = {
		Upper = "RightUpperArm",
		Lower = "RightLowerArm",
		End = "RightHand",
		Torso = "UpperTorso",
		TorsoJoint = "RightShoulderRigAttachment",
		LowerJoint2 = "RightWristRigAttachment"
	},
	LeftArm = {
		Upper = "LeftUpperArm",
		Lower = "LeftLowerArm",
		End = "LeftHand",
		Torso = "UpperTorso",
		TorsoJoint = "LeftShoulderRigAttachment",
		LowerJoint2 = "LeftWristRigAttachment"
	},
	RightLeg = {
		Upper = "RightUpperLeg",
		Lower = "RightLowerLeg",
		End = "RightFoot",
		Torso = "LowerTorso",
		TorsoJoint = "RightHipRigAttachment",
		LowerJoint2 = "RightAnkleRigAttachment"
	},
	LeftLeg = {
		Upper = "LeftUpperLeg",
		Lower = "LeftLowerLeg",
		End = "LeftFoot",
		Torso = "LowerTorso",
		TorsoJoint = "LeftHipRigAttachment",
		LowerJoint2 = "LeftAnkleRigAttachment"
	}
}
local v3 = {}
local v4 = {}
local highlight

if RunService:IsClient() then
	highlight = Instance.new("Highlight")
	highlight.Name = "StretchifyHover"
	highlight.FillColor = Color3.fromRGB(255, 220, 100)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.Enabled = false
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
else
	highlight = nil
end

local Stretchify = {
	GetMaxStretchRange = function(self)
		return 64
	end,
	ClampStretchPosition = function(self, instance, p: string, vector: Vector3)
		local v5 = self:GetMap()[p]

		if not v5 then
			return vector
		end

		local child = instance:FindFirstChild(v5.Torso)
		local child2 = child and child:FindFirstChild(v5.TorsoJoint)

		if not (child and child2) then
			return vector
		end

		local worldPosition = child2.WorldPosition
		local v6 = vector - worldPosition
		local magnitude = v6.Magnitude
		local maxStretchRange = self:GetMaxStretchRange()

		if maxStretchRange < magnitude then
			vector = worldPosition + v6.Unit * maxStretchRange
		end

		return vector
	end,
	GetMap = function(self)
		return v2
	end,
	GetLimbGroups = function(_)
		return v
	end,
	GetLimbFromAttributeName = function(_, value: string)
		local selected

		if value:sub(1, 11) == "Stretchify_" then
			selected = value:sub(12)
		end

		if selected and v2[selected] then
			return selected
		end
	end,
	GetLimbFromPlacingAttributeName = function(_, value: string)
		local selected

		if value:sub(1, 18) == "StretchifyPlacing_" then
			selected = value:sub(19)
		end

		if selected and v2[selected] then
			return selected
		end
	end,
	IsLimbPlacing = function(_, instance, p: string)
		local v5 = v3[instance]

		if v5 and v5[p] then
			return true
		end

		return instance:GetAttribute((`StretchifyPlacing_{p}`)) == true
	end,
	GetPartNamesForLimb = function(_, p: string)
		local v5 = v2[p]

		if v5 then
			return { v5.Upper, v5.Lower, v5.End }
		end
	end,
	GetLimbFromPart = function(_, instance, p)
		for _, v5 in v do
			local v6 = v2[v5]

			if p == instance:FindFirstChild(v6.Upper) or p == instance:FindFirstChild(v6.Lower) or p == instance:FindFirstChild(v6.End) then
				return v5
			end
		end
	end,
	GetLimbEndPart = function(self, instance, p: string)
		local v5 = v2[p]
		return v5 and instance:FindFirstChild(v5.End)
	end
}

function Stretchify.SetHoveredLimb(_, p, p2: string?)
	if not highlight then
		return
	end

	local limbEndPart = p and p2 and Stretchify:GetLimbEndPart(p, p2)

	if limbEndPart then
		highlight.Adornee = limbEndPart
		highlight.Parent = limbEndPart
		highlight.Enabled = true
	else
		highlight.Enabled = false
		highlight.Adornee = nil
	end
end

function Stretchify.SetPreview(_, p, p2: string, vector: Vector3?)
	local v5 = v3[p]

	if vector then
		v3[p] = v3[p] or {}
		v3[p][p2] = vector

		for _, v6 in v4 do
			v6(p, p2)
		end
	elseif v5 then
		v5[p2] = nil

		if not next(v5) then
			v3[p] = nil
		end

		for _, v6 in v4 do
			v6(p, p2)
		end
	end
end

function Stretchify.OnPreviewChanged(_, callback)
	table.insert(v4, callback)
end

function Stretchify.ClearPreviews(_, p)
	if p then
		v3[p] = nil
	else
		table.clear(v3)
	end
end

function Stretchify.GetTargetPosition(_, instance, p: string)
	local v5 = v3[instance]
	local selected = v5 and v5[p]

	if selected then
		return selected
	end

	local attribute = instance:GetAttribute((`Stretchify_{p}`))

	if typeof(attribute) == "Vector3" then
		return attribute
	end
end

function Stretchify:IsLimbAttached(instance, p: string)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	return humanoidRootPart ~= nil and humanoidRootPart:FindFirstChild((`StretchConstraint_{p}`)) ~= nil
end

function Stretchify.HasActiveStretch(_, instance)
	for _, v5 in v do
		if typeof(instance:GetAttribute((`Stretchify_{v5}`))) == "Vector3" or Stretchify:IsLimbAttached(instance, v5) then
			return true
		end
	end

	return false
end

function Stretchify.IsLimbStretched(_, instance, p: string)
	return typeof(instance:GetAttribute((`Stretchify_{p}`))) == "Vector3"
end

function Stretchify.GetMouseHit(_, p: string, p2)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local mouseLocation = UserInputService:GetMouseLocation()
	local viewportPointToRay = currentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	local filterDescendantsInstances = {}

	if localPlayer.Character then
		table.insert(filterDescendantsInstances, localPlayer.Character)
	end

	if p2 and p2.ExcludeInstances then
		for _, excludeInstance in p2.ExcludeInstances do
			if excludeInstance then
				table.insert(filterDescendantsInstances, excludeInstance)
			end
		end
	end

	if p == "Surface" then
		if House then
			local currentHouse = House:GetCurrentHouse()
			local currentPrefab = House:GetCurrentPrefab()

			if currentHouse and currentPrefab and currentHouse.Model and currentPrefab.Model then
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				raycastParams.FilterDescendantsInstances = { currentHouse.Model, currentPrefab.Model }
				local raycastResult = workspace:Raycast(
					viewportPointToRay.Origin,
					viewportPointToRay.Direction * 64,
					raycastParams
				)

				if raycastResult then
					return raycastResult.Position, nil, raycastResult.Instance
				end
			end
		end

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
		local raycastResult = workspace:Raycast(
			viewportPointToRay.Origin,
			viewportPointToRay.Direction * 64,
			raycastParams
		)

		if not raycastResult then
			return
		end

		local model = raycastResult.Instance:FindFirstAncestorOfClass("Model")

		if model and Players:GetPlayerFromCharacter(model) then
			return
		else
			return raycastResult.Position, nil, raycastResult.Instance
		end
	else
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
		local raycastResult = workspace:Raycast(
			viewportPointToRay.Origin,
			viewportPointToRay.Direction * 64,
			raycastParams
		)

		if not raycastResult then
			return
		end

		local model = raycastResult.Instance:FindFirstAncestorOfClass("Model")
		local playerFromCharacter = model and Players:GetPlayerFromCharacter(model)

		if playerFromCharacter and playerFromCharacter ~= localPlayer then
			return raycastResult.Position, model, raycastResult.Instance
		end
	end
end

return Stretchify