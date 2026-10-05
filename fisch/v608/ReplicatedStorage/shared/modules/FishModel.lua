local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./library/fish")
local module2 = require("./library/items")
local module3 = require("./fishing/mutations")
local module4 = require("../utils/assets")
require("./fishing/FishInstance/Types")
local fx = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("fx")
local FishModel = {
	ApplySparkling = function(folder, color: Color3?)
		local hitbox = folder:FindFirstChild("Hitbox")

		if not (hitbox and hitbox:IsA("BasePart")) then
			return folder
		end

		local cFrame = hitbox.CFrame
		local size = hitbox.Size
		local part = Instance.new("Part")
		part.Name = "VFX"
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Transparency = 1
		part.Massless = true
		part.Anchored = false
		part.Size = size
		part.CFrame = cFrame
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = hitbox
		weldConstraint.Part1 = part
		weldConstraint.Parent = part
		local color2 = color or Color3.new(1, 1, 1)
		local clone = fx.sparkleslight:Clone()
		clone.Color = color2
		local clone2 = fx.sparkles:Clone()
		clone2.Color = ColorSequence.new(color2)
		local clone3 = fx.rays:Clone()
		clone3.Color = ColorSequence.new(color2)
		clone.Parent = part
		clone2.Parent = part
		clone3.Parent = part
		part.Parent = hitbox

		for _, part2 in folder:GetDescendants() do
			if part2:IsA("BasePart") then
				part2.Material = Enum.Material.Neon
			end
		end

		return folder
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function resizeInvisPart(part, p: number)
	if not (part and part:IsA("BasePart")) then
		return
	end

	local v = part.Size * p
	local v2 = math.min(v.X, v.Y, v.Z)

	if v2 < 0.001 then
		part.Size *= 0.001 / v2
	end
end

function FishModel.Resize(instance, p: string, p2: number?, p3)
	local scale = instance:GetScale()
	local v

	if p2 and module[p] then
		local v2 = module[p].WeightPool[2] / 10
		local v3 = module[p].WeightPool[1] / 10
		local halfScale = scale / 2
		local v5 = scale * 3
		local v6 = math.min(p2, v2 * 10)
		local v7 = v6 / v2
		local v8

		if p2 < v3 then
			v8 = halfScale * (p2 / v3)
		elseif v7 <= 1 then
			v8 = halfScale + (scale - halfScale) * v7
		else
			local v9 = (v6 - v2) / v2
			v8 = scale + (v5 - scale) * v9
		end

		v = math.clamp(v8, 0.001, v5)

		if p3 and p3.ScaleMultiply then
			v *= p3.ScaleMultiply
		end
	else
		v = scale
	end

	if p3 and p3.MaxSize then
		local v2 = instance:GetExtentsSize() / scale * v
		local v3 = math.max(v2.X, v2.Y, v2.Z)

		if p3.MaxSize < v3 then
			v /= v3 / p3.MaxSize
		end
	end

	resizeInvisPart(instance:FindFirstChild("Center"), v / scale) -- equivalent call inferred; original call site unknown
	resizeInvisPart(instance:FindFirstChild("handle"), v / scale) -- equivalent call inferred; original call site unknown
	instance:ScaleTo(v)
	return instance, v
end

function FishModel.Create(data)
	local itemData = data.ItemData or {}
	local v = module[data.Name] or module2.Items[data.Name] or {}
	local async = module4.getAsync(
		module2.Items[data.Name] and "item" or "fish",
		(`{itemData.Shiny and "Shiny_" or ""}{data.Name}`)
	)

	if async and async:IsA("Folder") then
		async = async:FindFirstChild(data.Name)
	end

	if not async then
		warn(debug.traceback((`couldn't find model for {data.Name}, shiny: {itemData.Shiny}`)))
		async = module4.getAsync("fish", "Floppy")

		if not async then
			return nil
		end
	end

	local clone = async:Clone()
	local fish = itemData.FriendId and data.Name == "Friend Fish" and clone:FindFirstChild("Fish")

	if fish then
		fish:SetAttribute("FriendId", itemData.FriendId)
		fish:AddTag("FriendFish")
	end

	local v2 = v.From == "Everturn Forest"

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Massless = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.RootPriority = -127

		if data.CastShadow ~= nil then
			part.CastShadow = data.CastShadow
		end

		if v2 and part.Name == "Eyes" then
			part:AddTag("EverturnEyes")
		end
	end

	FishModel.Resize(clone, data.Name, itemData.Weight, data.ResizeArgs)

	if itemData.Mutation then
		local clone2 = table.clone(itemData)
		clone2.Name = data.Name
		module3:MutateModel(clone, itemData.Mutation, clone2)

		for _, part in clone:GetChildren() do
			local motor6D = part:FindFirstChildWhichIsA("Motor6D")

			if not (motor6D and part:IsA("BasePart") and motor6D.Enabled) then
				continue
			end

			local part1

			if motor6D.Part0 == part then
				part1 = motor6D.Part1
			else
				part1 = motor6D.Part0
			end

			if not part1 then
				continue
			end

			if part.Name == "Hitbox" or part.Name == "Center" or part.Name == "handle" then
				part1, part = part, part1
			end

			if part == motor6D.Part0 then
				part.CFrame = part1.CFrame * motor6D.C0 * motor6D.C1:Inverse() * motor6D.Transform
			else
				part.CFrame = part1.CFrame * motor6D.C1 * motor6D.C0:Inverse() * motor6D.Transform
			end
		end
	end

	if itemData.Sparkling then
		FishModel.ApplySparkling(clone, v.SparklingColor)
	end

	if data.RemoveScripts then
		for _, luaSourceContainer in clone:GetDescendants() do
			if luaSourceContainer:IsA("LuaSourceContainer") then
				luaSourceContainer:Destroy()
			end
		end
	end

	return clone
end

return FishModel