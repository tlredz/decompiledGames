local AdService = game:GetService("AdService")
local LocalizationService = game:GetService("LocalizationService")
local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local FullscreenPresentation = require(ReplicatedStorage.Client.FullscreenPresentation)
local GameFlags = require(ReplicatedStorage.Shared.Flags.GameFlags)
local localPlayer = Players.LocalPlayer
local v = {}
local v2 = {}
local v3 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function hideIneligible(instance)
	if not v3[instance] then
		v3[instance] = instance.Destroying:Once(function()
			v3[instance] = nil
		end)
	end

	instance.Parent = nil
end

local function dispose(model)
	if v2[model] then
		v2[model]:Disconnect()
		v2[model] = nil
	end

	local v4 = v[model]

	if not v4 then
		return
	end

	v[model] = nil

	for _, connection in v4.connections do
		connection:Disconnect()
	end

	if v4.session then
		v4.session.Close()
	end

	for _, tween in v4.tweens do
		tween:Cancel()
		tween:Destroy()
	end

	if v4.disclaimer then
		v4.disclaimer:Destroy()
	end

	if v4.video and v4.video.Parent then
		v4.video:Pause()
	end
end

local function bind(model)
	if model.Name ~= "ForbiddenIsland" or not model:IsA("Model") or v[model] then
		return
	end

	local display = model:FindFirstChild("Display")
	local adGUI = display and display:FindFirstChild("AdGUI")
	local videoFrame = adGUI and adGUI:FindFirstChild("VideoFrame")
	local clickDetector = display and display:FindFirstChild("ClickDetector")
	local watchingGUI = model:FindFirstChild("WatchingGUI")
	local disclaimerGUI = model:FindFirstChild("DisclaimerGUI")
	local adDisclosure = disclaimerGUI and disclaimerGUI:FindFirstChild("AdDisclosure")

	if disclaimerGUI then
		disclaimerGUI.Enabled = false
	end

	local hintGUI = model:FindFirstChild("HintGUI")
	local hintHighlight = model:FindFirstChild("HintHighlight")
	local hintIcon = hintGUI and hintGUI:FindFirstChild("HintIcon")
	local uIScale = hintIcon and hintIcon:FindFirstChildOfClass("UIScale")
	local watchStarted = model:FindFirstChild("WatchStarted")
	local watchEnded = model:FindFirstChild("WatchEnded")
	local watchLooped = model:FindFirstChild("WatchLooped")
	local watched = model:FindFirstChild("Watched")

	if not (display and adGUI and videoFrame and clickDetector and watchingGUI and disclaimerGUI and adDisclosure and hintGUI and hintHighlight and uIScale and watchStarted and watchEnded and watchLooped and watched) then
		return
	end

	local v4 = {
		connections = {},
		tweens = {},
		video = videoFrame
	}
	v[model] = v4

	if v2[model] then
		v2[model]:Disconnect()
		v2[model] = nil
	end

	adGUI.Enabled = false
	hintGUI.Enabled = false
	hintHighlight.Enabled = false
	videoFrame:Pause()

	local function current()
		return v[model] == v4 and model:IsDescendantOf(Workspace)
	end

	task.spawn(function()
		local success, countryRegionForPlayerAsync = pcall(
			LocalizationService.GetCountryRegionForPlayerAsync,
			LocalizationService,
			localPlayer
		)
		local v5

		if v[model] == v4 then
			v5 = model:IsDescendantOf(Workspace)
		else
			v5 = false
		end

		if not v5 then
			return
		end

		local parts = tostring(model:GetAttribute("RegionCodes") or ""):split()
		local v6 = table.find(parts, countryRegionForPlayerAsync) ~= nil

		if model:GetAttribute("RegionFilterType") ~= "Whitelist" then
			v6 = not v6
		end

		if success and v6 then
			local success2, policyInfoForPlayerAsync = pcall(
				PolicyService.GetPolicyInfoForPlayerAsync,
				PolicyService,
				localPlayer
			)
			local v7

			if v[model] == v4 then
				v7 = model:IsDescendantOf(Workspace)
			else
				v7 = false
			end

			if not v7 then
				return
			end

			if success2 and policyInfoForPlayerAsync and policyInfoForPlayerAsync.AreAdsAllowed then
				local campaignID = model:GetAttribute("CampaignID")

				if campaignID and campaignID ~= "" then
					local success3, campaignEligibilityAsync = pcall(
						AdService.GetCampaignEligibilityAsync,
						AdService,
						campaignID
					)
					local v8

					if v[model] == v4 then
						v8 = model:IsDescendantOf(Workspace)
					else
						v8 = false
					end

					if not v8 then
						return
					end

					if not (success3 and campaignEligibilityAsync and campaignEligibilityAsync.IsEligible) then
						hideIneligible(model) -- equivalent call inferred; original call site unknown
						return
					end
				end

				local placementID = tostring(model:GetAttribute("PlacementID") or "")

				if placementID ~= "" then
					local playerGui = localPlayer:WaitForChild("PlayerGui")
					local v8

					if v[model] == v4 then
						v8 = model:IsDescendantOf(Workspace)
					else
						v8 = false
					end

					if not v8 then
						return
					end

					local clone = disclaimerGUI:Clone()
					v4.disclaimer = clone
					clone.ResetOnSpawn = false
					clone.Adornee = model
					clone.Parent = playerGui
					local success3, result = pcall(
						AdService.RegisterDisclosureButton,
						AdService,
						clone.AdDisclosure,
						placementID
					)
					local v9

					if v[model] == v4 then
						v9 = model:IsDescendantOf(Workspace)
					else
						v9 = false
					end

					if not v9 then
						return
					end

					if success3 then
						clone.Enabled = GameFlags.ForbiddenIslandEnabled:Get()
					else
						warn("ForbiddenIsland disclosure registration failed", result)
						hideIneligible(model) -- equivalent call inferred; original call site unknown
						return
					end
				end

				videoFrame.Video = "rbxassetid://" .. tostring(model:GetAttribute("VideoID"))
				local enabled = false

				-- equivalent calls inferred from this helper; original call sites unknown
				local function updateHints()
					local enabled2 = enabled and not v4.session and GameFlags.ForbiddenIslandEnabled:Get()
					hintGUI.Enabled = enabled2
					hintHighlight.Enabled = enabled2
				end

				local function finishWatch()
					if not v4.session then
						return
					end

					v4.session = nil

					if v4.loopConnection then
						v4.loopConnection:Disconnect()
						v4.loopConnection = nil
					end

					local v9

					if v[model] == v4 then
						v9 = model:IsDescendantOf(Workspace)
					else
						v9 = false
					end

					if v9 and watchEnded:IsDescendantOf(Workspace) then
						watchEnded:FireServer()
						updateHints() -- equivalent call inferred; original call site unknown
					end
				end

				table.insert(v4.connections, clickDetector.MouseClick:Connect(function(p)
					if p == localPlayer then
						local v9

						if v[model] == v4 then
							v9 = model:IsDescendantOf(Workspace)
						else
							v9 = false
						end

						if v9 and enabled and adGUI.Enabled and not v4.session and GameFlags.ForbiddenIslandEnabled:Get() then
							local session = FullscreenPresentation.Open(model, display, watchingGUI)

							if not session then
								return
							end

							v4.session = session
							session.Closed:Once(finishWatch)
							updateHints() -- equivalent call inferred; original call site unknown
							watchStarted:FireServer()
							v4.loopConnection = videoFrame.DidLoop:Connect(function()
								local v11

								if v[model] == v4 then
									v11 = model:IsDescendantOf(Workspace)
								else
									v11 = false
								end

								if not v11 or not v4.session or v4.session.IsClosed() then
									return
								end

								watchEnded:FireServer()
								watchStarted:FireServer()
								watchLooped:FireServer()
								watched:Fire()
							end)
						end
					end
				end))
				table.insert(v4.connections, adGUI:GetPropertyChangedSignal("Enabled"):Connect(function()
					if not adGUI.Enabled and v4.session then
						v4.session.Close()
					end
				end))
				local total = 0
				table.insert(v4.connections, RunService.Heartbeat:Connect(function(dt)
					total += dt

					if total < 0.1 then
						return
					end

					total = 0
					local v9

					if v[model] == v4 then
						v9 = model:IsDescendantOf(Workspace)
					else
						v9 = false
					end

					if not v9 then
						dispose(model)
						return
					end

					local character = localPlayer.Character
					local humanoid = character and character:FindFirstChildOfClass("Humanoid")
					local v10

					if humanoid == nil or not (humanoid.Health > 0 and (character:GetPivot().Position - model:GetPivot().Position).Magnitude <= 48) then
						v10 = false
					else
						v10 = GameFlags.ForbiddenIslandEnabled:Get()
					end

					if v10 == enabled then
						return
					end

					enabled = v10
					adGUI.Enabled = enabled

					if not enabled and v4.session then
						v4.session.Close()
					end

					updateHints() -- equivalent call inferred; original call site unknown

					if enabled then
						videoFrame:Play()
					else
						videoFrame:Pause()
					end

					for _, tween in v4.tweens do
						tween:Cancel()
						tween:Destroy()
					end

					table.clear(v4.tweens)
					local tweenInfo

					if enabled then
						tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut, -1, true)
					else
						tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
					end

					table.insert(v4.tweens, TweenService:Create(hintHighlight, tweenInfo, {
						OutlineTransparency = enabled and 0 or 1
					}))
					table.insert(v4.tweens, TweenService:Create(uIScale, tweenInfo, {
						Scale = enabled and 0.75 or 1
					}))

					for _, tween in v4.tweens do
						tween:Play()
					end
				end))
				return
			end
		end

		hideIneligible(model) -- equivalent call inferred; original call site unknown
	end)
end

local function observe(model)
	if model.Name ~= "ForbiddenIsland" or not model:IsA("Model") then
		return
	end

	if v3[model] then
		v3[model]:Disconnect()
		v3[model] = nil
	end

	if not (v[model] or v2[model]) then
		v2[model] = model.DescendantAdded:Connect(function()
			bind(model)
		end)
	end

	bind(model)
end

Workspace.ChildAdded:Connect(observe)
Workspace.ChildRemoved:Connect(dispose)
GameFlags.ForbiddenIslandEnabled.Changed:Connect(function(enabled)
	for _, v4 in v do
		if v4.disclaimer then
			v4.disclaimer.Enabled = enabled
		end
	end

	if not enabled then
		for _, v4 in v do
			if v4.session then
				v4.session.Close()
			end
		end
	end
end)

for _, child in Workspace:GetChildren() do
	observe(child)
end

return table.freeze({})