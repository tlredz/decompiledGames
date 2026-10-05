local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.CUI)
local supportBar = require(ReplicatedStorage._FRAMEWORK.Features.supportBar)
require(script.Parent.Parent.Types)
return {
	DisplayName = "Support Bar",
	Permission = "cui.liveops.supportBar",
	Order = 35,
	Setup = function(object, _)
		if not RunService:IsClient() then
			return
		end

		local defaults = supportBar.getDefaults()
		local v = {}
		local v2 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setStatus(p: string)
			v2:SetText(p)
		end

		local function addPercentSlider(object2, p: string, p2: number, p3: number, callback, callback2)
			return object2:AddSlider(function(object3)
				object3:SetText(p):SetRange(0, p2):SetIncrement(p3):SetValue(callback() * 100):SetOnChanged(function(p4)
					callback2(p4 / 100)
				end)
			end)
		end

		local function syncInputs()
			v.active:SetValue(defaults.active)
			v.totalVotes:SetValue(defaults.totalVotes)
			v.totalNoise:SetValue(defaults.totalNoise * 100)
			v.totalGrowth:SetValue(defaults.totalGrowthPerMinute)
			v.cruzShare:SetValue(defaults.cruzShare * 100)
			v.shareNoise:SetValue(defaults.shareNoise * 100)
			v.drift:SetValue(defaults.driftPerSecond * 100)
			v.autoMode:SetValue(defaults.autoMode)
			v.autoMin:SetValue(defaults.autoMinShare * 100)
			v.autoMax:SetValue(defaults.autoMaxShare * 100)
			v.autoInterval:SetValue(defaults.autoIntervalSeconds)
		end

		local function push()
			supportBar.adminApply(defaults):andThen(function(p)
				setStatus(not p and "Request was rejected." or p.message) -- equivalent call inferred; original call site unknown
			end):catch(function(p)
				setStatus(`Failed: {tostring(p)}`) -- equivalent call inferred; original call site unknown
			end)
		end

		local function pull()
			setStatus("Reading server state...") -- equivalent call inferred; original call site unknown
			supportBar.adminFetch():andThen(function(p)
				if not p then
					setStatus("Request was rejected.") -- equivalent call inferred; original call site unknown
					return
				end

				defaults = p.config
				syncInputs()
				local snapshot = p.snapshot
				setStatus(`Saved globally - {not snapshot and "nothing broadcast yet" or `Cruz {snapshot.cruz} / Splink {snapshot.splink}`}`) -- equivalent call inferred; original call site unknown
			end):catch(function(p)
				setStatus(`Failed: {tostring(p)}`) -- equivalent call inferred; original call site unknown
			end)
		end

		object:AddTitle(function(object2)
			object2:SetTitle("Population")
		end)
		v.active = object:AddCheckbox(function(object2)
			object2:SetText("Show the bar"):SetValue(defaults.active):SetOnChanged(function(active)
				defaults.active = active
			end)
		end)
		v.totalVotes = object:AddNumberField(function(object2)
			object2:SetText("Players who voted"):SetNumberFilter(0, 1000000000000):SetValue(defaults.totalVotes):SetOnChangedUnfocus(function(p)
				defaults.totalVotes = math.round(p)
				object2:SetValue(defaults.totalVotes)
			end)
		end)

		local function fn()
			return defaults.totalNoise
		end

		local function fn2(totalNoise)
			defaults.totalNoise = totalNoise
		end

		local v3 = "Total noise (+/- %)"
		local v4 = 25
		local v5 = 1
		v.totalNoise = object:AddSlider(function(object2)
			object2:SetText(v3):SetRange(0, v4):SetIncrement(v5):SetValue(fn() * 100):SetOnChanged(function(p)
				fn2(p / 100)
			end)
		end)
		v.totalGrowth = object:AddNumberField(function(object2)
			object2:SetText("Votes gained per minute"):SetNumberFilter(-1000000000, 1000000000):SetValue(defaults.totalGrowthPerMinute):SetOnChangedUnfocus(function(p)
				defaults.totalGrowthPerMinute = math.round(p)
				object2:SetValue(defaults.totalGrowthPerMinute)
			end)
		end)
		object:AddTitle(function(object2)
			object2:SetTitle("Split")
		end)

		local function fn3()
			return defaults.cruzShare
		end

		local function fn4(cruzShare)
			defaults.cruzShare = cruzShare
		end

		local v6 = "Cruz target share (%)"
		local v7 = 100
		local v8 = 1
		v.cruzShare = object:AddSlider(function(object2)
			object2:SetText(v6):SetRange(0, v7):SetIncrement(v8):SetValue(fn3() * 100):SetOnChanged(function(p)
				fn4(p / 100)
			end)
		end)

		local function fn5()
			return defaults.shareNoise
		end

		local function fn6(shareNoise)
			defaults.shareNoise = shareNoise
		end

		local v9 = "Share noise (+/- points)"
		local v10 = 10
		local v11 = 0.5
		v.shareNoise = object:AddSlider(function(object2)
			object2:SetText(v9):SetRange(0, v10):SetIncrement(v11):SetValue(fn5() * 100):SetOnChanged(function(p)
				fn6(p / 100)
			end)
		end)

		local function fn7()
			return defaults.driftPerSecond
		end

		local function fn8(driftPerSecond)
			defaults.driftPerSecond = driftPerSecond
		end

		local v12 = "Drift toward target (points/s)"
		local v13 = 5
		local v14 = 0.1
		v.drift = object:AddSlider(function(object2)
			object2:SetText(v12):SetRange(0, v13):SetIncrement(v14):SetValue(fn7() * 100):SetOnChanged(function(p)
				fn8(p / 100)
			end)
		end)
		object:AddTitle(function(object2)
			object2:SetTitle("Auto mode")
		end)
		v.autoMode = object:AddCheckbox(function(object2)
			object2:SetText("Wander the target on its own"):SetValue(defaults.autoMode):SetOnChanged(function(autoMode)
				defaults.autoMode = autoMode
			end)
		end)
		object:AddSplit(function(p)
			local v15 = v
			local leftComponents = p.LeftComponents

			local function fn9()
				return defaults.autoMinShare
			end

			local function fn10(autoMinShare)
				defaults.autoMinShare = autoMinShare
			end

			local v16 = "Floor (%)"
			local v17 = 100
			local v18 = 1
			v15.autoMin = leftComponents:AddSlider(function(object2)
				object2:SetText(v16):SetRange(0, v17):SetIncrement(v18):SetValue(fn9() * 100):SetOnChanged(function(p2)
					fn10(p2 / 100)
				end)
			end)
			local v19 = v
			local rightComponents = p.RightComponents

			local function fn11()
				return defaults.autoMaxShare
			end

			local function fn12(autoMaxShare)
				defaults.autoMaxShare = autoMaxShare
			end

			local v20 = "Ceiling (%)"
			local v21 = 100
			local v22 = 1
			v19.autoMax = rightComponents:AddSlider(function(object2)
				object2:SetText(v20):SetRange(0, v21):SetIncrement(v22):SetValue(fn11() * 100):SetOnChanged(function(p2)
					fn12(p2 / 100)
				end)
			end)
		end)
		v.autoInterval = object:AddNumberField(function(object2)
			object2:SetText("Reroll target every (s)"):SetNumberFilter(1, 3600):SetValue(defaults.autoIntervalSeconds):SetOnChangedUnfocus(function(p)
				defaults.autoIntervalSeconds = math.round(p)
				object2:SetValue(defaults.autoIntervalSeconds)
			end)
		end)
		object:AddSeparator()
		object:AddSplit(function(p)
			p.LeftComponents:AddButton(function(object2)
				object2:SetButtonText("Apply"):SetEnabledPermission("cui.liveops.manage"):SetButtonCallback(push)
			end)
			p.RightComponents:AddButton(function(object2)
				object2:SetButtonText("Hide bar"):SetEnabledPermission("cui.liveops.manage"):SetButtonCallback(function()
					defaults.active = false
					v.active:SetValue(false)
					push()
				end)
			end)
		end)
		object:AddButton(function(object2)
			object2:SetButtonText("Read current state"):SetButtonCallback(pull)
		end)
		v2 = object:AddText(function(object2)
			object2:SetText("Not read yet."):SetAutoResize(true):SetTextSize(14)
		end)
		pull()
	end
}