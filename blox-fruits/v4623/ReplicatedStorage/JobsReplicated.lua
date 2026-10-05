local JobsReplicated = {}
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
JobsReplicated.IsServer = isServer
local Net = require(game.ReplicatedStorage.Modules.Net)
local remoteFunction = Net:RemoteFunction("JobsRemoteFunction")
local Net2 = require(game.ReplicatedStorage.Modules.Net)
local remoteEvent = Net2:RemoteEvent("JobsRemoteEvent")
local JobProgressionInfo = require(script.JobProgressionInfo)
JobsReplicated.JobCategories = {
	Fishing = {
		InventoryItemTypes = {
			Bait = {
				Equippable = true,
				Type = "Valuable",
				DisplayName = "Bait"
			},
			Fish = {
				Equippable = true,
				EquipButton = {
					Text = "Flex",
					onClick = function(p)
						remoteFunction:InvokeServer("FlexFish", p.details.Name)
					end
				}
			}
		}
	},
	Mining = {
		InventoryItemTypes = {}
	}
}
JobsReplicated.SubTypeCategories = {
	Fish = {
		parent = "Valuable",
		Image = ""
	}
}
JobsReplicated.InventorySubTypeJobNameLookup = {}
JobsReplicated.InventoryItemTypes = {}

for k, jobCategory in JobsReplicated.JobCategories do
	if jobCategory.InventoryItemTypes then
		for k2, inventoryItemType in jobCategory.InventoryItemTypes do
			JobsReplicated.InventorySubTypeJobNameLookup[k2] = k
			JobsReplicated.InventoryItemTypes[k2] = inventoryItemType
		end
	end

	if not jobCategory.InventoryCategories then
		continue
	end

	for k2, _ in jobCategory.InventoryCategories do
		JobsReplicated.InventorySubTypeJobNameLookup[k2] = k
	end
end

local onClientLoaded
task.spawn(function()
	if isServer then
		JobsReplicated.FishReplicated = game.ReplicatedStorage:FindFirstChild("FishReplicated")
		local baitData = JobsReplicated.FishReplicated:FindFirstChild("BaitData")

		if baitData then
			JobsReplicated.BaitData = require(baitData)
		end

		local v2 = {}
		local v3 = {}

		function JobsReplicated.RegisterNetCallback(p, p2)
			v2[p] = p2
		end

		remoteFunction.OnServerInvoke = function(p, value, ...)
			assert(typeof(value) == "string")
			local v4 = v2[value]

			if v4 then
				return v4(p, ...)
			end

			if not v3[value] then
				v3[value] = true
				warn((`JobsReplicated: no server callback registered for "{value}" (first invoked by {p.Name})`))
			end

			return nil
		end

		function JobsReplicated:FireClient(p, ...)
			remoteEvent:FireClient(self, p, ...)
		end
	else
		JobsReplicated.FishReplicated = game.ReplicatedStorage:WaitForChild("FishReplicated")
		JobsReplicated.BaitData = require(JobsReplicated.FishReplicated:WaitForChild("BaitData"))
		JobsReplicated.JobTools = require(script.JobTools)

		function JobsReplicated.InvokeServer(p, ...)
			return remoteFunction:InvokeServer(p, ...)
		end

		local v4 = {}
		remoteEvent.OnClientEvent:Connect(function(p, ...)
			local v5 = v4[p]

			if v5 then
				v5(...)
			else
				warn((`JobsReplicated: no client handler registered for "{p}"`))
			end
		end)

		function JobsReplicated.RegisterClientEvent(p, p2)
			v4[p] = p2
		end

		task.spawn(function()
			while not onClientLoaded do
				task.wait()
			end

			onClientLoaded()
		end)
	end
end)

if isServer then
	return JobsReplicated
end

JobsReplicated.JobClientData = {}
JobsReplicated.JobClientSignals = {}

function JobsReplicated.GetSignal(_: string) end

function JobsReplicated.GetEquippedJobToolOnCharacterOrInBackpack()
	local character = game.Players.LocalPlayer.Character
	local tool = character and character:FindFirstChildWhichIsA("Tool")

	if tool and tool.ToolTip == "JobTool" and tool:GetAttribute("UserId") == game.Players.LocalPlayer.UserId then
		return tool
	end

	local backpack = game.Players.LocalPlayer:FindFirstChild("Backpack")

	if backpack then
		for _, tool2 in backpack:GetChildren() do
			if tool2:IsA("Tool") and tool2.ToolTip == "JobTool" and tool2:GetAttribute("UserId") == game.Players.LocalPlayer.UserId then
				return tool2
			end
		end
	end

	return nil
end

