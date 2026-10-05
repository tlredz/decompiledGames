local JointTree = {}
JointTree.__index = JointTree
local v = {
	Seat = 20,
	VehicleSeat = 20
}
local v2 = {
	HumanoidRootPart = 10,
	Torso = 5
}

local function addJointEdge(p, joint)
	local part0 = joint.Part0
	local part1 = joint.Part1

	if part0 and part1 then
		p[part0] = p[part0] or {}
		p[part1] = p[part1] or {}
		table.insert(p[part0], {
			Joint = joint,
			Part = part1
		})
		table.insert(p[part1], {
			Joint = joint,
			Part = part0
		})
	end
end

local expandTree

expandTree = function(p, p2, options)
	local v3 = p[p2]
	local result = options or {}

	if not v3 then
		return result
	end

	p[p2] = nil

	for _, v4 in v3 do
		local part = v4.Part

		if not p[part] then
			continue
		end

		table.insert(result, v4)
		expandTree(p, part, result)
	end

	return result
end

function JointTree.Build(folder, _)
	local v3 = {}
	local descendants = folder:GetDescendants()

	if folder:IsA("BasePart") then
		table.insert(descendants, 1, folder)
	end

	for _, motor6D in folder:QueryDescendants("JointInstance") do
		local part0 = motor6D.Part0
		local part1 = motor6D.Part1

		if not (part0 and part1) then
			continue
		end

		local transform

		if motor6D:IsA("Motor6D") then
			transform = motor6D.Transform
		end

		addJointEdge(v3, {
			Transform = transform,
			Part0 = part0,
			Part1 = part1,
			C0 = motor6D.C0,
			C1 = motor6D.C1
		})
	end

	for _, animationConstraint in folder:QueryDescendants("Constraint") do
		local attachment0 = animationConstraint.Attachment0
		local attachment1 = animationConstraint.Attachment1

		if not (attachment0 and attachment1) then
			continue
		end

		local parent = attachment0.Parent
		local parent2 = attachment1.Parent

		if not (parent and parent2 and parent:IsA("BasePart") and parent2:IsA("BasePart")) then
			continue
		end

		local transform

		if animationConstraint:IsA("AnimationConstraint") then
			transform = animationConstraint.Transform
		end

		addJointEdge(v3, {
			Transform = transform,
			Part0 = parent,
			Part1 = parent2,
			C0 = attachment0.CFrame,
			C1 = attachment1.CFrame
		})
	end

	local descendants2 = folder:QueryDescendants("BasePart [Anchored=true]")
	local descendant = descendants2[1]

	if #descendants2 == 0 and folder:IsA("BasePart") and folder.Anchored then
		descendant = folder
	end

	if folder:IsA("BasePart") then
		descendant = folder
	end

	if descendant == nil then
		for _, v4 in folder:QueryDescendants("BasePart") do
			if descendant then
				local massless = v4.Massless

				if massless == descendant.Massless then
					local rootPriority = v4.RootPriority
					local rootPriority2 = descendant.RootPriority

					if rootPriority == rootPriority2 then
						local mass = v4.Mass
						local mass2 = descendant.Mass
						local v5 = v2[v4.Name]
						local v6 = v2[descendant.Name]
						local v7 = v[v4.ClassName]
						local v8 = v[descendant.ClassName]

						if v7 then
							mass *= v7
						elseif v5 then
							mass *= v5
						end

						if v8 then
							mass2 *= v8
						elseif v6 then
							mass2 *= v6
						end

						if mass2 < mass then
							descendant = v4
						end
					elseif rootPriority2 < rootPriority then
						descendant = v4
					end
				elseif not massless then
					descendant = v4
				end
			else
				descendant = v4
			end
		end
	end

	assert(descendant, "Model does not have any assembly root!")
	return expandTree(v3, descendant), descendant
end

local object = setmetatable({}, {
	__index = function(_, p)
		return p.CFrame
	end,
	__newindex = function(_, p, cFrame: CFrame)
		p.CFrame = cFrame
	end
})

function JointTree.Solve(items, p, flag: boolean?)
	local v3 = p or object

	for _, item in items do
		local joint = item.Joint
		local part = item.Part
		local part0 = joint.Part0
		local part1 = joint.Part1

		if not (part0 and part1) then
			continue
		end

		local cFrame

		if typeof(joint.C0) == "Instance" then
			cFrame = joint.C0.CFrame
		else
			cFrame = joint.C0
		end

		local cFrame2

		if typeof(joint.C1) == "Instance" then
			cFrame2 = joint.C1.CFrame
		else
			cFrame2 = joint.C1
		end

		if joint.Transform and not flag then
			local transform = joint.Transform

			if part1 == part then
				v3[part1] = v3[part0] * cFrame * transform * cFrame2:Inverse()
			else
				v3[part0] = v3[part1] * cFrame2 * transform:Inverse() * cFrame:Inverse()
			end
		elseif part1 == part then
			v3[part1] = v3[part0] * cFrame * cFrame2:Inverse()
		else
			v3[part0] = v3[part1] * cFrame2 * cFrame:Inverse()
		end
	end
end

return JointTree