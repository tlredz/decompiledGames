local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MaskFitCore = require(script.Parent.MaskFitCore)
local FaceAnchor = {}
local v = {
	"Head",
	"Eyes",
	"LeftHead",
	"BlinkingPart",
	"RightHead",
	"Value"
}
local v2 = {}
local sharedData = ReplicatedStorage:FindFirstChild("SharedData")
local maskFitData = sharedData and sharedData:FindFirstChild("MaskFitData")

if maskFitData then
	local success, result = pcall(require, maskFitData)

	if success and type(result) == "table" then
		v2 = result
	end
end

FaceAnchor.DEV_CENTRE = "_DevMaskFitCentre"
FaceAnchor.DEV_STANDOFF = "_DevMaskFitStandoff"
FaceAnchor.DEV_COVERAGE = "_DevMaskFitCoverage"
FaceAnchor.DEV_LATERAL = "_DevMaskFitLateral"
FaceAnchor.SKIN_FIT_OFFSET = "_MaskSkinFitOffset"
FaceAnchor.SKIN_FIT_COVERAGE = "_MaskSkinFitCoverage"

local function carriedSkinFit(instance)
	local attribute = instance:GetAttribute(FaceAnchor.SKIN_FIT_OFFSET)
	local attribute2 = instance:GetAttribute(FaceAnchor.SKIN_FIT_COVERAGE)

	if typeof(attribute) == "Vector3" and type(attribute2) == "number" then
		return {
			lateralOffset = attribute.X,
			centreOffset = attribute.Y,
			standoffBias = attribute.Z,
			coverage = attribute2
		}
	end

	return nil
end

local function resolveFit(p)
	local v3 = nil
	local v4 = nil
	local v5 = false
	local parent

	if p then
		parent = p.Parent
	else
		parent = p
	end

	while parent and parent ~= game do
		if parent:IsA("Model") then
			if not v3 then
				local toonName = parent:GetAttribute("ToonName")
				local currentSkin = parent:GetAttribute("CurrentSkin")
				v3, v5 = MaskFitCore.resolveRow(v2, toonName, currentSkin)

				if not v3 then
					v3, v5 = MaskFitCore.resolveRow(v2, parent.Name, currentSkin)
				end
			end

			if not v4 then
				local attribute = tonumber(parent:GetAttribute(FaceAnchor.DEV_CENTRE))
				local attribute2 = tonumber(parent:GetAttribute(FaceAnchor.DEV_STANDOFF))
				local attribute3 = tonumber(parent:GetAttribute(FaceAnchor.DEV_COVERAGE))
				local attribute4 = tonumber(parent:GetAttribute(FaceAnchor.DEV_LATERAL))

				if attribute or attribute2 or attribute3 or attribute4 then
					v4 = {
						centre = attribute or 0,
						standoff = attribute2 or 0,
						coverage = attribute3 or 0,
						lateral = attribute4 or 0
					}
				end
			end
		end

		parent = parent.Parent
	end

	if not v5 and p then
		v3 = carriedSkinFit(p) or v3
	end

	return v3, v4, v5
end

function FaceAnchor.skinTuned(p)
	local _, _, v3 = resolveFit(p)
	return v3
end

local function isRootPart(p)
	return p.Name == "HumanoidRootPart" or p.Name == "RootPart"
end

function FaceAnchor.largestPart(folder)
	local v3 = nil
	local v4 = nil

	for _, part in ipairs(folder:GetDescendants()) do
		if not (part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "RootPart" and part.Name ~= "HalloweenMask") then
			continue
		end

		local v5 = part.Size.X * part.Size.Y * part.Size.Z

		if not (not v3 or v3 < v5) then
			continue
		end

		v4 = part
		v3 = v5
	end

	return v4
end

function FaceAnchor.headBone(folder, p)
	if not (folder and folder.Parent) then
		return nil
	end

	local v3 = p or FaceAnchor.find(folder)
	local position = v3 and v3.Position
	local v4 = {}

	for _, bone in ipairs(folder:GetDescendants()) do
		if not bone:IsA("Bone") then
			continue
		end

		local parent = bone.Parent
		local names = {}

		while parent and parent:IsA("Bone") do
			table.insert(names, parent.Name)
			parent = parent.Parent
		end

		table.insert(v4, {
			bone = bone,
			name = bone.Name,
			dist = not position and 0 or (FaceAnchor.boneRestCFrame(bone).Position - position).Magnitude,
			ancestors = names,
			chainRoot = bone.Parent:IsA("BasePart")
		})
	end

	local headBone = MaskFitCore.pickHeadBone(v4)
	return headBone and headBone.bone
end

function FaceAnchor.boneRestCFrame(instance)
	local cFrame = instance.CFrame
	local parent = instance.Parent

	while parent and parent:IsA("Bone") do
		cFrame = parent.CFrame * cFrame
		parent = parent.Parent
	end

	if parent and parent:IsA("BasePart") then
		return parent.CFrame * cFrame
	end

	return instance.WorldCFrame
end