function JobsReplicated.GetJobData(p: string, flag: boolean?)
	if flag then
		local v2 = JobsReplicated.InvokeServer("GetJobClientData", p)

		if not JobsReplicated.JobClientData[p] then
			JobsReplicated.JobClientData[p] = {}
		end

		table.clear(JobsReplicated.JobClientData[p])

		for k, v3 in v2 do
			JobsReplicated.JobClientData[p][k] = v3
		end

		return JobsReplicated.JobClientData[p]
	else
		local v2 = JobsReplicated.JobClientData[p]

		if v2 then
			return v2
		end

		JobsReplicated.JobClientData[p] = JobsReplicated.InvokeServer("GetJobClientData", p)
		return JobsReplicated.JobClientData[p]
	end
end

function JobsReplicated.GetJobStatAlpha(p: string, p2: string, flag: boolean?)
	local statInfo = JobProgressionInfo.GetStatInfo(p, p2)
	return JobsReplicated.GetJobData(p, flag).Stats[p2] / statInfo.Max
end

function JobsReplicated.GetJobStatBoosts(p: string, p2: string)
	local v2 = {}
	local statInfo = JobProgressionInfo.GetStatInfo(p, p2)

	if JobsReplicated.GetJobData(p).IsSealEquipped then
		table.insert(v2, {
			Name = "Seal",
			Amount = statInfo.SealBoost
		})
	end

	return v2
end

onClientLoaded = function()
	JobsReplicated.RegisterClientEvent("GetJobClientData", function(p, items)
		if not JobsReplicated.JobClientData[p] then
			JobsReplicated.JobClientData[p] = {}
		end

		table.clear(JobsReplicated.JobClientData[p])

		for k, item in items do
			JobsReplicated.JobClientData[p][k] = item
		end

		JobsReplicated.JobClientData[p].lastChange = tick()
		task.defer(function()
			local JobMenuController = require(script.JobMenuController)
			JobMenuController.Update(p, JobsReplicated.JobClientData[p])
		end)
	end)
	JobsReplicated.RegisterClientEvent("UpdateJobStat", function(p: string, p2: string, p3: number)
		if not JobsReplicated.JobClientData[p] then
			JobsReplicated.GetJobData(p)
		end

		JobsReplicated.JobClientData[p].Stats[p2] = p3
		JobsReplicated.JobClientData[p].lastChange = tick()
		task.defer(function()
			local JobMenuController = require(script.JobMenuController)
			JobMenuController.Update(p, JobsReplicated.JobClientData[p])
		end)
	end)
	JobsReplicated.RegisterClientEvent("UpdateJobCheckpoint", function(p: string, checkpoint)
		if not JobsReplicated.JobClientData[p] then
			JobsReplicated.GetJobData(p)
		end

		JobsReplicated.JobClientData[p].Checkpoint = checkpoint
		JobsReplicated.JobClientData[p].lastChange = tick()
	end)
	JobsReplicated.RegisterClientEvent("UpdateJobLevelData", function(p: string, levelData)
		if not JobsReplicated.JobClientData[p] then
			JobsReplicated.GetJobData(p)
		end

		JobsReplicated.JobClientData[p].LevelData = levelData
		JobsReplicated.JobClientData[p].lastChange = tick()
		task.defer(function()
			local JobMenuController = require(script.JobMenuController)
			JobMenuController.Update(p, JobsReplicated.JobClientData[p])
		end)
	end)
end

local fishMenuEnabled = script:GetAttribute("FishMenuEnabled")
local flag = false

