local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("CollectionService")
local CAM = ReplicatedStorage.CAM
local client = CAM.Client
local global = CAM.Global
local Platform_Handler = require(client.Controllers.Platform_Handler)
require(global.Subsets.Gameplay.ManuelCancel)
local cleanit = require(game.ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local Utility = require(global.Utility)
local ServerClientPortal = require(ReplicatedStorage2.CAM.Global.ServerClientPortal)
local DebrisModule = require(CAM.DebrisModule)
local ManuelCancel = require(ReplicatedStorage2.CAM.Global.Subsets.Gameplay.ManuelCancel)
local Config = require(script.Parent.Config)
local SonidoSurge = {
	Id = 0
}
local v2 = {}
local getvaluesfolder = Utility.getvaluesfolder(game.Players.LocalPlayer)

function SonidoSurge.Hold(player)
	local character = player.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	local rootPart = humanoid.RootPart

	if not rootPart then
		return
	end

	local animator = humanoid:FindFirstChild("Animator")

	if not animator then
		return
	end

	local track = animator:LoadAnimation(script.User)
	track:Play()
	v2.User_Animation = track
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	local alignOrientationWithAttachment, v3 = Utility.CreateAlignOrientationWithAttachment(rootPart, "skill_look_at", {
		AlignType = Enum.AlignType.PrimaryAxisParallel,
		Responsiveness = 75,
		MaxTorque = 3000,
		CFrame = Utility.SafeLookAt(rootPart.Position, mousepos, rootPart.CFrame)
	})
	v:Add(v3)
	alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
		rootPart.Position,
		mousepos,
		alignOrientationWithAttachment.CFrame
	)
	local clone = script.Parent.Parent.Parent.holder.skill_stand_still:Clone()
	clone.Parent = rootPart
	DebrisModule:AddItem(clone, 10)
	v2.mover = clone
	v2.nomouvment = Utility.AddValue(getvaluesfolder, "NOMouvementlines", 10)
	local linearVelocity = clone.LinearVelocity
	local _ = SonidoSurge.Id
	linearVelocity.VectorVelocity = rootPart.CFrame.LookVector * Config.DASH_SPEED * createVector(1, 0, 1)
	v:Connect(RunService.Heartbeat, function(_: number)
		local mousepos2 = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			rootPart.Position,
			mousepos2,
			alignOrientationWithAttachment.CFrame
		)
		linearVelocity.VectorVelocity = rootPart.CFrame.LookVector * Config.DASH_SPEED * createVector(1, 0, 1)
	end)
end

function SonidoSurge.UnHold(player)
	v:Clean()
	local character = player.Character

	if character ~= nil then
		local humanoid = character:FindFirstChild("Humanoid")

		if humanoid ~= nil and humanoid.RootPart ~= nil then
			local id = SonidoSurge.Id
			local v3, v4 = ManuelCancel.new(player, 1)
			v3:Connect(function()
				SonidoSurge.Cancel(player)
			end)

			if v2.User_Animation then
				v2.User_Animation:Stop()
			end

			local mover = v2.mover

			if mover then
				TweenService:Create(mover.LinearVelocity, TweenInfo.new(Config.DASH_DECEL_TIME), {
					VectorVelocity = createVector(0, 0, 0)
				}):Play()
				local v5 = nil
				ServerClientPortal.Link(script.Parent.Name, Config.MISS_RECOVER_TIME):Connect(function(p)
					v5 = p
				end)
				task.wait(Config.MISS_RECOVER_TIME)

				if v5 ~= nil then
					task.wait(v5 - Config.MISS_RECOVER_TIME)
				end

				if mover ~= nil then
					mover:Destroy()
				end

				if SonidoSurge.Id == id then
					v2.mover = nil
				end
			end

			v4()
		end
	end

	if v2.nomouvment ~= nil then
		v2.nomouvment:Destroy()
		v2.nomouvment = nil
	end
end

function SonidoSurge.Cancel(player)
	v:Clean()

	if v2.User_Animation then
		v2.User_Animation:Stop()
		v2.User_Animation:Destroy()
	end

	if v2.mover then
		v2.mover:Destroy()
		v2.mover = nil
	end

	if v2.nomouvment ~= nil then
		v2.nomouvment:Destroy()
		v2.nomouvment = nil
	end

	local character = player.Character

	if not character then
		return
	end

	local primaryPart = character.PrimaryPart

	if not primaryPart then
		return
	end

	primaryPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	primaryPart.AssemblyAngularVelocity = createVector(0, 0, 0)
end

return SonidoSurge