local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdminGiveAll = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminGiveAll)
local CodeRedemption = require(ReplicatedStorage._FRAMEWORK.Features.CodeRedemption)
require(ReplicatedStorage._FRAMEWORK.Features.CodeRedemption.Types)
local CUI = require(ReplicatedStorage.CUI)
local Items = require(ReplicatedStorage.FeatureConfigs.Items)
local KnownUsers = require(ReplicatedStorage.Cmdr.Menus.AdminMenu.KnownUsers)
require(ReplicatedStorage.Utilities.Promise)
local Skins = require(ReplicatedStorage.FeatureConfigs.PersonalTreadmill.Skins)
local PersonalTreadmill = require(ReplicatedStorage.FeatureConfigs.PersonalTreadmill)
local color = Color3.fromRGB(100, 255, 100)
local color2 = Color3.fromRGB(255, 100, 100)
local limits = CodeRedemption.getLimits()
local v = {}
local values = {}
local v2 = {
	"Wins",
	"Item",
	"Treadmill skin",
	"Treadmill"
}
local v3 = {
	Wins = "wins",
	Item = "item",
	["Treadmill skin"] = "treadmillSkin",
	Treadmill = "treadmill"
}
local v4 = { "None", "Owner", "Custom" }

for _, v5 in AdminGiveAll.getItems() do
	local formatted = `{v5.displayName} [{v5.rarity}] - {v5.key}`
	v[formatted] = v5.key
	table.insert(values, formatted)
end

local v5 = {}
local values2 = {}

for k, v6 in Skins.SKINS do
	local formatted = `{v6.displayName} - {k}`
	v5[formatted] = k
	table.insert(values2, formatted)
end

table.sort(values2)
local v6 = {}

for k in PersonalTreadmill.TIER_ENTITLEMENTS do
	table.insert(v6, k)
end

table.sort(v6)
local v7 = {}

for i = 0, Items.MAX_TIER do
	table.insert(v7, (tostring(i)))
end

local function describeReward(data)
	if data.kind == "wins" then
		return (`Wins x{data.amount}`)
	end

	if data.kind == "item" then
		local v8 = not data.signature and "" or ` signed {data.signature}`
		return (`{data.itemKey} T{data.tier} x{data.amount}{v8}`)
	end

	if data.kind == "treadmillSkin" then
		return (`Skin {data.skinKey}`)
	end

	return (`Treadmill {data.treadmillTier}`)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function describeCode(data)
	local v8 = data.maxUses == 0 and "unlimited" or `{data.uses}/{data.maxUses}`
	local v9 = data.active and "active" or "revoked"
	return (`{data.id} - {data.label} [{v9}, {v8}]`)
end

