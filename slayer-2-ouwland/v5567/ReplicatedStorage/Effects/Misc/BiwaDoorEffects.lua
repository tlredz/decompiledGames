local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local MuzanSettings = require(ReplicatedStorage.CAM.Global.MuzanSettings)
local cframe = CFrame.new(0, -2.835, 0, 1, 0, 3.25059773e-30, 0, 1, 0, 3.25059773e-30, 0, 1)

-- equivalent calls inferred from this helper; original call sites unknown
local function playSound(instance, humanoidRootPart, duration: number?)
	if instance == nil then
		return
	end

	local clone = instance:Clone()
	clone.Parent = humanoidRootPart

	if duration == nil or not (duration > 0) then
		clone:Play()
	else
		task.delay(duration, function()
			if clone.Parent ~= nil then
				clone:Play()
			end
		end)
	end

	DebrisModule:AddItem(clone, (duration or 0) + clone.TimeLength + 1)
end

local tweenInfo = TweenInfo.new(0.3)

local function groundColorAt(vector2: Vector3)
	local raycastResult = workspace:Raycast(
		vector2 + createVector(0, 5, 0),
		createVector(0, -25, 0),
		RaycastHelper.Crater
	)

	if raycastResult == nil then
		return nil
	end

	if raycastResult.Instance:IsA("Terrain") then
		return (workspace.Terrain:GetMaterialColor(raycastResult.Material))
	end

	return raycastResult.Instance.Color
end

-- equivalent calls inferred from this helper; original call sites unknown
local function groundColorFor(character, position: Vector3)
	local playerFromCharacter = Players:GetPlayerFromCharacter(character)

	if playerFromCharacter ~= nil and playerFromCharacter:GetAttribute(MuzanSettings.LairAttribute) == true then
		return nil
	end

	local raycastResult = workspace:Raycast(
		position + createVector(0, 5, 0),
		createVector(0, -25, 0),
		RaycastHelper.Crater
	)

	if raycastResult == nil then
		return nil
	end

	if raycastResult.Instance:IsA("Terrain") then
		return (workspace.Terrain:GetMaterialColor(raycastResult.Material))
	end

	return raycastResult.Instance.Color
end

local function emitGrounded(folder, color: Color3?, instance)
	if color ~= nil then
		for _, emitter in ipairs(folder:GetDescendants()) do
			if not (emitter:IsA("ParticleEmitter") and emitter.Name ~= "ScreenEffect1" and emitter:FindFirstAncestor("ScreenEffect1") == nil) then
				continue
			end

			emitter.Color = ColorSequence.new(color)
		end
	end

	Ouwmit.Emit(folder, {
		Owner = instance
	})
end

