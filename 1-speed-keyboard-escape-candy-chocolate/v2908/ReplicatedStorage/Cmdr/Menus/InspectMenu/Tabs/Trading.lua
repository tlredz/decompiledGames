local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CUI = require(ReplicatedStorage.CUI)
local TradingAccess = require(script.Parent.Parent.TradingAccess)
require(ReplicatedStorage.Cmdr.Menus.InspectMenu.Types)
local destroyComponents

destroyComponents = function(components)
	for _, v in components:GetAll() do
		if CUI.IsComponentType(v, "Expandable") then
			destroyComponents(v.Components)
		end

		v:Destroy()
	end
end

local function formatOffer(list)
	if #list == 0 then
		return "None"
	end

	local v = {}

	for _, v2 in list do
		table.insert(v, (`{v2.displayName} [Tier {v2.tier}] x{v2.amount}`))
	end

	return table.concat(v, "\n")
end

local function matchesSearch(data, p: string)
	if p == "" then
		return true
	end

	local v = ""

	for _, v2 in {
		data.index,
		data.contractId,
		data.otherUserId,
		data.worldIndex,
		data.timestamp,
		data.details,
		formatOffer(data.given),
		formatOffer(data.received)
	} do
		v ..= ` {tostring(v2)}`
	end

	return string.find(string.lower(v), p, 1, true) ~= nil
end

