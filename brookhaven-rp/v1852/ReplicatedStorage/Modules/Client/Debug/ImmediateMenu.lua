local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GlobalReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.GlobalReplicatedDataController)
local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
local Iris = require(ReplicatedStorage.Packages.Iris)
local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
local HouseUtil = require(ReplicatedStorage.Modules.Shared.Game.HouseUtil)
local LiveOpsUtil = require(ReplicatedStorage.Modules.Shared.LiveOps.LiveOpsUtil)
local Permissions = require(ReplicatedStorage.Modules.Shared.Permissions)
local CountableDevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.CountableDevProducts)
local DevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.DevProducts)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = false
local number = nil
local textHint = nil
local number2 = nil

local function teleportToFirstLotOfType(p)
	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local upperTorso = character:FindFirstChild("UpperTorso")

	if not upperTorso then
		return
	end

	local allLots = LotUtil.GetAllLots()
	local _001_MapHouseTeleports = workspace:FindFirstChild("WorkspaceCom") and workspace.WorkspaceCom:FindFirstChild("001_MapHouseTeleports")

	if not _001_MapHouseTeleports then
		return
	end

	for k, _ in allLots do
		if HouseUtil.GetHouseType(k) ~= p then
			continue
		end

		local child = _001_MapHouseTeleports:FindFirstChild("House" .. k)

		if not child then
			continue
		end

		local angle = child:FindFirstChild("Angle")
		local v5 = not angle and 0 or angle.Value
		upperTorso.CFrame = CFrame.new(child.Position + createVector(0, 4, 0)) * CFrame.Angles(0, v5, 0)
		v = false
		break
	end
end

local function drawCharacterTree()
	Iris.Tree({ "Character" })
	Iris.SliderNum({
		"Walk Speed",
		1,
		0,
		200
	}, {
		number = number
	})
	local clicked = Iris.Button({ "Reset" }).clicked()

	if clicked then
		number:set(16)
	end

	local walkSpeed = number:get()
	local character = Players.LocalPlayer.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChild("Humanoid")
	end

	if humanoid and (clicked or walkSpeed ~= 16 and humanoid.WalkSpeed ~= walkSpeed) then
		humanoid.WalkSpeed = walkSpeed
	end

	Iris.End()
end

local function drawPropertiesTree()
	Iris.Tree({ "Properties" })

	if Iris.Button({ "Teleport to house" }).clicked() then
		teleportToFirstLotOfType("House")
	end

	if Iris.Button({ "Teleport to estate" }).clicked() then
		teleportToFirstLotOfType("Mansion")
	end

	if Iris.Button({ "Teleport to apartment" }).clicked() then
		teleportToFirstLotOfType("Apartment")
	end

	if Iris.Button({ "Teleport to motel" }).clicked() then
		teleportToFirstLotOfType("Motel")
	end

	if Iris.Button({ "Teleport to landmark" }).clicked() then
		teleportToFirstLotOfType("Landmark")
	end

	Iris.End()
end

local function drawGamepassesTree()
	Iris.Tree({ "Gamepasses and dev products" })

	if Iris.Button({ "Grant all" }).clicked() then
		Remotes.fireServer("IM_GamepassAll")
	end

	if Iris.Button({ "Clear all" }).clicked() then
		Remotes.fireServer("IM_GamepassClear")
	end

	Iris.Tree({ "Current" })
	local replicatedData = GlobalReplicatedDataController.GetReplicatedData(Players.LocalPlayer.UserId)

	if replicatedData == nil then
		Iris.Text({ "Loading.." })
	else
		for k, _ in replicatedData.profile.gamepasses do
			local v5 = tonumber(k)

			if v5 then
				Iris.Text({ Gamepasses.GetName(Gamepasses.GetById(v5)) })
			end
		end

		for k, _ in replicatedData.profile.devProducts do
			local v5 = tonumber(k)

			if v5 then
				Iris.Text({ DevProducts.GetName(DevProducts.GetById(v5)) })
			end
		end
	end

	Iris.End()
	Iris.End()
end

local v5 = {}

