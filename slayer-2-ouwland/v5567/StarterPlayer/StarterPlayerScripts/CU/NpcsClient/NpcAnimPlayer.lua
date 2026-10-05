task.wait()

function Tick()
	return workspace:GetServerTimeNow()
end

local Character_info_provider = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Character_info_provider"))
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local RaycastHelper = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("RaycastHelper"))
local gameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))
local CollectionService = game:GetService("CollectionService")
local npcAnimDistanceGating = gameSettings.NpcAnimDistanceGating
local v

if npcAnimDistanceGating == 2 then
	v = false
else
	v = npcAnimDistanceGating ~= false
end

if typeof(npcAnimDistanceGating) ~= "number" or npcAnimDistanceGating == 1 or npcAnimDistanceGating == 2 then
	npcAnimDistanceGating = nil
end

local currentCamera = workspace.CurrentCamera
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	currentCamera = workspace.CurrentCamera
end)
local v2 = {}
local v3 = {
	{},
	{},
	{}
}
local random = Random.new()
local v4 = {}
local v5 = npcAnimDistanceGating == nil and { nil, 0.5, 1.5 } or { 1, 1.5, 2 }
local fn
local fn2

-- equivalent calls inferred from this helper; original call sites unknown
local function bandInsert(p, p2, band)
	v3[band][p] = p2
	p2.Band = band

	if v4[band] == nil then
		fn(band)
	end
end

local v6 = {
	Default = 2,
	idle = 1
}
local v7 = { "flee1", "flee2" }
local v8 = { "flee", "fleedamaged", "cower" }

function ClearCivilian(state)
	if state.CivilianAnim then
		state.CivilianAnim:Stop(0.3)
		state.CivilianAnim = nil
	end

	if state.CivilianDisconnect then
		state.CivilianDisconnect:Disconnect()
		state.CivilianDisconnect = nil
	end

	state.CivilianVariant = nil
	state.CivilianAnimItem = nil
end

function UnloadTracks(state)
	if state.Anim then
		state.Anim:Stop(0.3)
		state.Anim = nil
	end

	state.CurrentInstance = nil

	if state.CivilianAnim then
		state.CivilianAnim:Stop(0.3)
		state.CivilianAnim = nil
	end

	state.CivilianAnimItem = nil
end

function Clear(p)
	if v2[p] then
		ClearCivilian(v2[p])

		if v2[p].Anim then
			v2[p].Anim:Stop()
			v2[p].Anim = nil
		end

		if v2[p].Disconnect then
			v2[p].Disconnect:Disconnect()
			v2[p].Disconnect = nil
		end

		if v2[p].AggroDisconnect then
			v2[p].AggroDisconnect:Disconnect()
			v2[p].AggroDisconnect = nil
		end

		local v9 = v3[v2[p].Band]

		if v9 ~= nil then
			v9[p] = nil
		end

		v2[p] = nil
	end
end

