local CollectionService = game:GetService("CollectionService")
local services = game.ReplicatedStorage.Services
require(services:WaitForChild("Table"))
local Object = require(services:WaitForChild("Object"))
game:GetService("RunService")
game.ReplicatedStorage:WaitForChild("GameData")
local Auras = {
	Remove = function(self, p)
		local tagged = CollectionService:GetTagged(p.Name .. "Aura")

		for _, v in tagged do
			v:Destroy()
		end
	end
}

function Auras.Apply(_, folder, folder2)
	Auras:Remove(folder2)
	local v = folder2.Name .. "Aura"

	if not (folder.PrimaryPart and folder2.PrimaryPart) then
		warn("Both auraRig and playerCharacter must have PrimaryPart set.")
		return
	end

	local humanoidRootPart = folder:WaitForChild("HumanoidRootPart")
	local humanoidRootPart2 = folder2:WaitForChild("HumanoidRootPart")
	local cFramesByPart = {}
	local v2 = {}
	local v3 = {}
	local v4 = {}

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			cFramesByPart[part] = part.CFrame
		end
	end

	for _, descendant in folder:GetDescendants() do
		if not (descendant.Name ~= "Overhead" and descendant.Name ~= "TouchInterest") then
			continue
		end

		local v5 = false
		local v6 = nil

		for _, descendant2 in folder2:GetDescendants() do
			if not (descendant.Name == descendant2.Name and Object:GetHierarchyFrom(descendant2, folder2) == Object:GetHierarchyFrom(
				descendant,
				folder
			)) then
				continue
			end

			v6 = descendant2
			v5 = true
			break
		end

		if v5 == true then
			v4[descendant] = v6
		elseif descendant:IsA("Weld") or descendant:IsA("Motor6D") then
			if descendant.Part0 and descendant.Part1 then
				table.insert(v2, {
					original = descendant,
					part0 = descendant.Part0,
					part1 = descendant.Part1,
					parent = descendant.Parent
				})
			end
		elseif descendant:IsA("Beam") then
			table.insert(v3, {
				original = descendant,
				attachment0 = descendant.Attachment0,
				attachment1 = descendant.Attachment1,
				parent = descendant.Parent
			})
		else
			local instance

			if descendant:IsA("Model") or descendant:IsA("Folder") then
				instance = Instance.new(descendant.ClassName)
				instance.Name = descendant.Name
				v4[descendant] = instance
			else
				instance = descendant:Clone()

				if not instance then
					warn("cannot get clone of " .. descendant.Name)
				end

				instance:ClearAllChildren()
				v4[descendant] = instance

				if instance:IsA("BasePart") or instance:IsA("MeshPart") then
					instance.Anchored = false
					instance.Massless = true
					instance.CanCollide = false
					instance.Parent = workspace
					local v8 = cFramesByPart[descendant]

					if v8 then
						local v9 = humanoidRootPart.CFrame:Inverse() * v8
						instance.CFrame = humanoidRootPart2.CFrame * v9
					end
				end
			end

			CollectionService:AddTag(instance, v)
		end
	end

	for k, v5 in pairs(v4) do
		if v5:IsDescendantOf(folder2) then
			continue
		end

		local v6 = k
		local instance = v5
		task.spawn(function()
			local part = v4[v6.Parent] or folder2

			if not part then
				warn("missing parent: %s", Object:PrintHierarchy(v6))
				return
			end

			if instance:IsA("Attachment") and part:IsA("BasePart") then
				instance.Parent = part
			elseif not instance:IsA("Beam") then
				instance.Parent = part
			end

			CollectionService:AddTag(instance, v)
		end)
	end

	for _, v5 in ipairs(v2) do
		local part = v4[v5.part0]
		local part2 = v4[v5.part1]
		local v8 = v4[v5.parent]
		local clone = nil

		if part and part2 then
			clone = v5.original:Clone()
			clone.Part0 = part
			clone.Part1 = part2
			clone.Parent = v8 or part
		else
			warn("Skipping joint: missing parts")
		end

		if clone then
			CollectionService:AddTag(clone, v)
		end
	end

	task.delay(0.1, function()
		for _, v5 in ipairs(v3) do
			local attachment = v4[v5.attachment0]
			local attachment2 = v4[v5.attachment1]
			local clone = v5.original:Clone()
			local v8 = v4[v5.parent]

			if attachment and attachment2 then
				clone.Attachment0 = attachment
				clone.Attachment1 = attachment2
			end

			clone.Parent = v8 or folder2
			CollectionService:AddTag(clone, v)
		end
	end)
end

return Auras