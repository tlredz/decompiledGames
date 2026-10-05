local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local Config = require(ReplicatedStorage.Skills.Wind["Whirlwind Cutter"].Config)
return function(instance, p: string, cFrame, list)
	if instance == nil then
		return
	end

	if p == "Grab" then
		local Players = game:GetService("Players")
		local localPlayer = Players.LocalPlayer
		local character = localPlayer and localPlayer.Character

		if character == nil or typeof(cFrame) ~= "CFrame" then
			return
		end

		local v

		if character == instance then
			v = true
		elseif type(list) == "table" then
			v = table.find(list, character) ~= nil
		else
			v = false
		end

		local humanoidRootPart = v and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart ~= nil then
			humanoidRootPart.CFrame = cFrame
		end
	else
		local formatted = `{instance.Name}-{script.Name}`
		local child = workspace.Debree:FindFirstChild(formatted)

		if child ~= nil then
			child.Name = "--"
			DebrisModule:AddItem(child, 2)
			Ouwmit.Enable(child, false)
		end

		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart == nil then
			return
		end

		if p == "Start" then
			vfxUtility.PlaySound(script.Sound, "PS2windWHIRLWINDCUTTERlaunchNEW", humanoidRootPart, true)
			local clone = script.Parent["Purifying ClawsVFX"].Startup:Clone()
			clone:PivotTo(humanoidRootPart.CFrame)
			clone.Parent = workspace.Debree
			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position,
				humanoidRootPart.CFrame.upVector * -11,
				RaycastHelper.Crater
			)
			Ouwmit.Emit(
				clone,
				Ouwmit.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
			)
			DebrisModule:AddItem(clone, 3)
			Cam_Shaker(humanoidRootPart.Position, "activate_shake")
		elseif p == "Hold" then
			local configuration = Instance.new("Configuration")
			configuration.Name = formatted
			configuration.Parent = workspace.Debree
			DebrisModule:AddItem(configuration, 4)
			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position,
				humanoidRootPart.CFrame.upVector * -11,
				RaycastHelper.Crater
			)
			local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
			local clone = script.Travelling.CycloneEmit:Clone()
			clone:PivotTo(humanoidRootPart.CFrame)
			clone.Parent = configuration
			Ouwmit.Emit(clone, Ouwmit.Owned(instance, v))
			local v2 = vfxUtility.PlaySound(script.Sound, "PS2windWHIRLWINDCUTTERtraveloop", humanoidRootPart, false)
			local cam_Shaker = Cam_Shaker(humanoidRootPart, {
				FadeInTime = 0.1,
				Frequency = 0.225,
				Amplitude = 0.45,
				SustainTime = 2,
				FadeOutTime = 0.65,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(1, 1, 1)
			})

			local function stopAmbience()
				cam_Shaker:Destroy()

				if v2 then
					TweenService:Create(v2, TweenInfo.new(0.3), {
						Volume = 0
					}):Play()
					DebrisModule:AddItem(v2, 0.35)
				end
			end

			task.wait(0.05)

			if configuration.Parent == nil or configuration.Name ~= formatted then
				stopAmbience()
				return
			end

			local clone2 = script.Travelling.Cyclone:Clone()
			clone2:PivotTo(humanoidRootPart.CFrame)
			clone2.Parent = configuration
			Ouwmit.Emit(clone2, Ouwmit.Owned(instance, v))

			while configuration ~= nil and configuration.Parent ~= nil and configuration.Name == formatted do
				clone2:PivotTo(humanoidRootPart.CFrame)
				task.wait()
			end

			stopAmbience()
		elseif p == "Release" then
			local clone = script.Travelling.UpwardsSlash:Clone()
			clone:PivotTo(humanoidRootPart.CFrame)
			clone.Parent = workspace.Debree
			DebrisModule:AddItem(clone, 3)
			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position,
				humanoidRootPart.CFrame.upVector * -11,
				RaycastHelper.Crater
			)
			Ouwmit.Emit(
				clone,
				Ouwmit.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
			)
		elseif p == "Missed" then
			vfxUtility.PlaySound(script.Sound, "whirlwindcuttermissed", humanoidRootPart, true)
		elseif p == "Final" then
			vfxUtility.PlaySound(script.Sound, "PS2windWHIRLWINDCUTTERgrabNEW", humanoidRootPart, true)
			local cFrame2 = humanoidRootPart.CFrame
			local configuration = Instance.new("Configuration")
			configuration.Name = formatted
			configuration.Parent = workspace.Debree
			DebrisModule:AddItem(configuration, Config.FINAL_SEQUENCE_DURATION + 3)
			local raycastResult = workspace:Raycast(cFrame2.Position, cFrame2.upVector * -11, RaycastHelper.Crater)
			local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil

			local function alive()
				return configuration.Parent ~= nil and configuration.Name == formatted and humanoidRootPart.Parent ~= nil
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function emitAt(p2: string)
				local clone = script.Connected[p2]:Clone()
				clone:PivotTo(cFrame2)
				clone.Parent = configuration
				Ouwmit.Emit(clone, Ouwmit.Owned(instance, v))
			end

			task.wait(Config.FINAL_CHARGE_AT - Config.FINAL_WINDUP_DELAY)
			local v2

			if configuration.Parent == nil or configuration.Name ~= formatted then
				v2 = false
			else
				v2 = humanoidRootPart.Parent ~= nil
			end

			if not v2 then
				return
			end

			emitAt("Charge") -- equivalent call inferred; original call site unknown
			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0.1,
				Frequency = 0.225,
				Amplitude = 0.2,
				SustainTime = 0.25,
				FadeOutTime = 0.2,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(1, 1, 1)
			})
			task.wait(Config.FINAL_END_SLASH_AT - Config.FINAL_CHARGE_AT)
			local v3

			if configuration.Parent == nil or configuration.Name ~= formatted then
				v3 = false
			else
				v3 = humanoidRootPart.Parent ~= nil
			end

			if not v3 then
				return
			end

			emitAt("EndSlash") -- equivalent call inferred; original call site unknown
			Cam_Shaker(cFrame2.Position, {
				FadeInTime = 0,
				Frequency = 0.175,
				Amplitude = 2.25,
				SustainTime = 0.1,
				FadeOutTime = 0.3,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(1, 1, 1)
			})
		end
	end
end