local createVector = vector.create
local Effect = require(game.ReplicatedStorage.Effect)
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local SewerSystem = require(game.ReplicatedStorage.Modules.World.SewerSystem)
local _ = {
	CHEST_DESPAWN_DELAY = 3,
	CHEST_BASE_PART_NAME = "Golden down.003",
	CHEST_FALLBACK_DROP = 3,
	CHEST_FX_HEIGHT = 6,
	CHEST_GROUND_CLEARANCE = 0,
	CHEST_GROUND_RAY_DEPTH = 80,
	CHEST_GROUND_RAY_HEIGHT = 10,
	CHEST_HIDE_ON_OPEN = "Ac.008",
	CHEST_HITBOX_PADDING = createVector(2, 2, 2),
	CHEST_HITBOX_SIZE = createVector(10, 8, 10),
	CHEST_INDEX = 2,
	CHEST_SCALE = 1.5,
	CHEST_TEMPLATE_NAME = "Treasure Chest"
}
local v = {
	hideForeignPreview = function(model)
		if not model:IsA("Model") then
			model = model:FindFirstAncestorOfClass("Model")
		end

		if not model or model:GetAttribute(SewerSystem.PREVIEW_OWNER_ATTRIBUTE) == nil or model:GetAttribute(SewerSystem.PREVIEW_OWNER_ATTRIBUTE) == game.Players.LocalPlayer.UserId then
			return
		end

		for _, descendant in model:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.LocalTransparencyModifier = 1
			elseif descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui") then
				descendant.Enabled = false
			elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("Light") then
				descendant.Enabled = false
			end
		end
	end
}

function v.watchPreviews(maid)
	local map = workspace:FindFirstChild("Map")
	local folder

	if map then
		folder = map:FindFirstChild(SewerSystem.MAP_NAME)
	end

	if not folder then
		return
	end

	for _, descendant in folder:GetDescendants() do
		v.hideForeignPreview(descendant)
	end

	maid:GiveTask(folder.DescendantAdded:Connect(v.hideForeignPreview))
end

function v.getState(p)
	local _sewerGangsChestState = p.MiscData._sewerGangsChestState

	if _sewerGangsChestState then
		return _sewerGangsChestState
	end

	local sewerGangsChestState = {
		activeChest = nil,
		claiming = false,
		completed = false
	}
	p.MiscData._sewerGangsChestState = sewerGangsChestState
	return sewerGangsChestState
end

function v:detachChest()
	if self.touchConnection then
		self.touchConnection:Disconnect()
		self.touchConnection = nil
	end

	self.hitbox:Destroy()

	if self.idleTrack then
		self.idleTrack:Stop()
	end
end

function v.destroyChest(p)
	if not p then
		return
	end

	v.detachChest(p)
	p.model:Destroy()
end

function v.getChestGroundPosition(cframe: CFrame)
	local filterDescendantsInstances = {}
	local Players = game:GetService("Players")
	local character = Players.LocalPlayer.Character
	local enemies = workspace:FindFirstChild("Enemies")

	if character then
		table.insert(filterDescendantsInstances, character)
	end

	if enemies then
		table.insert(filterDescendantsInstances, enemies)
	end

	local map = workspace:FindFirstChild("Map")
	local folder

	if map then
		folder = map:FindFirstChild(SewerSystem.MAP_NAME)
	end

	if folder then
		for _, part in folder:GetDescendants() do
			if part:IsA("BasePart") and part.Name == SewerSystem.WATER_PART_NAME then
				table.insert(filterDescendantsInstances, part)
			end
		end
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	raycastParams.IgnoreWater = true
	raycastParams.RespectCanCollide = true
	local v3 = cframe.Position + createVector(0, 10, 0)
	local raycastResult = workspace:Raycast(v3, createVector(-0, -80, -0), raycastParams)

	if raycastResult then
		return raycastResult.Position
	end

	return cframe.Position - createVector(0, 3, 0)
end

function v.getPartHalfExtents(instance)
	local v2 = instance.Size * 0.5
	local cFrame = instance.CFrame
	return (Vector3.new(
		math.abs(cFrame.RightVector.X) * v2.X + math.abs(cFrame.UpVector.X) * v2.Y + math.abs(cFrame.LookVector.X) * v2.Z,
		math.abs(cFrame.RightVector.Y) * v2.X + math.abs(cFrame.UpVector.Y) * v2.Y + math.abs(cFrame.LookVector.Y) * v2.Z,
		math.abs(cFrame.RightVector.Z) * v2.X + math.abs(cFrame.UpVector.Z) * v2.Y + math.abs(cFrame.LookVector.Z) * v2.Z
	))
end

function v.getChestBodyBounds(folder)
	local v2 = createVector(1e999, 1e999, 1e999)
	local v3 = createVector(-1e999, -1e999, -1e999)

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and part.Transparency < 1 and part.Name ~= "Ac.008") then
			continue
		end

		local partHalfExtents = v.getPartHalfExtents(part)
		v2 = v2:Min(part.Position - partHalfExtents)
		v3 = v3:Max(part.Position + partHalfExtents)
	end

	if v2.X == 1e999 then
		return folder:GetBoundingBox()
	end

	return CFrame.new((v2 + v3) * 0.5), v3 - v2
end

