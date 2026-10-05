local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
require3(script.Parent._Types)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("ServerScriptService")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local Players = game:GetService("Players")
local _ = Players.LocalPlayer
require3(ReplicatedStorage2.Shared.ThreadSafeTargetingHelper)
local v = require3(ReplicatedStorage2.Shared.ShockwaveEffect)
local v2 = require3(ReplicatedStorage2.Shared.SpeedModifiers)
local v3 = require3(ReplicatedStorage2.Shared.JumpModifiers)

local function playEffect(character, upgradeLevel: number)
	if not character:GetAttribute("WhirlwindJumpReady") then
		return
	end

	local torso = character:FindFirstChild("Torso")

	if not (torso and torso:IsA("BasePart")) then
		return
	end

	local jump = torso:FindFirstChild("Jump")

	if not (jump and jump:IsA("Sound")) then
		return
	end

	jump:Play()
	local v5 = {
		cframe = character:GetPivot(),
		diameter = 20,
		color = 0,
		orientation = "Forward"
	}
	local color

	if upgradeLevel >= 2 then
		color = Color3.fromRGB(120, 255, 194)
	else
		color = Color3.new(1, 1, 1)
	end

	v5.color = color
	v(v5)
end

local WindCloak = {}
WindCloak.cooldown = 25
WindCloak.cooldownReductionPerUpgrade = -4.166666666666667
WindCloak.iconId = "rbxassetid://14775984681"

function WindCloak.equipped(data)
	if not RunService:IsServer() then
		return
	end

	local jumpingConnection = data.humanoid.Jumping:Connect(function()
		playEffect(data.character, data.upgradeLevel)
	end)
	return function()
		jumpingConnection:Disconnect()
	end
end

function WindCloak.localOwnerActivation(p)
	local v4 = v2:SetModifierFor(p.character, "WindCloak", function(p2: number, _)
		return p2 + (55 + p.upgradeLevel * 5) - 36
	end, v2.Priority.ADD)
	local v5 = v3:SetModifierFor(p.character, "WindCloak", function(p2: number, _)
		return p2 + (18 + p.upgradeLevel * 4) - 7.2
	end)
	task.defer(function()
		local cooldownExpiration = p.character:GetAttribute("CooldownExpiration")
		task.wait(10 + p.upgradeLevel * 2)

		if cooldownExpiration and p.character then
			local cooldownExpiration2 = p.character:GetAttribute("CooldownExpiration")

			if cooldownExpiration2 and math.abs(cooldownExpiration2 - cooldownExpiration) > 2 then
				return
			end
		end

		v4()
		v5()
	end)
	return nil
end

function WindCloak.anyClientActivationAsync(data)
	local v4 = 10 + data.upgradeLevel * 2
	local color = Color3.fromRGB(255, 255, 255)

	if data.upgradeLevel >= 2 then
		color = Color3.fromRGB(120, 255, 194)
	end

	v({
		cframe = data.rootPart.CFrame,
		diameter = 30,
		color = color
	})
	local clones = {}

	for _, part in data.character:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		local limb = data.humanoid:GetLimb(part)

		if limb == Enum.Limb.Unknown then
			continue
		end

		local clone

		if data.upgradeLevel <= 2 then
			clone = ReplicatedStorage2.Misc.Whirlwinds:Clone()
		else
			clone = ReplicatedStorage2.Misc.MaxWhirlwinds:Clone()
		end

		clone.Parent = part
		clone.CFrame = part.CFrame
		clone.Size = part.Size
		clone.WeldConstraint.Part1 = part
		clone.Smoke.Enabled = true
		Debris:AddItem(clone, v4 + 1)

		if limb == Enum.Limb.Torso then
			clone.Trail.Enabled = true
			clone.att2.whirl.Enabled = true
			clone.WindSound:Play()
			clone.OniCharge:Play()
		elseif limb == Enum.Limb.RightLeg then
			clone.att1.whirl.Enabled = true
			clone.Specs1.Enabled = true
		elseif limb == Enum.Limb.LeftLeg then
			clone.att1.whirl.RotSpeed = NumberRange.new(500, 1000)
			clone.att1.whirl.Enabled = true
			clone.Specs1.Enabled = true
		end

		table.insert(clones, clone)
	end

	task.defer(function()
		data.character:SetAttribute("WhirlwindJumpReady", true)
		local cooldownExpiration = data.character:GetAttribute("CooldownExpiration")
		task.wait(v4 - 1)

		if cooldownExpiration and data.character then
			local cooldownExpiration2 = data.character:GetAttribute("CooldownExpiration")

			if cooldownExpiration2 and math.abs(cooldownExpiration2 - cooldownExpiration) > 2 then
				return
			end
		end

		v({
			cframe = data.rootPart.CFrame,
			diameter = 15,
			color = color
		})

		for _, folder in clones do
			for _, descendant in folder:GetDescendants() do
				if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
					descendant.Enabled = false
				elseif descendant:IsA("Sound") then
					if descendant.Name == "OniCharge" then
						descendant:Play()
					end

					TweenService:Create(descendant, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Volume = 0
					}):Play()
				end
			end
		end

		data.character:SetAttribute("WhirlwindJumpReady", nil)
	end)
end

WindCloak.playEffect = playEffect
return WindCloak