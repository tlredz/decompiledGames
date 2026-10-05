local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Sound = require(game.ReplicatedStorage.Util.Sound)

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { map }
local v = { TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out) }

local function createEffect(cFrame, instance, parent)
	local clone = instance:Clone()
	clone.CFrame = cFrame
	clone.CanCollide = true
	clone.Anchored = false
	clone.Parent = parent
	return clone
end

return function(list)
	local folder = list[1]
	local p = folder:GetModelCFrame().p
	local Y = folder:GetModelSize().Y

	if (workspace.CurrentCamera.CFrame.Position - p).magnitude > 600 or folder:GetAttribute("AlreadyDestroyedClient") then
		return
	end

	folder:SetAttribute("AlreadyDestroyedClient", true)
	local descendants = folder:GetDescendants()
	local v2 = nil

	for _, part in pairs(descendants) do
		if not (part:IsA("BasePart") and (part.Material == Enum.Material.Wood or part.Name == "Trunk")) then
			continue
		end

		v2 = part
		break
	end

	if not v2 then
		for _, part in pairs(descendants) do
			if not (part:IsA("BasePart") and part.Material ~= Enum.Material.Grass) then
				continue
			end

			v2 = part
			break
		end
	end

	if not v2 then
		return
	end

	local folder2 = Instance.new("Folder", _WorldOrigin)
	Debris:AddItem(folder2, 5.5)

	if folder:GetAttribute("IsWindow") then
		Sound:Play("MiddleTownSFX.BF_MidTown_WindowShatter_01", p)
	else
		Sound:Play("TreeBreak", p)
	end

	local raycastResult = workspace:Raycast(p, Vector3.new(0, -Y * 2, 0), raycastParams)

	if folder:GetAttribute("TreeType") == "Cactus" then
		local clone = folder:Clone()

		for _, descendant in clone:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.CanCollide = true
				descendant.Anchored = false
				descendant.Parent = folder2
			elseif descendant:IsA("Weld") and descendant.Name ~= "SpikeWeld" then
				descendant:Destroy()
			elseif descendant.Name == "SpikeWeld" then
				descendant.Enabled = true
			end
		end

		for _, part in descendants do
			if part:IsA("BasePart") then
				part:Destroy()
			end
		end

		clone.Parent = folder2
	else
		for _, part in descendants do
			if not part:IsA("BasePart") then
				continue
			end

			local cFrame = part.CFrame
			local clone = part:Clone()
			clone.CFrame = cFrame
			clone.CanCollide = true
			clone.Anchored = false
			clone.Parent = folder2
			part:Destroy()
		end
	end

	local cFrame2 = CFrame.new(p) * CFrame.new(0, Y / 8, 0)
	local clone = script.leaves:Clone()
	clone.CFrame = cFrame2
	clone.CanCollide = true
	clone.Anchored = false
	clone.Parent = folder2
	clone.CanCollide = false
	clone.Anchored = true

	for _, child in pairs(clone:GetChildren()) do
		if child.Name == "groundstuff" then
			if raycastResult then
				child.Color = ColorSequence.new(raycastResult.Instance.Color)
				child:Emit(child:GetAttribute("EmitCount"))
			end
		else
			if child.Name == "wood" then
				child.Color = ColorSequence.new(v2.Color)
			end

			child:Emit(child:GetAttribute("EmitCount"))
		end
	end

	task.wait(3)

	for _, part in pairs(folder2:GetChildren()) do
		if part:IsA("BasePart") then
			TweenService:Create(part, v[1], {
				Size = Vector3.new()
			}):Play()
		end
	end
end