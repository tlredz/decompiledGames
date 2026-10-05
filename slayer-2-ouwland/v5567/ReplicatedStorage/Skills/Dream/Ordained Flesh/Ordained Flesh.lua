local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local client = CAM.Client
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local SkillAimMarker = require(client.Modules.Effects.SkillAimMarker)
local Config = require(script.Parent.Config)
local OrdainedFlesh = {
	Id = 0
}
local v2 = {
	aimMarker = nil
}
local ordainedFleshStartup = script.OrdainedFleshStartup
local ordainedFleshRelease = script.OrdainedFleshRelease
local v3 = "PosPart" .. script.Parent.Name

local function updateAim(character)
	local mousepos = Platform_Handler.mousepos(Config.BEAM_RANGE)
	local child = character:FindFirstChild(v3)

	if child then
		child.CFrame = CFrame.new(mousepos)
		local bp = child:FindFirstChild("bp")

		if bp then
			bp.Position = mousepos
		end
	end

	if v2.aimMarker then
		v2.aimMarker:Update({
			position = mousepos
		})
	end
end

function OrdainedFlesh.Hold(player)
	v:Clean()
	local character = player.Character
	local animator = character:FindFirstChildOfClass("Humanoid"):FindFirstChildOfClass("Animator")
	local extended = v:Extend()
	local id = OrdainedFlesh.Id
	local track = animator:LoadAnimation(ordainedFleshStartup)
	track:Play()
	extended:Add(track)
	v2.aimMarker = SkillAimMarker.new({
		Dot = true
	})
	v:Add(v2.aimMarker)
	v:Connect(RunService.PostSimulation, function()
		updateAim(character)
	end)
	task.wait(Config.FLOWER_STARTUP_DURATION)

	if id ~= OrdainedFlesh.Id then
		return
	end

	extended:Clean()
end

function OrdainedFlesh.UnHold(p, _: Vector3?, _)
	local id = OrdainedFlesh.Id
	task.spawn(function()
		task.wait(Config.SHOOT_DURATION)

		if id ~= OrdainedFlesh.Id then
			return
		end

		OrdainedFlesh.Cancel(p)
	end)
end

function OrdainedFlesh.Switch(player)
	v:Clean()
	local animator = player.Character:FindFirstChild("Humanoid"):FindFirstChild("Animator")
	local id = OrdainedFlesh.Id
	local track = animator:LoadAnimation(ordainedFleshRelease)
	v:Add(track)
	track:Play()
	task.wait(1)

	if id ~= OrdainedFlesh.Id then
		return
	end

	OrdainedFlesh.Cancel(player)
end

function OrdainedFlesh.Cancel(_)
	v:Clean()
end

return OrdainedFlesh