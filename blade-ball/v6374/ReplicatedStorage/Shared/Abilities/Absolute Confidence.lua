local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
require3(script.Parent._Types)
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("Players")
local Debris = game:GetService("Debris")
local v = require3(ReplicatedStorage2.Shared.ThreadSafeTargetingHelper)
local v2 = require3(ReplicatedStorage2.Shared.SpeedModifiers)
require3(ReplicatedStorage2.Shared.ShockwaveEffect)
local v3 = require3(ReplicatedStorage2.Common.Utils)
require3(ReplicatedStorage2.Packages.Replion)
local v4 = require3(ReplicatedStorage2.Packages.Trove)
require3("@game/ReplicatedStorage/Types/Templates")
local v5 = {
	Pull = true,
	Telekinesis = true,
	Freeze = true,
	["Death Slash"] = true,
	["Absolute Confidence"] = true
}

if RunService:IsServer() then
	workspace.Balls.ChildAdded:Connect(function(child)
		if not require3(ReplicatedStorage2.Shared.UseBall2)() then
			return
		end

		child.Parried.Event:Connect(function(instance)
			if instance:GetAttribute("IsConfident") then
				child.SetSpeed:Invoke(child.GetSpeed:Invoke() + 5 + instance:GetAttribute("ConfidentLevel") * 5)
			end
		end)
	end)
	v.AddTargetFilter(script.AbsoluteConfidenceTargetFilter)
