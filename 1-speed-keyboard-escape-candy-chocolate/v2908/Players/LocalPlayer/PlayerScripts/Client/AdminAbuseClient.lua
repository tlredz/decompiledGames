local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local AdminAbuseGui = require(script.Parent:WaitForChild("AdminAbuseGui"))
local AdminAbuseRegistry = require(script.Parent:WaitForChild("AdminAbuseRegistry"))
local AdminAbuseTransition = require(script.Parent:WaitForChild("AdminAbuseTransition"))
local F8 = Enum.KeyCode.F8
local modules = nil
local v = nil
local v2 = nil
local v3 = nil

local function getModulesFolder()
	return (ReplicatedStorage:WaitForChild("AdminAbuse"):WaitForChild("Modules"))
end

local function getRemotes()
	local remotes = ReplicatedStorage:WaitForChild("AdminAbuse"):WaitForChild("Remotes")
	return remotes:WaitForChild("AdminAbuseRequest"), (remotes:WaitForChild("AdminAbuseSync"))
end

local function invalidateRegistry()
	v3 = nil
end

local function getRegistry()
	local v4 = modules
	assert(v4, "AdminAbuseClient.init() d'abord")

	if not v3 then
		v3 = AdminAbuseRegistry.loadRegistry(v4)
	end

	return v3
end

local AdminAbuseClient = {}

