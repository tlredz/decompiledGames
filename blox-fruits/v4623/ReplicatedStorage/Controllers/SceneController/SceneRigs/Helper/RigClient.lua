local TestRigUtil = require(game.ReplicatedStorage.Modules.Rig.TestRigUtil)
local SceneControllerUtil = require(game.ReplicatedStorage.Controllers.SceneController.SceneControllerUtil)
local v = nil
local v2 = {
	[Enum.KeyCode.Z] = "Z",
	[Enum.KeyCode.X] = "X",
	[Enum.KeyCode.C] = "C",
	[Enum.KeyCode.V] = "V",
	[Enum.KeyCode.F] = "F"
}
local v3 = {}
local v4 = {}
local v5 = 0

local function tryGetRemote()
	local Players = game:GetService("Players")
	local _RigNetwork = Players.LocalPlayer:FindFirstChild("_RigNetwork")

	if _RigNetwork then
		return _RigNetwork, true
	end

	return {
		FireServer = function() end
	}, false
end

local function sendPos(vector: Vector3)
	if next(v4) == nil then
		return
	end

	local now = os.clock()

	if now - v5 < 0.1 then
		return
	end

	v5 = now
	tryGetRemote():FireServer("aim", vector)
end

local function releaseAll()
	for k in v4 do
		tryGetRemote():FireServer("castEnd", k)
	end

	table.clear(v4)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disconnectAll()
	for _, connection in v3 do
		connection:Disconnect()
	end

	table.clear(v3)
end

return function(p)
	if v then
		v.Destroy()
	end

	local function fn(p2: string, vector: Vector3?)
		local position = nil

		if vector then
			position = vector
		else
			local tryFindCommandRig = TestRigUtil.tryFindCommandRig
			local Players = game:GetService("Players")
			local v6 = tryFindCommandRig(Players.LocalPlayer)

			if v6 then
				local facingCameraCF = SceneControllerUtil.getFacingCameraCF(v6:GetPivot())
				position = facingCameraCF.Position + facingCameraCF.LookVector * 1000
			end
		end

		if position == nil then
			warn("rig not found and position not provided - using camera cf")
			position = workspace.CurrentCamera.CFrame.Position
		end

		if typeof(position) == "CFrame" then
			position = position.Position
		end

		local v6, v7 = tryGetRemote()

		if not v7 then
			print((`remote doesn't exist for {p2}`))
			return
		end

		releaseAll()
		v4[p2] = true
		v6:FireServer("castBegin", p2, position)
	end

	local v6 = {}

	for _, v7 in pairs(v2) do
		if not (p and p.BlacklistedSkills and p.BlacklistedSkills[v7]) then
			v6[v7] = true
		end
	end

	if p == nil or not (p.BlacklistedSkills and p.BlacklistedSkills.TAP) then
		v6.TAP = true
	end

	local v7 = {
		SendPos = sendPos,
		Rage = function()
			tryGetRemote():FireServer("rage")
		end,
		SkillDown = function(p2, p3)
			assert(v6[p2])
			fn(p2, p3)
		end,
		SkillUp = function(p2)
			if p2 and v4[p2] then
				local v8, v9 = tryGetRemote()

				if v9 then
					v4[p2] = nil
					v8:FireServer("castEnd", p2)
				end
			elseif p2 then
				print((`not holding key: {p2}`))
			elseif p2 == nil then
				releaseAll()
			end
		end,
		Destroy = function()
			v = nil
			disconnectAll() -- equivalent call inferred; original call site unknown
			releaseAll()
		end,
		GetHeldSkills = function()
			return v4
		end
	}
	v = v7
	return v7
end