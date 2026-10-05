game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("TweenService")
game:GetService("CollectionService")
local CAM = ReplicatedStorage.CAM
local client = CAM.Client
local global = CAM.Global
require(client.Controllers.Platform_Handler)
require(global.Utility)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
require(global.Checker)
local DebrisModule = require(CAM.DebrisModule)
local Config = require(script.Parent.Config)
local ArrowEruption = {
	Id = 0
}
local track = nil
local lastTime = nil

function ArrowEruption.Hold(player)
	lastTime = os.clock()
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	track = humanoid:FindFirstChild("Animator"):LoadAnimation(script.StartUp)
	track:Play()
	track:AdjustSpeed(Config.HOLD_ANIM_SPEED)
	local clone = script.Parent.Parent.Parent.holder.skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	DebrisModule:AddItem(clone, Config.MIN_HOLD_DUR + Config.RELEASE_DUR)
end

function ArrowEruption.UnHold(player)
	if os.clock() - lastTime < Config.MIN_HOLD_DUR then
		if player ~= nil and player.Character ~= nil then
			local skill_stand_still = player.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("skill_stand_still")

			if skill_stand_still ~= nil then
				skill_stand_still:Destroy()
			end
		end

		track:Stop()
	else
		track.TimePosition = Config.RELEASE_ANIM_SKIP_TO
		track:AdjustSpeed(1)
		local v, v2 = ManuelCancel.new(player, Config.RELEASE_DUR)
		v:Connect(function()
			v2()
			v2 = nil
			ArrowEruption.Cancel(player)
		end)
		task.wait(Config.RELEASE_DUR)

		if player ~= nil and player.Character ~= nil then
			local skill_stand_still = player.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("skill_stand_still")

			if skill_stand_still ~= nil then
				skill_stand_still:Destroy()
			end
		end
	end
end

function ArrowEruption.Cancel(player)
	if player ~= nil and player.Character ~= nil then
		local skill_stand_still = player.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("skill_stand_still")

		if skill_stand_still ~= nil then
			skill_stand_still:Destroy()
		end
	end
end

return ArrowEruption