local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local skills = ReplicatedStorage.Skills
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local DebrisModule = require(CAM.DebrisModule)
local Utility = require(CAM.Global.Utility)
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local Config = require(script.Parent.Config)
local ThrowingStrike = {
	Id = 0
}
local skill_stand_still = skills.holder.skill_stand_still
local anim = script.Anim
local v = script.End
local v2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function stopTrack()
	if v2 then
		v2:Stop()
		v2 = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function plant(humanoidRootPart, p: number)
	local clone = skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	maid:Add(clone)
	DebrisModule:AddItem(clone, p + 0.2)
end

local function aim(humanoidRootPart, id: number, p: number, p2: number?)
	local function aimCF(cframe: CFrame)
		return Utility.SafeLookAt(humanoidRootPart.Position, Platform_Handler.mousepos(Config.MOUSE_RANGE), cframe)
	end

	local createAlignOrientationWithAttachment = Utility.CreateAlignOrientationWithAttachment
	local v3 = {
		AlignType = Enum.AlignType.AllAxes,
		Responsiveness = 70,
		MaxTorque = 500000,
		CFrame = 0
	}
	local cFrame = humanoidRootPart.CFrame
	v3.CFrame = Utility.SafeLookAt(humanoidRootPart.Position, Platform_Handler.mousepos(Config.MOUSE_RANGE), cFrame)
	local alignOrientationWithAttachment, v4 = createAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		v3
	)
	maid:Add(alignOrientationWithAttachment)
	maid:Add(v4)
	DebrisModule:AddItem(alignOrientationWithAttachment, p)
	DebrisModule:AddItem(v4, p)
	local v5 = os.clock() + (p2 or p)
	local postSimulationConnection = nil
	postSimulationConnection = RunService.PostSimulation:Connect(function()
		if ThrowingStrike.Id == id and alignOrientationWithAttachment.Parent ~= nil and not (v5 <= os.clock()) then
			local v6 = alignOrientationWithAttachment
			local cFrame2 = alignOrientationWithAttachment.CFrame
			v6.CFrame = Utility.SafeLookAt(
				humanoidRootPart.Position,
				Platform_Handler.mousepos(Config.MOUSE_RANGE),
				cFrame2
			)
			return
		end

		postSimulationConnection:Disconnect()
	end)
	maid:Add(postSimulationConnection)
end

function ThrowingStrike.Hold(player)
	maid:Clean()
	stopTrack() -- equivalent call inferred; original call site unknown
	local id = ThrowingStrike.Id
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if animator == nil or humanoidRootPart == nil then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", Config.MAX_HOLD))
	plant(humanoidRootPart, Config.MAX_HOLD) -- equivalent call inferred; original call site unknown
	aim(humanoidRootPart, id, Config.MAX_HOLD)
	local track = animator:LoadAnimation(anim)
	v2 = track
	track:Play()
	task.delay(Config.HOLD_PAUSE, function()
		if ThrowingStrike.Id ~= id or v2 ~= track then
			return
		end

		if track.IsPlaying then
			track:AdjustSpeed(0)
		end
	end)
	task.wait(Config.HOLD_PAUSE)
end

function ThrowingStrike.UnHold(player)
	maid:Clean()
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		stopTrack() -- equivalent call inferred; original call site unknown
		return true
	else
		local v3 = v2

		if v3 then
			v3:AdjustSpeed(1)
			maid:Add(v3)
			v2 = nil
		end

		local getvaluesfolder = Utility.getvaluesfolder(character)
		maid:Add(Utility.AddValue(getvaluesfolder, "NR", Config.LOCK))
		plant(humanoidRootPart, Config.LOCK) -- equivalent call inferred; original call site unknown
		local id = ThrowingStrike.Id
		aim(humanoidRootPart, id, Config.LOCK, Config.WINDUP + Config.THROW_TIME)
		local humanoid = character:FindFirstChild("Humanoid")
		local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
		task.delay(Config.WINDUP + Config.END_AT, function()
			if ThrowingStrike.Id ~= id or animator == nil then
				return
			end

			if v3 then
				v3:Stop()
			end

			local track = animator:LoadAnimation(v)
			maid:Add(track)
			track:Play()
		end)
		return true
	end
end

function ThrowingStrike.Cancel(_)
	maid:Clean()
	stopTrack() -- equivalent call inferred; original call site unknown
end

return ThrowingStrike