return function(instance, p)
	if instance == nil or p == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local cFrame = humanoidRootPart.CFrame

	if p == "Ring" then
		local clone = script.Sounds.PS2biwaBELL:Clone()
		clone.Parent = humanoidRootPart
		clone:Play()
		DebrisModule:AddItem(clone, clone.TimeLength)
	elseif p == "JumpIn" then
		local folder = Instance.new("Folder", workspace.Debree)
		DebrisModule:AddItem(folder, 3)
		local clone = script.Door:Clone()
		clone:PivotTo(cFrame * cframe)
		clone.Parent = folder
		DebrisModule:AddItem(clone, 2.0166666666666666)
		clone.AnimationController.Animator:LoadAnimation(script.Animations.DoorOpen):Play()

		for _, part in ipairs(clone:GetDescendants()) do
			if not (part:IsA("BasePart") and part.Transparency ~= 1) then
				continue
			end

			part.Transparency = 1
			TweenService:Create(part, tweenInfo, {
				Transparency = 0
			}):Play()
		end

		playSound(script.Sounds.Open.PS2biwaSPAWN, humanoidRootPart) -- equivalent call inferred; original call site unknown
		local pS2biwaOPEN = script.Sounds.Open.PS2biwaOPEN

		if pS2biwaOPEN ~= nil then
			local clone2 = pS2biwaOPEN:Clone()
			clone2.Parent = humanoidRootPart
			task.delay(0.1, function()
				if clone2.Parent ~= nil then
					clone2:Play()
				end
			end)
			DebrisModule:AddItem(clone2, 0.1 + clone2.TimeLength + 1)
		end

		local pS2biwaFALL = script.Sounds.Open.PS2biwaFALL

		if pS2biwaFALL ~= nil then
			local clone2 = pS2biwaFALL:Clone()
			clone2.Parent = humanoidRootPart
			task.delay(0.35, function()
				if clone2.Parent ~= nil then
					clone2:Play()
				end
			end)
			DebrisModule:AddItem(clone2, 0.35 + clone2.TimeLength + 1)
		end

		local pS2biwaCLOSE = script.Sounds.Open.PS2biwaCLOSE

		if pS2biwaCLOSE ~= nil then
			local clone2 = pS2biwaCLOSE:Clone()
			clone2.Parent = humanoidRootPart
			task.delay(2.0166666666666666, function()
				if clone2.Parent ~= nil then
					clone2:Play()
				end
			end)
			DebrisModule:AddItem(clone2, 2.0166666666666666 + clone2.TimeLength + 1)
		end

		local clone2 = script.Fall:Clone()
		clone2.Parent = folder
		clone2:PivotTo(cFrame)
		local v = groundColorFor(instance, cFrame.Position) -- equivalent call inferred; original call site unknown
		emitGrounded(clone2, v, instance)
		task.wait(0.35)
		local clone3 = script.Fall1:Clone()
		clone3.Parent = folder
		clone3:PivotTo(cFrame)
		emitGrounded(clone3, v, instance)
		local clone4 = script.SkillVFX:Clone()
		clone4.Parent = folder
		clone4:PivotTo(cFrame)
		emitGrounded(clone4, v, instance)
		task.wait(2.0166666666666666)

		if clone2:FindFirstChild("ScreenEffect1") then
			clone2.ScreenEffect1:Destroy()
		end

		Ouwmit.Emit(clone2, {
			Owner = instance
		})
	elseif p == "JumpOut" then
		local folder = Instance.new("Folder", workspace.Debree)
		DebrisModule:AddItem(folder, 3)
		local clone = script.Door:Clone()
		clone:PivotTo(cFrame * cframe)
		clone.Parent = folder
		DebrisModule:AddItem(clone, 2.0166666666666666)
		clone.AnimationController.Animator:LoadAnimation(script.Animations.DoorClose):Play()
		playSound(script.Sounds.Close.PS2biwaSPAWN2, humanoidRootPart) -- equivalent call inferred; original call site unknown
		local pS2biwaPLAYERSPAWN = script.Sounds.Close.PS2biwaPLAYERSPAWN

		if pS2biwaPLAYERSPAWN ~= nil then
			local clone2 = pS2biwaPLAYERSPAWN:Clone()
			clone2.Parent = humanoidRootPart
			task.delay(0.1, function()
				if clone2.Parent ~= nil then
					clone2:Play()
				end
			end)
			DebrisModule:AddItem(clone2, 0.1 + clone2.TimeLength + 1)
		end

		local pS2biwaCLOSE = script.Sounds.Open.PS2biwaCLOSE

		if pS2biwaCLOSE ~= nil then
			local clone2 = pS2biwaCLOSE:Clone()
			clone2.Parent = humanoidRootPart
			task.delay(2.0166666666666666, function()
				if clone2.Parent ~= nil then
					clone2:Play()
				end
			end)
			DebrisModule:AddItem(clone2, 2.0166666666666666 + clone2.TimeLength + 1)
		end

		local v = groundColorFor(instance, cFrame.Position) -- equivalent call inferred; original call site unknown
		local clone2 = script.PopoutVFX:Clone()
		clone2:PivotTo(cFrame)
		clone2.Parent = folder
		emitGrounded(clone2, v, instance)
		task.wait(2.0166666666666666)
		local clone3 = script.Fall1:Clone()
		clone3.Parent = folder
		clone3:PivotTo(cFrame)
		emitGrounded(clone3, v, instance)
	end
end