function AdminAbuseClient.init()
	modules = ReplicatedStorage:WaitForChild("AdminAbuse"):WaitForChild("Modules")
	local remotes = ReplicatedStorage:WaitForChild("AdminAbuse"):WaitForChild("Remotes")
	local adminAbuseRequest = remotes:WaitForChild("AdminAbuseRequest")
	local adminAbuseSync = remotes:WaitForChild("AdminAbuseSync")
	v = adminAbuseRequest
	v2 = adminAbuseSync
	local v4 = modules
	v4.ChildAdded:Connect(invalidateRegistry)
	v4.ChildRemoved:Connect(invalidateRegistry)
	local localPlayer = Players.LocalPlayer
	assert(localPlayer, "LocalPlayer manquant")
	local v5 = v
	local v6 = v2
	local activeAdminAbuse = nil
	local v8 = nil
	local activeEvent = nil
	local v10 = nil
	local v11 = nil
	local v12 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isTrusted()
		return localPlayer:GetAttribute("AdminAbuseTrusted") == true
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateMuteAttr()
		localPlayer:SetAttribute("AdminAbuseEventActive", activeAdminAbuse ~= nil or activeEvent ~= nil)
	end

	local function buildProps()
		return {
			moduleMetas = AdminAbuseRegistry.listModuleMetas(v4),
			onPickModule = function(p: string, p2: number?)
				if p2 then
					v5:FireServer("Start", p, p2)
				else
					v5:FireServer("Start", p)
				end
			end,
			onStop = function()
				v5:FireServer("Stop")
			end,
			onStopEvent = function()
				v5:FireServer("StopEvent")
			end,
			onBossDelta = function(p: number)
				if isTrusted() then
					v5:FireServer("BossDelta", p)
				end
			end,
			onClose = function()
				v12 = false
			end,
			showStop = isTrusted(),
			activeAdminAbuse = activeAdminAbuse,
			activeEvent = activeEvent
		}
	end

	local function ensureGui()
		if v11 then
			return v11
		end

		v11 = AdminAbuseGui.mountLocalPlayer((buildProps()))
		return v11
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function togglePanel()
		if localPlayer:GetAttribute("AdminAbuseTrusted") ~= true then
			return
		end

		if not v11 then
			v11 = AdminAbuseGui.mountLocalPlayer((buildProps()))
		end

		local v13 = v11
		v12 = not v12
		v13.SetProps((buildProps()))
		v13.SetVisible(v12)
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.KeyCode == F8 then
			togglePanel() -- equivalent call inferred; original call site unknown
		end
	end)
	localPlayer:GetAttributeChangedSignal("AdminAbuseTrusted"):Connect(function()
		if localPlayer:GetAttribute("AdminAbuseTrusted") ~= true and v11 then
			v12 = false
			v11.SetVisible(false)
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function runModuleFire(p: string, p2: number?)
		local v13 = modules
		assert(v13, "AdminAbuseClient.init() d'abord")

		if not v3 then
			v3 = AdminAbuseRegistry.loadRegistry(v13)
		end

		local v14 = v3[p]

		if v14 and type(v14.Fire) == "function" then
			if p2 then
				v14:Fire(p2)
			else
				v14:Fire()
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function runModuleStop(p: string)
		local v13 = modules
		assert(v13, "AdminAbuseClient.init() d'abord")

		if not v3 then
			v3 = AdminAbuseRegistry.loadRegistry(v13)
		end

		local v14 = v3[p]

		if v14 and type(v14.Stop) == "function" then
			v14:Stop()
		end
	end

	local function frameworkMainSlotLocksEvent()
		local success, result = pcall(function()
			return require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminAbuseEvent)
		end)

		if not success then
			return false
		end

		for _, v13 in result.getActiveStates() do
			if v13.slot == "main" then
				return true
			end
		end

		return false
	end

	local function applyPriorityLockToEvent()
		local v13

		if activeAdminAbuse then
			local v14 = modules
			assert(v14, "AdminAbuseClient.init() d'abord")

			if not v3 then
				v3 = AdminAbuseRegistry.loadRegistry(v14)
			end

			local v15 = v3[activeAdminAbuse]

			if v15 == nil then
				v13 = false
			else
				v13 = v15.HasPrioritySoundtrack == true
			end
		else
			v13 = false
		end

		local v14 = v13 or frameworkMainSlotLocksEvent()
		localPlayer:SetAttribute("AdminAbuseEventMusicLocked", v14)

		if not activeEvent then
			return
		end

		local v15 = modules
		assert(v15, "AdminAbuseClient.init() d'abord")

		if not v3 then
			v3 = AdminAbuseRegistry.loadRegistry(v15)
		end

		local v16 = v3[activeEvent]

		if v16 and type(v16.SetPriorityLocked) == "function" then
			v16:SetPriorityLocked(v14)
		end
	end

	local v13 = 0
	local flag = false
	local v14 = false
	local v15 = 0
	v6.OnClientEvent:Connect(function(p, value, value2, p2, value3, p3, p4)
		local v16 = type(value3) ~= "number" and 0 or value3

		if p4 == "Event" then
			if p == "Start" and type(value) == "string" and value ~= "" then
				local v17 = nil

				if type(value2) == "number" and value2 >= 0 then
					v17 = value2
				end

				if v16 > 0 then
					if v16 <= v15 then
						return
					else
						v15 = v16
					end
				elseif activeEvent == value and v10 == v17 then
					return
				end

				local v18 = activeEvent
				activeEvent = value
				v10 = v17
				updateMuteAttr() -- equivalent call inferred; original call site unknown

				if v18 and v18 ~= value then
					runModuleStop(v18) -- equivalent call inferred; original call site unknown
				end

				applyPriorityLockToEvent()
				runModuleFire(value, v17) -- equivalent call inferred; original call site unknown

				if v11 then
					v11.SetProps((buildProps()))
				end
			elseif p == "Stop" then
				if v16 > 0 then
					if v16 <= v15 then
						return
					else
						v15 = v16
					end
				end

				if activeEvent then
					runModuleStop(activeEvent) -- equivalent call inferred; original call site unknown
				end

				activeEvent = nil
				v10 = nil
				updateMuteAttr() -- equivalent call inferred; original call site unknown

				if v11 then
					v11.SetProps((buildProps()))
				end
			end
		elseif p == "Start" and type(value) == "string" and value ~= "" then
			local v17 = nil

			if type(value2) == "number" and value2 >= 0 then
				v17 = value2
			end

			local skip = p2 == true

			if v16 > 0 then
				if v16 < v13 then
					return
				end

				if v13 < v16 then
					v13 = v16
					flag = false
					v14 = false
				end

				if skip then
					if flag or v14 then
						return
					else
						v14 = true
					end
				elseif flag then
					return
				else
					flag = true
				end
			elseif activeAdminAbuse == value and v8 == v17 then
				return
			end

			local v19 = activeAdminAbuse
			activeAdminAbuse = value
			v8 = v17
			updateMuteAttr() -- equivalent call inferred; original call site unknown
			applyPriorityLockToEvent()

			if v11 then
				v11.SetProps((buildProps()))
			end

			if v19 and v19 ~= value then
				runModuleStop(v19) -- equivalent call inferred; original call site unknown
			end

			local v20 = v8
			local skipDoor = p3 == true
			AdminAbuseTransition.play(function()
				if activeAdminAbuse == value then
					runModuleFire(value, v20) -- equivalent call inferred; original call site unknown
				end
			end, {
				skip = skip,
				skipDoor = skipDoor
			})
		elseif p == "Stop" then
			if v16 > 0 then
				if v16 <= v13 then
					return
				else
					v13 = v16
				end
			end

			flag = false
			v14 = false
			AdminAbuseTransition.cancel()

			if activeAdminAbuse then
				runModuleStop(activeAdminAbuse) -- equivalent call inferred; original call site unknown
			end

			activeAdminAbuse = nil
			v8 = nil
			updateMuteAttr() -- equivalent call inferred; original call site unknown
			applyPriorityLockToEvent()

			if v11 then
				v11.SetProps((buildProps()))
			end
		end
	end)
	local character = localPlayer.Character
	localPlayer.CharacterAdded:Connect(function(character2)
		local v16 = modules
		assert(v16, "AdminAbuseClient.init() d'abord")

		if not v3 then
			v3 = AdminAbuseRegistry.loadRegistry(v16)
		end

		local v17 = v3

		if activeAdminAbuse then
			local v18 = v17[activeAdminAbuse]

			if v18 and v18.RequiresRespawnRefire == true and character ~= nil then
				task.defer(function()
					runModuleFire(activeAdminAbuse, v8) -- equivalent call inferred; original call site unknown
				end)
			end
		end

		if activeEvent then
			local v18 = v17[activeEvent]

			if v18 and v18.RequiresRespawnRefire == true and character ~= nil then
				task.defer(function()
					runModuleFire(activeEvent, v10) -- equivalent call inferred; original call site unknown
				end)
			end
		end

		character = character2
	end)
	task.spawn(function()
		local success, result = pcall(function()
			return require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminAbuseEvent)
		end)

		if success then
			result.remotes.Activated:connect(applyPriorityLockToEvent)
			result.remotes.Deactivated:connect(applyPriorityLockToEvent)
		end
	end)
	v5:FireServer("GetState")
end

function AdminAbuseClient.getAdminAbuseTable()
	local v4 = modules
	assert(v4, "AdminAbuseClient.init() d'abord")
	return AdminAbuseRegistry.buildAdminAbuseTable(v4)
end

return AdminAbuseClient