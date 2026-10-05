local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local skills = ReplicatedStorage.Skills
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local DebrisModule = require(CAM.DebrisModule)
local Utility = require(CAM.Global.Utility)
local Checker = require(CAM.Global.Checker)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local SkillAimMarker = require(CAM.Client.Modules.Effects.SkillAimMarker)
local Config = require(script.Parent.Config)
local PalisadeBite = {
	Id = 0
}
local skill_stand_still = skills.holder.skill_stand_still
local color = Color3.fromRGB(40, 200, 255)
local color2 = Color3.fromRGB(0, 150, 230)
local startup = script.Startup
local release = script.Release
local v = nil
local target = nil

local function scan(character, humanoidRootPart)
	local lookVector = humanoidRootPart.CFrame.LookVector
	local spherecast = workspace:Spherecast(
		humanoidRootPart.Position - lookVector * 5,
		4,
		lookVector * (Config.RADIUS + 5),
		RaycastHelper.EveryHumanoidExceptPlayer
	)

	if spherecast == nil then
		return nil
	end

	local find_character_from_descendant = Utility.find_character_from_descendant(spherecast.Instance)

	if find_character_from_descendant == nil or not Checker.check_can_select(
		script,
		character,
		find_character_from_descendant
	) then
		return nil
	end

	return find_character_from_descendant
end

function PalisadeBite.Hold(player, vector: Vector3)
	maid:Clean()
	local id = PalisadeBite.Id

	if v then
		v:Stop()
		v = nil
	end

	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", Config.MAX_HOLD))
	local clone = skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	maid:Add(clone)
	DebrisModule:AddItem(clone, Config.MAX_HOLD + 0.2)
	local alignOrientationWithAttachment, v3 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 75,
			MaxTorque = 3000,
			CFrame = Utility.SafeLookAt(humanoidRootPart.Position, vector, humanoidRootPart.CFrame)
		}
	)
	maid:Add(alignOrientationWithAttachment)
	maid:Add(v3)
	DebrisModule:AddItem(alignOrientationWithAttachment, Config.MAX_HOLD + 0.2)
	DebrisModule:AddItem(v3, Config.MAX_HOLD + 0.2)
	local v4 = SkillAimMarker.new({
		Highlight = {
			FillColor = color,
			OutlineColor = color2
		}
	})
	maid:Add(v4)
	target = nil
	maid:Connect(RunService.PostSimulation, function()
		if PalisadeBite.Id ~= id or humanoidRootPart.Parent == nil then
			return
		end

		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			humanoidRootPart.Position,
			Platform_Handler.mousepos(Config.MOUSE_RANGE),
			alignOrientationWithAttachment.CFrame
		)

		if target ~= nil and not (target:IsDescendantOf(workspace) and Checker.check_can_select(
			script,
			character,
			target
		)) then
			target = nil
		end

		local v5 = scan(character, humanoidRootPart)

		if v5 ~= nil and v5 ~= target then
			target = v5
		end

		v4:Update({
			target = target
		})
	end)
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if animator then
		local track = animator:LoadAnimation(startup)
		v = track
		track:Play()
		task.delay(Config.HOLD_PAUSE, function()
			if PalisadeBite.Id ~= id or v ~= track then
				return
			end

			if track.IsPlaying then
				track:AdjustSpeed(0)
			end
		end)
	end
end

function PalisadeBite.UnHold(player)
	maid:Clean()
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if v then
		v:Stop()
		v = nil
	end

	target = nil

	if animator then
		local track = animator:LoadAnimation(release)
		maid:Add(track)
		track:Play()
	end

	return true
end

function PalisadeBite.Cancel(_)
	maid:Clean()

	if v then
		v:Stop()
		v = nil
	end

	target = nil
end

return PalisadeBite