local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local sounds = script:WaitForChild("Sounds")
local v = { "PS2demonslayersummonSUMMON1", "PS2demonslayersummonSUMMON2" }

local function emitAt(instance, parent, cframe: CFrame, p: number, p2, p3)
	local clone = instance:Clone()
	clone.Parent = parent
	clone:PivotTo(cframe)
	Ouwmit.Emit(clone, Ouwmit.Owned(p2, p3))
	DebrisModule:AddItem(clone, p)
	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function groundDust(position: Vector3)
	local raycastResult = workspace:Raycast(
		position + createVector(0, 5, 0),
		createVector(-0, -20, -0),
		RaycastHelper.Crater
	)
	return raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function newFolder(name: string, p: number)
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = workspace.Debree
	DebrisModule:AddItem(folder, p)
	return folder
end

local v2 = {
	"WhistleWind",
	"WhistleFace",
	"Spawn",
	"HitGround"
}
local v3 = false

local function piece(childName: string)
	local child = script:FindFirstChild(childName)

	if child ~= nil or v3 then
		return child
	end

	v3 = true
	local childNames = {}

	for _, childName2 in v2 do
		if script:FindFirstChild(childName2) == nil then
			table.insert(childNames, childName2)
		end
	end

	warn((`[DemonSlayerSummonVFX] missing template children under {script:GetFullName()}: {table.concat(childNames, ", ")}`))
	return child
end

return function(instance, p: string, instance2)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	if p == "Whistle" then
		local v4 = piece("WhistleWind")
		local v5 = piece("WhistleFace")

		if v4 ~= nil then
			local debree = workspace.Debree
			local cFrame = humanoidRootPart.CFrame
			local clone = v4:Clone()
			clone.Parent = debree
			clone:PivotTo(cFrame)
			Ouwmit.Emit(clone, Ouwmit.Owned(instance, nil))
			DebrisModule:AddItem(clone, 5)
		end

		vfxUtility.PlaySound(sounds, "PS2demonslayersummonWHISTLE", humanoidRootPart, true)
		Cam_Shaker(humanoidRootPart.Position, "tinyshake_less_aggresive_preset")
		local head = instance:FindFirstChild("Head")

		if v5 ~= nil and head ~= nil then
			local clone = v5:Clone()
			clone.Parent = head
			Ouwmit.Emit(clone, Ouwmit.Owned(instance))
			DebrisModule:AddItem(clone, 3)
		end
	else
		if not (p == "Arrive" and instance2 ~= nil) then
			return
		end

		local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")
		local upperTorso = instance2:FindFirstChild("UpperTorso") or humanoidRootPart2

		if humanoidRootPart2 == nil or upperTorso == nil then
			return
		end

		local parent = newFolder("DemonSlayerSummonArrival", 5) -- equivalent call inferred; original call site unknown
		local v5 = groundDust(humanoidRootPart2.Position) -- equivalent call inferred; original call site unknown
		vfxUtility.PlaySound(sounds, v[math.random(1, #v)], humanoidRootPart2, true)
		local v6 = piece("Spawn")

		if v6 ~= nil then
			task.delay(0.05, function()
				if instance2.Parent == nil or parent.Parent == nil then
					return
				end

				local cFrame = upperTorso.CFrame
				local clone = v6:Clone()
				clone.Parent = parent
				clone:PivotTo(cFrame)
				Ouwmit.Emit(clone, Ouwmit.Owned(instance, nil))
				DebrisModule:AddItem(clone, 5)
			end)
		end

		local v7 = piece("HitGround")

		if v7 ~= nil then
			task.delay(0.2, function()
				if instance2.Parent == nil or parent.Parent == nil then
					return
				end

				local cFrame = humanoidRootPart2.CFrame
				local clone = v7:Clone()
				clone.Parent = parent
				clone:PivotTo(cFrame)
				Ouwmit.Emit(clone, Ouwmit.Owned(instance, v5))
				DebrisModule:AddItem(clone, 5)
				Cam_Shaker(humanoidRootPart2.Position, "medium_shake_preset")
			end)
		end
	end
end