local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local AdminGiveAll = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminGiveAll)
local AdminPollSystem = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminPollSystem)
local AdminRemote = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminRemote)
require(ReplicatedStorage.CUI)
require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminPollSystem.Types)
require(script.Parent.Parent.Types)
local t = require(ReplicatedStorage.Packages.t)
local maxItemAmount = AdminPollSystem.getMaxItemAmount()
local maxStatAmount = AdminPollSystem.getMaxStatAmount()
local color = Color3.fromRGB(100, 255, 100)
local color2 = Color3.fromRGB(255, 100, 100)
local interface = t.interface({
	duration = t.number,
	shardCount = t.number,
	question = t.string,
	choices = t.array(t.interface({
		text = t.string
	})),
	rewardAttached = t.boolean
})
local strictInterface = t.strictInterface({
	winningChoiceIndex = t.integer,
	kind = t.literal("item", "xp", "wins"),
	amount = t.integer,
	itemKey = t.string,
	tier = t.integer
})
local v = {}
local values = {}
local v2 = {}
local v3 = {
	"Yes",
	"No",
	"Maybe",
	"Surprise us",
	"Keep going",
	"Stop here"
}
local v4 = { "Item", "XP", "Wins" }
local v5 = {
	Item = "item",
	XP = "xp",
	Wins = "wins"
}

for _, v6 in AdminGiveAll.getItems() do
	local formatted = `{v6.displayName} [{v6.rarity}] - {v6.key}`
	v[formatted] = v6.key
	table.insert(values, formatted)
end

for i = 0, AdminPollSystem.getMaxTier() do
	table.insert(v2, (tostring(i)))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function trim(value: string)
	return string.match(value, "^%s*(.-)%s*$") or ""
end

local function limitCharacters(p: number)
	return function(value)
		return (string.sub(value, 1, p))
	end
end

local function truncateLabel(value: string)
	if #value <= 28 then
		return value
	end

	return string.sub(value, 1, 28) .. "..."
end

local function formatTimeLeft(p: number)
	local v6 = math.max(0, (math.ceil(p)))
	local v7 = math.floor(v6 / 60)
	local v8 = v6 % 60
	return (`{v7 // 10}{v7 % 10}:{v8 // 10}{v8 % 10}`)
end

local function validateBroadcastRequest(data)
	if data.duration ~= data.duration or math.abs(data.duration) == 1e999 or data.duration <= 0 or data.duration > 3600 then
		return false, (`Duration must be between 1 and {3600} seconds.`)
	end

	if data.shardCount ~= data.shardCount or math.abs(data.shardCount) == 1e999 or data.shardCount % 1 ~= 0 or data.shardCount < 1 then
		return false, "Shard count must be a whole number above 1."
	end

	if #data.question == 0 or #data.question > 200 or string.match(data.question, "%S") == nil then
		return false, (`Question must contain between 1 and {200} characters.`)
	end

	if #data.choices < 2 or #data.choices > 6 then
		return false, (`A poll must contain between {2} and {6} choices.`)
	end

	for _, choice in data.choices do
		if #choice.text == 0 or #choice.text > 80 or string.match(choice.text, "%S") == nil then
			return false, (`Each choice must contain between 1 and {80} characters.`)
		end
	end

	return true, ""
end

