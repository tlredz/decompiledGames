local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local ManuelCancel = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ManuelCancel)
local PlayerStatResolver = require(ReplicatedStorage.CAM.Global.PlayerStatResolver)
local Item = require(ServerStorage.SAM.Services.Removers.Item)
local v = {
	["Health Potion"] = "HealthActivated",
	["Health Elixir"] = "HealthActivated",
	["Health Regen Potion"] = "HealthActivated",
	["Health Regen Elixir"] = "HealthActivated",
	["Stamina Regen Potion"] = "StaminaActivated",
	["Stamina Regen Elixir"] = "StaminaActivated"
}
local v2 = {
	Default = 25,
	["Health Elixir"] = 60
}
local v3 = {
	Default = 10,
	["Health Regen Elixir"] = 20,
	["Stamina Regen Elixir"] = 20,
	["Underwater Breathing Potion"] = 120
}
local v4 = {
	Default = 3,
	["Underwater Breathing Potion"] = 1
}
local v5 = {
	["Health Regen Potion"] = "Health Regen Speed",
	["Stamina Regen Potion"] = "Stamina Regen Speed",
	["Health Regen Elixir"] = "Health Regen Speed",
	["Stamina Regen Elixir"] = "Stamina Regen Speed",
	["Underwater Breathing Potion"] = "Breath Duration Factor"
}

local function tune(p, p2: string)
	return p[p2] or p.Default
end

local function playPotionSound(instance, childName: string)
	local child = script:FindFirstChild(childName)

	if child == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local clone = child:Clone()
	clone.Parent = humanoidRootPart
	clone:Play()
	DebrisModule:AddItem(clone, 0)
end

local function giveReward(player, humanoid, p: string)
	local v6 = v[p]

	if v6 then
		EffectsEvent.ToAllInRange(player.Character, "TickActivated", player.Character, v6)
	end

	local v7 = v5[p]

	if v7 == nil then
		if humanoid.Health <= humanoid.MaxHealth then
			local health = humanoid.Health
			local v8 = v2
			humanoid.Health = math.clamp(health + (v8[p] or v8.Default), 0, humanoid.MaxHealth)
		end

		return true
	else
		local getvaluesfolder = Utility.getvaluesfolder(player)

		if getvaluesfolder == nil then
			return false
		end

		PlayerStatResolver.Invalidate(player, v7)
		local v8 = v3
		local v10 = v4
		Utility.AddTimedValue(getvaluesfolder, v7, v8[p] or v8.Default, "NumberValue", v10[p] or v10.Default)
		return true
	end
end

local function cancelCleanup(instance, p)
	local capWeld = instance:FindFirstChild("CapWeld", true)

	if capWeld ~= nil and capWeld.Parent and capWeld.Parent:FindFirstChild("Cap") then
		local handWeld = capWeld.Parent.Cap:FindFirstChild("HandWeld")

		if p.IsLast then
			capWeld.Parent.Cap.CanCollide = false
		elseif handWeld then
			handWeld.Part0 = nil
		end

		capWeld.Part1 = capWeld.Parent.Cap
	end

	p.Thread = nil
end

local HealthPotionServer = {}

function HealthPotionServer.MouseDown(p, instance, state, p2: string)
	if not (Checker.check(p) and state.Thread == nil) then
		return
	end

	local capWeld = instance:FindFirstChild("CapWeld", true)

	if capWeld == nil then
		return
	end

	local parent = capWeld.Parent

	if parent == nil then
		return
	end

	local data = Utility.GetData(p)

	if data == nil then
		return
	end

	local heldItem = Utility.HeldItem(data, p2)

	if heldItem == nil then
		return
	end

	state.IsLast = heldItem:FindFirstChild("Amount") == nil or heldItem.Amount.Value <= 1
	local v6, v7 = ManuelCancel.new(p, 5)
	v6:Connect(function()
		if state.Thread then
			task.cancel(state.Thread)
		end

		cancelCleanup(instance, state)
	end)
	state.Thread = task.spawn(function()
		task.wait(0.3)

		if Checker.check_victim(script, instance, instance) == nil then
			v7()
			return
		end

		capWeld.Part1 = nil
		playPotionSound(instance, "PS2potionOPEN")
		local cap = parent:FindFirstChild("Cap")

		if state.IsLast then
			if cap then
				cap.CanCollide = true
			end
		else
			local leftHand = instance:FindFirstChild("LeftHand")
			local handWeld = cap and cap:FindFirstChild("HandWeld")

			if leftHand and handWeld then
				handWeld.Part0 = leftHand
			end
		end

		task.wait(0.9500000000000001)

		if Checker.check_victim(script, instance, instance) == nil then
			v7()
			return
		end

		playPotionSound(instance, "PS2potionDRINK")
		task.wait(0.19999999999999996)

		if Checker.check_victim(script, instance, instance) == nil then
			v7()
			return
		end

		task.wait(0.3999999999999999)

		if Checker.check_victim(script, instance, instance) == nil then
			v7()
			return
		end

		if not Item(p, p2, nil, nil, "Consumed") then
			v7()
			return
		end

		local humanoid = instance:FindFirstChildOfClass("Humanoid")

		if humanoid == nil or humanoid.Health <= 0 then
			v7()
			return
		end

		if giveReward(p, humanoid, p2) then
			playPotionSound(instance, "PS2potionADMINISTER")
		end

		v7()
		state.Thread = nil

		if state.IsLast then
			if not parent.Parent then
				return
			end

			parent.Parent = workspace.Debree
			task.wait(0.5)

			if Checker.check_victim(script, instance, instance) == nil then
				return
			end

			local primaryPart = instance.PrimaryPart

			if primaryPart == nil then
				return
			end

			local weld = parent:FindFirstChild("Weld")

			if weld == nil then
				return
			end

			local part1 = weld.Part1

			if part1 == nil then
				return
			end

			local cFrame = primaryPart.CFrame

			for _, part in ipairs(parent:GetChildren()) do
				if part:IsA("BasePart") then
					part:SetNetworkOwner(p)
				end
			end

			weld:Destroy()
			playPotionSound(instance, "PS2potionTHROW")
			local attachment = Instance.new("Attachment", part1)
			local linearVelocity = Instance.new("LinearVelocity", attachment)
			linearVelocity.Attachment0 = attachment
			linearVelocity.VectorVelocity = cFrame.LookVector * -20 + cFrame.UpVector * 5
			DebrisModule:AddItem(parent, 2)
			task.wait(0.3)
			attachment:Destroy()
			part1.CanCollide = true
		else
			task.wait(0.5)
			local cap2 = parent:FindFirstChild("Cap")
			local handWeld = cap2 and cap2:FindFirstChild("HandWeld")

			if handWeld then
				handWeld.Part0 = nil
			end

			if capWeld.Parent and capWeld.Parent:FindFirstChild("Cap") then
				capWeld.Part1 = capWeld.Parent.Cap
			end
		end
	end)
end

function HealthPotionServer.MouseUp(_, p, p2)
	if p2.Thread then
		task.cancel(p2.Thread)
		cancelCleanup(p, p2)
	end
end

return HealthPotionServer