local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local Config = require(ReplicatedStorage.Skills.Wind["Rising Dust Storm"].Config)
local V1_CYCLONE_START = Config.V1_CYCLONE_START
local debree = workspace.Debree
local v = { "SlashAOE", "SlashTornadoProjectile" }
task.spawn(Ouwmit.Preload, { script.ShortRanged.Cyclone, script.LongRanged.Cyclone, script.LongRanged.Explode })
return function(instance, p: string, p2, p3)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local function folderName(p4: string)
		return string.format("%s_%s_%s_Effects", instance.Name, script.Name, p4)
	end

	local function newStateFolder(p4: string, p5: number)
		local child = debree:FindFirstChild(folderName(p4))

		if child then
			child:Destroy()
		end

		local folder = Instance.new("Folder")
		folder.Name = string.format("%s_%s_%s_Effects", instance.Name, script.Name, p4)
		folder.Parent = debree
		folder:SetAttribute("Active", true)
		DebrisModule:AddItem(folder, p5)
		return folder
	end

	local function explodeLongRange(parent)
		if parent:GetAttribute("Exploded") then
			return
		end

		parent:SetAttribute("Exploded", true)
		local cyclone = parent:FindFirstChild("Cyclone")

		if cyclone == nil then
			return
		end

		local pivot = cyclone:GetPivot()
		DebrisModule:AddItem(cyclone, 3)
		vfxUtility.PlaySound(script.Sound, "PS2windRISINGDUSTSTORMvar1disperse", humanoidRootPart, true)
		local clone = script.LongRanged.Explode:Clone()
		clone:PivotTo(pivot)
		clone.Parent = parent
		DebrisModule:AddItem(clone, 4)
		local raycastResult = workspace:Raycast(pivot.Position, createVector(-0, -11, -0), RaycastHelper.Crater)
		Ouwmit.Emit(
			clone,
			Ouwmit.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
		)
		Cam_Shaker(pivot.Position, {
			FadeInTime = 0,
			Frequency = 0.175,
			Amplitude = 2.25,
			SustainTime = 0.1,
			FadeOutTime = 0.65,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(1, 1, 1)
		})
		local pS2windRISINGDUSTSTORMvar1and2LOOP = humanoidRootPart:FindFirstChild("PS2windRISINGDUSTSTORMvar1and2LOOP")

		if pS2windRISINGDUSTSTORMvar1and2LOOP and pS2windRISINGDUSTSTORMvar1and2LOOP:IsA("Sound") then
			TweenService:Create(pS2windRISINGDUSTSTORMvar1and2LOOP, TweenInfo.new(0.3), {
				Volume = 0
			}):Play()
			DebrisModule:AddItem(pS2windRISINGDUSTSTORMvar1and2LOOP, 0.35)
		end
	end

	if p == "Cancel" then
		for _, v2 in v do
			local child = debree:FindFirstChild(folderName(v2))

			if not child then
				continue
			end

			child.Name = "_"
			child:SetAttribute("Active", nil)
			DebrisModule:AddItem(child, 3)
		end

		local pS2windRISINGDUSTSTORMvar1and2LOOP = humanoidRootPart:FindFirstChild("PS2windRISINGDUSTSTORMvar1and2LOOP")

		if pS2windRISINGDUSTSTORMvar1and2LOOP and pS2windRISINGDUSTSTORMvar1and2LOOP:IsA("Sound") then
			TweenService:Create(pS2windRISINGDUSTSTORMvar1and2LOOP, TweenInfo.new(0.3), {
				Volume = 0
			}):Play()
			DebrisModule:AddItem(pS2windRISINGDUSTSTORMvar1and2LOOP, 0.35)
		end
	elseif p == "Start" then
		vfxUtility.PlaySound(script.Parent, "PS2windGENERALinitiate", humanoidRootPart, true)
		local clone = script.Parent["Purifying ClawsVFX"].Startup:Clone()
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.Parent = debree
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
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")
	elseif p == "SlashAOE" then
		vfxUtility.PlaySound(script.Sound, "PS2windRISINGDUSTSTORMvar2shoot", humanoidRootPart, true)
		vfxUtility.PlaySound(script.Sound, "PS2windRISINGDUSTSTORMvar1and2LOOP", humanoidRootPart, false)
		local parent = newStateFolder("SlashAOE", Config.V1_SEQUENCE_DURATION + 3)
		local cFrame = humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(cFrame.Position, cFrame.upVector * -11, RaycastHelper.Crater)
		local v3 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		Cam_Shaker(cFrame.Position, {
			FadeInTime = 0.1,
			Frequency = 0.175,
			Amplitude = 0.5,
			SustainTime = Config.V1_SPIN_DURATION,
			FadeOutTime = 0.65,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(1, 1, 1)
		})

		local function alive()
			return parent.Parent ~= nil and parent:GetAttribute("Active") == true
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function emitAt(p4: string)
			local clone = script.ShortRanged[p4]:Clone()
			clone:PivotTo(cFrame)
			clone.Parent = parent
			Ouwmit.Emit(clone, Ouwmit.Owned(instance, v3))
			return clone
		end

		task.wait(V1_CYCLONE_START)
		local v4

		if parent.Parent == nil then
			v4 = false
		else
			v4 = parent:GetAttribute("Active") == true
		end

		if not v4 then
			return
		end

		emitAt("Cyclone") -- equivalent call inferred; original call site unknown
		task.wait(0.6666666666666666 - V1_CYCLONE_START)
		local v5

		if parent.Parent == nil then
			v5 = false
		else
			v5 = parent:GetAttribute("Active") == true
		end

		if not v5 then
			return
		end

		emitAt("SpinningSlash") -- equivalent call inferred; original call site unknown
		task.wait(0.8666666666666668)
		local v6

		if parent.Parent == nil then
			v6 = false
		else
			v6 = parent:GetAttribute("Active") == true
		end

		if not v6 then
			return
		end

		emitAt("EndSlash") -- equivalent call inferred; original call site unknown
		vfxUtility.PlaySound(script.Sound, "PS2windRISINGDUSTSTORMvar1disperse", humanoidRootPart, true)
	elseif p == "SlashAOEDisperse" then
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0.05,
			Frequency = 0.175,
			Amplitude = 1.45,
			SustainTime = 0.1,
			FadeOutTime = 0.65,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(1, 1, 1)
		})
		vfxUtility.PlaySound(script.Sound, "PS2windRISINGDUSTSTORMvar2disperse", humanoidRootPart, true)
		local pS2windRISINGDUSTSTORMvar1and2LOOP = humanoidRootPart:FindFirstChild("PS2windRISINGDUSTSTORMvar1and2LOOP")

		if pS2windRISINGDUSTSTORMvar1and2LOOP and pS2windRISINGDUSTSTORMvar1and2LOOP:IsA("Sound") then
			TweenService:Create(pS2windRISINGDUSTSTORMvar1and2LOOP, TweenInfo.new(0.3), {
				Volume = 0
			}):Play()
			DebrisModule:AddItem(pS2windRISINGDUSTSTORMvar1and2LOOP, 0.35)
		end
	elseif p == "SlashTornadoProjectile" then
		vfxUtility.PlaySound(script.Sound, "PS2windRISINGDUSTSTORMvar1SHOOT", humanoidRootPart, true)
		vfxUtility.PlaySound(script.Sound, "PS2windRISINGDUSTSTORMvar1and2LOOP", humanoidRootPart, false)
		local parent = newStateFolder("SlashTornadoProjectile", Config.V2_SEQUENCE_DURATION + 3)
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position,
			humanoidRootPart.CFrame.upVector * -11,
			RaycastHelper.Crater
		)
		local clone = script.LongRanged.Slash:Clone()
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.Parent = parent
		DebrisModule:AddItem(clone, 3)
		Ouwmit.Emit(
			clone,
			Ouwmit.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
		)
		local playerFromCharacter = Players:GetPlayerFromCharacter(instance)
		local name = playerFromCharacter and playerFromCharacter.Name or instance.Name
		local v3 = p2 or workspace.Debree.Projectiles:WaitForChild((`{name} Rising Dust Storm`))

		if v3 == nil then
			return
		end

		local v4 = p3 or CFrame.identity
		local clone2 = script.LongRanged.Cyclone:Clone()
		clone2:PivotTo(v3.CFrame * v4)
		local root = clone2.Root
		clone2.Parent = parent
		local raycastResult2 = workspace:Raycast(root.Position, createVector(-0, -11, -0), RaycastHelper.Crater)
		Ouwmit.Emit(
			clone2,
			Ouwmit.Owned(instance, raycastResult2 and vfxUtility.GetDustColorSettings(raycastResult2.Instance) or nil)
		)
		local cam_Shaker = Cam_Shaker(v3, {
			FadeInTime = 0.1,
			Frequency = 0.175,
			Amplitude = 0.75,
			SustainTime = Config.V2_SPIN_DURATION,
			FadeOutTime = 0.65,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(1, 1, 1)
		})

		while v3.Parent ~= nil and parent.Parent ~= nil and parent:GetAttribute("Active") and not parent:GetAttribute("Exploded") do
			clone2:PivotTo(v3.CFrame * v4)
			task.wait()
		end

		cam_Shaker:Destroy()

		if parent.Parent ~= nil and parent:GetAttribute("Active") then
			explodeLongRange(parent)
		end
	else
		local child = p == "SlashTornadoDisperse" and debree:FindFirstChild(folderName("SlashTornadoProjectile"))

		if child then
			explodeLongRange(child)
		end
	end
end