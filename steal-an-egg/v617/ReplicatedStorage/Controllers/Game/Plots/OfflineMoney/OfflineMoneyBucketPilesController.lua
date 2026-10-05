local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ActiveAssetsController = require(script.Parent.Parent.ActiveAssetsController)
local AssetRoster = require(ReplicatedStorage.Client.AssetRoster)
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local Currency = require(ReplicatedStorage.Shared.Types.Currency)
local TryLock = require(ReplicatedStorage.Shared.Utils.TryLock)
local Reward = require(ReplicatedStorage.Client.Notifications.Reward)
local OfflineAssets = require(ReplicatedStorage.Client.Types.OfflineAssets)
local ClaimVisual = require(script.ClaimVisual)
local Player = require(ReplicatedStorage.Shared.Player)
local PlotState = require(ReplicatedStorage.Client.PlotState)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Save = require(ReplicatedStorage.Shared.Save)
local Trove = require(ReplicatedStorage.Packages.Trove)
local money = Currency.AllCurrencyTypes.Money
local localPlayer = Players.LocalPlayer
local v = nil
local count = 0
local v2 = nil
local v3 = {}
return {
	Start = function()
		local function readSummary(p)
			if OfflineAssets.OfflineClaimSummary(p) then
				return p
			end

			return nil
		end

		local function readRedeemResult(p)
			if OfflineAssets.OfflineRedeemResult(p) then
				return p
			end

			return nil
		end

		local function hasReadiness()
			return Save.IsLoaded()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function currentClaimAmount()
			local v4 = v
			local selected = not v4 and 0 or math.max(v4.TotalAmount, 0)

			if Constants.OFFLINE_ASSETS.MIN_CLAIM_MONEY <= selected then
				return selected
			end

			return 0
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function clearSession(p)
			local v4 = v2

			if p ~= nil and v4 ~= p then
				return
			end

			v2 = nil

			if v4 then
				v4.trove:Destroy()
			end
		end

		local function feetInsideSession(p)
			local feetCFrame = Player.FindFeetCFrame(localPlayer)
			return feetCFrame ~= nil and p.visual:ContainsWorldPosition(feetCFrame.Position)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function requestSummary()
			count += 1
			local v4 = count
			task.spawn(function()
				local v5 = Remotes.AwayEarnings.FetchSummary:InvokeServer()

				if not OfflineAssets.OfflineClaimSummary(v5) then
					v5 = nil
				end

				if v4 ~= count then
					return
				end

				if v5 then
					v = v5
				end

				v3.Sync()
			end)
		end

		local function showOfflineMoneyNotification(awardedAmount: number)
			if awardedAmount <= 0 then
				return
			end

			Reward.Show({
				Item = {
					Kind = "Currency",
					Id = money,
					Amount = math.round(awardedAmount)
				}
			})
		end

		local function claim(data)
			if data.amount <= 0 then
				return
			end

			data.claimLock(function()
				v = {
					ClaimableAmount = 0,
					ReservedAmount = 0,
					TotalAmount = 0,
					IsMultiplierPurchasePending = false
				}
				data.visual:PlayClaim()
				local v4, _, v5 = Remotes.AwayEarnings.AskCollect:InvokeServer({
					Kind = "Claim"
				})

				if not OfflineAssets.OfflineRedeemResult(v5) then
					v5 = nil
				end

				if v4 == true and v5 ~= nil then
					showOfflineMoneyNotification(v5.AwardedAmount)
					clearSession(data) -- equivalent call inferred; original call site unknown
				else
					requestSummary() -- equivalent call inferred; original call site unknown
				end
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateClaimEntry(state)
			local feetCFrame = Player.FindFeetCFrame(localPlayer)
			local feetInside2

			if feetCFrame == nil then
				feetInside2 = false
			else
				feetInside2 = state.visual:ContainsWorldPosition(feetCFrame.Position)
			end

			local feetInside = state.feetInside
			state.feetInside = feetInside2
			state.visual:SetBillboardEnabled(not feetInside2)

			if feetInside2 and not feetInside then
				if state.amount <= 0 then
					return
				else
					state.claimLock(function()
						v = {
							ClaimableAmount = 0,
							ReservedAmount = 0,
							TotalAmount = 0,
							IsMultiplierPurchasePending = false
						}
						state.visual:PlayClaim()
						local v5, _, v6 = Remotes.AwayEarnings.AskCollect:InvokeServer({
							Kind = "Claim"
						})

						if not OfflineAssets.OfflineRedeemResult(v6) then
							v6 = nil
						end

						if v5 == true and v6 ~= nil then
							showOfflineMoneyNotification(v6.AwardedAmount)
							clearSession(state) -- equivalent call inferred; original call site unknown
						else
							requestSummary() -- equivalent call inferred; original call site unknown
						end
					end)
				end
			end
		end

		local function sessionFor(amount: number, penArea, plotFolder)
			local maid = Trove.new()
			local visual = ClaimVisual.new(amount, penArea, plotFolder)
			local v5 = {
				trove = maid,
				amount = amount,
				visual = visual,
				claimLock = TryLock(),
				feetInside = false
			}
			maid:Add(function()
				visual:Destroy()
			end)
			maid:Add(RunService.Heartbeat:Connect(function()
				updateClaimEntry(v5) -- equivalent call inferred; original call site unknown
			end))
			return v5
		end

		local function tryInitialize()
			if not Save.IsLoaded() then
				return
			end

			requestSummary() -- equivalent call inferred; original call site unknown
			v3.Sync()
		end

		function v3.Sync()
			if not Save.IsLoaded() then
				return
			end

			local amount = currentClaimAmount() -- equivalent call inferred; original call site unknown

			if amount <= 0 then
				local v5 = v2
				v2 = nil

				if v5 then
					v5.trove:Destroy()
				end
			else
				local penArea = AssetRoster.FindPenArea(localPlayer)

				if penArea == nil then
					local v5 = v2
					v2 = nil

					if v5 then
						v5.trove:Destroy()
					end
				else
					local plot = PlotState.ResolvePlot()
					local plotFolder

					if plot then
						plotFolder = plot.PlotFolder
					else
						plotFolder = workspace
					end

					local v5 = v2

					if v5 == nil then
						local v6 = sessionFor(amount, penArea, plotFolder)
						v2 = v6
						updateClaimEntry(v6) -- equivalent call inferred; original call site unknown
					else
						v5.amount = amount
						v5.visual:Update(amount, penArea)
						updateClaimEntry(v5) -- equivalent call inferred; original call site unknown
					end
				end
			end
		end

		Remotes.AwayEarnings.SummaryRefreshed.OnClientEvent:Connect(function(p)
			if not OfflineAssets.OfflineClaimSummary(p) then
				p = nil
			end

			if p then
				v = p
				v3.Sync()
			end
		end)
		Remotes.AwayEarnings.Redeemed.OnClientEvent:Connect(function(p)
			if not OfflineAssets.OfflineRedeemResult(p) then
				p = nil
			end

			if p then
				local v4 = v2
				v2 = nil

				if v4 then
					v4.trove:Destroy()
				end

				requestSummary() -- equivalent call inferred; original call site unknown
			end
		end)
		AssetRoster.PenAreaChanged:Connect(function(p)
			if p == localPlayer then
				v3.Sync()
			end
		end)
		PlotState.LocalPlotChanged:Connect(v3.Sync)
		ActiveAssetsController.ItemAdded:Connect(requestSummary)
		ActiveAssetsController.ItemRemoved:Connect(requestSummary)
		ActiveAssetsController.CashCollected:Connect(requestSummary)
		ActiveAssetsController.InitialLoadCompleted:Connect(tryInitialize)
		Save.Loaded:Connect(tryInitialize)
		task.defer(tryInitialize)
	end
}