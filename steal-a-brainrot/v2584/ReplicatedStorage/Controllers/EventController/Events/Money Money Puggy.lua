local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
require(ReplicatedStorage.Shared.EventTypes)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local BrainrotAssets = require(ReplicatedStorage.Shared.BrainrotAssets)
local MapInformation = require(ReplicatedStorage.Shared.MapInformation)
local JumpLTMWeather = require(ReplicatedStorage.Controllers.EventController.JumpLTMWeather)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local VFX = require(ReplicatedStorage.Shared.VFX)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local remoteEvent = Net:RemoteEvent("EventService/Money Money Puggy/Activation")
local remoteEvent2 = Net:RemoteEvent("EventService/Money Money Puggy/Burst")
local name = script.Name
local maid = Trove.new()
local maid2 = Trove.new()

local function facingCFrame(vector2: Vector3, vector3: Vector3)
	local vector4 = Vector3.new(vector3.X, vector2.Y, vector3.Z)
	return CFrame.lookAt(vector2, vector4)
end

local function initActivationVisual()
	local v = {}
	maid2:Add(function()
		table.clear(v)
	end)
	maid2:Add(RunService.PreRender:Connect(function()
		for _, v2 in v do
			if not (v2.target and v2.targetAttachment) then
				continue
			end

			v2.beam.First.Enabled = true
			v2.beam.Second.Enabled = true
			local v3 = math.clamp((os.clock() - v2.startedAt) / 2, 0, 1)
			local worldPosition = v2.beam.WorldPosition
			v2.targetAttachment.Position = worldPosition + (v2.target:GetPivot().Position - worldPosition) * v3
		end
	end))
	maid2:Add(Observers.observeTag("MoneyMoneyPuggyPlayerVFX", function(parent)
		local clone = script.PlayerVFX.Beam:Clone()
		clone.Parent = parent
		local clone2 = script.PlayerVFX.Torso:Clone()
		clone2.Parent = parent
		local moneyMoneyPuggyIndex = parent:GetAttribute("MoneyMoneyPuggyIndex")

		if type(moneyMoneyPuggyIndex) == "number" then
			v[moneyMoneyPuggyIndex] = {
				beam = clone,
				target = nil,
				startedAt = os.clock()
			}
			local v2 = Observers.observeTag("MoneyMoneyPuggyPlayerVFX", function(target)
				if target == parent then
					return nil
				end

				local moneyMoneyPuggyIndex2 = target:GetAttribute("MoneyMoneyPuggyIndex")

				if type(moneyMoneyPuggyIndex2) ~= "number" or moneyMoneyPuggyIndex2 ~= moneyMoneyPuggyIndex % 2 + 1 then
					return nil
				end

				local attachment = Instance.new("Attachment")
				attachment.Position = clone.WorldPosition
				attachment.Parent = workspace.Terrain
				local v3 = v[moneyMoneyPuggyIndex]
				v3.target = target
				v3.beam.First.Attachment0 = attachment
				v3.beam.Second.Attachment0 = attachment
				v3.targetAttachment = attachment
				v3.startedAt = os.clock()
				return function()
					attachment:Destroy()
				end
			end)
			return function()
				clone2:Destroy()
				clone:Destroy()
				v2()
				v[moneyMoneyPuggyIndex] = nil
			end
		else
			clone:Destroy()
			clone2:Destroy()
			return nil
		end
	end))
end

