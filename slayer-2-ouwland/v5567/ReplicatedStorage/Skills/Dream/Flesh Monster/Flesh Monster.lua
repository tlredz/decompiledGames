local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local Utility = require(CAM.Global.Utility)
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local Config = require(script.Parent.Config)
local FleshMonster = {
	Id = 0
}
local count = 0
local count2 = 0

function FleshMonster.Hold(player)
	maid:Clean()
	count = 0
	count2 += 1
	local rootPart = player.Character:FindFirstChild("Humanoid").RootPart
	local mousepos = Platform_Handler.mousepos()
	local alignOrientationWithAttachment, v = Utility.CreateAlignOrientationWithAttachment(rootPart, "skill_look_at", {
		Responsiveness = 70,
		MaxTorque = 500000,
		CFrame = Utility.SafeLookAt(
			rootPart.Position,
			Vector3.new(mousepos.X, rootPart.Position.Y, mousepos.Z),
			rootPart.CFrame
		)
	})
	maid:Add(v)
	maid:Add(alignOrientationWithAttachment)
	maid:Connect(RunService.PostSimulation, function()
		local mousepos2 = Platform_Handler.mousepos()
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			rootPart.Position,
			Vector3.new(mousepos2.X, rootPart.Position.Y, mousepos2.Z),
			alignOrientationWithAttachment.CFrame
		)
	end)
end

function FleshMonster.UnHold(p)
	local v = count2
	local v2, v3 = ManuelCancel.new(p, Config.TRANSFORM_DURATION)
	v2:Connect(function()
		FleshMonster.Id = -1
		FleshMonster.Cancel(p)
	end)
	maid:Add(v3)

	if Platform_Handler.Platform.Value == "Mobile" then
		local getvaluesfolder = Utility.getvaluesfolder(p, true)

		if getvaluesfolder ~= nil then
			maid:Add(Utility.AddValue(getvaluesfolder, "MinZoom", nil, "NumberValue", Config.MOBILE_MIN_ZOOM))
		end
	end

	task.delay(Config.TRANSFORM_DURATION + 0.5, function()
		if count2 ~= v then
			return
		end

		FleshMonster.Cancel(p)
	end)
end

function FleshMonster.Switch(p)
	count += 1

	if count >= Config.HIT_COUNT then
		local v = count2
		task.wait(Config.LAST_HIT_DURATION)

		if count2 ~= v then
			return
		end

		FleshMonster.Cancel(p)
	end
end

function FleshMonster.Cancel(_)
	count2 += 1
	maid:Clean()
	count = 0
end

return FleshMonster