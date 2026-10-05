local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
game:GetService("CollectionService")
local CAM = ReplicatedStorage2.CAM
local client = CAM.Client
local global = CAM.Global
local Platform_Handler = require(client.Controllers.Platform_Handler)
local cleanit = require(game.ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local Utility = require(global.Utility)
local SkillAimMarker = require(CAM.Client.Modules.Effects.SkillAimMarker)
require(global.Checker)
local DebrisModule = require(CAM.DebrisModule)
require(ReplicatedStorage.CAM.Global.RaycastHelper)
local ProjectileHoming = require(global.Subsets.Gameplay.ProjectileHoming)
local Config = require(script.Parent.Config)
local getvaluesfolder = Utility.getvaluesfolder(Players.LocalPlayer)
local track = nil
local v = nil
local TorrentialArrows = {}
TorrentialArrows.Id = 0

function TorrentialArrows.Hold(player)
	local lastTime = os.clock()
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	track = humanoid:FindFirstChild("Animator"):LoadAnimation(script.StartUp)
	track:Play()
	maid:Add(task.delay(Config.HOLD_ANIM_FREEZE_AT, function()
		track:AdjustSpeed(0)
	end))
	local clone = script.Parent.Parent.Parent.holder.skill_stand_still:Clone()
	clone.Parent = rootPart
	DebrisModule:AddItem(clone, Config.STAND_STILL_MAX_DUR)
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(rootPart, "skill_look_at", {
		AlignType = Enum.AlignType.PrimaryAxisParallel,
		Responsiveness = 75,
		MaxTorque = 3000
	})
	maid:Add(v2)
	v = SkillAimMarker.new({
		Dot = true,
		Highlight = true
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

function TorrentialArrows.UnHold(player)
	maid:Clean()
	v = nil

	if track ~= nil then
		track.TimePosition = Config.HOLD_ANIM_FREEZE_AT
		track:AdjustSpeed(1)
	end

	Utility.AddValue(getvaluesfolder, "NR", Config.RELEASE_LOCK_DUR)
	task.wait(Config.RELEASE_LOCK_DUR)

	if player ~= nil and player.Character ~= nil then
		local skill_stand_still = player.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("skill_stand_still")

		if skill_stand_still ~= nil then
			skill_stand_still:Destroy()
		end
	end
end

function TorrentialArrows.Cancel(player)
	maid:Clean()
	v = nil

	if player ~= nil and player.Character ~= nil then
		local skill_stand_still = player.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("skill_stand_still")

		if skill_stand_still ~= nil then
			skill_stand_still:Destroy()
		end
	end

	if track ~= nil then
		track:Stop()
		track = nil
	end
end

return TorrentialArrows