local function preparePuggy(model, folder)
	local clone = model:Clone()

	for _, v in clone:QueryDescendants("BasePart"), nil, nil do
		v.CanCollide = false
		v.CanQuery = false
		v.CanTouch = false
		v.Massless = true
		v.Anchored = false
	end

	local primaryPart = clone.PrimaryPart

	if not primaryPart then
		clone:Destroy()
		error("Money Money Puggy model has no PrimaryPart")
	end

	primaryPart.Anchored = true
	clone.Parent = folder
	local animationController = clone:FindFirstChild("AnimationController")
	local animator = animationController and animationController:FindFirstChildOfClass("Animator")
	local moneyMoneyPuggy = ReplicatedStorage.Animations.Animals:FindFirstChild("Money Money Puggy")
	local walk = moneyMoneyPuggy and moneyMoneyPuggy:FindFirstChild("Walk")
	local idle = moneyMoneyPuggy and moneyMoneyPuggy:FindFirstChild("Idle")
	local track

	if animator and walk and walk:IsA("Animation") then
		track = animator:LoadAnimation(walk)
	end

	local track2

	if animator and idle and idle:IsA("Animation") then
		track2 = animator:LoadAnimation(idle)
	end

	if track and walk then
		track.Looped = true
	end

	if track2 then
		track2.Looped = true
	end

	return clone, track, track2
end

local function isCloudPart(parent)
	while parent and parent ~= workspace do
		for _, v in parent:GetTags() do
			if string.sub(v, 1, 11) == "EggrotCloud" then
				return true
			end
		end

		parent = parent.Parent
	end

	return false
end

local function getGroundPosition(vector2: Vector3, instances)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.RespectCanCollide = true
	local raycastResult = nil

	for _ = 1, 10 do
		raycastParams.FilterDescendantsInstances = instances
		raycastResult = workspace:Raycast(vector2 + createVector(0, 20, 0), createVector(0, -100, 0), raycastParams)

		if not raycastResult then
			break
		end

		local instance = raycastResult.Instance

		if not instance:IsA("BasePart") or instance.CanCollide and instance.Transparency < 1 and not isCloudPart(instance) then
			break
		end

		table.insert(instances, instance)
		raycastResult = nil
	end

	if raycastResult then
		return (Vector3.new(vector2.X, raycastResult.Position.Y, vector2.Z))
	end

	return vector2 - createVector(0, 3, 0)
end

local function animatePair(items, p, p2, p3: number, p4, p5)
	local lastTime = os.clock()

	while true do
		local v = math.clamp((os.clock() - lastTime) / p3, 0, 1)
		local value = TweenService:GetValue(v, p4, p5)

		for k, item in items do
			if item.Parent then
				item:PivotTo(p[k]:Lerp(p2[k], value))
			end
		end

		if v >= 1 then
			break
		else
			RunService.PreRender:Wait()
		end
	end
end

local function spawnPlazaPuggy()
	local model = BrainrotAssets.getModel("Money Money Puggy", 10)

	if not (model and model:IsA("Model")) then
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = "MoneyMoneyPuggyPlaza"
	folder.Parent = workspace
	maid:Add(folder)
	local v, _, v2 = preparePuggy(model, folder)
	v:PivotTo(facingCFrame(getGroundPosition(createVector(90, 4, 0), { folder }), MapInformation.MapCenter.Position))

	if v2 then
		v2:Play(0)
	end
end

local flag = false

local function showMap()
	if flag then
		return
	end

	flag = true
	EffectController:Activate("Blink")
	maid:Add(function()
		EffectController:Activate("Blink")
	end)

	if ServerData.IsJumpLTMServer() then
		maid:Add(JumpLTMWeather.Cover(script.MoneyMapVFX))
		return
	end

	local clone = maid:Clone(script.MoneyMapVFX)
	clone.Parent = workspace
	VFX.enable(clone)
	VFX.emit(clone)
end

local function removeHeldPuggies(items)
	if typeof(items) ~= "table" then
		return
	end

	for _, item in items do
		if typeof(item) ~= "number" then
			continue
		end

		for _, part in CollectionService:GetTagged((`Held_{item}`)) do
			if not part:IsA("BasePart") then
				continue
			end

			for _, weld in part:GetJoints() do
				if not (weld:IsA("Weld") and weld.Part1 == part and weld.Part0) then
					continue
				end

				local model = weld.Part0:FindFirstAncestorOfClass("Model")

				if model then
					model:Destroy()
				end
			end
		end
	end
