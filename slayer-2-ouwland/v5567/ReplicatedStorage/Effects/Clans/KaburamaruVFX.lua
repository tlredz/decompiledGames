local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local sounds = script:WaitForChild("Sounds")
local v = {
	Fire = {
		piece = "Shoot",
		onTarget = false,
		dust = true,
		shake = "tinyshake_less_aggresive_preset",
		sound = "PS2kaburamaruSHOOT"
	},
	Captured = {
		piece = "Impact",
		onTarget = true,
		dust = true,
		shake = "activate_shake",
		sound = "PS2kaburamaruIMPACT"
	},
	Bite = {
		piece = "Snake",
		onTarget = true,
		onHead = true,
		sound = "PS2kaburamaruBITE"
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function groundDust(position: Vector3)
	local raycastResult = workspace:Raycast(
		position + createVector(0, 5, 0),
		createVector(-0, -20, -0),
		RaycastHelper.Crater
	)
	return raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
end

return function(p, p2: string, instance)
	if p == nil or p2 == nil then
		return
	end

	local v2 = v[p2]

	if v2 == nil then
		return
	end

	local child = script:FindFirstChild(v2.piece)

	if child == nil then
		return
	end

	if not v2.onTarget then
		instance = p
	end

	local humanoidRootPart

	if instance ~= nil then
		humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or nil
	end

	if humanoidRootPart == nil then
		return
	end

	local clone = child:Clone()

	if v2.onHead then
		local head = instance:FindFirstChild("Head")

		if head == nil then
			return
		else
			clone.Parent = head
		end
	else
		clone.Parent = workspace.Debree
		clone:PivotTo(humanoidRootPart.CFrame)
	end

	local emit = Ouwmit.Emit
	local owned = Ouwmit.Owned
	local v3

	if v2.dust then
		v3 = groundDust(humanoidRootPart.Position)
	end

	emit(clone, owned(p, v3))

	if v2.shake ~= nil then
		Cam_Shaker(humanoidRootPart.Position, v2.shake)
	end

	if v2.sound ~= nil then
		vfxUtility.PlaySound(sounds, v2.sound, humanoidRootPart, true)
	end

	DebrisModule:AddItem(clone, 2)
end