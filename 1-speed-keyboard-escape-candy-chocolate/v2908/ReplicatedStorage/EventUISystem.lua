local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local EventsConfig = require(ReplicatedStorage:WaitForChild("EventsConfig"))
local NotificationSystem = require(ReplicatedStorage:WaitForChild("NotificationSystem"))
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local flag = false

local function playSound(p)
	if not p then
		return
	end

	local sound = Instance.new("Sound")
	sound.SoundId = p.ID
	sound.Volume = p.Volume or 0.5
	sound.RollOffMaxDistance = 0
	sound:SetAttribute("IsEventSound", true)
	sound.Parent = SoundService
	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

local function getModalByTag(tag)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	for _, v in ipairs(CollectionService:GetTagged(tag)) do
		if v:IsDescendantOf(playerGui) then
			return v
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatCountdown(p)
	if p <= 0 then
		return "0j 00h 00m 00s"
	end

	local v = math.floor(p / 86400)
	local v2 = math.floor(p % 86400 / 3600)
	local v3 = math.floor(p % 3600 / 60)
	local v4 = p % 60
	return string.format("%dj %02dh %02dm %02ds", v, v2, v3, v4)
end

return {
	Init = function(_)
		if flag then
			return
		end

		flag = true
		local v = {}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function applyButton(p, gamepass)
			p.Activated:Connect(function()
				MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, gamepass)
			end)

			if v[gamepass] ~= nil then
				p.Visible = not v[gamepass]
			end
		end

		local v2 = {}
		local v3 = {}

		for _, v4 in ipairs(EventsConfig.GamepassButtons or {}) do
			for _, v5 in ipairs(CollectionService:GetTagged(v4.Tag)) do
				applyButton(v5, v4.Gamepass) -- equivalent call inferred; original call site unknown
			end

			local v5 = v4
			CollectionService:GetInstanceAddedSignal(v4.Tag):Connect(function(p)
				applyButton(p, v5.Gamepass) -- equivalent call inferred; original call site unknown
			end)
		end

		task.spawn(function()
			local userId = Players.LocalPlayer.UserId

			for _, v4 in ipairs(EventsConfig.GamepassButtons or {}) do
				local gamepass = v4.Gamepass
				local success, result = pcall(function()
					return MarketplaceService:UserOwnsGamePassAsync(userId, gamepass)
				end)
				v[gamepass] = success and result

				for _, v6 in ipairs(CollectionService:GetTagged(v4.Tag)) do
					v6.Visible = not v[gamepass]
				end
			end
		end)
		MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(_, p, p2)
			if not p2 then
				return
			end

			v[p] = true

			for _, v4 in ipairs(EventsConfig.GamepassButtons or {}) do
				if v4.Gamepass ~= p then
					continue
				end

				for _, v5 in ipairs(CollectionService:GetTagged(v4.Tag)) do
					v5.Visible = false
				end
			end
		end)
		local buyEventReward = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("BuyEventReward", 10)

		if buyEventReward then
			for _, v4 in ipairs(EventsConfig.ShopRewards or {}) do
				local tag = v4.Tag
				local v6 = v4

				local function applyShopBtn(p)
					p.Activated:Connect(function()
						local v7, v8 = buyEventReward:InvokeServer(tag)

						if v7 then
							local v9 = v6.Reward.Type ~= "Wins" and "XP" or Config.GetWinsLabel(v6.Reward.Amount)
							playSound(Config.SOUNDS.BUY)
							NotificationSystem:ShowMessage("+" .. v8 .. " " .. v9 .. "!", Color3.fromRGB(100, 255, 140))
						else
							playSound(Config.SOUNDS.ERROR)
							local modalByTag = getModalByTag("EventCurrencyModal")

							if modalByTag then
								ClientState:ToggleModal(modalByTag)
							else
								NotificationSystem:ShowMessage(
									"Not enough " .. v6.Currency.Key .. "!",
									Color3.fromRGB(255, 100, 100)
								)
							end
						end
					end)
				end

				for _, v7 in ipairs(CollectionService:GetTagged(tag)) do
					local v8 = tag
					local v9 = v4
					v7.Activated:Connect(function()
						local v10, v11 = buyEventReward:InvokeServer(v8)

						if v10 then
							local v12 = v9.Reward.Type ~= "Wins" and "XP" or Config.GetWinsLabel(v9.Reward.Amount)
							playSound(Config.SOUNDS.BUY)
							NotificationSystem:ShowMessage(
								"+" .. v11 .. " " .. v12 .. "!",
								Color3.fromRGB(100, 255, 140)
							)
						else
							playSound(Config.SOUNDS.ERROR)
							local modalByTag = getModalByTag("EventCurrencyModal")

							if modalByTag then
								ClientState:ToggleModal(modalByTag)
							else
								NotificationSystem:ShowMessage(
									"Not enough " .. v9.Currency.Key .. "!",
									Color3.fromRGB(255, 100, 100)
								)
							end
						end
					end)
				end

				CollectionService:GetInstanceAddedSignal(tag):Connect(applyShopBtn)
			end
		end

		for _, v4 in ipairs(EventsConfig.CurrencyDevProducts or {}) do
			local id = v4.Id

			local function applyDevBtn(p)
				p.Activated:Connect(function()
					MarketplaceService:PromptProductPurchase(Players.LocalPlayer, id)
				end)
			end

			for _, v6 in ipairs(CollectionService:GetTagged(v4.Tag)) do
				local v7 = id
				v6.Activated:Connect(function()
					MarketplaceService:PromptProductPurchase(Players.LocalPlayer, v7)
				end)
			end

			CollectionService:GetInstanceAddedSignal(v4.Tag):Connect(applyDevBtn)
		end

		local v4 = {}

		for _, v5 in ipairs(EventsConfig.CurrencyDevProducts or {}) do
			v4[v5.Id] = true
		end

		MarketplaceService.PromptProductPurchaseFinished:Connect(function(_, p, p2)
			if not v4[p] then
				return
			end

			playSound(p2 and Config.SOUNDS.BUY or Config.SOUNDS.ERROR)
		end)
		local v5 = {}

		for _, v6 in ipairs(EventsConfig.GamepassButtons or {}) do
			v5[v6.Gamepass] = true
		end

		MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(_, p, p2)
			if not v5[p] then
				return
			end

			playSound(p2 and Config.SOUNDS.BUY or Config.SOUNDS.ERROR)
		end)
		local now = os.time()
		local visible = false

		for _, event in ipairs(EventsConfig.Events) do
			if not (event.ShowEventShop ~= false and event.Start <= now and now < event.End) then
				continue
			end

			visible = true
			break
		end

		for _, v8 in ipairs(CollectionService:GetTagged("UIActionBtn")) do
			if v8:GetAttribute("Action") == "EventShop" then
				v8.Visible = visible
			end
		end

		for i, event in ipairs(EventsConfig.Events) do
			v2[i] = false
			v3[i] = false

			if event.FrameTag and event.FrameTag ~= "" then
				for _, v8 in ipairs(CollectionService:GetTagged(event.FrameTag)) do
					v8.Visible = false
				end
			end

			for _, tag in ipairs(event.ExtraFrameTags or {}) do
				for _, v8 in ipairs(CollectionService:GetTagged(tag)) do
					v8.Visible = false
				end
			end

			if event.TimerTag then
				for _, v8 in ipairs(CollectionService:GetTagged(event.TimerTag)) do
					v8.Visible = false
				end
			end

			if event.FrameTag and event.FrameTag ~= "" then
				local v8 = i
				CollectionService:GetInstanceAddedSignal(event.FrameTag):Connect(function(p)
					local event2 = EventsConfig.Events[v8]
					local now2 = os.time()
					local v9 = event2.FrameTag:gsub("Frame$", "")
					local visible2 = table.find(ClientState:Get().OwnedTrails or {}, v9) ~= nil

					if not visible2 then
						if event2.Start <= now2 then
							visible2 = now2 < event2.End
						else
							visible2 = false
						end
					end

					p.Visible = visible2
				end)
			end

			for _, v8 in ipairs(event.ExtraFrameTags or {}) do
				local v9 = i
				local v10 = v8
				CollectionService:GetInstanceAddedSignal(v8):Connect(function(p)
					local event2 = EventsConfig.Events[v9]
					local now2 = os.time()
					local v11 = v10:gsub("Frame$", "")
					local visible2 = table.find(ClientState:Get().OwnedTrails or {}, v11) ~= nil

					if not visible2 then
						if event2.Start <= now2 then
							visible2 = now2 < event2.End
						else
							visible2 = false
						end
					end

					p.Visible = visible2
				end)
			end
		end

		task.spawn(function()
			local userId = Players.LocalPlayer.UserId

			for i, event in ipairs(EventsConfig.Events) do
				local v8 = event
				local v9 = i
				task.spawn(function()
					if v8.Gamepass and v8.Gamepass > 0 then
						local success, result = pcall(function()
							return MarketplaceService:UserOwnsGamePassAsync(userId, v8.Gamepass)
						end)

						if success then
							v2[v9] = result
						end
					end

					v3[v9] = true
				end)
				local now2 = os.time()

				if not (now2 < event.Start) then
					continue
				end

				local v10 = event.Start - now2
				local v11 = event
				task.delay(v10, function()
					local ownedTrails = ClientState:Get().OwnedTrails

					if v11.FrameTag and v11.FrameTag ~= "" then
						for i2, v12 in ipairs(CollectionService:GetTagged(v11.FrameTag)) do
							v12.Visible = true
						end
					end

					for i2, tag in ipairs(v11.ExtraFrameTags or {}) do
						for i3, v12 in ipairs(CollectionService:GetTagged(tag)) do
							v12.Visible = true
						end
					end
				end)
			end

			while true do
				local now2 = os.time()
				local ownedTrails = ClientState:Get().OwnedTrails or {}
				local v8 = {}
				local v9 = {}
				local visible2 = false
				local name = nil

				for _, event in ipairs(EventsConfig.Events) do
					local v11

					if event.Start <= now2 then
						v11 = now2 < event.End
					else
						v11 = false
					end

					if v11 then
						name = event.Name
					end

					visible2 = v11 and event.ShowEventShop ~= false and true or visible2

					if event.FrameTag and event.FrameTag ~= "" then
						local v12 = event.FrameTag:gsub("Frame$", "")
						local v13 = table.find(ownedTrails, v12) ~= nil
						v8[event.FrameTag] = v8[event.FrameTag] or v13 or v11
					end

					for _, v12 in ipairs(event.ExtraFrameTags or {}) do
						local v13 = v12:gsub("Frame$", "")
						local v14 = table.find(ownedTrails, v13) ~= nil
						v8[v12] = v8[v12] or v14 or v11
					end

					if not event.TimerTag then
						continue
					end

					if not v9[event.TimerTag] then
						v9[event.TimerTag] = {
							visible = false,
							text = nil
						}
					end

					if not v11 then
						continue
					end

					v9[event.TimerTag].visible = true
					local v12 = v9[event.TimerTag]
					local text = formatCountdown(event.End - now2) -- equivalent call inferred; original call site unknown
					v12.text = text
				end

				for tag, visible3 in pairs(v8) do
					for _, v12 in ipairs(CollectionService:GetTagged(tag)) do
						v12.Visible = visible3
					end
				end

				for tag, v11 in pairs(v9) do
					for _, v12 in ipairs(CollectionService:GetTagged(tag)) do
						v12.Visible = v11.visible

						if v11.visible and v11.text then
							v12.Text = v11.text
						end
					end
				end

				for _, v11 in ipairs(CollectionService:GetTagged("UIActionBtn")) do
					if v11:GetAttribute("Action") == "EventShop" then
						v11.Visible = visible2
					end
				end

				local v11 = {}
				local v12 = {}
				local v13 = {}

				for _, currency in ipairs(EventsConfig.Currencies) do
					if not currency.Events then
						continue
					end

					for _, event in ipairs(currency.Events) do
						if event ~= name then
							continue
						end

						table.insert(v11, currency.Key)

						if (currency.Rarity or 0) == 0 then
							table.insert(v13, currency.Key)
						elseif currency.Rarity == 1 then
							table.insert(v12, currency.Key)
						end

						break
					end
				end

				local visible4 = #v11 > 0
				local visible5 = #v12 > 0
				local v16 = ClientState:Get()

				for _, v17 in ipairs(CollectionService:GetTagged("EventCurrencyFrame")) do
					v17.Visible = visible4
				end

				for _, v17 in ipairs(CollectionService:GetTagged("EventCurrency")) do
					local currencyKey = v17:GetAttribute("CurrencyKey")

					if currencyKey then
						v17.Text = tostring(v16[currencyKey] or 0)
					else
						v17.Text = tostring(not v13[1] and 0 or v16[v13[1]] or 0)
					end
				end

				for _, v17 in ipairs(CollectionService:GetTagged("EventCurrency2")) do
					v17.Visible = visible5

					if not visible5 then
						continue
					end

					local currencyKey = v17:GetAttribute("CurrencyKey")

					if currencyKey then
						v17.Text = tostring(v16[currencyKey] or 0)
					else
						v17.Text = tostring(not v12[1] and 0 or v16[v12[1]] or 0)
					end
				end

				local v17 = {}

				for _, currency in ipairs(EventsConfig.Currencies) do
					if currency.Icon and currency.Icon ~= 0 then
						v17[currency.Key] = "rbxassetid://" .. currency.Icon
					end
				end

				for _, v18 in ipairs(CollectionService:GetTagged("EventCurrencyIcon")) do
					local currencyKey = v18:GetAttribute("CurrencyKey")
					local image

					if currencyKey then
						image = v17[currencyKey]
					else
						image = v13[1] and v17[v13[1]]
					end

					if image then
						v18.Image = image
					end
				end

				for _, v18 in ipairs(CollectionService:GetTagged("EventCurrencyIcon2")) do
					v18.Visible = visible5

					if not visible5 then
						continue
					end

					local currencyKey = v18:GetAttribute("CurrencyKey")
					local image

					if currencyKey then
						image = v17[currencyKey]
					else
						image = v12[1] and v17[v12[1]]
					end

					if image then
						v18.Image = image
					end
				end

				task.wait(1)
			end
		end)
	end
}