local function enableFishMenu()
	if flag then
		return
	end

	if fishMenuEnabled and game.Players.LocalPlayer:GetAttribute("FishMenuEnabledForPlayer") then
		flag = true
		JobsReplicated.EasyMode = true
		local iris = require(game.ReplicatedStorage.Util.IrisLog.iris)
		local state = iris.State(Vector2.new(200, 300))
		local v2 = true
		local fishingData = game.Players.LocalPlayer:WaitForChild("Data"):WaitForChild("FishingData")

		if not iris.Internal._started then
			iris.Init()
		end

		local names = { "None" }
		task.spawn(function()
			task.wait()

			while not JobsReplicated.FishReplicated do
				task.wait()
			end

			local FishingIndexInventoryData = require(JobsReplicated.FishReplicated.FishingIndexInventoryData)

			for _, v3 in FishingIndexInventoryData.FishIndex do
				table.insert(names, v3.Name)
			end

			table.sort(names, function(a, b)
				return a < b
			end)
		end)
		iris:Connect(function()
			if v2 then
				if iris.Window({ "Fishing" }, {
					size = state
				}).state.isOpened then
					if iris.Button({ "Force Update" }).clicked() then
						task.defer(function()
							print(JobsReplicated.GetJobData("Fishing", true))
						end)
					end

					local fishing = iris.Tree({ "Stats" }).state.isOpened and JobsReplicated.JobClientData.Fishing

					if fishing then
						iris.Text({ (`Fishing Level: {fishing.LevelData.level} ({math.round(fishing.LevelData.percentToNextLevel * 1000) / 1000}%)`) })

						for k, _ in fishing.Stats do
							iris.Text({ (`{k}: {math.round(JobsReplicated.GetJobStatAlpha("Fishing", k) * 100 * 1000) / 1000}% to max`) })
						end
					end

					iris.End()
					iris.Text({ (`Selected Bait: {fishingData and fishingData:GetAttribute("SelectedBait")}`) })

					if iris.Tree({ "EXP/Level Debug" }).state.isOpened then
						if iris.Button({ "Add Bait" }).clicked() then
							task.defer(function()
								JobsReplicated.InvokeServer("AdminDebug", "AddBait")
							end)
						end

						if iris.Button({ "Add Rod Mastery" }).clicked() then
							task.defer(function()
								JobsReplicated.InvokeServer("AdminDebug", "RodMastery")
							end)
						end

						if iris.Button({ "Add Stats (1x)" }).clicked() then
							task.defer(function()
								JobsReplicated.InvokeServer("AdminDebug", "AddStats", 1)
							end)
						end

						if iris.Button({ "Add Stats (10x)" }).clicked() then
							task.defer(function()
								JobsReplicated.InvokeServer("AdminDebug", "AddStats", 10)
							end)
						end

						if iris.Button({ "Add Stats (100x)" }).clicked() then
							task.defer(function()
								JobsReplicated.InvokeServer("AdminDebug", "AddStats", 100)
							end)
						end

						if iris.Button({ "Reset Stats" }).clicked() then
							task.defer(function()
								JobsReplicated.InvokeServer("AdminDebug", "ResetStats")
							end)
						end

						if iris.Button({ "Add Fishing EXP" }).clicked() then
							task.defer(function()
								JobsReplicated.InvokeServer("AdminDebug", "AddJobExp")
							end)
						end

						if iris.Button({ "Reset Fishing EXP" }).clicked() then
							task.defer(function()
								JobsReplicated.InvokeServer("AdminDebug", "ResetJobExp")
							end)
						end
					end

					iris.End()

					if iris.Tree({ "Tools" }).state.isOpened then
						for _, v3 in {
							"Fishing Rod",
							"Gold Rod",
							"Shell Rod",
							"Shark Rod",
							"Treasure Rod",
							"Admin Rod"
						} do
							if not iris.Button({ v3 }).clicked() then
								continue
							end

							local v4 = v3
							task.defer(function()
								JobsReplicated.InvokeServer("AdminDebug", "Tool", v4)
							end)
						end
					end

					iris.End()

					if iris.Button({ "reset quest timer" }).clicked() then
						task.defer(function()
							JobsReplicated.InvokeServer("AdminDebug", "resetquesttimer")
						end)
					end

					if iris.Button({ "Print FishInventory (hit f9)" }).clicked() then
						task.defer(function()
							local v3 = JobsReplicated.InvokeServer("AdminDebug", "GetFishInventory")

							for _, v4 in v3 do
								print((`EconomyItemId: {v4.Id}, RawWeight: {v4.Weight}`))
							end
						end)
					end

					if iris.Button({ "empty fish inventory" }).clicked() then
						task.defer(function()
							JobsReplicated.InvokeServer("AdminDebug", "EmptyFishInventory")
						end)
					end

					local comboArray = iris.ComboArray({ "Fish Catch Override" }, nil, names)

					if comboArray.closed() then
						task.defer(function()
							JobsReplicated.InvokeServer("AdminDebug", "SetFishSelect", comboArray.state.index.value)
						end)
					end

					local comboArray2 = iris.ComboArray({ "get fish tool" }, nil, names)

					if comboArray2.closed() then
						task.defer(function()
							JobsReplicated.InvokeServer("AdminDebug", "GetFishTool", comboArray2.state.index.value)
						end)
					end
				end

				iris.End()
			end
		end)
		local Global = require(game.ReplicatedStorage.Global)
		Global.TestGameWarn("JobsReplicated testing mode, client commands: /localfishdata")
		local TextChatService = game:GetService("TextChatService")
		TextChatService.SendingMessage:Connect(function(p)
			if p.Text == "/fishmenu" then
				v2 = not v2
			end
		end)
	end
end

game.Players.LocalPlayer:GetAttributeChangedSignal("FishMenuEnabledForPlayer"):Connect(function()
	fishMenuEnabled = script:GetAttribute("FishMenuEnabled")
	enableFishMenu()
end)
script:GetAttributeChangedSignal("FishMenuEnabled"):Connect(function()
	fishMenuEnabled = script:GetAttribute("FishMenuEnabled")
	enableFishMenu()
end)
enableFishMenu()
return JobsReplicated