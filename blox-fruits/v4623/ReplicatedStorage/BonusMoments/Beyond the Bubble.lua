local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Effect = require(game.ReplicatedStorage.Effect)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local Sound = require(game.ReplicatedStorage.Util.Sound)
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local v = {
	getChestPart = function(instance)
		if instance:IsA("BasePart") then
			return instance
		end

		if instance:IsA("Model") then
			return instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)
		end

		return nil
	end,
	openChest = function(object)
		return object:InvokeServer("OpenChest") == true
	end
}

function v.despawnChest(instance)
	local chestPart = v.getChestPart(instance)

	if chestPart ~= nil then
		Effect.new("Chests.Despawn"):play({
			CFrame = chestPart.CFrame
		})
	end

	instance:Destroy()
end

function v.startIdle(model)
	if not model:IsA("Model") then
		return nil, nil
	end

	local animationController = model:FindFirstChildOfClass("AnimationController")
	local animator

	if animationController ~= nil then
		animator = animationController:FindFirstChildOfClass("Animator")
	end

	local idle = model:FindFirstChild("idle")

	if animator == nil or idle == nil or not idle:IsA("Animation") then
		return animator, nil
	end

	local track = animator:LoadAnimation(idle)
	track.Looped = true
	track:Play()
	return animator, track
end

function v.addFxAnchor(parent, name: string, cFrame: CFrame)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = createVector(1, 1, 1)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CFrame = cFrame
	part.Parent = parent
end

function v.openChestVisual(model, animator, object, character)
	if not model:IsA("Model") then
		v.despawnChest(model)
		return
	end

	if object ~= nil then
		object:Stop()
	end

	local open = model:FindFirstChild("open")

	if animator ~= nil and open ~= nil and open:IsA("Animation") then
		local track = animator:LoadAnimation(open)
		track.Looped = false
		track:Play()
		track.Stopped:Once(function()
			if model.Parent == nil then
				return
			end

			track:Play()
			track:AdjustSpeed(0)
			track.TimePosition = math.max(track.Length - 0.05, 0)
		end)
	end

	local ac008 = model:FindFirstChild("Ac.008")

	if ac008 ~= nil and ac008:IsA("BasePart") then
		ac008.Transparency = 1
	end

	local animationController = model:FindFirstChildOfClass("AnimationController")

	if animationController ~= nil then
		animationController.Name = "Controller"
	end

	local pivot = model:GetPivot()
	v.addFxAnchor(model, "BottomWood", pivot * CFrame.new(0, 3, 0))
	pcall(function()
		Effect.new("Chests.Open"):play({
			ID = 2,
			Model = model,
			Character = character
		})
	end)
	Sound:Play("Chests.GoldChestOpen", pivot.Position)
	local primaryPart = model.PrimaryPart
	task.delay(3, function()
		if primaryPart ~= nil then
			pcall(function()
				Effect.new("Chests.Despawn"):play({
					CFrame = primaryPart.CFrame
				})
			end)
		end

		model:Destroy()
	end)
end

function v.watchChest(p, p2, p3)
	local chestPart = v.getChestPart(p3)

	if chestPart == nil then
		return
	end

	local v2, v3 = v.startIdle(p3)

	if v3 ~= nil then
		p2.Maid:GiveTask(function()
			pcall(function()
				v3:Stop()
			end)
		end)
	end

	p2.Maid:GiveTask(task.spawn(function()
		while not p2.Cancelled do
			task.wait(0.1)
			local character = Players.LocalPlayer.Character
			local humanoidRootPart

			if character then
				humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			end

			if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") or (humanoidRootPart.Position - chestPart.Position).Magnitude > 10 then
				continue
			end

			if v.openChest(p) then
				v.openChestVisual(p3, v2, v3, character)
				break
			else
				task.wait(1)
			end
		end
	end))
end

function v.getState(maid)
	local _bubbleState = maid.MiscData._bubbleState

	if _bubbleState ~= nil then
		return _bubbleState
	end

	local bubbleState = {
		Maid = Maid.new(),
		Cancelled = false
	}
	maid.MiscData._bubbleState = bubbleState
	maid:GiveTask(bubbleState.Maid)
	bubbleState.Maid:GiveTask(function()
		bubbleState.Cancelled = true
	end)
	return bubbleState
end

local BeyondTheBubble = {}
BeyondTheBubble.DataName = script.Name
BeyondTheBubble.Repeatable = false

function BeyondTheBubble.OnLoad(p)
	if p.Completed then
		return
	end

	local state = v.getState(p)

	for _, v2 in CollectionService:GetTagged("CursedChest") do
		if v2:IsDescendantOf(workspace) then
			v.watchChest(p, state, v2)
		end
	end

	state.Maid:GiveTask(CollectionService:GetInstanceAddedSignal("CursedChest"):Connect(function(instance)
		if not state.Cancelled and instance:IsDescendantOf(workspace) then
			v.watchChest(p, state, instance)
		end
	end))
end

function BeyondTheBubble.OnComplete(p)
	local _bubbleState = p.MiscData._bubbleState

	if _bubbleState ~= nil then
		_bubbleState.Maid:DoCleaning()
		p.MiscData._bubbleState = nil
	end
end

return BeyondTheBubble