else
	script.AbsoluteConfidenceParried.OnClientEvent:Connect(function(p, instance)
		local clone = instance:Clone()

		for _, descendant in clone:GetDescendants() do
			Debris:AddItem(descendant, 2)

			if descendant.Parent == clone then
				descendant.Parent = p.Body
			end

			if descendant:IsA("Sound") then
				descendant.Parent = p.Body
				descendant:Play()
			elseif descendant:IsA("ParticleEmitter") then
				descendant:Emit(descendant:GetAttribute("EmitCount"))
			end
		end

		Debris:AddItem(clone, 2)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getEffect(p, p2: string)
	return script[p2][p.upgradeLevel >= 2 and "Upgraded" or "Normal"]
end

local function getDuration(p)
	if p.upgradeLevel >= 2 then
		return 12
	end

	return 7
end

local function timedCleanup(duration: number, p, callback)
	local thread = nil
	local v6 = nil
	local flag = false

	local function doCleanup()
		if flag then
			return
		end

		flag = true

		if thread then
			v3.Thread.SafeCancel(thread)
		end

		if v6 then
			v6()
		end

		callback()
	end

	thread = task.delay(duration, doCleanup)
	v6 = p.addCleaner(doCleanup)
	return doCleanup
end

local AbsoluteConfidence = {}
AbsoluteConfidence.cooldown = 50
AbsoluteConfidence.cooldownReductionPerUpgrade = 5
AbsoluteConfidence.iconId = "rbxassetid://16043669032"

function AbsoluteConfidence.canBeUsed(_)
	for _, child in workspace.Alive:GetChildren() do
		if child:GetAttribute("IsConfident") then
			return false
		end
	end

	return true
end

function AbsoluteConfidence.localOwnerActivation(data, p)
	local maid = v4.new()
	maid:Add(v2:SetModifierFor(data.character, "Absolute Confidence", function(p2: number)
		return p2 + 5 + data.upgradeLevel * 5
	end, v2.Priority.ADD))
	local v6 = data.upgradeLevel >= 2 and 12 or 7

	local function fn()
		maid:Destroy()
	end

	local thread = nil
	local v7 = nil
	local flag = false

	local function doCleanup()
		if flag then
			return
		end

		flag = true

		if thread then
			v3.Thread.SafeCancel(thread)
		end

		if v7 then
			v7()
		end

		fn()
	end

	thread = task.delay(v6, doCleanup)
	v7 = p.addCleaner(doCleanup)
	local track = data.animator:LoadAnimation(script.AbsoluteConfidencePose)
	track:Play()
	track.Ended:Connect(function()
		track:Destroy()
	end)
	return {
		expectedEndDuration = workspace:GetServerTimeNow() + (data.upgradeLevel >= 2 and 12 or 7)
	}
end

function AbsoluteConfidence.validateArguments(p, p2)
	assert(p ~= nil, "Bad arguments")
	assert(typeof(p.expectedEndDuration) == "number", "Bad expectedEndDuration")
	assert(
		p.expectedEndDuration <= workspace:GetServerTimeNow() + (p2.upgradeLevel >= 2 and 12 or 7),
		"Bad expectedEndDuration (exceeded)"
	)
end

function AbsoluteConfidence.serverActivationAsync(data, p, p2)
	local v6 = require3(ServerScriptService.Game.Services.AbilityService)
	local maid = v4.new()
	data.character:SetAttribute("IsConfident", true)
	data.character:SetAttribute("ConfidentLevel", data.upgradeLevel)
	maid:Add(function()
		data.character:SetAttribute("IsConfident", nil)
		data.character:SetAttribute("ConfidentLevel", nil)
	end)

	for _, child in workspace.Alive:GetChildren() do
		if not (child ~= data.character and v5[child:GetAttribute("Ability")]) then
			continue
		end

		v6:BlockAbilities(child, "Absolute_Confidence")
		local v7 = child
		maid:Add(function()
			v6:UnblockAbilities(v7, "Absolute_Confidence")
		end)
	end

	local bindableFunction = Instance.new("BindableFunction")
	bindableFunction.Name = "CustomParryEffect"
	bindableFunction.Parent = data.character
	maid:Add(bindableFunction)

	function bindableFunction.OnInvoke(p3)
		p3.ParryEffect:Invoke()
		script.AbsoluteConfidenceParried:FireAllClients(p3, getEffect(data, "Hit"))
	end

	local effect = getEffect(data, "Aura") -- equivalent call inferred; original call site unknown

	if effect then
		local clone = effect:Clone()
		local v7 = {}

		for _, sound in clone:GetChildren() do
			if sound:IsA("Sound") then
				sound.Parent = data.rootPart
				sound:Play()
				table.insert(v7, sound)
			else
				local child = data.character:FindFirstChild(sound.Name)

				if child then
					for _, descendant in clone:GetDescendants() do
						if descendant.Parent == sound then
							descendant.Parent = child
						end

						table.insert(v7, descendant)
					end
				end
			end
		end

		maid:Add(function()
			Debris:AddItem(clone, 2)

			for _, instance in v7 do
				Debris:AddItem(instance, 2)

				if instance:IsA("ParticleEmitter") or instance:IsA("Light") then
					instance.Enabled = false
				end
			end
		end)
	end

	local v7 = p2.expectedEndDuration - workspace:GetServerTimeNow()

	local function fn()
		maid:Destroy()
	end

	local thread = nil
	local v8 = nil
	local flag = false

	local function doCleanup()
		if flag then
			return
		end

		flag = true

		if thread then
			v3.Thread.SafeCancel(thread)
		end

		if v8 then
			v8()
		end

		fn()
	end

	thread = task.delay(v7, doCleanup)
	v8 = p.addCleaner(doCleanup)
end

function AbsoluteConfidence.anyClientActivationAsync(p, p2, p3)
	local maid = v4.new()

	local function onBallAdded(instance)
		local maid2 = maid:Extend()
		local effect = getEffect(p, "Chains") -- equivalent call inferred; original call site unknown

		if effect then
			local clone = maid2:Clone(effect)
			local parent = instance.Body:FindFirstChild("ConfidentChain")

			if not parent then
				parent = Instance.new("Attachment")
				parent.Name = "ConfidentChain"
				parent.Parent = instance.Body
			end

			for _, child in clone:GetChildren() do
				child.Parent = parent
			end

			local beam = parent.Beam
			beam.Attachment1 = p.rootAttachment
			clone:Destroy()
			maid2:Add(parent)
			maid2:Add(RunService.PostSimulation:Connect(function(_: number)
				beam.TextureLength = (p.rootAttachment.WorldPosition - instance.Body.Position).Magnitude * 0.5
			end))
		end

		maid2:Add(instance.Destroying:Once(function()
			maid2:Destroy()
		end))
	end

	maid:Add(workspace.Balls.ChildAdded:Connect(onBallAdded))

	for _, child in workspace.Balls:GetChildren() do
		task.spawn(onBallAdded, child)
	end

	local v6 = p3.expectedEndDuration - workspace:GetServerTimeNow()

	local function fn()
		maid:Destroy()
	end

	local thread = nil
	local v7 = nil
	local flag = false

	local function doCleanup()
		if flag then
			return
		end

		flag = true

		if thread then
			v3.Thread.SafeCancel(thread)
		end

		if v7 then
			v7()
		end

		fn()
	end

	thread = task.delay(v6, doCleanup)
	v7 = p2.addCleaner(doCleanup)
end

return AbsoluteConfidence