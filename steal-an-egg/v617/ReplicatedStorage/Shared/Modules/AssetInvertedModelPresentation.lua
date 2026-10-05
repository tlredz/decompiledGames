local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local ModelBounds = require(ReplicatedStorage.Shared.Utils.ModelBounds)
local cframe = CFrame.Angles(0, 0, 3.141592653589793)
local v = {
	"Size",
	"CFrame",
	"PivotOffset",
	"RootPriority",
	"CollisionGroup"
}
local v2 = {
	Transparency = 1,
	CastShadow = false,
	Anchored = true,
	CanCollide = false,
	CanQuery = false,
	CanTouch = false,
	Massless = true
}

local function childOfClass(instance, childName: string, className: string)
	local v3 = assert(instance:FindFirstChild(childName), (`{instance:GetFullName()} lacks {childName}`))
	assert(v3:IsA(className), (`{v3:GetFullName()} should have been a {className}`))
	return v3
end

local function parkWelds(folder)
	local enabledsByWeldConstraint = {}

	for _, weldConstraint in folder:GetDescendants() do
		if not weldConstraint:IsA("WeldConstraint") then
			continue
		end

		enabledsByWeldConstraint[weldConstraint] = weldConstraint.Enabled
		weldConstraint.Enabled = false
	end

	return enabledsByWeldConstraint
end

local function unparkWelds(items)
	for k, item in items do
		k.Enabled = item
	end
end

local function assertStill(cFrame: CFrame, cFrame2: CFrame, p: string)
	local dot = cFrame.XVector:Dot(cFrame2.XVector)
	local dot2 = cFrame.YVector:Dot(cFrame2.YVector)
	local dot3 = cFrame.ZVector:Dot(cFrame2.ZVector)
	assert(
		not ((cFrame.Position - cFrame2.Position).Magnitude > 0.00001 or dot < 0.99999 or dot2 < 0.99999 or dot3 < 0.99999),
		(`{p} shifted during the flip`)
	)
end

local function standInFor(p, parent)
	local part = Instance.new("Part")
	part.Name = "HumanoidRootPart"

	for _, v3 in v do
		part[v3] = p[v3]
	end

	for k, v3 in v2 do
		part[k] = v3
	end

	part.Parent = parent
	return part
end

return {
	Invert = function(self)
		t.strict(t.instanceIsA("Model"))(self)
		local part2 = childOfClass(self, "HumanoidRootPart", "BasePart")
		local v4 = childOfClass(self, "CENTER", "BasePart")
		local v5 = childOfClass(self, "Model", "Model")
		local v6 = childOfClass(part2, "AssetWeld", "WeldConstraint")
		local v7 = childOfClass(v4, "CenterWeld", "WeldConstraint")
		local cFrame = part2.CFrame
		local cFrame2 = v4.CFrame
		local cframe2 = ModelBounds(self)
		local objectSpace = cframe2:ToObjectSpace(v5:GetPivot())
		local v8 = parkWelds(self)
		assert(v8[v6] ~= nil, "AssetWeld escaped the parking sweep")
		assert(v8[v7] ~= nil, "CenterWeld escaped the parking sweep")
		v5:PivotTo(cframe2 * cframe * objectSpace)
		part2.Name = "InvertedModelOriginalRoot"
		local part = Instance.new("Part")
		part.Name = "HumanoidRootPart"

		for _, v9 in v do
			part[v9] = part2[v9]
		end

		for k, v9 in v2 do
			part[k] = v9
		end

		part.Parent = self
		part2.Anchored = false
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Name = "InvertedModelRootWeld"
		weldConstraint.Part0 = part
		weldConstraint.Part1 = part2
		weldConstraint.Parent = part
		self.PrimaryPart = part

		for k, enabled in v8 do
			k.Enabled = enabled
		end

		assertStill(part.CFrame, cFrame, "the stand-in HumanoidRootPart")
		assertStill(v4.CFrame, cFrame2, "CENTER")
	end
}