function Handle(p)
	local parent = p.Parent

	if parent == nil then
		return
	end

	parent:WaitForChild("ClientAnimatorServer", 5)
	local humanoid = parent:FindFirstChild("Humanoid") or parent:WaitForChild("Humanoid", 8)

	if humanoid ~= nil then
		humanoid:WaitForChild("Animator", 5)
	end

	Clear(p)

	if parent == nil or parent:FindFirstChild("ClientAnimatorServer") == nil then
		return
	end

	local clientAnimatorServer = parent.ClientAnimatorServer
	local currentAnim = clientAnimatorServer.CurrentAnim
	local v9 = {
		Parent = parent,
		Root = parent:FindFirstChild("HumanoidRootPart") or p,
		Active = false,
		Band = 1,
		CurrentInstance = nil
	}
	v2[p] = v9

	if v then
		bandInsert(p, v9, 1) -- equivalent call inferred; original call site unknown

		if npcAnimDistanceGating == nil then
			v9.AggroDisconnect = parent:GetAttributeChangedSignal("Aggroed"):Connect(function()
				if not (v2[p] == v9 and parent:GetAttribute("Aggroed") == true) then
					return
				end

				if v9.Band ~= 1 then
					v3[v9.Band][p] = nil
					bandInsert(p, v9, 1) -- equivalent call inferred; original call site unknown
				end

				fn2(v9, true)
			end)
		end
	end

	local anims = clientAnimatorServer:FindFirstChild("Anims")

	local function updAnim()
		if p == nil or p.Parent == nil or (v2[p] == nil or v2[p].Active ~= true) then
			return
		end

		local child = anims ~= nil and anims:FindFirstChild(currentAnim.Value) or nil

		if child == nil or child:GetAttribute("Custom") ~= true or not child then
			child = Character_info_provider.get_core_anim(parent, currentAnim.Value, true) or child
		end

		if child == nil then
			return
		end

		if v9.CurrentInstance ~= child then
			if v9.Anim then
				v9.Anim:Stop(0.3)
				v9.Anim = nil
			end

			if parent.Parent == workspace.Debree then
				return
			end

			local humanoid2 = parent:FindFirstChild("Humanoid")
			local animator

			if humanoid2 ~= nil then
				animator = humanoid2:FindFirstChildOfClass("Animator") or nil
			end

			if animator == nil or (p.Parent == nil or v2[p] == nil or v9.Active ~= true) then
				return
			end

			v9.Anim = animator:LoadAnimation(child)
			local length = 999

			if v9.Anim.Length > 0 then
				length = v9.Anim.Length or length
			end

			local v10 = math.min((Tick() - clientAnimatorServer.LastSwap.Value) % v9.Anim.Length, length - 0.01)
			local timePosition = v10 ~= v10 and 0 or v10
			v9.Anim:Play(0.3)
			v9.Anim.TimePosition = timePosition
			local v12 = v6[currentAnim.Value] or 2
			v9.Anim:AdjustWeight(v12)
			v9.CurrentInstance = child
		end
	end

	v9.UpdAnim = updAnim
	v9.Disconnect = currentAnim.Changed:Connect(updAnim)

	local function updCivilian()
		if v2[p] == nil or v9.Active ~= true then
			return
		end

		local civilianState = parent:GetAttribute("CivilianState")

		if civilianState == nil or civilianState == 0 then
			if v9.CivilianAnim then
				v9.CivilianAnim:Stop(0.3)
				v9.CivilianAnim = nil
			end

			v9.CivilianVariant = nil
			v9.CivilianAnimItem = nil
		else
			local civilianVariant = v8[civilianState]

			if civilianVariant == nil then
				return
			end

			if civilianVariant == "flee" then
				if v9.CivilianVariant == nil then
					v9.CivilianVariant = v7[math.random(1, #v7)]
				end

				civilianVariant = v9.CivilianVariant
			else
				v9.CivilianVariant = nil
			end

			local get_core_anim = Character_info_provider.get_core_anim(parent, civilianVariant, true)

			if not (get_core_anim ~= nil and v9.CivilianAnimItem ~= get_core_anim) then
				return
			end

			local humanoid2 = parent:FindFirstChild("Humanoid")
			local animator

			if humanoid2 ~= nil then
				animator = humanoid2:FindFirstChildOfClass("Animator") or nil
			end

			if animator == nil or (p.Parent == nil or v2[p] == nil or v9.Active ~= true) then
				return
			end

			if v9.CivilianAnim then
				v9.CivilianAnim:Stop(0.3)
			end

			v9.CivilianAnimItem = get_core_anim
			v9.CivilianAnim = animator:LoadAnimation(get_core_anim)
			v9.CivilianAnim:Play(0.3)
		end
	end

	v9.UpdCivilian = updCivilian
	v9.CivilianDisconnect = parent:GetAttributeChangedSignal("CivilianState"):Connect(updCivilian)

	if not v then
		v9.Active = true
		updAnim()
		updCivilian()
	end
end

fn2 = function(state, active)
	if active ~= state.Active then
		state.Active = active

		if active then
			if state.UpdAnim then
				state.UpdAnim()
			end

			if state.UpdCivilian then
				state.UpdCivilian()
			end
		else
			UnloadTracks(state)
		end
	end
end

local function processRig(k, data, position, lookVector)
	local parent = data.Parent

	if parent == nil or parent.Parent == nil then
		return
	end

	local root = data.Root

	if root == nil or root.Parent == nil then
		return
	end

	if npcAnimDistanceGating == nil and parent:GetAttribute("Aggroed") == true then
		if data.Band ~= 1 then
			v3[data.Band][k] = nil
			bandInsert(k, data, 1) -- equivalent call inferred; original call site unknown
		end

		fn2(data, true)
	else
		local vector = root.Position - position
		local v9

		if npcAnimDistanceGating == nil then
			local playAnimDistance = parent:GetAttribute("PlayAnimDistance")

			if playAnimDistance == nil and Utility.IsMeshRig(parent) then
				playAnimDistance = false
			end

			v9 = playAnimDistance == false and 1e999 or typeof(playAnimDistance) ~= "number" and 200 or playAnimDistance
		else
			v9 = npcAnimDistanceGating
		end

		local magnitude = vector.Magnitude
		local band = magnitude <= v9 + (npcAnimDistanceGating == nil and 75 or 0) and 1 or magnitude <= v9 + 200 and 2 or 3

		if band ~= data.Band then
			v3[data.Band][k] = nil
			bandInsert(k, data, band) -- equivalent call inferred; original call site unknown
		end

		local v11 = false

		if band == 1 then
			if npcAnimDistanceGating == nil and not (magnitude <= 25) then
				if magnitude > 0 then
					local v12 = vector:Dot(lookVector) / magnitude

					if (magnitude <= v9 or v12 >= 0.95) and v12 > 0 then
						v11 = workspace:Raycast(position, vector, RaycastHelper.Map) == nil
					end
				end
			else
				v11 = true
			end
		end

		fn2(data, v11)
	end
end

fn = function(band)
	local number = random:NextNumber()
	v4[band] = number
	local v9 = v5[band]
	task.spawn(function()
		while v4[band] == number do
			if v9 == nil then
				task.wait()
			else
				task.wait(v9)
			end

			if v4[band] ~= number then
				break
			end

			if next(v3[band]) == nil then
				v4[band] = nil
				break
			end

			local v10 = currentCamera

			if v10 == nil then
				continue
			end

			local cFrame = v10.CFrame
			local position = cFrame.Position
			local lookVector = cFrame.LookVector

			for k, v11 in pairs(v3[band]) do
				processRig(k, v11, position, lookVector)
			end
		end
	end)
end

for _, v9 in pairs(CollectionService:GetTagged("ClientAnimTagForNpc")) do
	task.spawn(Handle, v9)
end

CollectionService:GetInstanceAddedSignal("ClientAnimTagForNpc"):Connect(Handle)
CollectionService:GetInstanceRemovedSignal("ClientAnimTagForNpc"):Connect(Clear)