local function drawCountableDevProductsTree()
	Iris.Tree({ "Countable dev products" })
	local clientReplica = ReplicatedDataController.clientReplica
	local v6 = (clientReplica == nil or clientReplica.Data == nil or clientReplica.Data.countableDevProducts == nil) and {} or clientReplica.Data.countableDevProducts
	local v7 = {}

	for k in CountableDevProducts.All do
		table.insert(v7, k)
	end

	table.sort(v7)

	for _, v8 in v7 do
		local v9 = CountableDevProducts.All[v8]
		local id = CountableDevProducts.GetId(v9)
		local max = CountableDevProducts.GetMax(v9)
		local v10 = v6[tostring(id)] or 0

		if v5[id] == nil then
			v5[id] = Iris.State(v10)
		end

		local number3 = v5[id]
		local v12 = (max == nil or not max) and 1000 or max
		local v13 = max == nil and "∞" or tostring(max) or "∞"
		Iris.SameLine()
		Iris.Text({ string.format("%s (%d/%s)", v8, v10, v13) })

		if max ~= nil and Iris.Button({ "Max" }).clicked() then
			number3:set(max)
			Remotes.fireServer("IM_CountableSet", id, max)
		end

		if Iris.Button({ "Clear" }).clicked() then
			number3:set(0)
			Remotes.fireServer("IM_CountableSet", id, 0)
		end

		Iris.End()

		if not Iris.InputNum({
			"",
			1,
			0,
			v12
		}, {
			number = number3
		}).numberChanged() then
			continue
		end

		local v14 = math.clamp(math.floor((number3:get())), 0, v12)
		number3:set(v14)
		Remotes.fireServer("IM_CountableSet", id, v14)
	end

	Iris.End()
end

local function drawTeleportsTree()
	Iris.Tree({ "Teleports" })
	local v6 = {}

	for _, v7 in CollectionService:GetTagged("DebugTeleport") do
		if not v7:GetAttribute("Teleport") then
			continue
		end

		local category = v7:GetAttribute("Category") or "Uncategorized"
		local subcategory = v7:GetAttribute("Subcategory") or "Uncategorized"

		if not v6[category] then
			v6[category] = {}
		end

		if not v6[category][subcategory] then
			v6[category][subcategory] = {}
		end

		table.insert(v6[category][subcategory], v7)
	end

	local v7 = {}

	for k in v6 do
		table.insert(v7, k)
	end

	table.sort(v7)

	for _, v8 in v7 do
		local v9 = v6[v8]
		local v10 = {}

		for k in v9 do
			table.insert(v10, k)
		end

		table.sort(v10)
		Iris.Tree({ v8 })

		for _, v11 in v10 do
			local v12 = v9[v11]
			table.sort(v12, function(a, b)
				return (a:GetAttribute("Teleport") or a.Name) < (b:GetAttribute("Teleport") or b.Name)
			end)
			Iris.Tree({ v11 })

			for _, v13 in v12 do
				local v14 = { (v13:GetAttribute("Teleport")) }

				if not Iris.Button(v14).clicked() then
					continue
				end

				local localPlayer = Players.LocalPlayer
				local character

				if localPlayer then
					character = localPlayer.Character
				end

				local upperTorso

				if character then
					upperTorso = character:FindFirstChild("UpperTorso")
				end

				if not upperTorso then
					continue
				end

				upperTorso.CFrame = CFrame.new(v13.Position + createVector(0, 4, 0))
				v = false
			end

			Iris.End()
		end

		Iris.End()
	end

	Iris.End()
end

local function drawEventTree()
	if not LiveOpsUtil.IsEventStarted("EggHunt") then
		return
	end

	Iris.Tree({ "Event" })
	local v6, v7 = ReplicatedDataController.GetClientReplicaPromise():now():await()
	local v8 = not (v6 and v7 and v7.Data and v7.Data.LiveOpsEventData and v7.Data.LiveOpsEventData.Easter2026) and 0 or v7.Data.LiveOpsEventData.Easter2026.Tokens
	local state = Iris.State(v8)

	if state:get() ~= v8 then
		state:set(v8)
	end

	if Iris.InputNum({
		"Tokens",
		1,
		0,
		999999
	}, {
		number = state
	}).numberChanged() then
		Remotes.fireServer("IM_EventSetTokens", state:get())
	end

	Iris.SameLine()

	for _, v9 in {
		-1000,
		-100,
		-10,
		10,
		100,
		1000
	} do
		if not Iris.Button({ string.format("%+d", v9) }).clicked() then
			continue
		end

		state:set((math.clamp(state:get() + v9, 0, 999999)))
		Remotes.fireServer("IM_EventSetTokens", state:get())
	end

	Iris.End()
	Iris.End()
