local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local Effect = require(game.ReplicatedStorage.Effect)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local Sound = require(game.ReplicatedStorage.Util.Sound)
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local frozen = table.freeze({
	"UnderwaterCityBonusMoments.Clamshell_Open_01",
	"UnderwaterCityBonusMoments.Clamshell_Open_02",
	"UnderwaterCityBonusMoments.Clamshell_Open_03"
})
local frozen2 = table.freeze({
	"UnderwaterCityBonusMoments.Clamshell_Pearl_Reveal_01",
	"UnderwaterCityBonusMoments.Clamshell_Pearl_Reveal_02",
	"UnderwaterCityBonusMoments.Clamshell_Pearl_Reveal_03"
})
local v = {
	playRandom = function(list, p)
		Sound:Play(list[math.random(1, #list)], p)
	end,
	getClamPart = function(instance)
		if instance:IsA("BasePart") then
			return instance
		end

		if instance:IsA("Model") then
			return instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)
		end

		return nil
	end
}

function v.getClamPoint(p)
	local clamPart = v.getClamPart(p)

	if clamPart == nil then
		return nil
	end

	return clamPart.CFrame * createVector(0, 0, -3.5)
end

function v:setClamHidden(flag: boolean)
	local localTransparencyModifier = flag and 1 or 0
	local canCollide = not flag

	if self:IsA("BasePart") then
		self.LocalTransparencyModifier = localTransparencyModifier
		self.CanCollide = canCollide
	end

	for _, part2 in self:GetDescendants() do
		if not part2:IsA("BasePart") then
			continue
		end

		part2.LocalTransparencyModifier = localTransparencyModifier
		part2.CanCollide = canCollide
	end
end

function v.poof(p)
	local clamPart = v.getClamPart(p)

	if clamPart ~= nil then
		Effect.new("Chests.Despawn"):play({
			CFrame = clamPart.CFrame
		})
	end
end

function v.playOpenAnim(p, model)
	if not model:IsA("Model") then
		return
	end

	local animationController = model:FindFirstChild("AnimationController")
	local clamOpen = model:FindFirstChild("ClamOpen", true)

	if animationController ~= nil and clamOpen ~= nil and clamOpen:IsA("Animation") then
		for _, v2 in animationController:GetPlayingAnimationTracks() do
			v2:Stop(0)
		end

		local track = animationController:LoadAnimation(clamOpen)
		track.Looped = false
		track:Play()
		p.Tracks[model] = track
		track.KeyframeReached:Connect(function(p2: string)
			if p2 == "Stop" then
				track:AdjustSpeed(0)
			end
		end)
	end
end

function v.stopOpenAnim(p, model)
	if not model:IsA("Model") then
		return
	end

	local animationController = model:FindFirstChild("AnimationController")

	if animationController == nil then
		return
	end

	for _, v2 in animationController:GetPlayingAnimationTracks() do
		v2:Stop(0)
	end

	local clamOpen = model:FindFirstChild("ClamOpen", true)

	if clamOpen ~= nil and clamOpen:IsA("Animation") then
		local track = animationController:LoadAnimation(clamOpen)
		track:Play(0)
		track.TimePosition = 0
		track:AdjustSpeed(0)
		p.Tracks[model] = track
	end
end

function v.clearPrompt(p, p2)
	local prompt = p.Prompts[p2]

	if prompt ~= nil then
		local parent = prompt.Parent
		prompt:Destroy()

		if parent ~= nil and parent:IsA("Attachment") then
			parent:Destroy()
		end

		p.Prompts[p2] = nil
	end
end

function v.hideClam(p)
	v.poof(p)
	v.setClamHidden(p, true)
end

function v.addOpenPrompt(p, p2, p3)
	v.clearPrompt(p2, p3)
	local clamPart = v.getClamPart(p3)

	if clamPart == nil then
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.Parent = clamPart
	attachment.Position = createVector(0, 0, -3.5)
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt:AddTag("ProximityPrompt")
	proximityPrompt.ActionText = "Open"
	proximityPrompt.ObjectText = "Clam Shell"
	proximityPrompt.MaxActivationDistance = 12
	proximityPrompt.HoldDuration = 0.6
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Parent = attachment
	p2.Prompts[p3] = proximityPrompt
	p2.Maid:GiveTask(attachment)
	p2.Maid:GiveTask(proximityPrompt.Triggered:Connect(function()
		v.openClam(p, p2, p3, proximityPrompt)
	end))
end

function v.spawnPearl(p, p2, p3)
	if p2.Cancelled then
		return
	end

	local clamPoint = v.getClamPoint(p3)

	if clamPoint == nil then
		return
	end

	local v2 = clamPoint + createVector(0, 3, 0)
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Ball
	part.Size = createVector(1.5, 1.5, 1.5)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Material = Enum.Material.SmoothPlastic
	part.Reflectance = 0.5
	part.Color = Color3.fromRGB(15, 15, 20)
	part.CFrame = CFrame.new(v2 - createVector(0, 0.5, 0))
	part.Parent = workspace
	p2.Maid:GiveTask(part)
	v.playRandom(frozen2, part)
	local tween = TweenService:Create(
		part,
		TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{
			CFrame = CFrame.new(v2 + createVector(0, 0.5, 0))
		}
	)
	p2.Maid:GiveTask(tween)
	tween:Play()
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt:AddTag("ProximityPrompt")
	proximityPrompt.ActionText = "Claim"
	proximityPrompt.ObjectText = "Pearl of the Deep"
	proximityPrompt.MaxActivationDistance = 12
	proximityPrompt.HoldDuration = 0.6
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Parent = part
	p2.Maid:GiveTask(proximityPrompt)
	p2.Maid:GiveTask(proximityPrompt.Triggered:Connect(function()
		v.claim(p, p2, part, proximityPrompt)
	end))
end

function v.playAwakenCinematicAsync()
	local v2 = os.clock() + 6
	local root = nil

	while true do
		local enemies = workspace:FindFirstChild("Enemies")
		local fishmanLord

		if enemies ~= nil then
			fishmanLord = enemies:FindFirstChild("Fishman Lord")
		end

		local humanoidRootPart

		if fishmanLord ~= nil then
			humanoidRootPart = fishmanLord:FindFirstChild("HumanoidRootPart")
		end

		if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
			task.wait(0.1)
		else
			root = humanoidRootPart
		end

		if not (root ~= nil or v2 < os.clock()) then
			continue
		end

		if root == nil then
			break
		end

		Effect.new("BossAwaken.Cinematic"):play({
			Root = root,
			Duration = 2.5,
			Range = 1e999,
			PullEnd = 48,
			HeightEnd = 20,
			Saturation = -0.1
		})
		break
	end
end

function v.claim(object, p, instance, p2)
	if p.Cancelled then
		return
	end

	p2.Enabled = false

	if object:InvokeServer("ClaimPearl") == true then
		v.poof(instance)
		instance:Destroy()
		task.spawn(v.playAwakenCinematicAsync)
	elseif instance.Parent ~= nil and not p.Cancelled then
		p2.Enabled = true
	end
end

function v.openClam(object, p, p2, p3)
	if p.Cancelled then
		return
	end

	p3.Enabled = false
	local v2 = object:InvokeServer("OpenClam", p2)

	if v2 == false or v2 == nil then
		if p2.Parent ~= nil and not p.Cancelled then
			p3.Enabled = true
		end
	else
		v.clearPrompt(p, p2)
		v.playOpenAnim(p, p2)
		local clamPart = v.getClamPart(p2)

		if clamPart ~= nil then
			v.playRandom(frozen, clamPart)
		end

		if v2 == "Black" then
			task.wait(1)

			if p.Cancelled then
				return
			end

			v.spawnPearl(object, p, p2)
		else
			local v3 = v2 == "Mimic" and 1 or 2.25
			task.wait(v3)

			if p.Cancelled then
				return
			end

			v.hideClam(p2)
		end
	end
end

function v.getState(maid)
	local _pearlState = maid.MiscData._pearlState

	if _pearlState ~= nil then
		return _pearlState
	end

	local pearlState = {
		Maid = Maid.new(),
		Cancelled = false,
		Prompts = {},
		Tracks = {}
	}
	maid.MiscData._pearlState = pearlState
	maid:GiveTask(pearlState.Maid)
	pearlState.Maid:GiveTask(function()
		pearlState.Cancelled = true
	end)
	return pearlState
end

local PearlOfTheDeep = {}
PearlOfTheDeep.DataName = script.Name
PearlOfTheDeep.Repeatable = false
PearlOfTheDeep.RemoteEvents = {
	ClamRespawned = function(p, instance)
		if typeof(instance) ~= "Instance" or not instance:IsDescendantOf(workspace) then
			return
		end

		local state = v.getState(p)

		if state.Cancelled then
			return
		end

		v.setClamHidden(instance, false)
		v.stopOpenAnim(state, instance)
		v.addOpenPrompt(p, state, instance)
	end
}

function PearlOfTheDeep.OnLoad(p)
	local state = v.getState(p)

	for _, v2 in CollectionService:GetTagged("PearlClam") do
		if not v2:IsDescendantOf(workspace) then
			continue
		end

		v.setClamHidden(v2, false)
		v.stopOpenAnim(state, v2)
		v.addOpenPrompt(p, state, v2)
	end

	state.Maid:GiveTask(CollectionService:GetInstanceAddedSignal("PearlClam"):Connect(function(instance)
		if state.Cancelled or not instance:IsDescendantOf(workspace) then
			return
		end

		v.addOpenPrompt(p, state, instance)
	end))
end

function PearlOfTheDeep.OnComplete(p)
	local _pearlState = p.MiscData._pearlState

	if _pearlState ~= nil then
		for _, v2 in CollectionService:GetTagged("PearlClam") do
			if not v2:IsDescendantOf(workspace) then
				continue
			end

			v.setClamHidden(v2, false)
			v.stopOpenAnim(_pearlState, v2)
		end

		_pearlState.Maid:DoCleaning()
		p.MiscData._pearlState = nil
	end
end

return PearlOfTheDeep