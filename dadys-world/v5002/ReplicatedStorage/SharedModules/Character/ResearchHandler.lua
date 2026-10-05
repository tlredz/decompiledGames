local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HolidayEventConfig = require(ReplicatedStorage.SharedData.HolidayEventConfig)
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
local ENABLED = HolidayEventConfig.ENABLED
local CURRENT_EVENT = HolidayEventConfig.CURRENT_EVENT
local v = false
local v2 = nil
pcall(function()
	local ServerScriptService = game:GetService("ServerScriptService")

	if ServerScriptService:FindFirstChild("MonsterAI") then
		local modules = ServerScriptService.MonsterAI:FindFirstChild("Modules")

		if modules and modules:FindFirstChild("DebugDisplayModule") then
			local DebugDisplayModule = require(modules.DebugDisplayModule)
			v2 = DebugDisplayModule
		end
	end
end)

local function debugPrint(...)
	if v2 and v2.ENABLED then
		print("[ResearchHandler]", ...)
	end
end

task.defer(function()
	if v2 and v2.ENABLED then
		if ENABLED and CURRENT_EVENT ~= "" then
			print(string.format(
				"[ResearchHandler] Seasonal events ENABLED — event: %s, tapes/encounter: %d",
				CURRENT_EVENT,
				1
			))
		else
			print("[ResearchHandler] Seasonal events disabled — no tapes will be granted (legacy mode)")
		end
	end
end)

local function updateMasteryRequirements(player, _: string, p: number)
	local character = player.Character

	if not character then
		return
	end

	local config = character:FindFirstChild("Config")

	if not config then
		return
	end

	local moduleName = config:FindFirstChild("ModuleName")

	if not (moduleName and moduleName.Value) then
		return
	end

	local editData = ReplicatedStorage:FindFirstChild("editData")

	if not editData then
		return
	end

	editData:Invoke(player, function(p2)
		if not p2 then
			return
		end

		if p2.Data.Milestones.Monster then
			p2.Data.Milestones.Monster += 1
		else
			p2.Data.Milestones.Monster = 1
		end

		local v3 = false

		for _, v5 in pairs(p2.Data.Mastery) do
			if v5.Name ~= moduleName.Value then
				continue
			end

			v3 = v5
			break
		end

		if v3 then
			for _, v5 in pairs(v3.RequirementList) do
				if v5.Name == "EncounterMonster" then
					v5.Current += 1

					if v5.Current >= v5.Amount then
						v5.Current = v5.Amount
					end
				end

				if v5.Name ~= "CollectResearch" then
					continue
				end

				v5.Current += p

				if v5.Current >= v5.Amount then
					v5.Current = v5.Amount
				end
			end
		end
	end)
end

local function grantResearchLegacy(player, p: string, points: number, p2: string?, p3: number)
	local child = Workspace:FindFirstChild("Info") and Workspace.Info:FindFirstChild("PlayerStats") and Workspace.Info.PlayerStats:FindFirstChild(player.Name)
	local editData = ReplicatedStorage:FindFirstChild("editData")

	if not editData then
		return false
	end

	editData:Invoke(player, function(p4)
		if p4 then
			local v3 = false

			for _, v4 in pairs(p4.Data.Research) do
				if v4[1] ~= p then
					continue
				end

				v3 = true
				v4[2] += points

				if v4[2] >= 100 then
					v4[2] = 100
				end
			end

			if ENABLED and p2 and p3 > 0 and not pcall(function()
				local HolidayCurrencyModule = require(ReplicatedStorage:WaitForChild("SharedData"):WaitForChild("HolidayCurrencyModule"))
				local matchLockedMultiplier = workspace.Info:GetAttribute("MatchLockedMultiplier")
				HolidayCurrencyModule.Grant(player, "Monster", p3, matchLockedMultiplier)
				debugPrint("Granted", p3, "holiday currency to", player.Name, "via HolidayCurrencyModule")
			end) then
				warn("Failed to grant holiday currency via module, falling back to legacy system")

				if p4.Data.Seasonal and p4.Data.Seasonal.Christmas25 and p4.Data.Seasonal.Christmas25[p2] then
					p4.Data.Seasonal.Christmas25[p2] = p4.Data.Seasonal.Christmas25[p2] + p3
					local holidayPoints = child and child:FindFirstChild("HolidayPoints")

					if holidayPoints then
						holidayPoints.Value += p3
					end
				end
			end

			if not v3 then
				table.insert(p4.Data.Research, { p, points })
			end

			updateMasteryRequirements(player, p, points)
		end
	end)
	return true
end

