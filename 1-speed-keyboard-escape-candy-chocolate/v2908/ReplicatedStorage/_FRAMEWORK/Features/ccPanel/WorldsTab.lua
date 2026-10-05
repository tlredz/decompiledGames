local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CUI)
local Config = require(script.Parent.Config)
local Remotes = require(script.Parent.Remotes)
require(script.Parent.Types)
local v = {
	no_access = "%s has no CC Worlds access",
	inbox_full = "%s has too many pending invites",
	duplicate = "%s already has an invite from you"
}
return {
	build = function(object, data, flag: boolean)
		local v2 = ""
		local inviteId = nil
		local v3 = ""
		local v4 = 0
		local v5 = {}
		local v6 = {}
		local v7 = object:AddText(function(object2)
			object2:SetText("Teleport to your reserved CC World")
		end)
		local v8 = object:AddBox(function() end)

		local function teleport(p: number)
			data.setStatus(string.format("Teleporting to World %d...", p), false)
			Remotes.teleportToWorld:request(p):andThen(function(p2)
				if not p2.success then
					data.report(p2, false)
				end
			end):catch(data.reportError)
		end

		local v9 = object:AddButton(function(object2)
			object2:SetButtonText("⬅ Back to main game"):SetButtonCallback(function()
				data.setStatus("Returning to the main game...", false)
				Remotes.returnToMainGame:request():andThen(function(p)
					if not p.success then
						data.report(p, false)
					end
				end):catch(data.reportError)
			end)
		end)

		local function sendInvite()
			local v10 = string.match(v2, "^%s*(.-)%s*$")

			if string.match(v10, Config.USERNAME_PATTERN) == nil then
				data.setStatus("Enter a valid Roblox username", true)
			else
				Remotes.sendInvite:request(v10):andThen(function(data2)
					data.report(data2, false)

					if data2.success then
						inviteId = data2.inviteId
						v3 = v10
						v4 = os.clock() + data2.ackWindow
					end
				end):catch(data.reportError)
			end
		end

		local v10 = object:AddSplit(function(object2)
			object2:SetRightSizeAbsolute(110)
			object2.LeftComponents:AddField(function(object3)
				object3:SetTextVisible(false):SetPlaceholder("Username of the CC to invite"):SetValue(""):SetOnChangedRaw(function(p)
					v2 = p
				end)
			end)
			object2.RightComponents:AddButton(function(object3)
				object3:SetButtonText("Invite"):SetButtonCallback(sendInvite)
			end)
		end)
		object:AddTitle(function(object2)
			object2:SetTitle("Sandbox tools")
		end)
		local v11 = nil
		local v12 = nil
		object:AddSplit(function(p)
			v11 = p.LeftComponents:AddNumberField(function(object2)
				object2:SetText("Amount"):SetNumberFilter(1, Config.MAX_GIVE_AMOUNT):SetValue(1)
			end)
			v12 = p.RightComponents:AddSlider(function(object2)
				object2:SetText("Stars ★"):SetRange(0, Config.MAX_ITEM_TIER):SetIncrement(1):SetValue(0)
			end)
		end)
		object:AddText(function(object2)
			object2:SetText("Amount and stars only apply to Items"):SetTextSize(12)
		end)

		local function getAmount()
			return (math.clamp(math.floor(v11:GetValue() or 1), 1, Config.MAX_GIVE_AMOUNT))
		end

		local function getTier()
			return (math.clamp(math.floor((v12:GetValue())), 0, Config.MAX_ITEM_TIER))
		end

		local loadCatalog

		loadCatalog = function(p)
			Remotes.getCatalog:request(p):andThen(function(items)
				local v13 = v5[p]

				for _, v14 in v13.Components:GetAll() do
					v14:Destroy()
				end

				for _, item in items do
					local v14 = item
					v13.Components:AddButton(function(object2)
						local v15

						if v14.owned then
							v15 = "✓ " .. v14.label
						else
							v15 = v14.label
						end

						object2:SetButtonText(v15):SetYSize(Config.LIST_ROW_HEIGHT):SetButtonCallback(function()
							Remotes.giveOne:request(
								p,
								v14.key,
								math.clamp(math.floor(v11:GetValue() or 1), 1, Config.MAX_GIVE_AMOUNT),
								(math.clamp(math.floor((v12:GetValue())), 0, Config.MAX_ITEM_TIER))
							):andThen(function(p2)
								data.report(p2, false)

								if p2.success then
									loadCatalog(p)
								end
							end):catch(data.reportError)
						end)
						object2:SetEnabled(v14.canGive)
					end)
				end
			end):catch(data.reportError)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function addGiveAllButton(object2, p)
			object2:AddButton(function(object3)
				object3:SetButtonText(Config.WORLD_CATEGORY_LABELS[p].giveAll):SetButtonCallback(function()
					Remotes.giveAll:request(p, (math.clamp(math.floor((v12:GetValue())), 0, Config.MAX_ITEM_TIER))):andThen(function(p2)
						data.report(p2, true)

						if p2.success then
							local v13 = p
							Remotes.getCatalog:request(v13):andThen(function(items)
								local v14 = v5[v13]

								for _, v15 in v14.Components:GetAll() do
									v15:Destroy()
								end

								for _, item in items do
									local v15 = item
									v14.Components:AddButton(function(object4)
										local v16

										if v15.owned then
											v16 = "✓ " .. v15.label
										else
											v16 = v15.label
										end

										object4:SetButtonText(v16):SetYSize(Config.LIST_ROW_HEIGHT):SetButtonCallback(function()
											Remotes.giveOne:request(
												v13,
												v15.key,
												math.clamp(math.floor(v11:GetValue() or 1), 1, Config.MAX_GIVE_AMOUNT),
												(math.clamp(math.floor((v12:GetValue())), 0, Config.MAX_ITEM_TIER))
											):andThen(function(p3)
												data.report(p3, false)

												if p3.success then
													loadCatalog(v13)
												end
											end):catch(data.reportError)
										end)
										object4:SetEnabled(v15.canGive)
									end)
								end
							end):catch(data.reportError)
						end
					end):catch(data.reportError)
				end)
			end)
		end

		local WORLD_CATEGORY_IDS = Config.WORLD_CATEGORY_IDS

		for i = 1, #WORLD_CATEGORY_IDS, 2 do
			local v13 = i
			object:AddSplit(function(p)
				addGiveAllButton(p.LeftComponents, WORLD_CATEGORY_IDS[v13]) -- equivalent call inferred; original call site unknown
				local v15 = WORLD_CATEGORY_IDS[v13 + 1]

				if v15 then
					addGiveAllButton(p.RightComponents, v15) -- equivalent call inferred; original call site unknown
				end
			end)
		end

		local v13 = object:AddTab(function(object2)
			local tabs = {}

			for _, v14 in WORLD_CATEGORY_IDS do
				local tab = Config.WORLD_CATEGORY_LABELS[v14].tab
				v6[tab] = v14
				table.insert(tabs, tab)
			end

			object2:SetTabs(tabs)

			for k, v14 in v6 do
				v5[v14] = object2:GetComponentCtn(k):AddList(function(object3)
					object3:SetSizeY(Config.CATALOG_LIST_HEIGHT)
				end)
			end

			object2:SetOnTabChanged(function(p)
				local v14 = v6[p]
				Remotes.getCatalog:request(v14):andThen(function(items)
					local v15 = v5[v14]

					for _, v16 in v15.Components:GetAll() do
						v16:Destroy()
					end

					for _, item in items do
						local v16 = item
						v15.Components:AddButton(function(object3)
							local v17

							if v16.owned then
								v17 = "✓ " .. v16.label
							else
								v17 = v16.label
							end

							object3:SetButtonText(v17):SetYSize(Config.LIST_ROW_HEIGHT):SetButtonCallback(function()
								Remotes.giveOne:request(
									v14,
									v16.key,
									math.clamp(math.floor(v11:GetValue() or 1), 1, Config.MAX_GIVE_AMOUNT),
									(math.clamp(math.floor((v12:GetValue())), 0, Config.MAX_ITEM_TIER))
								):andThen(function(p2)
									data.report(p2, false)

									if p2.success then
										loadCatalog(v14)
									end
								end):catch(data.reportError)
							end)
							object3:SetEnabled(v16.canGive)
						end)
					end
				end):catch(data.reportError)
			end)
		end)

		local function addStatSetter(p: string, p2: string, p3: number, callback)
			object:AddSplit(function(object2)
				object2:SetRightSizeAbsolute(110)
				local v14 = object2.LeftComponents:AddShortenedNumberField(function(object3)
					object3:SetTextVisible(false):SetPlaceholder(p2):SetNumberFilter(0, p3)
				end)
				object2.RightComponents:AddButton(function(object3)
					object3:SetButtonText("Set " .. p):SetButtonCallback(function()
						local value = v14:GetValue()

						if value == nil then
							data.setStatus("Type a number first", true)
						else
							callback((math.floor(value)))
						end
					end)
				end)
			end)
		end

		local MAX_SET_WINS = Config.MAX_SET_WINS

		local function fn(p)
			Remotes.setWins:request(p):andThen(function(p2)
				data.report(p2, false)
			end):catch(data.reportError)
		end

		local v14 = "Wins (e.g. 1.5M)"
		local v15 = "Wins"
		object:AddSplit(function(object2)
			object2:SetRightSizeAbsolute(110)
			local v16 = object2.LeftComponents:AddShortenedNumberField(function(object3)
				object3:SetTextVisible(false):SetPlaceholder(v14):SetNumberFilter(0, MAX_SET_WINS)
			end)
			object2.RightComponents:AddButton(function(object3)
				object3:SetButtonText("Set " .. v15):SetButtonCallback(function()
					local value = v16:GetValue()

					if value == nil then
						data.setStatus("Type a number first", true)
					else
						fn(math.floor(value))
					end
				end)
			end)
		end)
		local MAX_SET_LEVEL = Config.MAX_SET_LEVEL

		local function fn2(p)
			Remotes.setLevel:request((math.max(1, p))):andThen(function(p2)
				data.report(p2, false)
			end):catch(data.reportError)
		end

		local v16 = "Level"
		local v17 = "Level"
		object:AddSplit(function(object2)
			object2:SetRightSizeAbsolute(110)
			local v18 = object2.LeftComponents:AddShortenedNumberField(function(object3)
				object3:SetTextVisible(false):SetPlaceholder(v16):SetNumberFilter(0, MAX_SET_LEVEL)
			end)
			object2.RightComponents:AddButton(function(object3)
				object3:SetButtonText("Set " .. v17):SetButtonCallback(function()
					local value = v18:GetValue()

					if value == nil then
						data.setStatus("Type a number first", true)
					else
						fn2(math.floor(value))
					end
				end)
			end)
		end)
		object:AddButton(function(object2)
			object2:SetButtonText("⚠ Reset my data"):SetButtonColor(Config.DANGER_COLOR):DoNeedConfirmation(true):SetButtonCallback(function()
				Remotes.resetData:request():andThen(function(p)
					data.report(p, true)
				end):catch(data.reportError)
			end)
		end)

		local function renderWorldState(data2)
			for _, v18 in v8.Components:GetAll() do
				v18:Destroy()
			end

			for i = 1, data2.worldCount do
				local v19 = data2.inOwnServer and data2.currentWorldIndex == i
				local v20 = i
				v8.Components:AddButton(function(object2)
					object2:SetButtonText(string.format(v19 and "World %d (you are here)" or "World %d", v20)):SetButtonCallback(function()
						teleport(v20)
					end)
					object2:SetEnabled(not v19)
				end)
			end

			v9:SetVisible(data2.inReservedServer)
			v10:SetVisible(data2.inReservedServer)
		end

		local function onInviteAck(data2)
			if data2.inviteId == inviteId then
				inviteId = nil

				if data2.ok then
					data.setStatus(string.format("✓ %s received your invite", data2.targetName), false)
				elseif data2.reason then
					data.setStatus(string.format(v[data2.reason], data2.targetName), true)
				else
					data.setStatus(string.format("%s did not receive the invite", data2.targetName), true)
				end
			end
		end

		local inviteAckConnection = Remotes.inviteAck:connect(onInviteAck)
		v7:GetUI().Destroying:Connect(inviteAckConnection)
		v7:SetVisible(flag)
		v8:SetVisible(flag)
		v9:SetVisible(false)
		v10:SetVisible(false)
		return {
			refresh = function()
				if flag then
					Remotes.getWorldState:request():andThen(renderWorldState):catch(data.reportError)
				end

				local v18 = v6[v13:GetOpenTabName()]
				Remotes.getCatalog:request(v18):andThen(function(items)
					local v19 = v5[v18]

					for _, v20 in v19.Components:GetAll() do
						v20:Destroy()
					end

					for _, item in items do
						local v20 = item
						v19.Components:AddButton(function(object2)
							local v21

							if v20.owned then
								v21 = "✓ " .. v20.label
							else
								v21 = v20.label
							end

							object2:SetButtonText(v21):SetYSize(Config.LIST_ROW_HEIGHT):SetButtonCallback(function()
								Remotes.giveOne:request(
									v18,
									v20.key,
									math.clamp(math.floor(v11:GetValue() or 1), 1, Config.MAX_GIVE_AMOUNT),
									(math.clamp(math.floor((v12:GetValue())), 0, Config.MAX_ITEM_TIER))
								):andThen(function(p)
									data.report(p, false)

									if p.success then
										loadCatalog(v18)
									end
								end):catch(data.reportError)
							end)
							object2:SetEnabled(v20.canGive)
						end)
					end
				end):catch(data.reportError)
			end,
			tick = function(p: number)
				if inviteId and v4 <= p then
					inviteId = nil
					data.setStatus(string.format("No CC named %s answered in CC Worlds", v3), true)
				end
			end
		}
	end
}