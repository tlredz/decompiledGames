local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local v = nil
local Platform = {
	AbilityName = "Platform",
	AbilityCooldown = 30,
	CanUseAbility = function(_, instance)
		if not instance.PrimaryPart or instance:GetAttribute("PULSED") and not instance:GetAttribute("teamVIP") then
			return false
		end

		return not instance:GetAttribute("AbilityCooldown")
	end
}

function Platform:RegisterCooldown(instance, _: number)
	instance:SetAttribute("AbilityCooldown", true)
	task.delay(Platform.AbilityCooldown, function()
		if instance:IsDescendantOf(workspace) then
			instance:SetAttribute("AbilityCooldown", nil)
		end
	end)
end

function Platform.ServerInit(_, p, p2: number, flag: boolean)
	if not v then
		local MapManager = require(ServerScriptService.Game.CoreGameModules.MapManager)
		v = MapManager
	end

	if not flag then
		Platform:RegisterCooldown(p, p2)
	end
end

function Platform.ServerStart(_, instance, p: number)
	local v2 = p * 3 + 12
	local _ = 30 - p * 3.75
	local v3 = p == 2
	local humanoidRootPart = instance.HumanoidRootPart

	if not humanoidRootPart then
		return
	end

	local freeMove = instance:GetAttribute("FreeMove")
	local doNotMove = instance:GetAttribute("DoNotMove")
	instance:SetAttribute("FreeMove", nil)
	instance:SetAttribute("DoNotMove", true)
	local clone = ReplicatedStorage.Misc.Platform:Clone()
	clone.Name = "Vanity"

	if v3 then
		clone.Size = createVector(15, 0.1, 15)
	end

	local objectValue = Instance.new("ObjectValue")
	objectValue.Name = "OwnerCharacter"
	objectValue.Value = instance
	objectValue.Parent = clone
	clone:AddTag("Platform")
	local pathfindingModifier = Instance.new("PathfindingModifier")
	pathfindingModifier.Label = "MapBoundaries"
	pathfindingModifier.PassThrough = false
	pathfindingModifier.Parent = clone
	local folder = Instance.new("Folder")
	folder.Name = instance.Name
	folder.Parent = clone
	local folder2 = Instance.new("Folder")
	folder2.Parent = instance
	folder2.Name = "IsAbilityHigh"
	task.delay(v2 * 1.5, function()
		folder2:Destroy()
	end)
	clone.Parent = workspace.Runtime
	clone.Sound:Play()
	clone.Rocks:Play()
	task.delay(25, function()
		clone:Destroy()
	end)
	local currentMaps = {}
	local currentMap = v.getCurrentMap()

	if currentMap then
		table.insert(currentMaps, currentMap)
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = currentMaps
	local raycastResult = workspace:Raycast(
		humanoidRootPart.Position,
		(createVector(0, -1, 0)).Unit * 100,
		raycastParams
	)

	if raycastResult then
		instance:SetAttribute("DoNotMove", true)
		local instance2 = raycastResult.Instance
		clone.Position = raycastResult.Position
		clone.Orientation = humanoidRootPart.Orientation
		clone.Outlinez:SetPrimaryPartCFrame(clone.CFrame)
		clone.dos:SetPrimaryPartCFrame(clone.CFrame)
		clone.diggle.CFrame = clone.CFrame
		clone.Color = instance2.Color
		clone.Material = instance2.Material
		clone.CollisionGroup = "LockedParts"
		local diggle = clone.diggle
		diggle.Parent = workspace
		task.delay(3, function()
			diggle:Destroy()
		end)
		local outlinez = clone.Outlinez

		if v3 then
			outlinez = clone.dos
		end

		for _, descendant in ipairs(outlinez:GetDescendants()) do
			if descendant.Name ~= "dust" then
				continue
			end

			descendant.Color = ColorSequence.new(clone.Color)
			descendant.Enabled = true
			local v4 = descendant
			task.delay(2.25, function()
				v4.Enabled = false
			end)
		end

		local v4 = p * 32.5 + 75
		local size = clone.Size
		Vector3.new(clone.Size.X, 0, clone.Size.Y)
		clone.Position += Vector3.new(0, v4 / 2, 0)
		local cFrame = clone.CFrame
		clone.CFrame *= CFrame.new(0, -v4 / 2, 0)
		clone.Size = createVector(0, 0, 0)
		clone.Size = Vector3.new(size.X, 0, size.Z)
		local v5 = LinearInterpolation(clone, 4, {
			Size = clone.Size + Vector3.new(0, v4, 0),
			CFrame = cFrame
		})
		local v6 = LinearInterpolation(diggle, 4, {
			Position = clone.Position + Vector3.new(0, v4 + 3, 0)
		})
		v5:Play()
		v6:Play()
		task.delay(v2 - 2 + 4, function()
			local sound = clone and clone:FindFirstChild("Sound")

			if sound then
				sound:Play()
			end

			LinearInterpolation(clone, 2, {
				Size = size,
				CFrame = cFrame
			}):Play()

			for _, descendant in ipairs(outlinez:GetDescendants()) do
				if descendant.Name ~= "dust" then
					continue
				end

				descendant.Enabled = true
				local v7 = descendant
				task.delay(1, function()
					v7.Enabled = false
				end)
			end

			instance:SetAttribute("FreeMove", freeMove)
			instance:SetAttribute("DoNotMove", doNotMove)
		end)
		task.delay(v2 - 2 + 8, function()
			clone:Destroy()
		end)
		task.spawn(function()
			local v7 = p == 1 and 4.1 or v3 and 6.1 or 3.1
			local count = 0

			while count < v7 do
				task.wait(3.5 / v7)
				Wave(diggle, instance2.Color, v3)
				count += 1
			end
		end)
	end
end

function LinearInterpolation(p, p2, items)
	local v2 = {}
	local flag = true
	local v3 = 0

	for k in items do
		v2[k] = p[k]
	end

	local thread = nil
	local bindableEvent = Instance.new("BindableEvent")

	local function useCustom(_)
		if thread then
			return
		end

		thread = task.spawn(function()
			while flag do
				local v4 = task.wait(0.022222222222222223)
				v3 = math.clamp(v3 + v4 / p2, 0, 1)

				for k, item in items do
					local v5 = v2[k]

					if typeof(item) == "CFrame" then
						local v6 = item - (item.Position - v5.Position) * (1 - v3)
						p[k]:Lerp(v6, 0.1)
					else
						p[k] = v5 + (item - v5) * v3
					end
				end

				if v3 ~= 1 then
					continue
				end

				bindableEvent:Fire()
				break
			end
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cancelCustom(_)
		flag = false

		if typeof(thread) == "thread" and coroutine.status(thread) == "suspended" then
			task.cancel(thread)
		end
	end

	local function destroyCustom(_)
		bindableEvent:Destroy()
		cancelCustom() -- equivalent call inferred; original call site unknown
	end

	return {
		Play = useCustom,
		Cancel = cancelCustom,
		Destroy = destroyCustom,
		Completed = bindableEvent.Event
	}
end

function Wave(p, color: Color3, flag: boolean)
	local clone = ReplicatedStorage.Misc.Wave:Clone()
	clone.Transparency = 0
	clone.Size = createVector(0.01, 0.5, 0.01)
	clone.Color = color
	clone.CFrame = p.CFrame
	TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0), {
		Size = flag and createVector(50, 0.5, 50) or createVector(30, 0.5, 30),
		Transparency = 1
	}):Play()
	clone.Parent = workspace.Runtime
	task.delay(1.5, function()
		clone:Destroy()
	end)
end

return Platform