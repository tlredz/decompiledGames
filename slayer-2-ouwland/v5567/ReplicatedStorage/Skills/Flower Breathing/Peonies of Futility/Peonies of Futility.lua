local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local skills = ReplicatedStorage.Skills
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local DebrisModule = require(CAM.DebrisModule)
local Utility = require(CAM.Global.Utility)
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local ServerClientPortal = require(CAM.Global.ServerClientPortal)
local Config = require(script.Parent.Config)
local PeoniesOfFutility = {
	Id = 0
}
local skill_stand_still = skills.holder.skill_stand_still
local startup = script.Startup
local jump = script.Jump
local v2 = nil
local v3 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function closeLink()
	if v3 ~= nil then
		if v3.__Active then
			v3:Destroy()
		end

		v3 = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopTrack()
	if v2 ~= nil then
		v2:Stop()
		v2 = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function plant(humanoidRootPart, p: number)
	local clone = skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	v:Add(clone)
	DebrisModule:AddItem(clone, p)
end

function PeoniesOfFutility.Hold(player)
	v:Clean()
	stopTrack() -- equivalent call inferred; original call site unknown
	closeLink() -- equivalent call inferred; original call site unknown
	v3 = ServerClientPortal.Link(script.Parent.Name, Config.MAX_HOLD + Config.ENDLAG + 1)
	local id = PeoniesOfFutility.Id
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if animator == nil or humanoidRootPart == nil then
		return
	end

	plant(humanoidRootPart, Config.MAX_HOLD + 0.2) -- equivalent call inferred; original call site unknown

	-- equivalent calls inferred from this helper; original call sites unknown
	local function flatAim(cFrame: CFrame)
		local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		return Utility.SafeLookAt(
			humanoidRootPart.Position,
			Vector3.new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z),
			cFrame
		)
	end

	local alignOrientationWithAttachment, v6 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 80,
			MaxTorque = 500000,
			CFrame = flatAim(humanoidRootPart.CFrame)
		}
	)
	v:Add(alignOrientationWithAttachment)
	v:Add(v6)
	DebrisModule:AddItem(alignOrientationWithAttachment, Config.MAX_HOLD + 0.2)
	DebrisModule:AddItem(v6, Config.MAX_HOLD + 0.2)
	v:Connect(RunService.Heartbeat, function()
		if alignOrientationWithAttachment.Parent == nil then
			return
		end

		alignOrientationWithAttachment.CFrame = flatAim(alignOrientationWithAttachment.CFrame)
	end)
	local track = animator:LoadAnimation(startup)
	v2 = track
	track:Play()
	task.delay(Config.HOLD_PAUSE, function()
		if PeoniesOfFutility.Id ~= id or v2 ~= track then
			return
		end

		if track.IsPlaying then
			track:AdjustSpeed(0)
		end
	end)
	task.wait(Config.HOLD_PAUSE)
end

function PeoniesOfFutility.UnHold(player)
	v:Clean()
	local v4 = v2

	if v4 ~= nil then
		v4:AdjustSpeed(1)
		v:Add(v4)
		v2 = nil
	end

	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart ~= nil then
		plant(humanoidRootPart, Config.RELEASE_WINDUP) -- equivalent call inferred; original call site unknown
	end

	local id = PeoniesOfFutility.Id
	local v5 = v3

	if v5 ~= nil then
		v5:Once(function(flag: boolean)
			if PeoniesOfFutility.Id ~= id or flag ~= true then
				return
			end

			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

			if animator == nil then
				return
			end

			if v4 ~= nil then
				v4:Stop()
			end

			local track = animator:LoadAnimation(jump)
			track.Priority = Enum.AnimationPriority.Action4
			v:Add(track)
			track:Play()
		end)
	end

	return true
end

function PeoniesOfFutility.Cancel(_)
	v:Clean()
	stopTrack() -- equivalent call inferred; original call site unknown
	closeLink() -- equivalent call inferred; original call site unknown
end

return PeoniesOfFutility