local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local v = {}
local sounds = script:WaitForChild("Sounds")

local function soundAt(childName: string, cFrame: CFrame, p, p2: number?)
	local sound = sounds:FindFirstChild(childName)

	if sound == nil or not sound:IsA("Sound") then
		return nil
	end

	local part = Instance.new("Part")
	part.Name = "CoreDetachmentSpeaker"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.CFrame = cFrame
	part.Parent = p or workspace.Debree
	local clone = sound:Clone()
	clone.Parent = part
	clone:Play()
	DebrisModule:AddItem(part, p2 or math.max(clone.TimeLength, 1) + 0.5)
	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function template(childName: string)
	return script:FindFirstChild(childName)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function folderFor(name: string, value: number?)
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = workspace.Debree
	DebrisModule:AddItem(folder, (math.max(10, (value or 0) + 3 + 0.3)))
	return folder
end

local function cutCharge(p)
	local v2 = v[p]

	if v2 == nil then
		return
	end

	v[p] = nil

	for _, v3 in v2 do
		if v3.Parent == nil then
			continue
		end

		Ouwmit.Enable(v3, false)
		DebrisModule:AddItem(v3, 3)
	end
end

local function onCharge(instance, upperTorso)
	cutCharge(instance)
	local clones = {}
	v[instance] = clones
	local v2 = template("Trail") -- equivalent call inferred; original call site unknown

	if v2 ~= nil then
		local clone = v2:Clone()
		clone.Parent = workspace.Debree
		clone:PivotTo(upperTorso.CFrame)
		Ouwmit.Emit(clone, Ouwmit.Owned(instance))
		DebrisModule:AddItem(clone, 3)
	end

	local v3 = template("Essence") -- equivalent call inferred; original call site unknown

	if v3 ~= nil then
		local clone = v3:Clone()
		clone.Parent = upperTorso
		Ouwmit.Enable(clone, true, Ouwmit.Owned(instance))
		table.insert(clones, clone)
	end
end

local function onThrow(instance, upperTorso, cframe: CFrame, value: number?, p: number?)
	local v2 = value or 0.4
	local v3 = p == nil and 2.7 or math.max(p - 0.3, 0)
	cutCharge(instance)
	local parent = folderFor("CoreDetachmentThrow", v3) -- equivalent call inferred; original call site unknown
	local position = upperTorso.Position
	local v5 = template("Transition") -- equivalent call inferred; original call site unknown

	if v5 ~= nil then
		local clone = v5:Clone()
		clone.Parent = upperTorso
		Ouwmit.Emit(clone, Ouwmit.Owned(instance))
		DebrisModule:AddItem(clone, 3)

		if clone:IsA("Attachment") then
			position = clone.WorldPosition
		end
	end

	local v6 = template("Effects") -- equivalent call inferred; original call site unknown

	if v6 == nil then
		return
	end

	local clone = v6:Clone()
	clone.Parent = parent
	clone:PivotTo(CFrame.new(position))
	Ouwmit.Enable(clone, true, Ouwmit.Owned(instance))
	vfxUtility.PlaySound(sounds, "PS2coredetachmentSHOOT", clone, true)
	Cam_Shaker(position, "tinyshake_less_aggresive_preset")
	TweenService:Create(clone, TweenInfo.new(v2), {
		Position = cframe.Position
	}):Play()
	task.delay(v2, function()
		if clone.Parent == nil then
			return
		end

		Ouwmit.Enable(clone, false)
		DebrisModule:AddItem(clone, 3)
		local v7 = template("Impact") -- equivalent call inferred; original call site unknown

		if v7 ~= nil then
			local clone2 = v7:Clone()
			clone2.Parent = parent
			clone2:PivotTo(cframe)
			Ouwmit.Emit(clone2, Ouwmit.Owned(instance))
			DebrisModule:AddItem(clone2, 3)
		end

		soundAt("PS2coredetachmentIMPACT", cframe)
		local v8 = soundAt("PS2coredetachmentLOOP", cframe, parent, v3 + 0.3)
		Cam_Shaker(cframe.Position, "activate_shake")
		local v9 = template("Eye") -- equivalent call inferred; original call site unknown

		if v9 == nil then
			return
		end

		local clone2 = v9:Clone()
		clone2.Parent = parent
		clone2:PivotTo(cframe)
		Ouwmit.Enable(clone2, true, Ouwmit.Owned(instance))
		local top = clone2:FindFirstChild("Top")
		local v10

		if top == nil then
			v10 = nil
		else
			v10 = top:FindFirstChild("Eyes") or nil
		end

		if v10 ~= nil then
			task.delay(v3, function()
				if v10.Parent == nil then
					return
				end

				Ouwmit.Enable(v10, false)
			end)
		end

		task.delay(v3, function()
			if v8 ~= nil then
				v8:Stop()
			end

			soundAt("PS2coredetachmentFADEAWAY", cframe)
		end)
		task.delay(v3 + 0.3, function()
			if clone2.Parent == nil then
				return
			end

			Ouwmit.Enable(clone2, false)
			DebrisModule:AddItem(clone2, 3)
		end)
	end)
end

return function(instance, p: string, cframe: CFrame?, p2: number?, p3: number?)
	if instance == nil then
		return
	end

	local upperTorso = instance:FindFirstChild("UpperTorso") or instance:FindFirstChild("Torso")

	if upperTorso == nil then
		return
	end

	if p == "Charge" then
		onCharge(instance, upperTorso)
	elseif p == "Throw" then
		if cframe == nil then
			return
		end

		onThrow(instance, upperTorso, cframe, p2, p3)
	elseif p == "Cancel" then
		cutCharge(instance)
	end
end