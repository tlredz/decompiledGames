local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
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
local DebrisModule = require(CAM.DebrisModule)
local Config = require(script.Parent.Config)
local gameSettings = require(global.gameSettings)
local getvaluesfolder = Utility.getvaluesfolder(game.Players.LocalPlayer)
local Sonido = {
	Id = 0
}
local track = nil
local clone = nil

function Sonido.Hold(player)
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

	track = animator:LoadAnimation(script["Sonido-Startup"])
	track:Play()
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(rootPart, "skill_look_at", {
		AlignType = Enum.AlignType.PrimaryAxisParallel,
		Responsiveness = 75,
		MaxTorque = 3000,
		CFrame = Utility.SafeLookAt(rootPart.Position, mousepos, rootPart.CFrame)
	})
	v:Add(v2)
	alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
		rootPart.Position,
		mousepos,
		alignOrientationWithAttachment.CFrame
	)
	clone = script.Parent.Parent.Parent.holder.skill_stand_still:Clone()
	clone.Parent = rootPart
	DebrisModule:AddItem(clone, 6)
	local linearVelocity = clone.LinearVelocity
	local maxForce = Config.DASH_START_SPEED * gameSettings.skillDashForcePerSpeed

	if linearVelocity.ForceLimitMode == Enum.ForceLimitMode.PerAxis then
		linearVelocity.MaxAxesForce = Vector3.new(maxForce, 0, maxForce)
	else
		linearVelocity.MaxForce = maxForce
	end

	local id = Sonido.Id
	task.delay(Config.STARTUP_AT, function()
		if Sonido.Id ~= id then
			return
		end

		Utility.AddValue(getvaluesfolder, "NOMouvementlines", 1)
		local DASH_START_SPEED = Config.DASH_START_SPEED
		linearVelocity.VectorVelocity = rootPart.CFrame.LookVector * DASH_START_SPEED * createVector(1, 0, 1)
		track = humanoid.Animator:LoadAnimation(script["Sonido-Loop"])
		track:Play()
		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Exclude
		overlapParams.FilterDescendantsInstances = { character, workspace.Map, workspace.Debree }
		local flag = false
		local v6 = 0
		v:Connect(RunService.Heartbeat, function(p: number)
			if not flag then
				for _, v8 in workspace:GetPartBoundsInBox(rootPart.CFrame, Config.HIT_HITBOX_SIZE, overlapParams) do
					local model = v8:FindFirstAncestorWhichIsA("Model")

					if not (model ~= nil and model ~= character and model:FindFirstChildOfClass("Humanoid") ~= nil) then
						continue
					end

					flag = true
					v6 = math.max(DASH_START_SPEED - Config.HIT_REDUCED_SPEED, 0) / math.max(
						Config.HIT_SLOWDOWN_TIME,
						0.001
					)
					break
				end
			end

			if flag then
				if DASH_START_SPEED > Config.HIT_REDUCED_SPEED then
					DASH_START_SPEED = math.max(Config.HIT_REDUCED_SPEED, DASH_START_SPEED - v6 * p)
				end
			elseif DASH_START_SPEED > Config.DASH_CRUISE_SPEED then
				local v7 = 1 - (1 - Config.DASH_DECAY_RATE) ^ (p * 60)
				DASH_START_SPEED += (Config.DASH_CRUISE_SPEED - DASH_START_SPEED) * v7

				if DASH_START_SPEED <= Config.DASH_CRUISE_SPEED + 0.05 then
					DASH_START_SPEED = Config.DASH_CRUISE_SPEED
				end
			end

			local mousepos2 = Platform_Handler.mousepos(Config.MOUSE_RANGE)
			alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
				rootPart.Position,
				mousepos2,
				alignOrientationWithAttachment.CFrame
			)
			linearVelocity.VectorVelocity = rootPart.CFrame.LookVector * DASH_START_SPEED * createVector(1, 0, 1)
		end)
	end)
end

function Sonido.UnHold(player)
	v:Clean()

	if track then
		track:Stop()
		track:Destroy()
		track = nil
	end

	local character = player.Character

	if character ~= nil then
		local humanoid = character:FindFirstChild("Humanoid")

		if humanoid ~= nil then
			local _ = humanoid.RootPart
			humanoid.Animator:LoadAnimation(script["Sonido-End"]):Play(nil, nil, 2.1)
			TweenService:Create(clone.LinearVelocity, TweenInfo.new(Config.DASH_DECEL_TIME), {
				VectorVelocity = createVector(0, 0, 0)
			}):Play()
			task.wait(Config.DASH_DECEL_TIME)
		end
	end

	if clone then
		clone:Destroy()
		clone:Destroy()
		clone = nil
	end
end

function Sonido.Cancel(player)
	v:Clean()

	if track then
		track:Stop()
		track:Destroy()
		track = nil
	end

	if clone then
		clone:Destroy()
		clone:Destroy()
		clone = nil
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

return Sonido