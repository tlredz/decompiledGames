local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
game:GetService("CollectionService")
local CAM = ReplicatedStorage.CAM
local client = CAM.Client
local global = CAM.Global
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local cleanit = require(ReplicatedStorage2.Packages.cleanit)
local Platform_Handler = require(client.Controllers.Platform_Handler)
local Utility = require(global.Utility)
require(CAM.DebrisModule)
Utility.getvaluesfolder(game.Players.LocalPlayer)
local vfxUtility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("vfxUtility"))
local Config = require(script.Parent.Config)
local maid = cleanit.new()
local track = nil
local BloodTiles = {}
BloodTiles.Id = 0

function BloodTiles.Hold(player)
	local humanoid = player.Character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	track = humanoid:FindFirstChild("Animator"):LoadAnimation(script["Blood Tiles"])
	track:Play()
	maid:Add(task.delay(Config.HOLD_FREEZE_AT, function()
		if track then
			if track:GetAttribute("DoNotPause") then
				return
			else
				track:AdjustSpeed(0)
			end
		end
	end))
	maid:Add(function()
		if track then
			track:Stop()
			track:Destroy()
			track = nil
		end
	end)
	vfxUtility.TweenFOV(0.4, 60)
	local clone = script.Parent.Parent.Parent.holder.skill_stand_still:Clone()
	clone.Parent = rootPart
	maid:Add(clone)
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	local alignOrientationWithAttachment, v = Utility.CreateAlignOrientationWithAttachment(rootPart, "skill_look_at", {
		AlignType = Enum.AlignType.PrimaryAxisParallel,
		Responsiveness = 75,
		MaxTorque = 3000,
		CFrame = Utility.SafeLookAt(rootPart.Position, mousepos, rootPart.CFrame)
	})
	maid:Add(v)
	maid:Add(RunService.PostSimulation:Connect(function(_: number)
		mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			rootPart.Position,
			mousepos,
			alignOrientationWithAttachment.CFrame
		)
	end))
end

function BloodTiles.UnHold(player)
	local _ = player.Character:FindFirstChild("Humanoid").RootPart

	if track then
		track:SetAttribute("DoNotPause", true)
		track.TimePosition = Config.HOLD_FREEZE_AT
		track:AdjustSpeed(1)
	end

	maid:CleanAfter(Config.RELEASE_PAUSE_DUR)
	maid:Add(task.delay(0.25, vfxUtility.TweenFOV, 0.1, 90))
	maid:Add(function()
		vfxUtility.TweenFOV(1, 70)
	end)
end

function BloodTiles.Cancel(_)
	maid:Clean()
	vfxUtility.TweenFOV(0.5, 70)
end

return BloodTiles