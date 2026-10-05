local FlameUndulation = {
	Id = 0
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local clone = nil
local v = nil
local v2 = nil
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v3 = cleanit.new()
local RunService = game:GetService("RunService")
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local ManuelCancel = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ManuelCancel)
local SkillStats = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.StatsFetch.Modules.SkillStats)
local Config = require(script.Parent.Config)
local track = nil

local function interrupted(instance)
	if instance == nil then
		return false
	end

	local v4 = SkillStats.Get(script.Parent.Name)

	if v4 ~= nil and v4.cancel_bypass then
		return false
	end

	for _, child in ipairs(instance:GetChildren()) do
		if Utility.Cancel_Values[child.Name] then
			return true
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function teardown()
	v3:Clean()

	if clone ~= nil then
		clone:Destroy()
		clone = nil
	end

	if v2 ~= nil then
		v2:Destroy()
		v2 = nil
	end

	if track ~= nil then
		track:Stop()
		track = nil
	end
end

function FlameUndulation.Hold(player, p)
	local character = player.Character
	local id = FlameUndulation.Id

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	local humanoid = character:FindFirstChild("Humanoid")

	if not (humanoidRootPart and humanoid) then
		return
	end

	local animator = humanoid:FindFirstChild("Animator")
	clone = script.Parent.Parent.Parent.holder.skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	v, v2 = Utility.CreateAlignOrientationWithAttachment(humanoidRootPart, "skill_look_at", {
		AlignType = Enum.AlignType.PrimaryAxisParallel,
		Responsiveness = 80,
		MaxTorque = 500000,
		CFrame = Utility.SafeLookAt(humanoidRootPart.Position, p, humanoidRootPart.CFrame)
	})
	v3:Connect(RunService.Heartbeat, function(_: number)
		p = Platform_Handler.mousepos()
		v.CFrame = Utility.SafeLookAt(humanoidRootPart.Position, p, v.CFrame)
	end)
	track = animator:LoadAnimation(script.Startup)
	track:Play()
	task.wait(Config.HOLD_STARTUP_DUR)

	if FlameUndulation.Id == id then
		track:Stop()
		track = animator:LoadAnimation(script.Loop)
		track:Play()
	end
end

function FlameUndulation.UnHold(player)
	local character = player.Character

	if character == nil then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid == nil then
		teardown() -- equivalent call inferred; original call site unknown
	else
		local animator = humanoid:FindFirstChild("Animator")

		if animator == nil then
			teardown() -- equivalent call inferred; original call site unknown
		else
			local getvaluesfolder = Utility.getvaluesfolder(character)

			if interrupted(getvaluesfolder) then
				teardown() -- equivalent call inferred; original call site unknown
			else
				if track ~= nil then
					track:Stop()
					track = nil
				end

				local track2 = animator:LoadAnimation(script.Release)
				track2:Play(nil, nil, 1.35)
				local v4 = Utility.AddValue(getvaluesfolder, "NR", Config.RELEASE_LOCK_DURATION)
				local v5 = Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.RELEASE_LOCK_DURATION)
				v3:Clean()
				local id = FlameUndulation.Id
				local v6, v7 = ManuelCancel.new(player, Config.RELEASE_LOCK_DURATION, nil, script.Parent.Name)
				v6:Connect(function()
					id = -1
					track2:Stop()
					v4:Destroy()
					v5:Destroy()
					teardown() -- equivalent call inferred; original call site unknown
					v7()
				end)
				task.wait(Config.RELEASE_LOCK_DURATION)
				v7()

				if id ~= FlameUndulation.Id then
					return
				end

				teardown() -- equivalent call inferred; original call site unknown
			end
		end
	end
end

function FlameUndulation.Cancel(_)
	teardown() -- equivalent call inferred; original call site unknown
end

function FlameUndulation.Counter(p, _, _)
	FlameUndulation.UnHold(p)
end

return FlameUndulation