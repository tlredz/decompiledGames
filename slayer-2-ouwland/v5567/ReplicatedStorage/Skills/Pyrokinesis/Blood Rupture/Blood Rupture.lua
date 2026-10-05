local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
game:GetService("CollectionService")
local CAM = ReplicatedStorage.CAM
local client = CAM.Client
local global = CAM.Global
local Platform_Handler = require(client.Controllers.Platform_Handler)
local Utility = require(global.Utility)
require(CAM.DebrisModule)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local maid = require(ReplicatedStorage2.Packages.cleanit).new()
local Config = require(script.Parent.Config)
local track = nil
local BloodRupture = {
	Id = 0,
	Hold = function(player)
		local character = player.Character
		local humanoid = character:FindFirstChild("Humanoid")
		local rootPart = humanoid.RootPart
		track = humanoid:FindFirstChild("Animator"):LoadAnimation(script.StartUp)
		track:Play()
		maid:Add(function()
			if track then
				track:Stop()
				track:Destroy()
				track = nil
			end
		end)
		maid:Add(task.delay(Config.STARTUP_DUR, function()
			Utility.AddValue(Utility.getvaluesfolder(character), "NOMouvementlines", 1)
			local v = maid:Add(script.Parent.Parent.Parent.holder.skill_stand_still:Clone())
			v.Parent = rootPart
			local linearVelocity = v.LinearVelocity
			local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
			local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(
				rootPart,
				"skill_look_at",
				{
					AlignType = Enum.AlignType.PrimaryAxisParallel,
					Responsiveness = 75,
					MaxTorque = 3000,
					CFrame = Utility.SafeLookAt(rootPart.Position, mousepos, rootPart.CFrame)
				}
			)
			maid:Add(v2)
			maid:Add(RunService.PostSimulation:Connect(function(_: number)
				mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
				alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
					rootPart.Position,
					mousepos,
					alignOrientationWithAttachment.CFrame
				)
				linearVelocity.VectorVelocity = rootPart.CFrame.LookVector * Config.DASH_SPEED * createVector(1, 0, 1)
			end))
		end))
	end
}

function BloodRupture.UnHold(p)
	BloodRupture.Cancel(p)
end

function BloodRupture.Cancel(player)
	local rootPart = player.Character:FindFirstChild("Humanoid").RootPart
	maid:Clean()
	rootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
end

return BloodRupture