local function grantResearch(player, p: string, options, p2: string?)
	if not (player and player:IsA("Player")) then
		return false
	end

	local v3 = options or {}
	local points = v3.points or 5
	local character = player.Character

	if character then
		if character == nil then
			character = false
		else
			character = TowerLUT:HasPassive(character, "Rodger")
		end
	end

	if character then
		debugPrint("Rodger character detected, doubling research points to: " .. points * 2)
		points *= 2
	end

	local v4 = 1
	local v5

	if ENABLED and CURRENT_EVENT ~= "" then
		v5 = CURRENT_EVENT
	else
		v4 = 0
	end

	if not v3.displayMessage then
		local _ = "You found research on " .. p .. "!"
	end

	if not v3.messageColor then
		Color3.fromRGB(255, 215, 0)
	end

	if not shared.ResearchGranted then
		shared.ResearchGranted = {}
	end

	local v6 = player.UserId .. "_" .. p

	if p ~= "BlottMonster" and p2 then
		v6 ..= "_" .. p2
	end

	local v7 = player.UserId .. "_" .. p

	if shared.ResearchGranted[v7] then
		debugPrint("Player already received research via base key " .. v7)
		return false
	end

	if shared.ResearchGranted[v6] then
		debugPrint("Player already received research for " .. v6)
		return false
	end

	shared.ResearchGranted[v6] = true
	local v8 = 0
	local child = workspace:FindFirstChild("Info") and workspace.Info:FindFirstChild("PlayerStats") and workspace.Info.PlayerStats:FindFirstChild(player.Name)

	if child then
		local survivalPoints = child:FindFirstChild("SurvivalPoints")

		if survivalPoints then
			survivalPoints.Value += 5
			v8 = 5
		end
	end

	debugPrint(string.format(
		"granted %s +%d research (+%d SP%s) for %s [%s]",
		player.Name,
		points,
		v8,
		not (v5 and v4 > 0) and "" or string.format(", +%d tapes/%s", v4, v5) or "",
		p,
		v6
	))
	local grantPlayerResearch = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("GrantPlayerResearch")

	if not grantPlayerResearch then
		return (grantResearchLegacy(player, p, points, v5, v4))
	end

	grantPlayerResearch:FireClient(player, p)
	updateMasteryRequirements(player, p, points)
	return true
end

local ResearchHandler = {}
ResearchHandler.grantResearch = grantResearch

function ResearchHandler.setupResearchChecker(parent, p: number, p2: string, p3)
	if not (parent and parent.Parent) then
		return
	end

	local v3 = {}
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "ResearchCheckerRunning"
	boolValue.Value = true
	boolValue.Parent = parent
	local v4 = tostring(os.time() .. "_" .. parent:GetFullName() .. "_" .. math.random(1000, 9999))
	task.spawn(function()
		while parent and parent.Parent and boolValue.Value do
			local primaryPart = parent:FindFirstChild("PrimaryPart") or parent:FindFirstChild("HumanoidRootPart")

			if primaryPart then
				local position = primaryPart.Position

				for _, v5 in ipairs(Players:GetPlayers()) do
					local character = v5.Character

					if not character then
						continue
					end

					local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

					if not humanoidRootPart or not ((humanoidRootPart.Position - position).Magnitude <= p) or v3[v5.UserId] then
						continue
					end

					print("Player", v5.Name, "is within research radius of", p2)
					v3[v5.UserId] = true
					grantResearch(v5, p2, p3, v4)
				end

				task.wait(1)
			else
				task.wait(1)
			end
		end
	end)
	parent.AncestryChanged:Connect(function(_, parent2)
		if not parent2 and boolValue then
			boolValue.Value = false
		end
	end)
	return boolValue
end

function ResearchHandler.setEvent(p)
	if p and p ~= "" then
		ENABLED = true
		CURRENT_EVENT = p
		print("[ResearchHandler] Seasonal event enabled: " .. p)
	else
		ENABLED = false
		CURRENT_EVENT = ""
		print("[ResearchHandler] Seasonal events disabled")
	end
end

function ResearchHandler.getCurrentEvent()
	if ENABLED then
		return CURRENT_EVENT
	end

	return nil
end

function ResearchHandler.setDebugMode(p)
	v = p
	print("[ResearchHandler] Debug mode " .. (p and "enabled" or "disabled"))
end

ResearchHandler._internal = {
	updateMasteryRequirements = updateMasteryRequirements,
	grantResearchLegacy = grantResearchLegacy,
	isRodgerCharacter = function(p)
		return p ~= nil and TowerLUT:HasPassive(p, "Rodger")
	end
}
return ResearchHandler