local clientEvent = AdminRemote.RegisterClientEvent(
	"AdminMenu_LiveOps_Polls_Broadcast",
	"cui.liveops.manage",
	true,
	function(_, data)
		if not interface(data) then
			return {
				success = false,
				message = "Invalid poll request."
			}
		end

		local v6, message = validateBroadcastRequest(data)

		if not v6 then
			return {
				success = false,
				message = message
			}
		end

		if AdminPollSystem.isPollOngoing() then
			return {
				success = false,
				message = "Another poll is already ongoing."
			}
		end

		local success, v9 = AdminPollSystem.broadcastPoll(
			data.duration,
			data.question,
			data.choices,
			data.shardCount,
			data.rewardAttached
		):await()
		return {
			success = success,
			message = success and "Poll broadcast successfully." or tostring(v9)
		}
	end
)
local clientEvent2 = AdminRemote.RegisterClientEvent(
	"AdminMenu_LiveOps_Polls_ForceStop",
	"cui.liveops.manage",
	true,
	function()
		local success, v7 = AdminPollSystem.broadcastForceStop():await()
		return {
			success = success,
			message = success and "Force stop broadcast sent." or tostring(v7)
		}
	end
)
local clientEvent3 = AdminRemote.RegisterClientEvent(
	"AdminMenu_LiveOps_Polls_GetRewardSnapshot",
	"cui.liveops.polls",
	false,
	function()
		return AdminPollSystem.getRewardPollSnapshot()
	end
)
local clientEvent4 = AdminRemote.RegisterClientEvent(
	"AdminMenu_LiveOps_Polls_BroadcastReward",
	"cui.liveops.manage",
	true,
	function(_, p)
		if strictInterface(p) then
			return AdminPollSystem.broadcastReward(p)
		end

		return {
			success = false,
			message = "Invalid reward request."
		}
	end
)
return {
	DisplayName = "Polls",
	Permission = "cui.liveops.polls",
	Order = 30,
	Setup = function(object, _)
		if not RunService:IsClient() then
			return
		end

		local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
		local v6 = "What should happen next?"
		local duration = 30
		local shardCount = 8
		local v9 = 2
		local v10 = values[1] or ""
		local clone = table.clone(v3)
		local v11 = {}
		local v12 = object:AddField(function(object2)
			object2:SetText("Status"):SetValue("Ready to broadcast"):SetEnabled(false)
		end)
		object:AddField(function(object2)
			local v13 = 200
			object2:SetText("Question"):SetValue(v6):SetCustomFilter(function(value)
				return (string.sub(value, 1, v13))
			end):SetOnChangedRaw(function(p)
				v6 = p
			end)
		end)
		object:AddSplit(function(p)
			p.LeftComponents:AddNumberField(function(object2)
				object2:SetText("Duration (seconds)"):SetNumberFilter(1, 3600):SetValue(duration):SetOnChangedUnfocus(function(p2)
					duration = p2
				end)
			end)
			p.RightComponents:AddDropdown(function(object2)
				object2:SetText("Choices"):SetChoiceList({
					"2",
					"3",
					"4",
					"5",
					"6"
				}):SetSelected((tostring(v9))):SetOnChanged(function(p2)
					v9 = tonumber(p2) or 2

					for k, v13 in v11 do
						v13:SetVisible(k <= v9)
					end
				end)
			end)
		end)
		object:AddNumberField(function(object2)
			object2:SetText("Shard count"):SetNumberFilter(1, 1024):SetValue(shardCount):SetOnChangedUnfocus(function(p)
				shardCount = math.round(p)
				object2:SetValue(shardCount)
			end)
		end)
		local rewardAttached = false
		local v14 = false
		local flag = false
		local count = 0
		local fn
		local kind = "item"
		local v16 = nil
		local v17 = nil
		local amount = 1
		local v19 = nil
		local v20 = 0
		local v21 = {}
		local v22 = false

		for i = 1, 6 do
			local v23 = i
			v11[i] = object:AddField(function(object2)
				local v24 = 80
				object2:SetText((`Choice {v23}`)):SetValue(clone[v23]):SetCustomFilter(function(value)
					return (string.sub(value, 1, v24))
				end):SetOnChangedRaw(function(p)
					clone[v23] = p
				end):SetVisible(v23 <= v9)
			end)
		end

		object:AddCheckbox(function(object2)
			object2:SetText("Keep votes for reward (1h)"):SetValue(false):SetOnChanged(function(p)
				rewardAttached = p
			end)
		end)
		local v23 = nil
		v23 = object:AddButton(function(object2)
			object2:SetButtonText("Broadcast poll"):SetYSize(22):SetEnabledPermission("cui.liveops.manage"):DoNeedConfirmation(true):SetButtonCallback(function()
				if v14 or flag then
					return
				end

				local question = trim(v6) -- equivalent call inferred; original call site unknown

				if question == "" then
					NotificationSystem:ShowGeneralNotification("Enter a poll question.", color2, 4)
					return
				end

				local choices = {}

				for i = 1, v9 do
					local text = trim(clone[i]) -- equivalent call inferred; original call site unknown

					if text == "" then
						NotificationSystem:ShowGeneralNotification(`Enter text for choice {i}.`, color2, 4)
						return
					else
						table.insert(choices, {
							text = text
						})
					end
				end

				v14 = true
				count += 1
				local v27 = count
				v12:SetValue("Publishing...")
				v23:SetButtonText("Publishing...")

				if clientEvent then
					clientEvent:Fire({
						duration = duration,
						shardCount = shardCount,
						question = question,
						choices = choices,
						rewardAttached = rewardAttached
					}):andThen(function(p)
						if flag or v27 ~= count then
							return
						end

						v14 = false
						local success

						if p == nil then
							success = false
						else
							success = p.success
						end

						local v28 = not p and "Poll request was rejected." or p.message
						v12:SetValue(success and "Broadcast sent" or v28)
						v23:SetButtonText("Broadcast poll")
						local v30

						if success then
							v30 = color
						else
							v30 = color2
						end

						NotificationSystem:ShowGeneralNotification(v28, v30, 4)

						if success and rewardAttached then
							fn()
						end
					end):catch(function(p)
						if flag or v27 ~= count then
							return
						end

						v14 = false
						local formatted = `Poll broadcast failed: {tostring(p)}`
						v12:SetValue(formatted)
						v23:SetButtonText("Broadcast poll")
						NotificationSystem:ShowGeneralNotification(formatted, color2, 4)
					end)
					return
				end

				v14 = false
				v12:SetValue("Poll remote unavailable")
				v23:SetButtonText("Broadcast poll")
			end)
		end)
		object:AddButton(function(object2)
			object2:SetButtonText("FORCE STOP ALL POLLS"):SetYSize(22):SetEnabledPermission("cui.liveops.manage"):SetButtonColor(Color3.fromRGB(
				190,
				45,
				45
			)):DoNeedConfirmation(true):SetButtonCallback(function()
				if flag then
					return
				end

				if not clientEvent2 then
					v12:SetValue("Force stop remote unavailable")
					return
				end

				v12:SetValue("Force stopping all polls...")
				clientEvent2:Fire({}):andThen(function(p)
					if flag then
						return
					end

					local success

					if p == nil then
						success = false
					else
						success = p.success
					end

					local v24 = not p and "Force stop request was rejected." or p.message
					v12:SetValue(success and "Force stop sent" or v24)
					local v26

					if success then
						v26 = color
					else
						v26 = color2
					end

					NotificationSystem:ShowGeneralNotification(v24, v26, 4)
				end):catch(function(p)
					if flag then
						return
					end

					local formatted = `Force stop failed: {tostring(p)}`
					v12:SetValue(formatted)
					NotificationSystem:ShowGeneralNotification(formatted, color2, 4)
				end)
			end)
		end)
		object:AddTitle(function(object2)
			object2:SetTitle("Reward voters")
		end)
		local v24 = object:AddField(function(object2)
			object2:SetText("Cached poll"):SetValue("No reward poll cached on this server."):SetEnabled(false)
		end)
		object:AddDropdown(function(object2)
			object2:SetText("Reward"):SetChoiceList(v4):SetSelected("Item"):SetOnChanged(function(p)
				kind = v5[p] or "item"
				local v25 = kind == "item"
				v16:SetVisible(v25)
				v17:SetVisible(v25)
				local v26

				if v25 then
					v26 = maxItemAmount
				else
					v26 = maxStatAmount
				end

				amount = math.clamp(amount, 1, v26)
				v19:SetNumberFilter(1, v26)
				v19:SetValue(amount)
			end)
		end)
		v16 = object:AddDropdown(function(object2)
			object2:SetText("Item"):SetChoiceList(not (#values > 0) and { "No items" } or values):SetSelected(v10):SetEnabled(#values > 0):SetOnChanged(function(p)
				v10 = p
			end)
		end)
		v17 = object:AddDropdown(function(object2)
			object2:SetText("Tier"):SetChoiceList(v2):SetSelected("0"):SetOnChanged(function(p)
				v20 = tonumber(p) or 0
			end)
		end)
		v19 = object:AddNumberField(function(object2)
			object2:SetText("Amount"):SetValue(1):SetNumberFilter(1, maxItemAmount):SetOnChangedUnfocus(function(p)
				local v25

				if kind == "item" then
					v25 = maxItemAmount
				else
					v25 = maxStatAmount
				end

				amount = math.clamp(math.floor(p), 1, v25)
				object2:SetValue(amount)
			end)
		end)

		local function applyRewardSnapshot(p)
			if p == nil then
				v24:SetValue("No reward poll cached on this server.")

				for _, v25 in v21 do
					v25:SetVisible(false)
				end
			else
				v24:SetValue((`{p.question}`))

				for k, v25 in v21 do
					local choice = p.choices[k]

					if choice then
						local text = choice.text

						if not (#text <= 28) then
							text = string.sub(text, 1, 28) .. "..."
						end

						v25:SetButtonText((`Give to: {text}`))
						v25:SetVisible(true)
					else
						v25:SetVisible(false)
					end
				end
			end
		end

		fn = function()
			if flag or not clientEvent3 then
				return
			end

			clientEvent3:Fire({}):andThen(function(p)
				if flag then
					return
				end

				applyRewardSnapshot(p)
			end):catch(function()
				if flag then
					return
				end

				v24:SetValue("No reward poll cached on this server.")

				for _, v25 in v21 do
					v25:SetVisible(false)
				end
			end)
		end

		local function requestRewardBroadcast(winningChoiceIndex: number)
			if v22 or flag then
				return
			end

			if not clientEvent4 then
				NotificationSystem:ShowGeneralNotification("Reward remote unavailable", color2, 4)
				return
			end

			local v25 = kind ~= "item" and "" or v[v10]

			if kind == "item" and (v25 == nil or v25 == "") then
				NotificationSystem:ShowGeneralNotification("Select a valid item.", color2, 4)
				return
			end

			v22 = true
			clientEvent4:Fire({
				winningChoiceIndex = winningChoiceIndex,
				kind = kind,
				amount = amount,
				itemKey = v25 or "",
				tier = kind ~= "item" and 0 or v20
			}):andThen(function(p2)
				v22 = false

				if flag then
					return
				end

				local success

				if p2 == nil then
					success = false
				else
					success = p2.success
				end

				local v26 = not p2 and "Reward request was rejected." or p2.message
				local v28

				if success then
					v28 = color
				else
					v28 = color2
				end

				NotificationSystem:ShowGeneralNotification(v26, v28, 4)
			end):catch(function(p2)
				v22 = false

				if flag then
					return
				end

				NotificationSystem:ShowGeneralNotification(`Reward broadcast failed: {tostring(p2)}`, color2, 4)
			end)
		end

		for i = 1, 6 do
			local v25 = i
			v21[i] = object:AddButton(function(object2)
				object2:SetButtonText((`Give to choice {v25}`)):SetYSize(22):SetVisible(false):SetEnabledPermission("cui.liveops.manage"):DoNeedConfirmation(true):SetButtonCallback(function()
					requestRewardBroadcast(v25)
				end)
			end)
		end

		object:AddTitle(function(object2)
			object2:SetTitle("Developer Note")
		end)
		object:AddText(function(object2)
			object2:SetText([[
Polls should never be created on multiple servers, only 1 "admin server" should own a voting session.
Poll duration shouldn't be below 30s, the lower the duration, the more vote may get lost in the process.
Shard could should be around 128 on production, make sure to check with the dev for the numbers, this number is modifiable for testing place tests.
Reward polls keep votes on each server for 1 hour. Starting another reward poll replaces that cache. Rewards go only to players still on the server they voted on at payout time.]])
			object2:SetAutoResize(true)
		end)
		fn()
		v12:GetUI().Destroying:Connect(function()
			flag = true
			count += 1
		end)
	end
}