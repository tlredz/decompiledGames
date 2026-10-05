local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Assets = require(ReplicatedStorage.Data.Assets)
local AssetViewport = require(ReplicatedStorage.Client.AssetViewport)
local GUI = require(ReplicatedStorage.Client.GUI)
return {
	Start = function()
		local onboardingQuestline = ReplicatedStorage.Data:FindFirstChild("OnboardingQuestline")

		if onboardingQuestline == nil then
			return
		end

		local module = require(onboardingQuestline)
		local OnboardingQuestlineFlags = require(ReplicatedStorage.Shared.Flags.OnboardingQuestlineFlags)
		local OnboardingQuestline = require(ReplicatedStorage.Shared.Types.OnboardingQuestline)
		local Remotes = require(ReplicatedStorage.Shared.Remotes)
		local Save = require(ReplicatedStorage.Shared.Save)
		local Audio = require(ReplicatedStorage.Shared.Audio)
		local Tabs = require(ReplicatedStorage.Client.Tabs)
		local Time = require(ReplicatedStorage.Shared.Utils.Time)
		local profileKey = module.ProfileKey
		local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local v = GUI.Get(module.ScreenName)
		local child = v:WaitForChild(module.ApiFolderName)
		local fTUEQuestMain = v:WaitForChild("FTUEQuestMain")
		local content = fTUEQuestMain:WaitForChild("Content")
		local info1 = content:WaitForChild("Info1")
		local info2 = content:WaitForChild("Info2")
		local text = info1.Text
		local text2 = info2.Text

		local function apiEvent(childName: string)
			local bindableEvent = child:WaitForChild(childName)
			assert(bindableEvent:IsA("BindableEvent"), (`RescueDragonAPI.{childName} must be a BindableEvent`))
			return bindableEvent
		end

		local open = child:WaitForChild("Open")
		assert(open:IsA("BindableEvent"), "RescueDragonAPI.Open must be a BindableEvent")
		local close = child:WaitForChild("Close")
		assert(close:IsA("BindableEvent"), "RescueDragonAPI.Close must be a BindableEvent")
		local loadQuestSet = child:WaitForChild("LoadQuestSet")
		assert(loadQuestSet:IsA("BindableEvent"), "RescueDragonAPI.LoadQuestSet must be a BindableEvent")
		local setQuest = child:WaitForChild("SetQuest")
		assert(setQuest:IsA("BindableEvent"), "RescueDragonAPI.SetQuest must be a BindableEvent")
		local claimQuest = child:WaitForChild("ClaimQuest")
		assert(claimQuest:IsA("BindableEvent"), "RescueDragonAPI.ClaimQuest must be a BindableEvent")
		local unlockNextLock = child:WaitForChild("UnlockNextLock")
		assert(unlockNextLock:IsA("BindableEvent"), "RescueDragonAPI.UnlockNextLock must be a BindableEvent")
		local resetAll = child:WaitForChild("ResetAll")
		assert(resetAll:IsA("BindableEvent"), "RescueDragonAPI.ResetAll must be a BindableEvent")
		local claimClicked = child:WaitForChild("ClaimClicked")
		assert(claimClicked:IsA("BindableEvent"), "RescueDragonAPI.ClaimClicked must be a BindableEvent")
		local goNowClicked = child:WaitForChild("GoNowClicked")
		assert(goNowClicked:IsA("BindableEvent"), "RescueDragonAPI.GoNowClicked must be a BindableEvent")
		local closeClicked = child:WaitForChild("CloseClicked")
		assert(closeClicked:IsA("BindableEvent"), "RescueDragonAPI.CloseClicked must be a BindableEvent")
		local lockUnlocked = child:WaitForChild("LockUnlocked")
		assert(lockUnlocked:IsA("BindableEvent"), "RescueDragonAPI.LockUnlocked must be a BindableEvent")
		local allLocksUnlocked = child:WaitForChild("AllLocksUnlocked")
		assert(allLocksUnlocked:IsA("BindableEvent"), "RescueDragonAPI.AllLocksUnlocked must be a BindableEvent")
		local v2 = nil
		local setIndex = 0
		local v3 = {}
		local ids = {}
		local flag = true
		local v4 = false
		local v5 = 0
		local v6 = false
		local fn
		local rewardGranted = false
		local v7 = nil
		local v8 = nil
		local v9 = nil
		local parts = {}

		local function now()
			return Workspace:GetServerTimeNow()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function currentState()
			local v10 = Save.Await()

			if v10 then
				return (OnboardingQuestline.Reconcile(v10[profileKey]))
			end

			return nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function acknowledge(p)
			task.spawn(function()
				pcall(function()
					Remotes.OnboardingQuestline.AskAcknowledge:InvokeServer(p)
				end)
			end)
		end

		local function renderTimer(p)
			local v10 = v9

			if v10 == nil then
				return
			end

			if p.RewardGranted then
				v10.Text = "RESCUED!"
				return
			end

			local v11 = module.ExpiresAt(p) - Workspace:GetServerTimeNow()
			v10.Text = v11 <= 0 and "EXPIRED" or `{Time.Elapsed(v11)} LEFT`
		end

		local function playCue(p, p2, options)
			local sound = module.Sounds[p]
			assert(sound ~= nil, (`no sound slot named {p} in OnboardingQuestline.Sounds`))

			if sound == 0 then
				return nil
			end

			return Audio.Play(sound, p2 or script, options or {})
		end

		local function applyCageLocks(p: number, flag2: boolean)
			for k, v10 in parts do
				local v11 = k <= p

				if v11 and flag2 and v10.LocalTransparencyModifier < 1 then
					TweenService:Create(v10, tweenInfo, {
						LocalTransparencyModifier = 1
					}):Play()
				else
					v10.LocalTransparencyModifier = v11 and 1 or 0
				end

				v10.CanCollide = not v11
			end
		end

		local function showRewardScreen()
			local genericRewardScreen2 = GUI.PlayerGui():FindFirstChild("GenericRewardScreen2")
			assert(genericRewardScreen2 ~= nil, "PlayerGui is missing GenericRewardScreen2")
			local showReward = genericRewardScreen2:FindFirstChild("ShowReward")
			local v10

			if showReward == nil then
				v10 = false
			else
				v10 = showReward:IsA("BindableEvent")
			end

			assert(v10, "GenericRewardScreen2 has no ShowReward event; its RewardController did not start")
			local v11 = Assets.Directory[module.RewardAssetId]
			assert(v11 ~= nil, (`no asset config for {module.RewardAssetId}`))
			Tabs.Deactivate({
				instant = true
			})
			showReward:Fire({
				title = module.TitleComplete,
				item = v11.DisplayName,
				rarity = v11.Rarity._id,
				image = v11.Icon,
				autoClose = 0
			})
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setRescuedPresentation(flag2: boolean)
			local v10 = info1
			local text3

			if flag2 then
				text3 = module.TitleComplete
			else
				text3 = text
			end

			v10.Text = text3
			local v12 = info2
			local text4

			if flag2 then
				text4 = module.SubtitleComplete
			else
				text4 = text2
			end

			v12.Text = text4
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function renderEntryPoints(p)
			local shouldShowEntryPoint = module.ShouldShowEntryPoint(p, now())
			local v10 = v7

			if v10 ~= nil then
				v10.Enabled = shouldShowEntryPoint and not p.RewardGranted
			end

			local v11 = v8

			if v11 ~= nil then
				v11.Enabled = shouldShowEntryPoint
			end
		end

		local function loadSet(p)
			local questRows = module.BuildQuestRows(p)
			setIndex = p.SetIndex
			v3 = questRows
			ids = {}

			for k, v10 in module.GetActiveQuests(p) or {} do
				ids[k] = v10.Id
			end

			loadQuestSet:Fire(questRows)
		end

		local function everyRowClaimed()
			if #v3 == 0 then
				return false
			end

			for _, v10 in v3 do
				if v10.State ~= "Claimed" then
					return false
				end
			end

			return true
		end

		local function claimRow(p: number, p2)
			v3[p] = p2
			local questClaimed = module.Sounds.QuestClaimed
			assert(questClaimed ~= nil, "no sound slot named QuestClaimed in OnboardingQuestline.Sounds")

			if questClaimed ~= 0 then
				Audio.Play(questClaimed, script, {})
			end

			claimQuest:Fire(p)
			local flag2

			if #v3 == 0 then
				flag2 = false
			else
				local flag3 = true

				for _, v10 in v3 do
					if v10.State == "Claimed" then
						continue
					end

					flag2 = false
					flag3 = false
					break
				end

				if flag3 then
					flag2 = true
				end
			end

			if flag2 then
				v4 = true
				local keyEarned = module.Sounds.KeyEarned
				assert(keyEarned ~= nil, "no sound slot named KeyEarned in OnboardingQuestline.Sounds")

				if keyEarned == 0 then
					return
				else
					Audio.Play(keyEarned, script, {})
				end
			end
		end

		local function pushRows(items)
			for k, item in items do
				local v10 = v3[k]

				if v10 == nil then
					continue
				end

				if item.State == "Claimed" and v10.State ~= "Claimed" then
					v3[k] = item
					local questClaimed = module.Sounds.QuestClaimed
					assert(questClaimed ~= nil, "no sound slot named QuestClaimed in OnboardingQuestline.Sounds")

					if questClaimed ~= 0 then
						Audio.Play(questClaimed, script, {})
					end

					claimQuest:Fire(k)
					local flag2

					if #v3 == 0 then
						flag2 = false
					else
						local flag3 = true

						for _, v11 in v3 do
							if v11.State == "Claimed" then
								continue
							end

							flag2 = false
							flag3 = false
							break
						end

						if flag3 then
							flag2 = true
						end
					end

					if flag2 then
						v4 = true
						local keyEarned = module.Sounds.KeyEarned
						assert(keyEarned ~= nil, "no sound slot named KeyEarned in OnboardingQuestline.Sounds")

						if keyEarned ~= 0 then
							Audio.Play(keyEarned, script, {})
						end
					end
				elseif v10.Current ~= item.Current or v10.State ~= item.State or v10.ProgressText ~= item.ProgressText then
					local v11 = {
						Current = item.Current,
						Goal = item.Goal,
						ProgressText = item.ProgressText
					}

					if v10.State ~= item.State then
						v11.State = item.State
					end

					v3[k] = item
					setQuest:Fire(k, v11)
				end
			end
		end

		local function reconcile(data)
			v2 = data
			renderEntryPoints(data) -- equivalent call inferred; original call site unknown
			local v10 = v9

			if v10 ~= nil then
				if data.RewardGranted then
					v10.Text = "RESCUED!"
				else
					local v11 = module.ExpiresAt(data) - Workspace:GetServerTimeNow()
					v10.Text = v11 <= 0 and "EXPIRED" or `{Time.Elapsed(v11)} LEFT`
				end
			end

			if flag or v4 then
				return
			end

			if data.SetIndex == setIndex then
				if v5 ~= math.min(data.UnlockedPadlocks, module.PadlockCount) then
					fn(data)
				elseif not module.IsComplete(data) then
					pushRows(module.BuildQuestRows(data))
				end
			else
				if data.SetIndex == setIndex + 1 then
					local flag2 = false

					for k, v11 in v3 do
						if v11.State == "Claimed" then
							continue
						end

						local clone = table.clone(v11)
						clone.State = "Claimed"
						clone.Current = clone.Goal
						clone.ProgressText = v11.ProgressText
						v3[k] = clone
						local questClaimed = module.Sounds.QuestClaimed
						assert(questClaimed ~= nil, "no sound slot named QuestClaimed in OnboardingQuestline.Sounds")

						if questClaimed ~= 0 then
							Audio.Play(questClaimed, script, {})
						end

						claimQuest:Fire(k)
						local flag3

						if #v3 == 0 then
							flag3 = false
						else
							local flag4 = true

							for _, v12 in v3 do
								if v12.State == "Claimed" then
									continue
								end

								flag3 = false
								flag4 = false
								break
							end

							if flag4 then
								flag3 = true
							end
						end

						if flag3 then
							v4 = true
							local keyEarned = module.Sounds.KeyEarned
							assert(keyEarned ~= nil, "no sound slot named KeyEarned in OnboardingQuestline.Sounds")

							if keyEarned ~= 0 then
								Audio.Play(keyEarned, script, {})
							end
						end

						flag2 = true
					end

					if flag2 then
						return
					end
				end

				fn(data)
			end
		end

		fn = function(data)
			flag = true
			v4 = false
			rewardGranted = data.RewardGranted
			setRescuedPresentation(rewardGranted) -- equivalent call inferred; original call site unknown
			resetAll:Fire()
			v5 = math.min(data.UnlockedPadlocks, module.PadlockCount)

			for _ = 1, v5 do
				unlockNextLock:Fire()
			end

			applyCageLocks(v5, false)

			if module.IsComplete(data) then
				setIndex = data.SetIndex
			else
				loadSet(data)
			end

			flag = false
			reconcile(data)
		end

		local function openMenu()
			local v10 = v2

			if v10 == nil or not module.ShouldShowEntryPoint(v10, now()) then
				return
			end

			if not v4 and v5 ~= math.min(v10.UnlockedPadlocks, module.PadlockCount) then
				fn(v10)
			end

			Tabs.Deactivate({
				instant = true
			})
			v6 = true
			open:Fire()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function closeMenu()
			if not v6 then
				return
			end

			v6 = false
			close:Fire()
			local closeFrame = module.Sounds.CloseFrame
			assert(closeFrame ~= nil, "no sound slot named CloseFrame in OnboardingQuestline.Sounds")

			if closeFrame == 0 then
				return
			end

			Audio.Play(closeFrame, script, {})
		end

		local function claim(p: number)
			local v10 = ids[p]

			if v10 == nil then
				return
			end

			task.spawn(function()
				local success, result, v11 = pcall(function()
					return Remotes.OnboardingQuestline.AskClaim:InvokeServer(v10)
				end)

				if not success then
					warn((`[OnboardingQuestline] claim request failed: {result}`))
				elseif not result then
					local warning = module.Sounds.Warning
					assert(warning ~= nil, "no sound slot named Warning in OnboardingQuestline.Sounds")

					if warning ~= 0 then
						Audio.Play(warning, script, {})
					end

					warn((`[OnboardingQuestline] claim rejected: {tostring(v11)}`))
				end
			end)
		end

		local function bindCagePrompt()
			local child2 = Workspace:FindFirstChild(module.CageModelName)

			if child2 == nil then
				return
			end

			local rescueDragonPrompt = child2:FindFirstChild("RescueDragonPrompt", true)
			local v10

			if rescueDragonPrompt == nil then
				v10 = false
			else
				v10 = rescueDragonPrompt:IsA("ProximityPrompt")
			end

			assert(v10, (`Workspace.{module.CageModelName} needs a ProximityPrompt named RescueDragonPrompt`))
			v7 = rescueDragonPrompt
			rescueDragonPrompt.Enabled = false
			local rescueDragonTimer = child2:FindFirstChild("RescueDragonTimer", true)
			local v11

			if rescueDragonTimer == nil then
				v11 = false
			else
				v11 = rescueDragonTimer:IsA("BillboardGui")
			end

			assert(v11, (`Workspace.{module.CageModelName} needs a BillboardGui named RescueDragonTimer`))
			local countdown = rescueDragonTimer:FindFirstChild("Countdown", true)
			local v12

			if countdown == nil then
				v12 = false
			else
				v12 = countdown:IsA("TextLabel")
			end

			assert(v12, "RescueDragonTimer needs a TextLabel named Countdown")
			v8 = rescueDragonTimer
			v9 = countdown
			rescueDragonTimer.Enabled = false
			local cagedDragon = child2:FindFirstChild("CagedDragon")
			local v13

			if cagedDragon == nil then
				v13 = false
			else
				v13 = cagedDragon:IsA("Model")
			end

			assert(v13, (`Workspace.{module.CageModelName} needs a Model named CagedDragon`))
			AssetViewport.LoopIdle(module.RewardAssetId, cagedDragon)
			parts = {}

			for i = 1, module.PadlockCount do
				local part = child2:FindFirstChild("Lock" .. i)
				local v14

				if part == nil then
					v14 = false
				else
					v14 = part:IsA("BasePart")
				end

				assert(v14, (`Workspace.{module.CageModelName} needs a padlock part named Lock{i}`))
				parts[i] = part
			end

			applyCageLocks(v5, false)
			local v14 = v2

			if v14 ~= nil then
				renderEntryPoints(v14) -- equivalent call inferred; original call site unknown
				local v15 = v9

				if v15 == nil then
					return
				end

				if v14.RewardGranted then
					v15.Text = "RESCUED!"
				else
					local v16 = module.ExpiresAt(v14) - Workspace:GetServerTimeNow()
					v15.Text = v16 <= 0 and "EXPIRED" or `{Time.Elapsed(v16)} LEFT`
				end
			end
		end

		claimClicked.Event:Connect(claim)
		goNowClicked.Event:Connect(function()
			if not v6 then
				return
			end

			v6 = false
			close:Fire()
			local closeFrame = module.Sounds.CloseFrame
			assert(closeFrame ~= nil, "no sound slot named CloseFrame in OnboardingQuestline.Sounds")

			if closeFrame == 0 then
				return
			end

			Audio.Play(closeFrame, script, {})
		end)
		closeClicked.Event:Connect(function()
			v6 = false
			local closeFrame = module.Sounds.CloseFrame
			assert(closeFrame ~= nil, "no sound slot named CloseFrame in OnboardingQuestline.Sounds")

			if closeFrame == 0 then
				return
			end

			Audio.Play(closeFrame, script, {})
		end)
		lockUnlocked.Event:Connect(function()
			if flag then
				return
			end

			v5 += 1
			applyCageLocks(v5, true)
			task.wait(0.4)
			local v10 = v2

			if v10 ~= nil then
				if module.IsComplete(v10) then
					setIndex = v10.SetIndex
				else
					loadSet(v10)
				end
			end

			v4 = false

			if v10 ~= nil then
				reconcile(v10)
			end
		end)
		allLocksUnlocked.Event:Connect(function()
			if flag or rewardGranted then
				return
			end

			rewardGranted = true
			info1.Text = module.TitleComplete
			info2.Text = module.SubtitleComplete
			closeMenu() -- equivalent call inferred; original call site unknown
			showRewardScreen()
			acknowledge({
				Reward = true
			}) -- equivalent call inferred; original call site unknown
		end)
		fTUEQuestMain.ChildAdded:Connect(function(child2)
			if child2.Name == "FlyingKey" then
				local keyFlight = module.Sounds.KeyFlight
				assert(keyFlight ~= nil, "no sound slot named KeyFlight in OnboardingQuestline.Sounds")

				if keyFlight == 0 then
					return
				else
					Audio.Play(keyFlight, script, {})
				end
			end
		end)
		fTUEQuestMain.ChildRemoved:Connect(function(child2)
			if child2.Name == "FlyingKey" then
				local keyTurn = module.Sounds.KeyTurn
				assert(keyTurn ~= nil, "no sound slot named KeyTurn in OnboardingQuestline.Sounds")

				if keyTurn == 0 then
					return
				else
					Audio.Play(keyTurn, script, {})
				end
			end
		end)

		for i = 1, module.PadlockCount do
			local child2 = fTUEQuestMain:FindFirstChild("Lock" .. i)
			assert(child2 ~= nil, (`FTUEQuestMain needs a Lock{i} frame`))
			local v10 = i
			child2.ChildAdded:Connect(function(child3)
				if child3.Name ~= "LockUnlockedAnim" then
					return
				end

				local lockBreak = module.Sounds.LockBreak
				assert(lockBreak ~= nil, "no sound slot named LockBreak in OnboardingQuestline.Sounds")

				if lockBreak ~= 0 then
					Audio.Play(lockBreak, script, {})
				end

				local v11 = parts[v10]

				if v11 ~= nil then
					local v12 = {
						MaxDistance = 90
					}
					local lockBreak2 = module.Sounds.LockBreak
					assert(lockBreak2 ~= nil, "no sound slot named LockBreak in OnboardingQuestline.Sounds")

					if lockBreak2 ~= 0 then
						Audio.Play(lockBreak2, v11 or script, v12 or {})
					end
				end

				applyCageLocks(v10, true)
			end)
		end

		Tabs.Activated:Connect(function()
			if not v6 then
				return
			end

			v6 = false
			close:Fire()
			local closeFrame = module.Sounds.CloseFrame
			assert(closeFrame ~= nil, "no sound slot named CloseFrame in OnboardingQuestline.Sounds")

			if closeFrame == 0 then
				return
			end

			Audio.Play(closeFrame, script, {})
		end)
		ProximityPromptService.PromptTriggered:Connect(function(player)
			if player == v7 then
				openMenu()
			end
		end)
		OnboardingQuestlineFlags.Enabled.Changed:Connect(function(flag2: boolean)
			if not flag2 and v6 then
				v6 = false
				close:Fire()
				local closeFrame = module.Sounds.CloseFrame
				assert(closeFrame ~= nil, "no sound slot named CloseFrame in OnboardingQuestline.Sounds")

				if closeFrame ~= 0 then
					Audio.Play(closeFrame, script, {})
				end
			end

			local v10 = v2

			if v10 ~= nil then
				renderEntryPoints(v10) -- equivalent call inferred; original call site unknown
			end
		end)
		OnboardingQuestlineFlags.QuestTargets.Changed:Connect(function()
			local v10 = v2

			if v10 ~= nil and not (flag or v4) then
				fn(v10)
			end
		end)
		Workspace.ChildAdded:Connect(function(child2)
			if child2.Name == module.CageModelName then
				task.defer(bindCagePrompt)
			end
		end)
		bindCagePrompt()
		task.spawn(function()
			while true do
				local v10 = v2

				if v10 ~= nil then
					local v11 = v9

					if v11 ~= nil then
						if v10.RewardGranted then
							v11.Text = "RESCUED!"
						else
							local v12 = module.ExpiresAt(v10) - Workspace:GetServerTimeNow()
							v11.Text = v12 <= 0 and "EXPIRED" or `{Time.Elapsed(v12)} LEFT`
						end
					end

					renderEntryPoints(v10) -- equivalent call inferred; original call site unknown
				end

				task.wait(1)
			end
		end)
		local v10 = currentState() -- equivalent call inferred; original call site unknown

		if v10 ~= nil then
			fn(v10)

			if OnboardingQuestlineFlags.AutoOpenEnabled:Get() and module.ShouldShowEntryPoint(v10, now()) and module.HasClaimable(v10) then
				task.delay(1.25, function()
					if not Tabs.IsActive() then
						openMenu()
					end
				end)
			end
		end

		Save.WatchFields(profileKey, function()
			local v11 = currentState() -- equivalent call inferred; original call site unknown

			if v11 == nil then
				return
			end

			if v2 == nil then
				fn(v11)
			else
				reconcile(v11)
			end
		end)
	end
}