end

local function drawTicketsTree()
	if not LiveOpsUtil.IsEventStarted("SummerCarnival2026") then
		return
	end

	Iris.Tree({ "Tickets" })

	if number2:get() ~= 0 then
		number2:set(0)
	end

	Iris.Text({ string.format("Current: %d", 0) })
	Iris.SameLine()
	Iris.InputNum({
		"Set tickets",
		1,
		0,
		9999999
	}, {
		number = number2
	})

	if Iris.Button({ "Set" }).clicked() then
		Remotes.fireServer("IM_SetTickets", (math.max(0, (math.floor((number2:get()))))))
	end

	Iris.End()
	Iris.SameLine()

	for _, v6 in {
		-1000,
		-100,
		-10,
		10,
		100,
		1000
	} do
		if not Iris.Button({ string.format("%+d", v6) }).clicked() then
			continue
		end

		Remotes.fireServer("IM_SetTickets", (math.max(0, 0 + v6)))
	end

	Iris.End()
	Iris.End()
end

local function drawUnlockablesTree()
	Iris.Tree({ "Unlockables" })
	Iris.InputText({ "Feature name" }, {
		TextHint = textHint
	})
	Iris.SameLine()

	if Iris.Button({ "Add" }).clicked() then
		local v6 = textHint:get()

		if v6 ~= "" then
			Remotes.fireServer("IM_UnlockableAdd", v6)
		end
	end

	if Iris.Button({ "Remove" }).clicked() then
		local v6 = textHint:get()

		if v6 ~= "" then
			Remotes.fireServer("IM_UnlockableRemove", v6)
		end
	end

	Iris.End()

	if Iris.Button({ "Clear all" }).clicked() then
		Remotes.fireServer("IM_UnlockableClear")
	end

	Iris.Tree({ "Current" })
	local v6, v7 = ReplicatedDataController.GetClientReplicaPromise():now():await()

	if v6 and v7 ~= nil then
		local v8 = {}

		for k in v7.Data.unlockedFeatures do
			table.insert(v8, k)
		end

		table.sort(v8)

		for _, v9 in v8 do
			Iris.SameLine()
			Iris.Text({ v9 })

			if Iris.Button({ "X" }).clicked() then
				Remotes.fireServer("IM_UnlockableRemove", v9)
			end

			Iris.End()
		end
	else
		Iris.Text({ "Loading.." })
	end

	Iris.End()
	Iris.End()
end

local ImmediateMenu = {}

function ImmediateMenu.FrameworkInit() end

function ImmediateMenu.FrameworkStart()
	if not Permissions.hasAdminAccess(Players.LocalPlayer) then
		return
	end

	Iris.Init()
	number = Iris.State(16)
	textHint = Iris.State("")
	number2 = Iris.State(0)
	local state = Iris.State(false)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.KeyCode == Enum.KeyCode.F8 then
			state:set(not state:get())
			v = not v
		end
	end)
	RunService.Heartbeat:Connect(function()
		local walkSpeed = number:get()

		if walkSpeed == 16 then
			return
		end

		local character = Players.LocalPlayer.Character
		local humanoid

		if character then
			humanoid = character:FindFirstChild("Humanoid")
		end

		if humanoid ~= nil and humanoid.WalkSpeed ~= walkSpeed then
			humanoid.WalkSpeed = walkSpeed
		end
	end)
	Iris:Connect(function()
		if not state:get() then
			return
		end

		Iris.Window({ "Immediate menu" }, {
			isOpened = state
		})
		drawCharacterTree()
		drawPropertiesTree()
		drawGamepassesTree()
		drawTicketsTree()
		drawUnlockablesTree()
		drawTeleportsTree()
		Iris.End()
	end)
end

return ImmediateMenu