end

local function runActivation(list, p)
	if typeof(list) ~= "table" or typeof(list[1]) ~= "CFrame" or typeof(list[2]) ~= "CFrame" then
		return
	end

	local model = BrainrotAssets.getModel("Money Money Puggy", 10)

	if not (model and model:IsA("Model")) then
		return
	end

	removeHeldPuggies(p)
	local extended = maid:Extend()
	local folder = Instance.new("Folder")
	folder.Name = "MoneyMoneyPuggyActivation"
	folder.Parent = workspace
	extended:Add(folder)
	local v, v2, v3 = preparePuggy(model, folder)
	local v4, v5, v6 = preparePuggy(model, folder)
	local characters = { folder }
	local v7 = { v, v4 }

	for _, v8 in Players:GetPlayers() do
		if v8.Character then
			table.insert(characters, v8.Character)
		end
	end

	local groundPosition = getGroundPosition(list[1].Position, characters)
	local groundPosition2 = getGroundPosition(list[2].Position, characters)
	local v8 = (groundPosition + groundPosition2) * 0.5
	local unit = (groundPosition2 - groundPosition).Unit
	local v9 = math.clamp(
		math.sqrt(math.max(list[1].Position.Y - groundPosition.Y, list[2].Position.Y - groundPosition2.Y, 0) * 2 / workspace.Gravity),
		0.15,
		0.6
	)
	local vector2 = Vector3.new(v8.X, groundPosition.Y, v8.Z)
	local v10 = { CFrame.lookAt(groundPosition, vector2), facingCFrame(groundPosition2, v8) }
	local v11 = { CFrame.new(groundPosition) * list[1].Rotation, CFrame.new(groundPosition2) * list[2].Rotation }
	local v12 = v8 - unit * 3.5
	local vector3 = Vector3.new(v8.X, v12.Y, v8.Z)
	local v13 = { CFrame.lookAt(v12, vector3), facingCFrame(v8 + unit * 3.5, v8) }
	v:PivotTo(list[1])
	v4:PivotTo(list[2])

	for _, v14 in { v3, v6 } do
		if v14 then
			v14:Play(0)
		end
	end

	animatePair(v7, list, v11, v9, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	for _, v14 in { v3, v6 } do
		if v14 then
			v14:Stop()
		end
	end

	v:PivotTo(v10[1])
	v4:PivotTo(v10[2])

	for _, v14 in { v2, v5 } do
		if v14 then
			v14:Play(0.1, 1, 0.8)
		end
	end

	animatePair(v7, v10, v13, 1.6, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

	for _, v14 in { v2, v5 } do
		if v14 then
			v14:Stop()
		end
	end

	ClientEventUtils.playBurst(script.ActivationBurst, v8, { ReplicatedStorage.Sounds.Events[name].Burst })
	showMap()
	extended:Destroy()
end

local MoneyMoneyPuggy = {}

function MoneyMoneyPuggy.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)
	local v = math.max(0, activeEventData.startedAt + 5 - workspace:GetServerTimeNow())
	maid:Add(task.delay(v, showMap))

	if ServerData.IsJumpLTMServer() then
		maid:Add(task.spawn(spawnPlazaPuggy))
	end
end

function MoneyMoneyPuggy.OnStop(_)
	maid:Clean()
	flag = false
end

function MoneyMoneyPuggy.OnLoad(_)
	BrainrotAssets.preload({ "Money Money Puggy" })
	initActivationVisual()
	task.spawn(pcall, function()
		ContentProvider:PreloadAsync(script:GetChildren())
	end)
	remoteEvent.OnClientEvent:Connect(runActivation)
	remoteEvent2.OnClientEvent:Connect(function(p)
		ClientEventUtils.playBurst(script.Burst, p, { ReplicatedStorage.Sounds.Events[name].Burst })
	end)
end

return MoneyMoneyPuggy