return {
	DisplayName = "Trading",
	Permission = "cui.inspect.moderation",
	Order = 55,
	Setup = function(object, data)
		local NotificationSystem

		if RunService:IsClient() then
			NotificationSystem = require(ReplicatedStorage.NotificationSystem)
		else
			NotificationSystem = nil
		end

		local history = {}
		local v = ""
		local tradeBanned = false
		local editable = false

		local function fn() end

		local v2 = {}
		local v3 = {}
		local v4 = {}
		local v5 = {}
		local count = 0

		local function getRowTitle(p)
			return (`Trade #{p.index} | {v2[p.otherUserId] or "Loading..."} ({p.otherUserId})`)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function requestUsername(otherUserId: number)
			if RunService:IsServer() or otherUserId <= 0 or v2[otherUserId] or v3[otherUserId] then
				return
			end

			v3[otherUserId] = true
			task.spawn(function()
				local success, nameFromUserIdAsync = pcall(Players.GetNameFromUserIdAsync, Players, otherUserId)
				v3[otherUserId] = nil
				v2[otherUserId] = (not success or type(nameFromUserIdAsync) ~= "string") and "Unknown" or nameFromUserIdAsync
				local v6 = v5[otherUserId]

				if v6 then
					for k, v7 in v6 do
						k:SetText((`Trade #{v7.index} | {v2[v7.otherUserId] or "Loading..."} ({v7.otherUserId})`))
					end
				end
			end)
		end

		local function notify(p: string, flag: boolean)
			if not NotificationSystem or p == "" then
				return
			end

			local v6

			if flag then
				v6 = Color3.fromRGB(100, 255, 100)
			else
				v6 = Color3.fromRGB(255, 100, 100)
			end

			NotificationSystem:ShowGeneralNotification(p, v6, 4)
		end

		object:AddTitle(function(object2)
			object2:SetTitle("Trading controls")
		end)
		local v6 = nil
		local v7 = nil
		object:AddSplit(function(p)
			v6 = p.LeftComponents:AddCheckbox(function(object2)
				object2:SetText("Trading ban"):SetValue(false):SetEnabled(false):SetEnabledPermission("cui.inspect.moderation")
			end)
			v7 = p.RightComponents:AddNumberField(function(object2)
				object2:SetText("Completed trades"):SetValue(0):SetEnabled(false)
			end)
		end)
		object:AddTitle(function(object2)
			object2:SetTitle("Trading history")
		end)
		object:AddField(function(object2)
			object2:SetTextVisible(false):SetPlaceholder("search..."):SetOnChangedRaw(function(value)
				v = string.lower(value)
				fn()
			end)
		end)
		local v8 = object:AddList(function(object2)
			object2:SetSizeY(265)
		end)

		local function applyResponse(data2, flag: boolean?)
			tradeBanned = data2.tradeBanned
			editable = data2.editable
			history = data2.history
			v6:SetValue(tradeBanned):SetEnabled(editable)
			v7:SetValue(#history)
			fn()

			if flag == true then
				notify(data2.message, data2.ok)
			elseif not data2.ok then
				data.NotifyProfileError(data2.message)
			end
		end

		local function refresh()
			if RunService:IsServer() or not TradingAccess.getTrading then
				return
			end

			TradingAccess.getTrading:Fire({
				userId = data.UserId
			}):andThen(applyResponse):catch(function(p)
				notify(`Failed to load trading data: {tostring(p)}`, false)
			end)
		end

		v6:SetOnChanged(function(banned)
			if editable and TradingAccess.setTradeBanned then
				v6:SetEnabled(false)
				TradingAccess.setTradeBanned:Fire({
					userId = data.UserId,
					banned = banned
				}):andThen(function(data2)
					tradeBanned = data2.tradeBanned
					editable = data2.editable
					history = data2.history
					v6:SetValue(tradeBanned):SetEnabled(editable)
					v7:SetValue(#history)
					fn()
					notify(data2.message, data2.ok)

					if data2.ok then
						data.ProfileChanged:Fire("TradeBanned")
					end
				end):catch(function(p2)
					v6:SetValue(tradeBanned):SetEnabled(editable)
					notify(`Failed to update trading ban: {tostring(p2)}`, false)
				end)
			else
				v6:SetValue(tradeBanned)
			end
		end)

		local function buildTradeDetails(object2, data2)
			object2.Components:AddSplit(function(p)
				p.LeftComponents:AddNumberField(function(object3)
					object3:SetText("Partner UserId"):SetValue(data2.otherUserId):SetEnabled(false)
				end)
				p.RightComponents:AddField(function(object3)
					object3:SetText("World"):SetValue((tostring(data2.worldIndex))):SetEnabled(false)
				end)
			end)
			object2.Components:AddField(function(object3)
				object3:SetText("Contract ID"):SetValue(data2.contractId):SetEnabled(false)
			end)

			if data2.timestamp > 0 then
				object2.Components:AddTime(function(object3)
					object3:SetText("Completed at"):SetTime(data2.timestamp):SetEnabled(false)
				end)
			end

			object2.Components:AddText(function(object3)
				object3:SetText((`Given:\n{formatOffer(data2.given)}`)):SetAutoResize(true)
			end)
			object2.Components:AddText(function(object3)
				object3:SetText((`Received:\n{formatOffer(data2.received)}`)):SetAutoResize(true)
			end)

			if data2.details ~= "" then
				object2.Components:AddText(function(object3)
					object3:SetText((`Additional data: {data2.details}`)):SetAutoResize(true)
				end)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function addTradeRow(p)
			v8.Components:AddExpandable(function(object2)
				local v9 = false

				if not v5[p.otherUserId] then
					v5[p.otherUserId] = {}
				end

				v5[p.otherUserId][object2] = p
				requestUsername(p.otherUserId) -- equivalent call inferred; original call site unknown
				local v10 = p
				object2:SetText((`Trade #{v10.index} | {v2[v10.otherUserId] or "Loading..."} ({v10.otherUserId})`))
				object2:BindOnExpanded(function(p2)
					if p2 and not v9 then
						v9 = true
						buildTradeDetails(object2, p)
					end
				end)
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function renderRows()
			local v9 = count
			task.spawn(function()
				for _, v10 in v4 do
					if v9 ~= count then
						break
					end

					addTradeRow(v10) -- equivalent call inferred; original call site unknown
					RunService.RenderStepped:Wait()
				end
			end)
		end

		fn = function()
			count += 1
			destroyComponents(v8.Components)
			table.clear(v5)
			table.clear(v4)

			for i = #history, 1, -1 do
				if matchesSearch(history[i], v) then
					table.insert(v4, history[i])
				end
			end

			if #v4 == 0 then
				v8.Components:AddText(function(object2)
					object2:SetText(#history == 0 and "No completed trades recorded." or "No trades match this search.")
					object2:SetTextColor(Color3.fromRGB(160, 160, 160)):SetYSize(22)
				end)
				return
			end

			renderRows() -- equivalent call inferred; original call site unknown
		end

		object:AddButton(function(object2)
			object2:SetButtonText("Refresh trading data"):SetYSize(22):SetEnabledPermission("cui.inspect.moderation"):SetButtonCallback(refresh)
		end)
		v8:GetUI().Destroying:Connect(function()
			count += 1
		end)
		data.PresenceChanged:Connect(refresh)
		data.ProfileChanged:Connect(function(p)
			if p == "TradeBanned" then
				refresh()
			end
		end)
		fn()
		refresh()
	end
}