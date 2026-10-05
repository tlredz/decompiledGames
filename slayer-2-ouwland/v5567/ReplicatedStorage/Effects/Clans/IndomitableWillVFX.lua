local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local v = {
	Initial = {
		piece = "Initial",
		phase = "Tap"
	},
	Roar = {
		piece = "Roar",
		phase = "Tap",
		offset = CFrame.new(0, 0, 1.3),
		shake = "Tap",
		dust = true
	},
	HoldCharge = {
		piece = "Charge",
		phase = "Hold",
		rider = "ChargeChar"
	},
	Kick = {
		piece = "Kick",
		phase = "Hold",
		dust = true
	},
	Out = {
		piece = "Out",
		phase = "Hold",
		dust = true
	}
}
local v2 = {
	Tap = {
		FadeInTime = 0,
		Frequency = 0.15,
		Amplitude = 0.45,
		SustainTime = 0.1,
		FadeOutTime = 0.4,
		RotationInfluence = createVector(0.3, 0.3, 0.3),
		PositionInfluence = createVector(1, 1, 1)
	},
	Hold = {
		FadeInTime = 0.1,
		Frequency = 0.12,
		Amplitude = 0.35,
		SustainTime = 1,
		FadeOutTime = 1.2,
		RotationInfluence = createVector(0.2, 0.2, 0.2),
		PositionInfluence = createVector(1, 0.6, 1)
	}
}
local sounds = script:WaitForChild("Sounds")

local function speaker(childName: string, cFrame: CFrame, clone, p: number?)
	local sound = sounds:FindFirstChild(childName)

	if sound == nil or not sound:IsA("Sound") then
		return nil
	end

	local part = Instance.new("Part")
	part.Name = "IndomitableWillSpeaker"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.CFrame = cFrame
	part.Parent = clone or workspace.Debree
	local clone2 = sound:Clone()
	clone2.Parent = part
	clone2:Play()
	DebrisModule:AddItem(part, p or math.max(clone2.TimeLength, 1) + 0.5)
	return clone2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function windup(instance, humanoidRootPart, p: string)
	local upperTorso = instance:FindFirstChild("UpperTorso") or instance:FindFirstChild("Torso") or humanoidRootPart
	vfxUtility.PlaySound(sounds, p, upperTorso, true)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fieldNameFor(p)
	return "IndomitableWillFieldVFX" .. "_" .. p.Name
end

local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)

local function flash(instance)
	local activationVFX = script.Parent:FindFirstChild("ActivationVFX")
	local highlight

	if activationVFX ~= nil then
		highlight = activationVFX:FindFirstChild("Highlight") or nil
	end

	local v3

	if highlight == nil then
		v3 = Instance.new("Highlight")
	else
		v3 = highlight:Clone()
	end

	v3.FillTransparency = -1
	v3.OutlineTransparency = -5
	v3.Adornee = instance
	v3.Parent = instance
	DebrisModule:AddItem(v3, 0.6)
	TweenService:Create(v3, tweenInfo, {
		FillTransparency = 1,
		OutlineTransparency = 1
	}):Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function groundDust(humanoidRootPart)
	local raycastResult = workspace:Raycast(
		humanoidRootPart.Position + createVector(0, 5, 0),
		createVector(-0, -20, -0),
		RaycastHelper.Crater
	)
	return raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
end

local function closeField(instance)
	if instance:GetAttribute("Closing") == true then
		return
	end

	instance:SetAttribute("Closing", true)
	instance.Name ..= "_Closing"
	Ouwmit.Enable(instance, false)
	vfxUtility.EnableAll(instance, false)
	DebrisModule:AddItem(instance, 1.5)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearField(instance)
	local child = workspace.Debree:FindFirstChild(fieldNameFor(instance))

	if child ~= nil then
		closeField(child)
	end
end

local function resolve(childName: string, childName2: string)
	local child = script:FindFirstChild(childName2)
	local child2

	if child ~= nil then
		child2 = child:FindFirstChild(childName) or nil
	end

	if child2 == nil then
		return script:FindFirstChild(childName)
	end

	return child2
end

return function(instance, p: string, value: number?)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	if p == "Cancel" then
		clearField(instance) -- equivalent call inferred; original call site unknown
	elseif p == "Lines" then
		clearField(instance) -- equivalent call inferred; original call site unknown
		local hold = script:FindFirstChild("Hold")
		local lines

		if hold ~= nil then
			lines = hold:FindFirstChild("Lines") or nil
		end

		if lines == nil then
			lines = script:FindFirstChild("Lines")
		end

		if lines == nil then
			return
		end

		local clone = lines:Clone()
		clone.Name = fieldNameFor(instance)
		clone.Parent = workspace.Debree
		clone:PivotTo(humanoidRootPart.CFrame)
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, groundDust(humanoidRootPart)))
		task.delay(value or 10, function()
			if clone.Parent ~= nil then
				closeField(clone)
			end
		end)
		speaker("PS2indominatewillLONGblast", humanoidRootPart.CFrame, clone)
		Cam_Shaker(humanoidRootPart.Position, v2.Hold)
		flash(instance)
	else
		local v3 = v[p]

		if v3 == nil then
			return
		end

		if p == "Roar" then
			flash(instance)
		end

		if p == "Initial" then
			windup(instance, humanoidRootPart, "PS2indominatewillSHORTwindup") -- equivalent call inferred; original call site unknown
		elseif p == "HoldCharge" then
			windup(instance, humanoidRootPart, "PS2indominatewillLONGwindup") -- equivalent call inferred; original call site unknown
		end

		if v3.shake ~= nil then
			Cam_Shaker(humanoidRootPart.Position, v2[v3.shake])
		end

		local cFrame

		if v3.offset == nil then
			cFrame = humanoidRootPart.CFrame
		else
			cFrame = humanoidRootPart.CFrame * v3.offset
		end

		local piece = v3.piece
		local phase = v3.phase
		local child = script:FindFirstChild(phase)
		local child2

		if child ~= nil then
			child2 = child:FindFirstChild(piece) or nil
		end

		if child2 == nil then
			child2 = script:FindFirstChild(piece)
		end

		local clone

		if child2 ~= nil then
			clone = child2:Clone()
			clone.Parent = workspace.Debree
			clone:PivotTo(cFrame)
			local emit = Ouwmit.Emit
			local owned = Ouwmit.Owned
			local v4

			if v3.dust then
				v4 = groundDust(humanoidRootPart)
			end

			emit(clone, owned(instance, v4))
			DebrisModule:AddItem(clone, 3)
		end

		if p == "Roar" then
			speaker("PS2indominatewillSHORTblast", cFrame, clone)
		end

		if v3.rider ~= nil then
			local rider = v3.rider
			local phase2 = v3.phase
			local child3 = script:FindFirstChild(phase2)
			local child4

			if child3 ~= nil then
				child4 = child3:FindFirstChild(rider) or nil
			end

			if child4 == nil then
				child4 = script:FindFirstChild(rider)
			end

			local upperTorso = instance:FindFirstChild("UpperTorso")

			if child4 ~= nil and upperTorso ~= nil then
				local clone2 = child4:Clone()
				clone2.Parent = upperTorso
				Ouwmit.Emit(clone2, Ouwmit.Owned(instance))
				DebrisModule:AddItem(clone2, 3)
			end
		end
	end
end