function FaceAnchor.find(instance)
	if not (instance and instance.Parent) then
		return nil
	end

	local blinkingParts = instance:FindFirstChild("BlinkingParts")

	if blinkingParts then
		for _, childName in ipairs(v) do
			local objectValue = blinkingParts:FindFirstChild(childName)

			if not (objectValue and objectValue:IsA("ObjectValue") and objectValue.Value and objectValue.Value:IsA("BasePart")) then
				continue
			end

			local value = objectValue.Value

			if value.Name ~= "HumanoidRootPart" and value.Name ~= "RootPart" then
				return objectValue.Value
			end
		end

		for _, objectValue in ipairs(blinkingParts:GetChildren()) do
			if objectValue:IsA("ObjectValue") and objectValue.Value and objectValue.Value:IsA("BasePart") then
				return FaceAnchor.largestPart(instance) or objectValue.Value
			end
		end
	end

	local head = instance:FindFirstChild("Head")

	if head and head:IsA("BasePart") then
		return head
	end

	local primaryPart = instance.PrimaryPart

	if primaryPart and primaryPart.Name ~= "HumanoidRootPart" and primaryPart.Name ~= "RootPart" then
		return primaryPart
	end

	return FaceAnchor.largestPart(instance)
end

function FaceAnchor.faces(instance)
	local v3 = FaceAnchor.find(instance)

	if not v3 then
		return {}
	end

	local result = { v3 }
	local blinkingParts = instance:FindFirstChild("BlinkingParts")

	if not blinkingParts then
		return result
	end

	for _, objectValue in ipairs(blinkingParts:GetChildren()) do
		local value = objectValue:IsA("ObjectValue") and objectValue.Value

		if not (value and value:IsA("BasePart") and value.Name ~= "HumanoidRootPart" and value.Name ~= "RootPart") then
			continue
		end

		if not objectValue.Name:find("Head", 1, true) or table.find(result, value) then
			continue
		end

		table.insert(result, value)
	end

	return result
end

FaceAnchor.COVERAGE = 0.85

function FaceAnchor.fitScale(p, p2)
	local fit, v3 = resolveFit(p)
	local coverage = fit and fit.coverage or FaceAnchor.COVERAGE

	if v3 then
		coverage += v3.coverage
	end

	local v4 = math.clamp(coverage, 0.05, 3)
	return math.min(p.Size.X, p.Size.Y) * v4 / math.max(p2, 0.01)
end

function FaceAnchor.standoff(p, value)
	local fit, v3 = resolveFit(p)
	local v4 = (fit and fit.standoffBias or 0) + (v3 and v3.standoff or 0)
	return p.Size.Z / 2 + (value or 0) / 2 + 0.02 + v4
end

function FaceAnchor.centreOffset(p)
	local fit, v3 = resolveFit(p)
	local centreOffset

	if fit and fit.centreOffset then
		centreOffset = fit.centreOffset
	else
		local X = p.Size.X
		local Y = p.Size.Y
		centreOffset = Y <= X and 0 or (X - Y) / 2
	end

	return centreOffset + (v3 and v3.centre or 0)
end

function FaceAnchor.lateralOffset(p)
	local fit, v3 = resolveFit(p)
	return (fit and fit.lateralOffset or 0) + (v3 and v3.lateral or 0)
end

function FaceAnchor.effectiveFit(p)
	local fit, v3 = resolveFit(p)
	local coverage = fit and fit.coverage or FaceAnchor.COVERAGE
	local standoffBias = fit and fit.standoffBias or 0

	if v3 then
		coverage += v3.coverage
		standoffBias += v3.standoff
	end

	return {
		centreOffset = FaceAnchor.centreOffset(p),
		lateralOffset = FaceAnchor.lateralOffset(p),
		coverage = math.clamp(coverage, 0.05, 3),
		standoffBias = standoffBias
	}
end

function FaceAnchor.formatRow(p, data, p2)
	local v3 = {}

	if math.abs(data.centreOffset) > 0.0005 then
		table.insert(v3, string.format("centreOffset = %.3f", data.centreOffset))
	end

	if math.abs(data.lateralOffset or 0) > 0.0005 then
		table.insert(v3, string.format("lateralOffset = %.3f", data.lateralOffset))
	end

	if math.abs(data.coverage - FaceAnchor.COVERAGE) > 0.0005 then
		table.insert(v3, string.format("coverage = %.3f", data.coverage))
	end

	if math.abs(data.standoffBias) > 0.0005 then
		table.insert(v3, string.format("standoffBias = %.3f", data.standoffBias))
	end

	local v4

	if p2 then
		v4 = p .. "/" .. p2
	else
		v4 = p
	end

	if #v3 == 0 then
		return string.format("-- %s: automatic fit, no row needed", v4)
	end

	if p2 then
		return string.format("%s = { skins = { %s = { %s } } },", p, p2, table.concat(v3, ", "))
	end

	return string.format("%s = { %s },", p, table.concat(v3, ", "))
end

function FaceAnchor.centre(p)
	return (p.CFrame * CFrame.new(FaceAnchor.lateralOffset(p), FaceAnchor.centreOffset(p), 0)).Position
end

function FaceAnchor.fitMask(p, state)
	local fitScale = FaceAnchor.fitScale(p, (math.max(state.Size.X, state.Size.Y)))
	state.Size *= fitScale
	local pivotOffset = state.PivotOffset
	state.PivotOffset = CFrame.new(pivotOffset.Position * fitScale) * pivotOffset.Rotation
	return fitScale
end

function FaceAnchor.pivotLift(p)
	return -p.PivotOffset.Y
end

function FaceAnchor.maskCFrame(p, p2)
	return p.CFrame * CFrame.new(
		FaceAnchor.lateralOffset(p),
		FaceAnchor.centreOffset(p) + FaceAnchor.pivotLift(p2),
		-FaceAnchor.standoff(p, p2.Size.Z)
	)
end

return FaceAnchor