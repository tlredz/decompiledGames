local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local BossMastery = require(ReplicatedStorage.Data.BossMastery)
local BossMasteryFlags = require(ReplicatedStorage.Shared.Flags.BossMasteryFlags)
local EggRecords = require(ReplicatedStorage.Shared.Util.EggRecords)
local FallenPowerUp = require(ReplicatedStorage.Data.FallenPowerUp)
local Time = require(ReplicatedStorage.Shared.Utils.Time)
local elapsed = Time.Elapsed
local GUI = require(ReplicatedStorage.Client.GUI)
local HoverCard = require(ReplicatedStorage.Client.HoverCard)
local LightVsDarknessEventFlags = require(ReplicatedStorage.Shared.Flags.LightVsDarknessEventFlags)
local MonsterParasite = require(ReplicatedStorage.Data.MonsterParasite)
local MonsterParasite2 = require(ReplicatedStorage.Shared.Types.MonsterParasite)
local PlatformController = require(ReplicatedStorage.Client.PlatformController)
local PlayerEarningsBoost = require(ReplicatedStorage.Shared.Util.PlayerEarningsBoost)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Sakura = require(ReplicatedStorage.Data.Sakura)
local SakuraBloomPolicy = require(ReplicatedStorage.Client.Modules.SakuraBloomPolicy)
local Save = require(ReplicatedStorage.Shared.Save)
local ServerLuck = require(ReplicatedStorage.Shared.Types.ServerLuck)
local v = { "RecoveryEvent" }
return {
	Start = function()
		local bottomUI = GUI.BottomUI()
		local bottomFrame = bottomUI.BottomFrame
		local holder = bottomFrame.Holder
		local list = holder.List
		local luck = list.Luck
		local button = luck.Button
		local textLabel = button.Content.Value.TextLabel
		local x2Luck = list.x2Luck
		local timer = x2Luck.Timer
		local x2Growth = list.x2Growth
		local timer2 = x2Growth.Timer
		local playerEarningsBoost = list.PlayerEarningsBoost
		local timer3 = playerEarningsBoost.Timer
		local value = playerEarningsBoost.Value
		local clone = playerEarningsBoost:Clone()
		local v2 = assert(BossMastery.GetShopProduct("SpeedBoost"))
		clone.Name = "BossSpeedBoost"
		clone.Icon.Image = v2.Icon
		clone.LayoutOrder = playerEarningsBoost.LayoutOrder + 1
		clone.Visible = false
		clone.Parent = list
		local playerSpeedBoost = list:FindFirstChild("PlayerSpeedBoost")
		local boostMultiplier = MonsterParasite.BoostMultiplier(MonsterParasite2.BoostKinds.Speed)
		local playerEggGrowthBoost = list:FindFirstChild("PlayerEggGrowthBoost")
		local boostMultiplier2 = MonsterParasite.BoostMultiplier(MonsterParasite2.BoostKinds.EggGrowth)
		local adBoostx2Growth = list:FindFirstChild("AdBoostx2Growth")
		local localPlayer = Players.LocalPlayer
		local v3 = {
			Magnet = {
				Frame = list:FindFirstChild("PowerUpMagnet"),
				Tooltip = {
					{
						kind = "heading",
						text = "RING MAGNET"
					},
					{
						kind = "rule"
					},
					{
						kind = "heading",
						text = "Nearby rings fly straight to you!"
					}
				}
			},
			x2Rings = {
				Frame = list:FindFirstChild("PowerUpx2Rings"),
				Tooltip = {
					{
						kind = "heading",
						text = "2X RINGS"
					},
					{
						kind = "rule"
					},
					{
						kind = "heading",
						text = "Every ring you collect counts double!"
					}
				}
			},
			Fusion = {
				Frame = list:FindFirstChild("PowerUpFusion"),
				Tooltip = {
					{
						kind = "heading",
						text = "FUSION"
					},
					{
						kind = "rule"
					},
					{
						kind = "heading",
						text = "Charged with fusion energy!"
					}
				}
			}
		}
		local v4 = {
			Countdown = {
				Frame = list:FindFirstChild("Countdown")
			},
			DemonicEvent = {
				Frame = list:FindFirstChild("DemonicEvent"),
				Tooltip = {
					{
						kind = "heading",
						text = "A DEMONIC EGG HAS SPAWNED"
					}
				}
			},
			DragonEggEvent = {
				Frame = list:FindFirstChild("DragonEggEvent"),
				Tooltip = {
					{
						kind = "heading",
						text = "A DRAGON HAS DESCENDED"
					}
				},
				HideTimer = true
			},
			GreatBloom = {
				Frame = list:FindFirstChild("GreatBloom"),
				Tooltip = {
					{
						kind = "heading",
						text = "🌸 THE GREAT BLOOM 🌸"
					},
					{
						kind = "rule"
					},
					{
						kind = "heading",
						text = "Bat Crystal Sakura Trees for Sakura Crystals!"
					}
				}
			},
			EggLuckBoost = {
				Frame = list:FindFirstChild("EggLuckBoost"),
				Tooltip = {
					{
						kind = "heading",
						text = "EGG LUCK BOOST"
					},
					{
						kind = "rule"
					},
					{
						kind = "heading",
						text = "Rarer eggs are spawning on the map!"
					}
				},
				ShowMultiplier = true
			},
			EggSizeBoost = {
				Frame = list:FindFirstChild("EggSizeBoost"),
				Tooltip = {
					{
						kind = "heading",
						text = "EGG SIZE BOOST"
					},
					{
						kind = "rule"
					},
					{
						kind = "heading",
						text = "Bigger eggs are spawning on the map!"
					}
				},
				ShowMultiplier = true
			},
			EarningsBoost = {
				Frame = list:FindFirstChild("EarningsBoost"),
				Tooltip = {
					{
						kind = "heading",
						text = "EARNINGS BOOST"
					},
					{
						kind = "rule"
					},
					{
						kind = "heading",
						text = "Your pets earn more cash!"
					}
				},
				ShowMultiplier = true
			},
			SpeedBoost = {
				Frame = list:FindFirstChild("SpeedBoost"),
				Tooltip = {
					{
						kind = "heading",
						text = "SPEED BOOST"
					},
					{
						kind = "rule"
					},
					{
						kind = "heading",
						text = "Everyone runs faster!"
					}
				},
				ShowMultiplier = true
			},
			MutationBoost = {
				Frame = list:FindFirstChild("MutationBoost"),
				Tooltip = {
					{
						kind = "heading",
						text = "MUTATION BOOST"
					},
					{
						kind = "rule"
					},
					{
						kind = "heading",
						text = "Mutated eggs are more common!"
					}
				},
				ShowMultiplier = true
			},
			AdminTreadmill = {
				Frame = list:FindFirstChild("AdminTreadmill"),
				Tooltip = {
					{
						kind = "heading",
						text = "ADMIN TREADMILL"
					},
					{
						kind = "rule"
					},
					{
						kind = "heading",
						text = "Run on the Admin Treadmill in the base for multiplied speed gains!"
					}
				},
				ShowMultiplier = true
			},
			MonsterEvent = {
				Frame = list:FindFirstChild("MonsterEvent"),
				Tooltip = {
					{
						kind = "heading",
						text = "A MONSTER HAS SPAWNED"
					}
				}
			}
		}
		local anchorPoint = bottomFrame.AnchorPoint
		local position = bottomFrame.Position
		local anchorPoint2 = holder.AnchorPoint
		local position2 = holder.Position
		local anchorPoint3 = list.AnchorPoint
		local position3 = list.Position
		local size = list.Size
		local v5 = {
			Multiplier = 1
		}
		local v6 = {}
		local v7 = {}

		local function isBloomUnlocked()
			local isLoaded = Save.IsLoaded()
			local v8

			if isLoaded then
				v8 = Save.Peek()
			end

			return SakuraBloomPolicy.HasBloomUnlocked(isLoaded, v8)
		end

		local function escapeRichText(value2: string)
			return value2:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
		end

		local function getMultiplierText()
			return (`x{math.max(1, (math.floor(v5.Multiplier)))}`)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getBoosterText()
			local boostedByDisplayName = v5.BoostedByDisplayName

			if boostedByDisplayName == nil or boostedByDisplayName == "" then
				return "<font color=\"#38E839\">@Server</font>"
			end

			return (`<font color="#38E839">@{boostedByDisplayName:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")}</font>`)
		end

		local function getOverlayBlocks()
			return {
				{
					kind = "heading",
					text = `<font color="#38E839">{`x{math.max(1, (math.floor(v5.Multiplier)))}`}</font> Server Luck!`
				},
				{
					kind = "rule"
				},
				{
					kind = "heading",
					text = ("Boosted by %*!"):format(getBoosterText())
				}
			}
		end

		local function formatMultiplier(p: number)
			return (`x{math.floor(p * 100 + 0.5) / 100}`)
		end

		local function getEventMultiplierText(p: string)
			local v8 = v7[p]
			local multiplier

			if type(v8) == "table" then
				multiplier = v8.Multiplier
			end

			if type(multiplier) == "number" then
				return (`x{math.floor(multiplier * 100 + 0.5) / 100}`)
			end

			return ""
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getRemainingSeconds(p: string, p2: number)
			local v8 = v6[p]

			if v8 == nil then
				return 0
			end

			return (math.max(0, (math.ceil(v8 - p2))))
		end

		local function getBuffRemainingSeconds(p: number)
			local v8 = 0

			for _, v9 in v do
				v8 = math.max(v8, getRemainingSeconds(v9, p))
			end

			return v8
		end

		local function getMonsterBoostSeconds(p, p2, p3: number)
			if p == nil then
				return 0
			end

			return MonsterParasite2.BoostRemainingSeconds(p.MonsterParasite, p2, p3)
		end

		local function render(p: number?)
			local v8 = p or Workspace:GetServerTimeNow()
			local visible = v5.Multiplier > 1
			local v10 = 0

			for _, v11 in v do
				v10 = math.max(v10, getRemainingSeconds(v11, v8))
			end

			local visible2 = v10 > 0
			local text = elapsed(v10)
			luck.Visible = visible
			textLabel.Text = `x{math.max(1, (math.floor(v5.Multiplier)))}`
			local timer4 = luck:FindFirstChild("Timer")

			if timer4 then
				local v13 = not v5.ExpiresAt and 0 or v5.ExpiresAt - v8
				timer4.Visible = v13 > 0
				timer4.Text = not (v13 > 0) and "" or elapsed((math.ceil(v13)))
			end

			x2Luck.Visible = visible2
			timer.Text = text
			x2Growth.Visible = visible2
			timer2.Text = text
			local v13 = EggRecords.ServerGrowthBoostMultiplier() or 0
			local growthBoost = list:FindFirstChild("GrowthBoost")

			if v13 > 0 then
				local timer5 = growthBoost:FindFirstChild("Timer")
				local value2 = growthBoost:FindFirstChild("Value")
				local v14 = EggRecords.ServerGrowthBoostEndsAt() - v8
				timer5.Visible = v14 > 0
				timer5.Text = not (v14 > 0) and "" or elapsed((math.ceil(v14)))
				growthBoost.Visible = true
				value2.Text = `x{v13 + 1}`
			else
				growthBoost.Visible = false
			end

			local remainingSeconds = PlayerEarningsBoost.GetRemainingSeconds(localPlayer, v8)
			local visible3 = remainingSeconds > 0
			playerEarningsBoost.Visible = visible3
			timer3.Text = elapsed((math.ceil(remainingSeconds)))
			value.Text = `x{BossMasteryFlags.CashBoosterMultiplier:Get()}`
			local v15 = Save.Peek()
			local speed = MonsterParasite2.BoostKinds.Speed
			local v16 = v15 == nil and 0 or MonsterParasite2.BoostRemainingSeconds(v15.MonsterParasite, speed, v8)
			local eggGrowth = MonsterParasite2.BoostKinds.EggGrowth
			local v17 = v15 == nil and 0 or MonsterParasite2.BoostRemainingSeconds(v15.MonsterParasite, eggGrowth, v8)
			local visible4 = v16 > 0
			local visible5 = v17 > 0
			local v20 = v15 == nil and 0 or math.max(0, (v15.BossMastery.SpeedBoostExpiresAt or 0) - v8)
			local visible6 = v20 > 0
			clone.Visible = visible6
			clone.Timer.Text = elapsed((math.ceil(v20)))
			clone.Value.Text = `x{math.floor(BossMasteryFlags.SpeedBoostMultiplier:Get() * 100 + 0.5) / 100}`

			if playerSpeedBoost then
				playerSpeedBoost.Visible = visible4
				playerSpeedBoost.Timer.Text = elapsed((math.ceil(v16)))
				playerSpeedBoost.Value.Text = `x{math.floor(boostMultiplier * 100 + 0.5) / 100}`
			end

			if playerEggGrowthBoost then
				playerEggGrowthBoost.Visible = visible5
				playerEggGrowthBoost.Timer.Text = elapsed((math.ceil(v17)))
				playerEggGrowthBoost.Value.Text = `x{math.floor(boostMultiplier2 * 100 + 0.5) / 100}`
			end

			local adEggBoostExpiresAt = localPlayer:GetAttribute("AdEggBoostExpiresAt")
			local v22 = typeof(adEggBoostExpiresAt) ~= "number" and 0 or math.max(0, adEggBoostExpiresAt - v8)
			local visible7 = v22 > 0

			if adBoostx2Growth then
				adBoostx2Growth.Visible = visible7

				if visible7 then
					adBoostx2Growth.Timer.Text = elapsed((math.ceil(v22)))
				end
			end

			local enabled = visible or visible2 or v13 > 0 or visible3 or visible6 or visible4 or visible5 or visible7

			for k, v25 in v3 do
				local frame = v25.Frame

				if not frame then
					continue
				end

				local v26 = FallenPowerUp.ActiveUntil(localPlayer, k) - v8

				if v26 > 0 then
					frame.Timer.Text = elapsed((math.ceil(v26)))
					frame.Value.Text = not v25.ShowValue and "" or `x{LightVsDarknessEventFlags.PowerUpRingMultiplier:Get()}`
					frame.Visible = true
					enabled = true
				else
					frame.Visible = false
				end
			end

			for k, v25 in v4 do
				if not v25.Frame then
					continue
				end

				local remainingSeconds2 = getRemainingSeconds(k, v8) -- equivalent call inferred; original call site unknown
				local v26

				if k == Sakura.EventName then
					local isLoaded = Save.IsLoaded()
					local v27

					if isLoaded then
						v27 = Save.Peek()
					end

					v26 = SakuraBloomPolicy.HasBloomUnlocked(isLoaded, v27)
				else
					v26 = true
				end

				if remainingSeconds2 > 0 and v26 then
					v25.Frame.Timer.Text = elapsed(remainingSeconds2)
					v25.Frame.Timer.Visible = v25.HideTimer ~= true
					local value2 = v25.ShowMultiplier and v25.Frame:FindFirstChild("Value")

					if value2 then
						local v27 = v7[k]
						local multiplier

						if type(v27) == "table" then
							multiplier = v27.Multiplier
						end

						value2.Text = type(multiplier) ~= "number" and "" or `x{math.floor(multiplier * 100 + 0.5) / 100}`
					end

					v25.Frame.Visible = true
					enabled = true
				else
					v25.Frame.Visible = false
				end
			end

			bottomUI.Enabled = enabled
		end

		local function renderPlatform(_: string?)
			if PlatformController.IsMobile() then
				bottomFrame.AnchorPoint = Vector2.new(1, 0)
				bottomFrame.Position = UDim2.fromScale(0.98, 0.07)
				holder.AnchorPoint = Vector2.new(1, 0)
				holder.Position = UDim2.fromScale(1, 0)
				list.AnchorPoint = Vector2.new(0.5, 0)
				list.Position = UDim2.fromScale(0.5, 0)
				list.Size = UDim2.fromScale(0.975, 0.5)
			else
				bottomFrame.AnchorPoint = anchorPoint
				bottomFrame.Position = position
				holder.AnchorPoint = anchorPoint2
				holder.Position = position2
				list.AnchorPoint = anchorPoint3
				list.Position = position3
				list.Size = size
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function applyState(p)
			v5 = p
			render()
		end

		local function getEarningsOverlayBlocks()
			local v8 = BossMasteryFlags.CashBoosterMultiplier:Get()
			return {
				{
					kind = "heading",
					text = `X{v8} EARNINGS`
				},
				{
					kind = "rule"
				},
				{
					kind = "heading",
					text = `Your pets earn {v8}x cash!`
				}
			}
		end

		HoverCard.Attach(button, getOverlayBlocks)
		HoverCard.Attach(x2Luck.Icon, {
			{
				kind = "heading",
				text = "X2 LUCK"
			}
		})
		HoverCard.Attach(x2Growth.Icon, {
			{
				kind = "heading",
				text = "X2 EGG GROWTH SPEED"
			}
		})
		HoverCard.Attach(list:FindFirstChild("GrowthBoost"), {
			{
				kind = "heading",
				text = "GROWTH BOOSTED!"
			}
		})
		HoverCard.Attach(playerEarningsBoost.Icon, getEarningsOverlayBlocks)
		HoverCard.Attach(clone.Icon, {
			{
				kind = "heading",
				text = `X{BossMasteryFlags.SpeedBoostMultiplier:Get()} SPEED`
			},
			{
				kind = "rule"
			},
			{
				kind = "heading",
				text = "You run faster!"
			}
		})
		PlayerEarningsBoost.GetChangedSignal(localPlayer):Connect(function()
			render()
		end)
		BossMasteryFlags.CashBoosterMultiplier.Changed:Connect(render)
		BossMasteryFlags.SpeedBoostMultiplier.Changed:Connect(render)

		if playerSpeedBoost then
			HoverCard.Attach(playerSpeedBoost.Icon, {
				{
					kind = "heading",
					text = `X{boostMultiplier} SPEED`
				},
				{
					kind = "rule"
				},
				{
					kind = "heading",
					text = "You run faster!"
				}
			})
		end

		if playerEggGrowthBoost then
			HoverCard.Attach(playerEggGrowthBoost.Icon, {
				{
					kind = "heading",
					text = `X{boostMultiplier2} EGG GROWTH`
				},
				{
					kind = "rule"
				},
				{
					kind = "heading",
					text = "Your eggs grow faster!"
				}
			})
		end

		if adBoostx2Growth then
			HoverCard.Attach(adBoostx2Growth.Icon, {
				{
					kind = "heading",
					text = "X2 EGG GROWTH"
				},
				{
					kind = "rule"
				},
				{
					kind = "heading",
					text = "Watch ads to grow eggs faster!"
				}
			})
		end

		localPlayer:GetAttributeChangedSignal("AdEggBoostExpiresAt"):Connect(render)

		for _, v8 in v4 do
			if v8.Frame and v8.Tooltip then
				HoverCard.Attach(v8.Frame.Icon, v8.Tooltip)
			end
		end

		for k, v8 in v3 do
			if not v8.Frame then
				continue
			end

			local modelView = v8.Frame.Icon:FindFirstChild("ModelView")

			if modelView then
				modelView:Destroy()
			end

			v8.Frame.Icon.Image = FallenPowerUp.IconFor(k)
			HoverCard.Attach(v8.Frame.Icon, v8.Tooltip)
			localPlayer:GetAttributeChangedSignal(FallenPowerUp.AttributeFor(k)):Connect(function()
				render()
			end)
		end

		render()
		PlatformController.Observe(renderPlatform)
		Remotes.LuckWindow.StateRefreshed.OnClientEvent:Connect(function(p)
			if ServerLuck.State(p) then
				applyState(p) -- equivalent call inferred; original call site unknown
			end
		end)
		local v8 = Remotes.LuckWindow.FetchState:InvokeServer()

		if ServerLuck.State(v8) then
			applyState(v8) -- equivalent call inferred; original call site unknown
		end

		Remotes.LiveEvents.Began.OnClientEvent:Connect(function(p: string, p2: number, p3)
			v6[p] = Workspace:GetServerTimeNow() + p2
			v7[p] = p3
			render()
		end)
		Remotes.LiveEvents.Ended.OnClientEvent:Connect(function(p: string)
			v6[p] = nil
			v7[p] = nil
			render()
		end)
		Save.WatchFields("Sakura", function()
			render()
		end)
		Save.WatchFields("MonsterParasite", function()
			render()
		end)
		Save.WatchFields("BossMastery", function()
			render()
		end)
		local v9, v10 = Remotes.LiveEvents.FetchRunning:InvokeServer()
		v6 = v9
		v7 = v10 or {}
		render()
		task.spawn(function()
			while true do
				task.wait(1)
				render()
			end
		end)
	end
}