return {
	Start = function()
		print("[TreadmillAdPopup] Booted")
		local Players = game:GetService("Players")
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local RunService = game:GetService("RunService")
		local AdEggBoostClient = require(script.AdEggBoostClient)
		local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
		local GUI = require(ReplicatedStorage.Client.GUI)
		require(ReplicatedStorage.Shared.Audio)
		local adEggBoostRemotes = ReplicatedStorage:WaitForChild("AdEggBoostRemotes")
		local Remotes = require(ReplicatedStorage.Shared.Remotes)
		local Sparkles = require(ReplicatedStorage.Client.UI.VFX.Sparkles)
		local TweenService = game:GetService("TweenService")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function dbg(p: string)
			print("[TreadmillAdPopup]", p)
		end

		local v = false
		local v2 = false
		local flag = false
		local flag2 = false
		local v3 = false
		local v4 = 0
		local adEggBoostPopupUI = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("AdEggBoostPopupUI")
		local container = adEggBoostPopupUI:WaitForChild("Container")
		local uIScale = container:WaitForChild("UIScale")
		local close = container:WaitForChild("Close")
		local claim = container:WaitForChild("Claim")
		local select = container:WaitForChild("Select")
		local shine = select:WaitForChild("Shine")
		local audio = adEggBoostPopupUI:WaitForChild("Audio")
		local onHover = audio:WaitForChild("OnHover")
		local onOpen = audio:WaitForChild("OnOpen")
		local onClick = audio:WaitForChild("OnClick")
		adEggBoostPopupUI.ResetOnSpawn = false
		select.Visible = false
		shine.Offset = Vector2.new(1, 0)
		local renderSteppedConnection = nil
		local total = 0

		-- equivalent calls inferred from this helper; original call sites unknown
		local function startPulse()
			if renderSteppedConnection then
				return
			end

			total = 0
			renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
				if not flag then
					return
				end

				total += dt
				uIScale.Scale = math.sin(total * 2.0943951023931953) * 0.02 + 1 + v4
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function stopPulse()
			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end

			v4 = 0
			uIScale.Scale = 1
		end

		local eggImage = container:WaitForChild("Design"):WaitForChild("EggImage")
		local thread = nil
		local flag3 = false

		local function rattleEgg()
			if flag3 then
				return
			end

			flag3 = true
			local total2 = 0

			while total2 < 2 do
				total2 += RunService.RenderStepped:Wait()
				local v5 = 1 - total2 / 2
				eggImage.Rotation = math.sin(total2 * 9.42477796076938) * 10 * v5
			end

			eggImage.Rotation = 0
			flag3 = false
		end

		local function runRattleLoop()
			while flag do
				local v5 = 5 + math.random() * 5
				task.wait(v5)

				if flag then
					rattleEgg()
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function startRattle()
			if thread then
				return
			end

			thread = task.spawn(runRattleLoop)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function stopRattle()
			if thread then
				task.cancel(thread)
				thread = nil
			end

			eggImage.Rotation = 0
			flag3 = false
		end

		local v5 = nil
		local v6 = nil

		local function startSparkles()
			if not v5 then
				v5 = Sparkles(eggImage, {
					Size = 0.6,
					Pace = 2,
					Lanes = 7
				})
			end

			if not v6 then
				v6 = Sparkles(container, {
					Size = 0.3,
					Pace = 1,
					Lanes = 1
				})
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function clearSparkles()
			if v5 then
				v5()
				v5 = nil
			end

			if v6 then
				v6()
				v6 = nil
			end
		end

		local function showPopup()
			if flag then
				dbg("showPopup skipped - already visible") -- equivalent call inferred; original call site unknown
				return
			end

			dbg("showPopup") -- equivalent call inferred; original call site unknown
			flag = true
			adEggBoostRemotes.LogTelemetry:FireServer("RegisterOpportunity")
			adEggBoostPopupUI.Enabled = true
			uIScale.Scale = 1.35
			TweenService:Create(uIScale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Scale = 1
			}):Play()
			onOpen:Play()
			startPulse() -- equivalent call inferred; original call site unknown
			startSparkles()
			task.spawn(rattleEgg)
			startRattle() -- equivalent call inferred; original call site unknown
		end

		local function hidePopup()
			if not flag then
				return
			end

			dbg("hidePopup") -- equivalent call inferred; original call site unknown
			flag = false
			stopPulse() -- equivalent call inferred; original call site unknown
			clearSparkles() -- equivalent call inferred; original call site unknown
			stopRattle() -- equivalent call inferred; original call site unknown
			select.Visible = false
			TweenService:Create(uIScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Scale = 0
			}):Play()
			task.delay(0.2, function()
				if not flag then
					adEggBoostPopupUI.Enabled = false
					uIScale.Scale = 1
				end
			end)
		end

		local function tryShowPrompt()
			dbg("tryShowPrompt: silenced=" .. tostring(v2) .. " onTreadmill=" .. tostring(v) .. " adPending=" .. tostring(flag2)) -- equivalent call inferred; original call site unknown

			if v2 or not v or flag2 or AdEggBoostClient.IsGated() then
				dbg("tryShowPrompt - blocked") -- equivalent call inferred; original call site unknown
			else
				task.spawn(function()
					dbg("tryShowPrompt - checking ad availability") -- equivalent call inferred; original call site unknown
					local v8 = AdEggBoostClient.CheckAdAvailable()
					dbg("tryShowPrompt - available=" .. tostring(v8) .. " onTreadmill=" .. tostring(v) .. " silenced=" .. tostring(v2)) -- equivalent call inferred; original call site unknown

					if v8 and v and not v2 then
						showPopup()
					end
				end)
			end
		end

		local thread2 = nil

		local function easeLinear(p: number)
			return p
		end

		local function easeBackOut(p: number)
			local v7 = p - 1
			return v7 * v7 * (v7 * 2.70158 + 1.70158) + 1
		end

		local function sweepOffset(p: number, p2: number, callback)
			local v7 = p2 - p
			local total2 = 0

			while total2 < 0.2 do
				total2 += RunService.RenderStepped:Wait()
				local v8 = math.clamp(total2 / 0.2, 0, 1)
				shine.Offset = Vector2.new(p + v7 * callback(v8), 0)
			end

			shine.Offset = Vector2.new(p2, 0)
		end

		local function runShine()
			local X = shine.Offset.X

			if X < 1 then
				sweepOffset(X, 1, easeLinear)
			end

			shine.Offset = Vector2.new(-1, 0)
			sweepOffset(-1, 0, easeBackOut)
			thread2 = nil
		end

		local function startShine()
			if thread2 then
				task.cancel(thread2)
				thread2 = nil
			end

			local X = shine.Offset.X

			if X < 0 then
				thread2 = task.spawn(function()
					sweepOffset(X, 0, easeBackOut)
					thread2 = nil
				end)
			else
				thread2 = task.spawn(runShine)
			end
		end

		local function stopShine()
			if thread2 then
				task.cancel(thread2)
				thread2 = nil
			end
		end

		claim.MouseEnter:Connect(function()
			v3 = true
			select.Visible = true
			v4 = 0.08
			startShine()
			task.spawn(rattleEgg)
			onHover:Play()
		end)
		claim.MouseLeave:Connect(function()
			v3 = false
			select.Visible = false
			v4 = 0
		end)

		local function onClaimClicked()
			dbg("onClaimClicked") -- equivalent call inferred; original call site unknown

			if flag2 then
				dbg("onClaimClicked - blocked, ad pending") -- equivalent call inferred; original call site unknown
				return
			end

			onClick:Play()
			v4 = -0.08
			select.Visible = true
			task.delay(0.1, function()
				select.Visible = false
				v4 = 0
			end)
			flag2 = true
			hidePopup()
			AdEggBoostClient.RequestAd()
		end

		local function onCloseClicked()
			dbg("onCloseClicked - silencing for " .. 120 .. "s") -- equivalent call inferred; original call site unknown
			adEggBoostRemotes.LogTelemetry:FireServer("PopupDismissed")
			hidePopup()
			v2 = true
			task.delay(120, function()
				v2 = false
			end)
		end

		AdEggBoostClient.AdCompleted:Connect(function(_: boolean)
			flag2 = false

			if v then
				task.delay(30, tryShowPrompt)
			end
		end)
		Remotes.Treadmill.AssignedBeltShifted.OnClientEvent:Connect(function(p: string?)
			v = p ~= nil
			dbg("AssignedBeltShifted: treadmillId=" .. tostring(p) .. " onTreadmill=" .. tostring(v)) -- equivalent call inferred; original call site unknown

			if v then
				dbg("Mounted - waiting " .. 1 .. "s before tryShowPrompt") -- equivalent call inferred; original call site unknown
				task.delay(1, tryShowPrompt)
			else
				dbg("Dismounted - hiding popup") -- equivalent call inferred; original call site unknown
				hidePopup()
			end
		end)
		local guiObjects = {}

		for _, guiObject in container:GetDescendants() do
			if guiObject.Name == "Rays" and guiObject:IsA("GuiObject") then
				table.insert(guiObjects, guiObject)
			end
		end

		RunService.RenderStepped:Connect(function(dt: number)
			if not flag then
				return
			end

			for _, v7 in guiObjects do
				v7.Rotation = (v7.Rotation + dt * 22.5) % 360
			end
		end)
		GUI.OnActivated(claim, onClaimClicked)
		ButtonFX(claim, 1.08)
		GUI.OnActivated(close, onCloseClicked)
	end
}