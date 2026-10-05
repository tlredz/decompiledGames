local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CUI)
local Config = require(script.Parent.Config)
local Remotes = require(script.Parent.Remotes)
require(script.Parent.Types)

local function describeTarget(p)
	if p == nil then
		return "Gift target: none"
	end

	if p.player then
		return string.format("Gift target: %s", p.name)
	end

	return string.format("Gift target: %s (offline)", p.name)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatDuration(p: number)
	local v = p // 86400
	local v2 = p % 86400 // 3600
	local v3 = p % 3600 // 60

	if v > 0 then
		return (`{v}d {v2}h`)
	end

	if v2 > 0 then
		return (`{v2}h {v3}m`)
	end

	return (`{v3}m`)
end

local function describeQuota(data)
	local v = string.format("%d/%d left", data.remaining, data.quota)

	if not (data.periodStart > 0) then
		return v
	end

	local v2 = math.max(0, data.periodSeconds - (os.time() - data.periodStart))
	local v4 = formatDuration(v2) -- equivalent call inferred; original call site unknown
	return v .. string.format("  ·  resets in %s", v4)
end

local function resolveUser(p: string)
	local selected = tonumber(p)

	if selected then
		local success, nameFromUserIdAsync = pcall(Players.GetNameFromUserIdAsync, Players, selected)

		if not success then
			selected = nil
		end

		if success then
			return selected, nameFromUserIdAsync
		end

		return selected, nil
	else
		local success, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, Players, p)

		if not success then
			userIdFromNameAsync = nil
		end

		if success then
			return userIdFromNameAsync, p
		end

		return userIdFromNameAsync, nil
	end
end

return {
	build = function(object, data)
		local v = ""
		local v2 = false
		local v3 = {}
		local fn
		local v4 = nil
		object:AddSplit(function(object2)
			object2:SetRightSizeAbsolute(130)
			v4 = object2.LeftComponents:AddText(function(object3)
				object3:SetText("Gift target: none")
			end)
			object2.RightComponents:AddButton(function(object3)
				object3:SetButtonText("Choose player"):SetButtonCallback(data.openPlayerPicker)
			end)
		end)

		local function setOfflineTarget()
			local v5 = string.match(v, "^%s*(.-)%s*$")

			if v5 == "" then
				data.setStatus("Enter a username or UserId", true)
			elseif not v2 then
				v2 = true
				data.setStatus(string.format("Looking up %s...", v5), false)
				local userIdFromNameAsync = tonumber(v5)
				local nameFromUserIdAsync

				if userIdFromNameAsync then
					local success
					success, nameFromUserIdAsync = pcall(Players.GetNameFromUserIdAsync, Players, userIdFromNameAsync)

					if not success then
						userIdFromNameAsync = nil
					end

					if not success then
						nameFromUserIdAsync = nil
					end
				else
					local success
					success, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, Players, v5)

					if not success then
						userIdFromNameAsync = nil
					end

					if success then
						nameFromUserIdAsync = v5
					end
				end

				v2 = false

				if userIdFromNameAsync and nameFromUserIdAsync then
					data.setTarget({
						userId = userIdFromNameAsync,
						name = nameFromUserIdAsync,
						player = Players:GetPlayerByUserId(userIdFromNameAsync)
					})
					data.setStatus(
						string.format("Offline target: %s [%d]", nameFromUserIdAsync, userIdFromNameAsync),
						false
					)
				else
					data.setStatus(string.format("No Roblox user matches \"%s\"", v5), true)
				end
			end
		end

		object:AddSplit(function(object2)
			object2:SetRightSizeAbsolute(130)
			object2.LeftComponents:AddField(function(object3)
				object3:SetTextVisible(false):SetPlaceholder("Offline username or UserId"):SetValue(""):SetOnChangedRaw(function(p)
					v = p
				end)
			end)
			object2.RightComponents:AddButton(function(object3)
				object3:SetButtonText("Set offline target"):SetButtonCallback(setOfflineTarget)
			end)
		end)
		local v5 = object:AddText(function(object2)
			object2:SetText("You cannot gift treadmills"):SetVisible(false)
		end)
		local v6 = object:AddBox(function() end)
		object:AddButton(function(object2)
			object2:SetButtonText("↺ Refresh quotas"):SetButtonCallback(function()
				fn()
			end)
		end)
		local v7 = object:AddTitle(function(object2)
			object2:SetTitle("Candy self-gift")
		end)
		local v8 = object:AddButton(function(object2)
			object2:SetButtonText("Gift Candy Treadmill to myself"):SetButtonCallback(function()
				Remotes.selfGiftCandy:request():andThen(function(p)
					data.report(p, true)
					fn()
				end):catch(data.reportError)
			end)
		end)

		local function gift(p)
			local target = data.getTarget()

			if target == nil then
				data.setStatus("Select a player or set an offline target first", true)
			else
				Remotes.giftTreadmill:request(p.tag, target.userId):andThen(function(p2)
					data.report(p2, true)

					if p2.success and target.player == nil and data.getTarget() == target then
						data.setTarget(nil)
					end

					fn()
				end):catch(data.reportError)
			end
		end

		local function renderGiftState(data2)
			for _, v9 in v6.Components:GetAll() do
				v9:Destroy()
			end

			table.clear(v3)
			v5:SetVisible(not data2.canGift)

			if data2.canGift then
				for _, treadmill in data2.treadmills do
					local v9 = treadmill
					v6.Components:AddSplit(function(p)
						p.LeftComponents:AddButton(function(object2)
							object2:SetButtonText(string.format("Gift %s", v9.label)):SetButtonCallback(function()
								gift(v9)
							end)
							object2:SetEnabled(v9.remaining > 0)
						end)
						p.RightComponents:AddText(function(object2)
							local v10 = object2:SetText((describeQuota(v9)))
							local v11

							if v9.remaining > 0 then
								v11 = Config.SUCCESS_COLOR
							else
								v11 = Config.ERROR_COLOR
							end

							v10:SetTextColor(v11)
							v3[object2] = v9
						end)
					end)
				end
			end

			v7:SetVisible(data2.canSelfGiftCandy)
			v8:SetVisible(data2.canSelfGiftCandy)
			v8:SetButtonText(data2.ownsCandy and "✓ Candy Treadmill owned" or "Gift Candy Treadmill to myself")
			v8:SetEnabled(not data2.ownsCandy)
		end

		fn = function()
			Remotes.getGiftState:request():andThen(renderGiftState):catch(data.reportError)
		end

		local targetChangedConnection = data.targetChanged:Connect(function()
			v4:SetText(describeTarget(data.getTarget()))
		end)
		v4:GetUI().Destroying:Connect(function()
			targetChangedConnection:Disconnect()
		end)
		return {
			refresh = fn,
			tick = function()
				for k, v9 in v3 do
					k:SetText((describeQuota(v9)))
				end
			end
		}
	end
}