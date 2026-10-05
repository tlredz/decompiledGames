local createVector = vector.create
local RunService = game:GetService("RunService")
local replicatedStorage = game.ReplicatedStorage
local machine = require(replicatedStorage:WaitForChild("Services"):WaitForChild("Core"):WaitForChild("machine"))
local req = machine.req(replicatedStorage, "Classes", "DataTypes", "promise")
local v = {}
local ModelUtil = {
	getAttribute = function(instance, attributeName, value)
		local v2 = debug.info(2, "s")
		local v3 = debug.info(2, "l")
		return req.new(function(callback, callback2)
			local attribute = instance:GetAttribute(attributeName)

			if attribute ~= nil then
				callback(attribute)
				return
			end

			local flag = false
			task.delay(5, function()
				if flag then
					return
				end

				local attribute2 = instance:GetAttribute(attributeName)
				warn(string.format(
					"getAttribute(%s, %s) may never resolve, leaking memory. current value: %s. called from %s:%s",
					instance:GetFullName(),
					attributeName,
					attribute2 == nil and "nil" or attribute2,
					v2,
					v3
				))
			end)
			local lastTime = os.clock()

			while true do
				task.wait(0)
				local v4 = os.clock() - lastTime

				if (value or 1e999) <= v4 then
					break
				end

				if instance:GetAttribute(attributeName) == nil then
					continue
				end

				flag = true
				callback((instance:GetAttribute(attributeName)))
				return
			end

			flag = true
			callback2()
		end)
	end,
	makeTransparent = function(instance, p)
		if not instance:GetAttribute("DefaultTransparency") then
			instance:SetAttribute("DefaultTransparency", instance.Transparency)
		end

		local defaultTransparency = instance:GetAttribute("DefaultTransparency")
		instance.Transparency = p and 1 or defaultTransparency
	end
}

function ModelUtil:applyTransparency(p)
	if self:IsA("BasePart") or self:IsA("Decal") then
		ModelUtil.makeTransparent(self, p)
	elseif self:IsA("ParticleEmitter") or self:IsA("BillboardGui") or self:IsA("SurfaceGui") then
		self.Enabled = not p
	end

	for _, child in pairs(self:GetChildren()) do
		ModelUtil.applyTransparency(child, p)
	end
end

function ModelUtil.lastChild(instance)
	local v2 = instance:GetChildren()[1]

	if v2 then
		instance = ModelUtil.lastChild(v2) or instance
	end

	return instance
end

function ModelUtil.part(_)
	local part = Instance.new("Part")
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.Anchored = true
	part.CanCollide = false
	part.Parent = workspace
	return part
end

function ModelUtil.weldDescendants(part, folder)
	local folder2 = Instance.new("Folder")

	for _, part2 in pairs(folder:GetDescendants()) do
		if not part2:IsA("BasePart") then
			continue
		end

		part2.Anchored = false
		part2.CanCollide = false
		part2.Massless = true
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = part
		weldConstraint.Part1 = part2
		weldConstraint.Parent = folder2
	end

	folder2.Name = "Welds"
	folder2.Parent = folder
	return folder2
end

function ModelUtil.scale(folder, p)
	local primaryPart = folder.PrimaryPart
	local cFrame = primaryPart.CFrame

	for _, part in pairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Size *= p

		if part ~= primaryPart then
			part.CFrame = cFrame + cFrame:inverse() * part.Position * p
		end
	end

	return folder
end

function ModelUtil.move(folder, cFrame)
	local primaryPart = folder.PrimaryPart
	local cFrame2 = primaryPart.CFrame

	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("BasePart") and part ~= primaryPart then
			part.CFrame = cFrame * (cFrame2:inverse() * part.CFrame)
		end
	end

	primaryPart.CFrame = cFrame
	return folder
end

function ModelUtil.runPartDescendants(folder, callback)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			callback(part)
		end
	end
end

function ModelUtil.weldLimb(instance, p, p2)
	local child = instance:FindFirstChild(p2 or p.Name)

	if not child then
		return 1
	end

	ModelUtil.weldDescendants(p, p)
	local manualWeld = Instance.new("ManualWeld")
	manualWeld.Part0 = child
	manualWeld.Part1 = p
	manualWeld.Parent = p
	p.Anchored = false
	p.CanCollide = false
	p.Massless = true
end

function ModelUtil.weldArmor(p, instance)
	for _, child in pairs(instance:GetChildren()) do
		local _ = ModelUtil.weldLimb(p, child) == 1
	end

	return instance
end

local v2 = {}
RunService.Heartbeat:Connect(function()
	for _, v3 in pairs(v2) do
		for _, list in pairs(v3) do
			local v4, v5 = unpack(list)

			if v4.Parent then
				v4.WorldCFrame = v5.TransformedWorldCFrame
			else
				table.remove(boneArray, v2[v4])
				return
			end
		end
	end
end)

function ModelUtil.cloneBones(instance, parent, list)
	local clone = instance:Clone()
	clone:ClearAllChildren()
	clone.Parent = parent

	if not list then
		list = {}
		v2[instance] = list
		instance.AncestryChanged:Connect(function()
			if instance.Parent and clone.Parent then
				return
			end

			v2[instance] = nil
		end)
	end

	table.insert(list, { clone, instance })

	for _, child in pairs(instance:GetChildren()) do
		if child.ClassName == "Bone" then
			ModelUtil.cloneBones(child, clone, list)
		end
	end
end

function ModelUtil.IKRig(p, target)
	local iKControl = Instance.new("IKControl")
	iKControl.Parent = p.AnimationController
	iKControl.Type = Enum.IKControlType.Position
	iKControl.EndEffector = ModelUtil.lastChild(p.Mesh.Bone)
	iKControl.ChainRoot = p.Mesh
	iKControl.Target = target
	iKControl.Pole = nil
end

function ModelUtil.recurseChild(instance, callback, value)
	local v3 = instance:GetChildren()[1]
	local v4 = value or 0
	callback(instance, v4)

	if v3 then
		ModelUtil.recurseChild(v3, callback, v4 + 1)
	end
end

function ModelUtil.manualWeld(part, p, p2, p3)
	local manualWeld = Instance.new("ManualWeld")
	manualWeld.C0 = p2 or CFrame.new(0, 0, 0)
	manualWeld.C1 = p3 or CFrame.new(0, 0, 0)
	manualWeld.Part0 = part
	manualWeld.Part1 = p
	manualWeld.Parent = p
	p.Anchored = false
	p.Massless = true
	return manualWeld
end

function ModelUtil.weld(part, p)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = part
	weldConstraint.Part1 = p
	weldConstraint.Parent = p
	p.Anchored = false
	return weldConstraint
end

function ModelUtil.clientWeld(p, parent, p2)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = p2 or CFrame.new(0, 0, 0)
	cFrameValue.Parent = parent
	v[cFrameValue] = { p, parent }
	parent.Anchored = true
	return cFrameValue
end

function ModelUtil.cacheDescendants(folder, className)
	local descendantsByName = {}

	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA(className) then
			descendantsByName[descendant.Name] = descendant
		end
	end

	return descendantsByName
end

RunService.Heartbeat:Connect(function(_)
	for k, v3 in pairs(v) do
		if k.Parent then
			v3[2].CFrame = v3[1].CFrame * k.Value:inverse()
		else
			v[k] = nil
		end
	end
end)
return ModelUtil