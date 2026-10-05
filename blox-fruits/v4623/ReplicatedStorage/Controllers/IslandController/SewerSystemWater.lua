local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Maid = require(game.ReplicatedStorage.Util.Maid)
local SewerSystem = require(game.ReplicatedStorage.Modules.World.SewerSystem)
local SewerSystemWater = {
	LoadForLocations = { SewerSystem.LOCATION_NAME },
	Maid = Maid.new()
}

local function isWaterTexture(texture)
	local parent = texture.Parent
	local isA = texture:IsA("Texture")

	if isA then
		if parent == nil then
			isA = false
		else
			isA = parent:IsA("BasePart") and parent.Name == SewerSystem.WATER_PART_NAME
		end
	end

	return isA
end

-- equivalent calls inferred from this helper; original call sites unknown
local function createOffset(name: string, cframe: CFrame, folder)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Name = name
	cFrameValue.Value = cframe
	cFrameValue.Parent = folder
	return cFrameValue
end

local function animateOffset(p)
	while p.Parent do
		local v = math.random() * 3 + 9
		local v2 = math.rad(90 - math.random(-20000, 20000) / 1000)
		local tween = TweenService:Create(p, TweenInfo.new(v, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Value = p.Value * CFrame.Angles(0, v2, 0) * CFrame.new(0, 0, -40)
		})
		tween:Play()
		tween.Completed:Wait()
		tween:Destroy()
	end
end

local function updateTextures(list, value: CFrame, value2: CFrame)
	for i = #list, 1, -1 do
		local v = list[i]

		if v.texture.Parent == nil then
			table.remove(list, i)
		else
			local v2

			if v.usesBackOffset then
				v2 = value2
			else
				v2 = value
			end

			v.texture.OffsetStudsU = v.baseOffset.X + v2.X
			v.texture.OffsetStudsV = v.baseOffset.Y + v2.Z
		end
	end
end

local function restoreTextures(items)
	for _, item in items do
		if not item.texture.Parent then
			continue
		end

		item.texture.OffsetStudsU = item.baseOffset.X
		item.texture.OffsetStudsV = item.baseOffset.Y
	end
end

function SewerSystemWater.RegionEntered(p)
	p.Maid:GiveTask(task.spawn(function()
		local folder = workspace:WaitForChild("Map"):WaitForChild(SewerSystem.MAP_NAME, 30)

		if not folder then
			return
		end

		local offset = createOffset("SewerWaterFrontOffset", CFrame.Angles(0, 2.2689280275926285, 0), folder) -- equivalent call inferred; original call site unknown
		local offset2 = createOffset("SewerWaterBackOffset", CFrame.identity, folder) -- equivalent call inferred; original call site unknown
		p.Maid:GiveTask(offset)
		p.Maid:GiveTask(offset2)
		p.Maid:GiveTask(task.spawn(animateOffset, offset))
		p.Maid:GiveTask(task.spawn(animateOffset, offset2))
		local v = {}
		local v2 = {}

		local function track(texture)
			local parent = texture.Parent
			local isA = texture:IsA("Texture")

			if isA then
				if parent == nil then
					isA = false
				else
					isA = parent:IsA("BasePart") and parent.Name == SewerSystem.WATER_PART_NAME
				end
			end

			if not isA or v2[texture] then
				return
			end

			v2[texture] = true
			table.insert(v, {
				baseOffset = Vector2.new(texture.OffsetStudsU, texture.OffsetStudsV),
				texture = texture,
				usesBackOffset = texture.Name == "BackTexture"
			})
		end

		for _, descendant in folder:GetDescendants() do
			track(descendant)
		end

		p.Maid:GiveTask(folder.DescendantAdded:Connect(track))
		p.Maid:GiveTask(function()
			restoreTextures(v)
		end)
		RunService:BindToRenderStep(
			"IslandController.SewerSystem.Water",
			Enum.RenderPriority.Camera.Value + 1,
			function()
				updateTextures(v, offset.Value, offset2.Value)
			end
		)
		p.Maid:GiveTask(function()
			RunService:UnbindFromRenderStep("IslandController.SewerSystem.Water")
		end)
	end))
end

function SewerSystemWater.RegionLeaving(_) end

return SewerSystemWater