local function build(p)
	local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
	local localPlayer = Players.LocalPlayer
	local clone = table.clone(KnownUsers)
	clone[localPlayer.Name] = localPlayer.UserId
	local clone2 = {}
	local flag = false
	local id = ""
	local label = ""
	local userId = tostring(localPlayer.UserId)
	local maxUses = 0
	local expiresInHours = 0
	local active = true
	local flag2 = false
	local v9 = "wins"
	local amount = 1
	local v11 = values[1] or ""
	local tier = 0
	local amount2 = 1
	local v14 = "None"
	local v15 = ""
	local v16 = values2[1] or ""
	local treadmillTier = v6[1] or ""
	local v18 = nil
	local v19 = nil
	local v20 = nil
	local v21 = nil
	local v22 = nil
	local v23 = nil
	local v24 = nil
	local v25 = nil
	local v26 = nil
	local v27 = nil
	local v28 = nil
	local v29 = nil
	local v30 = nil
	local v31 = nil
	local v32 = nil
	local v33 = nil
	local v34 = nil
	local v35 = nil
	local v36 = nil
	local fn
	local fn2

	-- equivalent calls inferred from this helper; original call sites unknown
	local function notify(message: string, ok: boolean)
		local v38

		if ok then
			v38 = color
		else
			v38 = color2
		end

		NotificationSystem:ShowGeneralNotification(message, v38, 5)
	end

	local function refreshRewardFields()
		v26:SetVisible(v9 == "wins")
		v27:SetVisible(v9 == "item")
		v28:SetVisible(v9 == "item")
		v29:SetVisible(v9 == "item")
		v30:SetVisible(v9 == "item")
		v31:SetVisible(v9 == "item" and v14 == "Custom")
		v32:SetVisible(v9 == "treadmillSkin")
		v33:SetVisible(v9 == "treadmill")
	end

	local function loadRecord(data)
		flag = true
		id = data.id
		label = data.label
		userId = tostring(data.ownerUserId)
		maxUses = data.maxUses
		expiresInHours = not (data.expiresAt > 0) and 0 or math.max(0, (math.ceil((data.expiresAt - os.time()) / 3600)))
		active = data.active
		clone2 = table.clone(data.rewards)
		v20:SetValue(id)
		v21:SetValue(label)
		v22:SetValue(userId)
		v23:SetValue(maxUses)
		v24:SetValue(expiresInHours)
		v25:SetValue(active)
		v19:SetTitle((`Editing {data.id}`))
		v36:SetButtonText("Save code")
		fn()
		v18:OpenTab("Editor")
	end

	local function resetEditor()
		flag = false
		id = ""
		label = ""
		userId = tostring(localPlayer.UserId)
		maxUses = 0
		expiresInHours = 0
		active = true
		clone2 = {}
		v20:SetValue("")
		v21:SetValue("")
		v22:SetValue(userId)
		v23:SetValue(0)
		v24:SetValue(0)
		v25:SetValue(true)
		v19:SetTitle("New code")
		v36:SetButtonText("Create code")
		fn()
	end

	local function fn3()
		CodeRedemption.admin.list():andThen(function(p2)
			fn2(p2.codes or {})
		end):catch(function(p2)
			NotificationSystem:ShowGeneralNotification(`Could not list codes: {tostring(p2)}`, color2, 5)
		end)
	end

	local function sendWrite()
		local ownerUserId = tonumber(userId)

		if flag2 then
			return
		end

		if ownerUserId == nil or ownerUserId < 1 or ownerUserId % 1 ~= 0 then
			NotificationSystem:ShowGeneralNotification("The owner UserId is invalid", color2, 5)
			return
		end

		flag2 = true
		local v38 = {
			id = CodeRedemption.normalizeCode(id),
			label = label,
			ownerUserId = ownerUserId,
			rewards = clone2,
			maxUses = maxUses,
			active = active,
			expiresInHours = expiresInHours
		}
		local v39

		if flag then
			v39 = CodeRedemption.admin.update(v38)
		else
			v39 = CodeRedemption.admin.create(v38)
		end

		v39:andThen(function(p2)
			flag2 = false
			notify(p2.message, p2.ok) -- equivalent call inferred; original call site unknown

			if p2.ok then
				fn3()
			end
		end):catch(function(p2)
			flag2 = false
			NotificationSystem:ShowGeneralNotification(`Code request failed: {tostring(p2)}`, color2, 5)
		end)
	end

	local function sendCodeAction(callback, p2: string)
		local code = CodeRedemption.normalizeCode(id)

		if flag2 or code == "" then
			return
		end

		flag2 = true
		callback(code):andThen(function(p3)
			flag2 = false
			notify(p3.message, p3.ok) -- equivalent call inferred; original call site unknown

			if p3.ok then
				fn3()
			end
		end):catch(function(p3)
			flag2 = false
			NotificationSystem:ShowGeneralNotification(`{p2} failed: {tostring(p3)}`, color2, 5)
		end)
	end

	local function buildEditor(componentCtn)
		v19 = componentCtn:AddTitle(function(object)
			object:SetTitle("New code")
		end)
		componentCtn:AddSplit(function(object)
			object:SetLeftSizePercent(0.65)
			v20 = object.LeftComponents:AddField(function(object2)
				object2:SetTextVisible(false):SetPlaceholder("CODE..."):SetCustomFilter(function(p2)
					return (string.sub(CodeRedemption.normalizeCode(p2), 1, limits.MAX_CODE_LENGTH))
				end):SetOnChangedRaw(function(p2)
					id = p2
				end)
			end)
			object.RightComponents:AddButton(function(object2)
				object2:SetButtonText("Generate"):SetYSize(22):SetButtonCallback(function()
					id = CodeRedemption.generateCode()
					v20:SetValue(id)
				end)
			end)
		end)
		v21 = componentCtn:AddField(function(object)
			object:SetText("Label"):SetPlaceholder("shown to the player..."):SetOnChangedRaw(function(value)
				label = string.sub(value, 1, limits.MAX_LABEL_LENGTH)
			end)
		end)
		local v37 = nil
		componentCtn:AddSplit(function(object)
			object:SetLeftSizePercent(0.5)
			v37 = object.LeftComponents:AddDropdown(function(object2)
				object2:SetTextVisible(false):SetOnChanged(function(p2)
					local v38 = clone[p2]

					if v38 then
						userId = tostring(v38)
						v22:SetValue(userId)
					end
				end)
			end)
			v22 = object.RightComponents:AddField(function(object2)
				object2:SetTextVisible(false):SetPlaceholder("owner UserId..."):SetValue(userId):SetOnChangedRaw(function(p2)
					userId = p2
				end)
			end)
		end)
		local v38 = {}

		for k in clone do
			table.insert(v38, k)
		end

		table.sort(v38)
		v37:SetChoiceList(v38):SetSelected(localPlayer.Name)
		componentCtn:AddSplit(function(p2)
			v23 = p2.LeftComponents:AddNumberField(function(object)
				object:SetText("Max uses"):SetValue(0):SetNumberFilter(0, limits.MAX_USES):SetOnChangedUnfocus(function(p3)
					maxUses = math.clamp(math.floor(p3), 0, limits.MAX_USES)
				end)
			end)
			v24 = p2.RightComponents:AddNumberField(function(object)
				object:SetText("Expiry (h)"):SetValue(0):SetNumberFilter(0, limits.MAX_EXPIRY_HOURS):SetOnChangedUnfocus(function(p3)
					expiresInHours = math.clamp(math.floor(p3), 0, limits.MAX_EXPIRY_HOURS)
				end)
			end)
		end)
		componentCtn:AddText(function(object)
			object:SetAutoResize(true):SetText("0 max uses = unlimited, and costs no DataStore write. 0 expiry = never. A capped code shares one universe-wide write budget with every other capped code.")
		end)
		v25 = componentCtn:AddCheckbox(function(object)
			object:SetText("Active"):SetValue(true):SetOnChanged(function(p2)
				active = p2
			end)
		end)
		componentCtn:AddExpandable(function(object)
			object:SetText("Rewards")
			local components = object.Components
			components:AddDropdown(function(object2)
				object2:SetText("Kind"):SetChoiceList(v2):SetSelected(v2[1]):SetOnChanged(function(p2)
					v9 = v3[p2] or "wins"
					refreshRewardFields()
				end)
			end)
			v26 = components:AddShortenedNumberField(function(object2)
				object2:SetText("Wins"):SetValue(1):SetNumberFilter(1, limits.MAX_WINS_PER_REWARD):SetOnChangedUnfocus(function(p2)
					amount = math.clamp(math.floor(p2), 1, limits.MAX_WINS_PER_REWARD)
				end)
			end)
			components:AddText(function(object2)
				object2:SetAutoResize(true):SetText("Wins land in the galaxy of the server where the code is claimed.")
			end)
			v27 = components:AddDropdown(function(object2)
				object2:SetText("Item"):SetChoiceList(values):SetSelected(v11):SetOnChanged(function(p2)
					v11 = p2
				end)
			end)
			v28 = components:AddDropdown(function(object2)
				object2:SetText("Tier"):SetChoiceList(v7):SetSelected("0"):SetOnChanged(function(p2)
					tier = tonumber(p2) or 0
				end)
			end)
			v29 = components:AddNumberField(function(object2)
				object2:SetText("Amount"):SetValue(1):SetNumberFilter(1, limits.MAX_ITEM_AMOUNT):SetOnChangedUnfocus(function(p2)
					amount2 = math.clamp(math.floor(p2), 1, limits.MAX_ITEM_AMOUNT)
				end)
			end)
			v30 = components:AddDropdown(function(object2)
				object2:SetText("Signature"):SetChoiceList(v4):SetSelected("None"):SetOnChanged(function(p2)
					v14 = p2
					refreshRewardFields()
				end)
			end)
			v31 = components:AddField(function(object2)
				object2:SetText("Signature UserId"):SetPlaceholder("UserId..."):SetOnChangedRaw(function(p2)
					v15 = p2
				end)
			end)
			v32 = components:AddDropdown(function(object2)
				object2:SetText("Skin"):SetChoiceList(values2):SetSelected(v16):SetOnChanged(function(p2)
					v16 = p2
				end)
			end)
			v33 = components:AddDropdown(function(object2)
				object2:SetText("Treadmill"):SetChoiceList(v6):SetSelected(treadmillTier):SetOnChanged(function(p2)
					treadmillTier = p2
				end)
			end)
			components:AddButton(function(object2)
				object2:SetButtonText("Add reward"):SetYSize(22):SetButtonCallback(function()
					if #clone2 >= limits.MAX_REWARDS_PER_CODE then
						NotificationSystem:ShowGeneralNotification(
							`A code carries at most {limits.MAX_REWARDS_PER_CODE} rewards`,
							color2,
							5
						)
					else
						local v39 = {
							kind = "wins",
							amount = amount
						}
						local v40

						if v9 == "item" then
							local signature = nil

							if v14 == "Owner" then
								signature = tonumber(userId)
							elseif v14 == "Custom" then
								signature = tonumber(v15)
							end

							v40 = {
								kind = "item",
								itemKey = v[v11],
								tier = tier,
								amount = amount2,
								signature = signature
							}
						elseif v9 == "treadmillSkin" then
							v40 = {
								kind = "treadmillSkin",
								skinKey = v5[v16]
							}
						else
							v40 = v9 == "treadmill" and {
								kind = "treadmill",
								treadmillTier = treadmillTier
							} or v39
						end

						table.insert(clone2, v40)
						fn()
					end
				end)
			end)
			v34 = components:AddList(function(object2)
				object2:SetSizeY(110)
			end)
		end)

		fn = function()
			for _, v39 in v34.Components:GetAll() do
				v39:Destroy()
			end

			for k, v39 in clone2 do
				local v40 = k
				local v41 = v39
				v34.Components:AddButton(function(object)
					object:SetButtonText((`{v40}. {describeReward(v41)}  (remove)`)):SetYSize(22):SetButtonCallback(function()
						table.remove(clone2, v40)
						fn()
					end)
				end)
			end
		end

		componentCtn:AddSplit(function(p2)
			v36 = p2.LeftComponents:AddButton(function(object)
				object:SetButtonText("Create code"):SetYSize(22):SetButtonCallback(sendWrite)
				object:SetEnabledPermission("cui.admin.codes.create")
			end)
			p2.RightComponents:AddButton(function(object)
				object:SetButtonText("New"):SetYSize(22):SetButtonCallback(resetEditor)
			end)
		end)
		componentCtn:AddSplit(function(p2)
			p2.LeftComponents:AddButton(function(object)
				object:SetButtonText("Revoke"):SetYSize(22):DoNeedConfirmation(true):SetButtonCallback(function()
					sendCodeAction(CodeRedemption.admin.revoke, "Revoke")
				end)
				object:SetEnabledPermission("cui.admin.codes.revoke")
			end)
			p2.RightComponents:AddButton(function(object)
				object:SetButtonText("Delete"):SetYSize(22):DoNeedConfirmation(true):SetButtonCallback(function()
					sendCodeAction(CodeRedemption.admin.delete, "Delete")
				end)
				object:SetEnabledPermission("cui.admin.codes.revoke")
			end)
		end)
	end

	local function buildList(componentCtn)
		componentCtn:AddTitle(function(object)
			object:SetTitle("Existing codes")
		end)
		componentCtn:AddText(function(object)
			object:SetAutoResize(true):SetText("Uses are counted as reserved, not delivered: a crashed server keeps its block.")
		end)
		componentCtn:AddButton(function(object)
			object:SetButtonText("Refresh"):SetYSize(22):SetButtonCallback(function()
				fn3()
			end)
		end)
		v35 = componentCtn:AddList(function(object)
			object:SetSizeY(260)
		end)

		fn2 = function(codes)
			for _, v37 in v35.Components:GetAll() do
				v37:Destroy()
			end

			for _, item in codes do
				local v37 = item
				v35.Components:AddButton(function(object)
					object:SetButtonText(describeCode(v37)):SetYSize(22):SetButtonCallback(function()
						loadRecord(v37)
					end)
				end)
			end
		end
	end

	p.Components:AddTab(function(object)
		v18 = object
		object:SetTabs({ "Editor", "Codes" })
		buildEditor(object:GetComponentCtn("Editor"))
		buildList(object:GetComponentCtn("Codes"))
		object:SetOnTabChanged(function(p2: string)
			if p2 == "Codes" then
				fn3()
			end
		end)
	end)
	refreshRewardFields()
	fn()
end

return {
	Open = function()
		CUI.GetWindow("Codes", 400, build):SetVisible(true)
	end
}