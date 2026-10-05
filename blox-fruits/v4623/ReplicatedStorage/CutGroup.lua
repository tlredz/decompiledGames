if not workspace:FindFirstChild("CutParts") then
	local folder = Instance.new("Folder")
	folder.Name = "CutParts"
	folder.Parent = workspace
end

local util = game.ReplicatedStorage.Util
require(util.Signal2)
require(script.CutMesh)
require(script.CutUnion)
require(script.ShellBuilder)

function findCuttableParent(p)
	if not p.Parent then
		return nil
	end

	if p.Parent:HasTag("CuttableObject") then
		return p.Parent
	end

	return findCuttableParent(p.Parent)
end

require(game.ReplicatedStorage.Util.Realm)

function GetParent(parent)
	local _ = parent.Parent

	while not parent:HasTag("CuttableObject") and parent.Parent do
		parent = parent.Parent
	end

	if parent:HasTag("BeingCut") then
		return
	else
		return parent
	end
end

local function getCasterName(p)
	return p and p.Name
end

local function getCasterCharacter(instance)
	if not (instance and typeof(instance) == "Instance") then
		return nil
	end

	if instance:IsA("Player") then
		return instance.Character
	end

	if instance:IsA("Model") then
		return instance
	end

	return nil
end

local function getControlTool(player, character)
	local controlControl = character:FindFirstChild("Control-Control")

	if controlControl and controlControl:IsA("Tool") then
		return controlControl
	end

	local tool = character:FindFirstChildOfClass("Tool")

	if tool and tool.Name == "Control-Control" then
		return tool
	end

	if typeof(player) == "Instance" and player:IsA("Player") then
		for _, tool2 in pairs(player.Backpack:GetChildren()) do
			if tool2:IsA("Tool") and tool2.Name == "Control-Control" then
				return tool2
			end
		end
	end

	return nil
end

function GetModelFromParts(items, p, callback)
	local v = {}
	local folders = {}

	for _, item in pairs(items) do
		if v[item] then
			continue
		end

		if (item.Name == "Left" or item.Name == "Right") and p and item.Parent and item.Parent.Name == "CutModel" and item.Parent:GetAttribute("OwnedPlayer") == (p and p.Name) then
			return item
		end

		local folder = GetParent(item)

		if not folder then
			continue
		end

		table.insert(folders, folder)

		for _, descendant in pairs(folder:GetDescendants()) do
			v[descendant] = true
		end
	end

	local v2 = callback or function()
		return true
	end
	local instance = folders[1]

	if not instance then
		return folders[1]
	end

	if instance:IsA("Model") then
		if not v2(instance:GetPivot().Position) then
			return
		end
	elseif instance:IsA("BasePart") and not v2(instance.CFrame.Position) then
		return
	end

	return folders[1]
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.CutParts }
local CollectionService = game:GetService("CollectionService")
local tagged = CollectionService:GetTagged("CuttableObject")
table.insert(tagged, workspace.CutParts)
raycastParams.FilterDescendantsInstances = tagged
local CollectionService2 = game:GetService("CollectionService")
CollectionService2:GetInstanceAddedSignal("CuttableObject"):Connect(function(p)
	table.insert(tagged, p)
	raycastParams.FilterDescendantsInstances = tagged
end)
local CollectionService3 = game:GetService("CollectionService")
CollectionService3:GetInstanceRemovedSignal("CuttableObject"):Connect(function(p)
	local index = table.find(tagged, p)

	if index then
		table.remove(tagged, index)
		raycastParams.FilterDescendantsInstances = tagged
	end
end)

local function CutGroup(_, cframe: CFrame, value, _: number?, instance, callback)
	if typeof(value) == "table" and #value == 0 then
		return
	end

	if typeof(value) == "CFrame" then
		local v = (cframe - cframe.Position + value.Position) * CFrame.Angles(-1.5707963267948966, 0, 0)
		local v2 = value
		local count = 0

		while typeof(value) ~= "Instance" do
			count += 1

			if count > 50 then
				return
			end

			local v3 = v * CFrame.Angles(count // 2 * 0.0017453292519943296 * (count % 2 == 0 and -1 or 1), 0, 0)
			local raycastResult = workspace:Raycast(v2.Position, v3.LookVector * 1000, raycastParams)

			if raycastResult then
				value = GetModelFromParts({ raycastResult.Instance }, instance, callback)
			end
		end
	end

	local character

	if instance and typeof(instance) == "Instance" then
		if instance:IsA("Player") then
			character = instance.Character
		elseif instance:IsA("Model") then
			character = instance
		end
	end

	if not (character and character:FindFirstChild("Humanoid") and value and value.Parent) then
		return
	end

	value:AddTag("BeingCut")
	local _ = value.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	local controlTool = getControlTool(instance, character)

	if not controlTool then
		return
	end

	local CutUnion = require(script.CutUnion)
	local cutSlice = CutUnion:CutSlice(cframe, value, nil, instance)
	local RunFunction = require(util.RunFunction)
	RunFunction(function()
		local Maid = require(util.Maid)
		local maid = Maid.new()
		local parent = value.Parent
		local originalModel = value.Parent:FindFirstChild("OriginalModel")

		if originalModel then
			local clone = originalModel:Clone()
			clone.Parent = cutSlice
			originalModel.Value:SetAttribute("RegenAfter", os.clock() + 15)
			value:Destroy()
		else
			local objectValue = Instance.new("ObjectValue", cutSlice)
			objectValue.Name = "OriginalModel"
			objectValue.Value = value
			value:SetAttribute("RegenAfter", os.clock() + 15)

			local function DoRegen()
				for _, descendant in pairs(workspace.CutParts:GetDescendants()) do
					if not (descendant.Name == "OriginalModel" and descendant.Value == value) then
						continue
					end

					descendant.Parent:AddTag("BeingCut")
					descendant.Parent:Destroy()
				end

				pcall(function()
					value.Parent = parent
				end)
				value:RemoveTag("BeingCut")
				maid:DoCleaning()
			end

			maid:GiveTask(controlTool.AncestryChanged:Connect(function(_, parent2)
				if not parent2 then
					DoRegen()
				end
			end))
			maid:GiveTask(humanoid.Died:Once(function()
				DoRegen()
			end))

			if typeof(instance) == "Instance" and instance:IsA("Player") then
				maid:GiveTask(game.Players.PlayerRemoving:Connect(function(player)
					if player == instance then
						DoRegen()
					end
				end))
			end

			maid:GiveTask(task.delay(15.1, function()
				while true do
					local regenAfter = value:GetAttribute("RegenAfter") or 0

					if regenAfter < os.clock() then
						break
					end

					task.wait(regenAfter - os.clock() + 0.1)
				end

				DoRegen()
			end))
		end
	end)
	return cutSlice, value
end

return {
	CutSlice = CutGroup
}