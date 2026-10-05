local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local client = CAM:WaitForChild("Client")
local global = CAM:WaitForChild("Global")
local Platform_Handler = require(client:WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local Utility = require(global:WaitForChild("Utility"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local maid = require(ReplicatedStorage2.Packages.cleanit).new()
local DebrisModule = require(CAM:FindFirstChild("DebrisModule"))
local ServerClientPortal = require(global.ServerClientPortal)
local Combat_presets = require(global:WaitForChild("Combat_presets"))
local getvaluesfolder = Utility.getvaluesfolder(game.Players.LocalPlayer, true)
require(global:FindFirstChild("Subsets"):FindFirstChild("Gameplay"):FindFirstChild("ManuelCancel"))
local Config = require(script.Parent.Config)
local HundredLeggedZigzag = {
	Id = 0
}
local new = Vector3.new
local boolValue = nil
local v = script.Parent.Name .. "Hold"

function HundredLeggedZigzag.Hold(player)
	if boolValue ~= nil then
		boolValue:Destroy()
		boolValue = nil
	end

	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	local humanoid = character:FindFirstChild("Humanoid")
	local animator = humanoid:FindFirstChild("Animator")
	local id = HundredLeggedZigzag.Id

	if not (humanoidRootPart and humanoid and animator) then
		return
	end

	local v2 = maid:Add(ServerClientPortal.Link(v))
	boolValue = Instance.new("BoolValue")
	boolValue.Name = "NOMouvementlines"
	boolValue.Parent = getvaluesfolder
	DebrisModule:AddItem(boolValue, 0.5)
	v2:Connect(function(p)
		if p == 2 then
			maid:Clean()
			id = -1
		else
			maid:Add(animator:LoadAnimation(script["Miss Loop"])):Play()
			local getvaluesfolder2 = Utility.getvaluesfolder(character)
			Combat_presets.stop_extra_anims(humanoid)
			local v3 = maid:Add(Instance.new("BoolValue"))
			v3.Name = "NOMouvementlines"
			v3.Parent = getvaluesfolder2
			DebrisModule:AddItem(v3, 5)
			local v4 = maid:Add(Instance.new("Attachment", humanoidRootPart))
			v4.Name = "skill_stand_still"
			local v5 = maid:Add(Instance.new("LinearVelocity"))
			v5.Attachment0 = v4
			v5.Name = "bp"
			v5.ForceLimitMode = Enum.ForceLimitMode.PerAxis
			v5.MaxAxesForce = Vector3.new(Config.DASH_MAX_FORCE, 0, Config.DASH_MAX_FORCE)
			v5.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
			local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
			v5.VectorVelocity = (new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z) - humanoidRootPart.Position).Unit * 0
			v5.Parent = v4
			local alignOrientationWithAttachment, v6 = Utility.CreateAlignOrientationWithAttachment(
				humanoidRootPart,
				"skill_look_at",
				{
					AlignType = Enum.AlignType.PrimaryAxisParallel,
					Responsiveness = 45,
					MaxTorque = 1000,
					CFrame = Utility.SafeLookAt(humanoidRootPart.Position, mousepos, humanoidRootPart.CFrame)
				}
			)
			maid:Add(alignOrientationWithAttachment)
			maid:Add(v6)
			task.spawn(function()
				while id == HundredLeggedZigzag.Id and v4 ~= nil and humanoidRootPart and v5 ~= nil and v4.Parent == humanoidRootPart and v5.Parent == v4 and v4.Name == "skill_stand_still" and v6:FindFirstChild("Cancel") == nil and v5:FindFirstChild("Cancel") == nil do
					mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
					v5.VectorVelocity = CFrame.new(
						humanoidRootPart.Position,
						(Vector3.new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z))
					).LookVector * Config.DASH_SPEED
					alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
						humanoidRootPart.Position,
						Vector3.new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z),
						alignOrientationWithAttachment.CFrame
					)
					task.wait()
				end
			end)
		end
	end)
	task.wait(0.5)
end

function HundredLeggedZigzag.UnHold(_)
	if boolValue ~= nil then
		boolValue:Destroy()
		boolValue = nil
	end

	maid:Clean()
end

function HundredLeggedZigzag.Cancel(_)
	maid:Clean()

	if boolValue ~= nil then
		boolValue:Destroy()
		boolValue = nil
	end
end

return HundredLeggedZigzag