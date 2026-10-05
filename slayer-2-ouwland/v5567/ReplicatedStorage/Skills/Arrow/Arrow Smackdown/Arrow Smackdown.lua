game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
game:GetService("CollectionService")
require(ReplicatedStorage.CAM.Global.RaycastHelper)
local CAM = ReplicatedStorage2.CAM
local client = CAM.Client
local global = CAM.Global
local Platform_Handler = require(client.Controllers.Platform_Handler)
local cleanit = require(game.ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local Utility = require(global.Utility)
local SkillAimMarker = require(CAM.Client.Modules.Effects.SkillAimMarker)
local ProjectileHoming = require(global.Subsets.Gameplay.ProjectileHoming)
require(global.Checker)
require(CAM.DebrisModule)
local Config = require(script.Parent.Config)
local ArrowSmackdown = {
	Id = 0
}
local v = nil
local track = nil

function ArrowSmackdown.Hold(player)
	local lastTime = os.clock()
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	local animator = humanoid:FindFirstChild("Animator")
	local id = ArrowSmackdown.Id
	track = animator:LoadAnimation(script.Attempt)
	track:Play()
	maid:Add(task.delay(Config.HOLD_ANIM_FREEZE_AT, function()
		if id ~= ArrowSmackdown.Id then
			return
		end

		track:AdjustSpeed(0)
	end))
	local clone = script.Parent.Parent.Parent.holder.skill_stand_still:Clone()
	clone.Parent = rootPart
	maid:Add(clone)
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(rootPart, "skill_look_at", {
		AlignType = Enum.AlignType.PrimaryAxisParallel,
		Responsiveness = 75,
		MaxTorque = 3000
	})
	maid:Add(v2)
	v = SkillAimMarker.new({
		Dot = true,
		Highlight = true,
		Ground = {
			CFrame = rootPart.CFrame * CFrame.new(0, -2.5, 0),
			LifeTime = 4,
			Radius = Config.AIM_RANGE
		}
	})
	maid:Add(v)
	local lock = ProjectileHoming.NewLock({
		Script = script,
		Caster = character,
		Range = Config.AIM_RANGE,
		Radius = Config.AIM_PICK_RADIUS,
		Downcast = Config.AIM_DOWNCAST,
		Select = true,
		KeepUntilGone = true
	})
	maid:Connect(RunService.PostSimulation, function(_: number)
		local mousepos = Platform_Handler.mousepos(500)
		local child = character:FindFirstChild(Config.POS_PART_NAME)

		if child then
			child.Position = mousepos
			local bp = child:FindFirstChild("bp")

			if bp then
				bp.Position = mousepos
			end
		end

		local target, v4 = lock:Update(rootPart.Position, mousepos)
		local position = v4 or rootPart.Position + rootPart.CFrame.LookVector * Config.AIM_RANGE
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			rootPart.Position,
			position,
			alignOrientationWithAttachment.CFrame
		)

		if v then
			v:Update({
				position = position,
				target = target
			})
		end
	end)
	local v3 = Config.MIN_WINDUP - (os.clock() - lastTime)

	if v3 > 0 then
		task.wait(v3)
	end
end

function ArrowSmackdown.UnHold(player, _: Vector3, _: boolean?)
	maid:Clean()
	v = nil
	local humanoid = player.Character:FindFirstChild("Humanoid")
	local _ = humanoid.RootPart
	humanoid:FindFirstChild("Animator")
	track.TimePosition = Config.HOLD_ANIM_FREEZE_AT
	track:AdjustSpeed(1)
	track = nil
end

function ArrowSmackdown.Cancel(_)
	maid:Clean()
	v = nil

	if track then
		track:Stop()
		track = nil
	end
end

return ArrowSmackdown