function v.placeChestOnGround(instance, cframe: CFrame)
	local chestGroundPosition = v.getChestGroundPosition(cframe)
	instance:PivotTo(CFrame.new(chestGroundPosition) * cframe.Rotation)
	local goldendown003 = instance:FindFirstChild("Golden down.003", true)
	local v2

	if goldendown003 and goldendown003:IsA("BasePart") then
		v2 = goldendown003.Position.Y - v.getPartHalfExtents(goldendown003).Y
	else
		local chestBodyBounds, v3 = v.getChestBodyBounds(instance)
		v2 = chestBodyBounds.Position.Y - v3.Y * 0.5
	end

	instance:PivotTo(instance:GetPivot() + createVector(0, 1, 0) * (chestGroundPosition.Y - v2 + 0))
	return v.getChestBodyBounds(instance)
end

function v.createChest(cframe: CFrame)
	local treasureChest = script:FindFirstChild("Treasure Chest")

	if not (treasureChest and treasureChest:IsA("Model")) then
		return nil
	end

	local clone = treasureChest:Clone()
	local primaryPart = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)

	if primaryPart then
		clone.PrimaryPart = primaryPart
	end

	clone:ScaleTo(clone:GetScale() * 1.5)

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = primaryPart == nil or part == primaryPart
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Massless = true
	end

	clone.Name = "SewerTreasureChest"
	local placeChestOnGround, v2 = v.placeChestOnGround(clone, cframe)
	clone.Parent = workspace
	local animationController = clone:FindFirstChildOfClass("AnimationController")
	local animator

	if animationController then
		animator = animationController:FindFirstChildOfClass("Animator")
	end

	local idle = clone:FindFirstChild("idle")
	local track

	if animator and idle and idle:IsA("Animation") then
		track = animator:LoadAnimation(idle)
		track.Looped = true
		track:Play()
	end

	local part = Instance.new("Part")
	part.Name = "SewerTreasureHitbox"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = true
	part.Size = Vector3.new(math.max(10, v2.X + 2), math.max(8, v2.Y + 2), (math.max(10, v2.Z + 2)))
	part.CFrame = placeChestOnGround
	part.Transparency = 1
	part.Parent = workspace
	return {
		animator = animator,
		hitbox = part,
		idleTrack = track,
		model = clone,
		touchConnection = nil
	}
end

function v.addFxAnchor(parent, name: string, cFrame: CFrame)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CFrame = cFrame
	part.Size = createVector(1, 1, 1)
	part.Transparency = 1
	part.Parent = parent
end

function v.playOpen(p, p2)
	v.detachChest(p2)
	local model = p2.model
	local open = model:FindFirstChild("open")

	if p2.animator and open and open:IsA("Animation") then
		local track = p2.animator:LoadAnimation(open)
		track.Looped = false
		track:Play()
		track.Stopped:Once(function()
			if model.Parent then
				track:Play()
				track:AdjustSpeed(0)
				track.TimePosition = math.max(track.Length - 0.05, 0)
			end
		end)
	end

	local ac008 = model:FindFirstChild("Ac.008")

	if ac008 and ac008:IsA("BasePart") then
		ac008.Transparency = 1
	end

	local animationController = model:FindFirstChildOfClass("AnimationController")

	if animationController then
		animationController.Name = "Controller"
	end

	local pivot = model:GetPivot()
	v.addFxAnchor(model, "BottomWood", pivot * CFrame.new(0, 5, 0))
	v.addFxAnchor(model, "LootTexture", pivot * CFrame.new(0, 6, 0))
	pcall(function()
		Effect.new("Chests.Open"):play({
			Character = p.Player.Character,
			ID = 2,
			Model = model
		})
	end)
	local primaryPart = model.PrimaryPart
	task.delay(3, function()
		if primaryPart and primaryPart.Parent then
			pcall(function()
				Effect.new("Chests.Despawn"):play({
					CFrame = primaryPart.CFrame
				})
			end)
		end

		model:Destroy()
	end)
end

function v.claimTreasure(object, state, p)
	if state.claiming or state.activeChest ~= p then
		return
	end

	state.claiming = true
	local success, result = pcall(function()
		return object:InvokeServer("ClaimTreasure") == true
	end)
	state.claiming = false

	if not success or not result or state.activeChest ~= p then
		return
	end

	state.activeChest = nil
	v.playOpen(object, p)

	if state.completed then
		object.MiscData._sewerGangsChestState = nil
	end
end

function v.spawnChest(p, p2, cframe: CFrame)
	v.destroyChest(p2.activeChest)
	local chest = v.createChest(cframe)
	p2.activeChest = chest

	if not chest then
		return
	end

	chest.touchConnection = chest.hitbox.Touched:Connect(function(otherPart)
		local character = p.Player.Character

		if character and otherPart:IsDescendantOf(character) then
			v.claimTreasure(p, p2, chest)
		end
	end)
end

local SewerGangs = {}
SewerGangs.DataName = script.Name

function SewerGangs.OnLoad(p)
	p.MiscData[SewerSystem.DUNGEON_PREVIEW_MODULE_DATA_KEY] = script.DungeonCameraController
	v.getState(p)
	v.watchPreviews(p)
end

function SewerGangs.OnComplete(p, flag: boolean)
	p.MiscData[SewerSystem.DUNGEON_PREVIEW_MODULE_DATA_KEY] = nil
	local _sewerGangsChestState = p.MiscData._sewerGangsChestState

	if not _sewerGangsChestState then
		return
	end

	if flag and _sewerGangsChestState.claiming then
		_sewerGangsChestState.completed = true
		return
	end

	v.destroyChest(_sewerGangsChestState.activeChest)
	_sewerGangsChestState.activeChest = nil
	p.MiscData._sewerGangsChestState = nil
end

SewerGangs.RemoteEvents = {
	TreasureReady = function(p, p2)
		if typeof(p2) == "CFrame" then
			v.spawnChest(p, v.getState(p), p2)
		end
	end
}
return SewerGangs