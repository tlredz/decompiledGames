local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local sounds = script:WaitForChild("Sounds")
local v = {
	Start = "PS2clanskillsBELLSPLITTERinit",
	Dash = "PS2clanskillsBELLSPLITTERdash",
	Clash = "PS2clanskillsBELLSPLITTERsequence",
	Land = "PS2clanskillsBELLSPLITTERland"
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

local function emitGroup(name: string, cframe: CFrame, list, instance)
	local v2 = groundDust(cframe.Position) -- equivalent call inferred; original call site unknown
	local parent = workspace.Debree

	if #list > 1 then
		parent = Instance.new("Folder")
		parent.Name = name
		parent.Parent = workspace.Debree
		DebrisModule:AddItem(parent, 5)
	end

	for _, v4 in list do
		local clone = v4:Clone()
		clone.Parent = parent
		clone:PivotTo(cframe)
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v2))
		DebrisModule:AddItem(clone, 5)
	end
end

return function(instance, p: string, p2, cframe: CFrame?)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local v2 = cframe or humanoidRootPart.CFrame
	local v3 = v[p]

	if v3 ~= nil then
		if p == "Land" then
			task.delay(0.5, function()
				if humanoidRootPart.Parent ~= nil then
					vfxUtility.PlaySound(sounds, v3, humanoidRootPart, true)
				end
			end)
		else
			vfxUtility.PlaySound(sounds, v3, humanoidRootPart, true)
		end
	end

	if p == "Dash" then
		emitGroup("BellSplitterDash", v2, { script.DashVFX }, instance)
	elseif p == "Clash" then
		emitGroup("BellSplitterClash", v2, { script.ClashVFX, script.ClashEmitVFX }, instance)
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")
	elseif p == "ClashEmit" then
		emitGroup("BellSplitterClashEmit", v2, { script.ClashEmitVFX }, instance)
	elseif p == "Land" then
		emitGroup("BellSplitterLand", v2, { script.LandVFX }, instance)
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")

		for _, v4 in { instance, p2 } do
			local upperTorso

			if v4 ~= nil then
				upperTorso = v4:FindFirstChild("UpperTorso") or nil
			end

			if upperTorso ~= nil then
				Ouwmit.Emit(script.CenterWinds, Ouwmit.Owned(instance, {
					Parent = upperTorso,
					Lifetime = 3
				}))
			end
		end
	end
end