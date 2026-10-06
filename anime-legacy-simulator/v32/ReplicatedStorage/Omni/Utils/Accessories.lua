local ReplicatedStorage = game:GetService("ReplicatedStorage")
local accessories = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Accessories")

-- equivalent calls inferred from this helper; original call sites unknown
local function RemoveAccessories(model)
	local accessoriesFolder = model:FindFirstChild("AccessoriesFolder")

	if accessoriesFolder then
		accessoriesFolder:Destroy()
	end
end

local function CreateAccessory(parent, instance)
	local handle = instance:FindFirstChild("Handle")

	if not (handle and handle:IsA("BasePart")) then
		return
	end

	local attachment = handle:FindFirstChildOfClass("Attachment")

	if not attachment then
		return
	end

	local v2 = nil

	for _, part in parent:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		local attachment2 = part:FindFirstChild(attachment.Name)

		if not (attachment2 and attachment2:IsA("Attachment")) then
			continue
		end

		v2 = attachment2
		break
	end

	if not v2 then
		return
	end

	local clone = instance:Clone()
	local handle2 = clone:FindFirstChild("Handle")
	handle2.CFrame = v2.WorldCFrame * attachment.CFrame:Inverse()
	local weld = Instance.new("Weld")
	weld.Name = "AccessoryWeld"
	weld.Part0 = v2.Parent
	weld.Part1 = handle2
	weld.C0 = v2.CFrame
	weld.C1 = attachment.CFrame
	weld.Parent = handle2

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Massless = true
		part.Anchored = false
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.CollisionGroup = "Fighters"
	end

	return clone
end

local function SetAccessories(model, items)
	local parent = model:FindFirstChild("AccessoriesFolder")

	if not parent then
		parent = Instance.new("Folder")
		parent.Name = "AccessoriesFolder"
		parent.Parent = model
	end

	for _, child in parent:GetChildren() do
		local item = items[child.Name]

		if not item or child:GetAttribute("Name") ~= item.Name then
			child:Destroy()
		end
	end

	for childName, item in items do
		local child = parent:FindFirstChild(childName)

		if not (not child or child:GetAttribute("Name") ~= item.Name) then
			continue
		end

		local instance = accessories:FindFirstChild(item.Name)

		if not instance then
			continue
		end

		if instance:IsA("Accessory") then
			local accessory = CreateAccessory(model, instance)

			if accessory then
				accessory.Name = childName
				accessory:SetAttribute("Name", item.Name)
				accessory.Parent = parent
			end
		elseif instance:IsA("Model") then
			local childrenByName = {}

			for _, part in instance:GetChildren() do
				if not part:IsA("BasePart") then
					continue
				end

				local child2 = model:FindFirstChild(part.Name)

				if child2 then
					childrenByName[part.Name] = child2
				end
			end

			if next(childrenByName) then
				local clone = instance:Clone()
				clone.Name = childName
				clone:PivotTo(model:GetPivot())
				clone:SetAttribute("Name", item.Name)

				for childName2, part in childrenByName do
					local child2 = clone:FindFirstChild(childName2)

					if not child2 then
						continue
					end

					local weld = Instance.new("Weld")
					weld.Part0 = part
					weld.Part1 = child2
					weld.Parent = child2
					child2.Transparency = 1
					child2.CastShadow = false
				end

				for _, part in clone:GetChildren() do
					if not part:IsA("BasePart") then
						continue
					end

					part.Massless = true
					part.Anchored = false
					part.CanCollide = false
					part.CollisionGroup = "Fighters"
				end

				clone.Parent = parent
			end
		end
	end
end

return table.freeze({
	EnsureAccessories = function(model, items)
		if not model or typeof(model) ~= "Instance" or not model:IsA("Model") then
			return
		end

		if typeof(items) == "table" then
			for k, item in items do
				if not (typeof(k) ~= "string" or typeof(item) ~= "table" or typeof(item.Name) ~= "string") then
					continue
				end

				items[k] = nil
			end

			SetAccessories(model, items)
		else
			RemoveAccessories(model) -- equivalent call inferred; original call site unknown
		end
	end
})