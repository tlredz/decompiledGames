-- failed to load script (decompiled with syntax error):
-- ptSrqiVfyqKPXmnwHuOATerDq:292: Expected identifier when parsing expression, got ';'

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local packages = ReplicatedStorage:WaitForChild("packages")
require(packages:WaitForChild("Signal"))
local Trove = require(packages:WaitForChild("Trove"))
local Net = require(packages:WaitForChild("Net"))
local library = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("library"))
local SharedTimeFlowPuzzle = require(ReplicatedStorage.shared.modules.SharedTimeFlowPuzzle)
local TimeFlowPuzzleController = require(ReplicatedStorage.client.legacyControllers.Locations.Sunstone.TimeFlowPuzzleController)
local DeferredSignalHackaround = require(ReplicatedStorage.shared.modules.DeferredSignalHackaround)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local hud = playerGui:WaitForChild("hud")
local backpack = playerGui:WaitForChild("backpack")
local parent = script.Parent
local resources = ReplicatedStorage:WaitForChild("resources")
local animations = resources:WaitForChild("animations")
local sfx = resources.sounds:WaitForChild("sfx")
local replicated = resources:WaitForChild("replicated")
local fishing = replicated:WaitForChild("fishing")
local fishing2 = sfx:WaitForChild("fishing")
local remoteFunction = Net:RemoteFunction("SpearFishing/Minigame", -1)
local remoteEvent = Net:RemoteEvent("SpearFishing/GeodeBlockerMinigame")
local remoteEvent2 = Net:RemoteEvent("SpearFishing/Minigame/ProgressGain")
local spear = library.spears[parent.Name]
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local EnchantReminder = require(ReplicatedStorage.client.modules.EnchantReminder)
local spearEnchants = require(ReplicatedStorage.shared.modules.library.spears.spearEnchants)
local playerDataReplicator = DataController.PlayerDataReplicator
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)

local function getSpearStats()
	if not spear then
		return spear
	end

	local copy = GeneralUtils.copy(spear, true)
	local v = playerDataReplicator:TryIndex({ "Spears", parent.Name })

	if v then
		spearEnchants:ApplyToStats(copy, { v.enchant, v.secondaryEnchant }, localPlayer)
	end

	return copy
end

local maid = Trove.new()
maid:AttachToInstance(script)
local v = spear
local tracksByName = {}
local now = 0
local v2 = false
local v3 = false

for _, animation in animations.spears:GetChildren() do
	tracksByName[animation.Name] = humanoid:LoadAnimation(animation)
end

local v4 = {}

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fastTween(p, tweenInfo, p2)
	local tween = TweenService:Create(p, tweenInfo, p2)
	tween.Completed:Once(function()
		tween:Destroy()
	end)
	tween:Play()
	return tween
end

local function impact(p, position, p2, p3, duration, p4, value)
	for _ = 0, p3, duration do
		p.Position = position:Lerp(
			position + UDim2.new(Random.new():NextNumber(-0.05, 0.05), 0, Random.new():NextNumber(-0.08, 0.08), 0),
			p2
		)

		if p4 then
			p.Rotation = 0 + (Random.new():NextNumber(-8, 8) - 0) * p2
		end

		p2 *= value or 0.9
		task.wait(duration)
	end

	p.Position = position
	p.Rotation = p4 and 0 or p.Rotation
end

local function pickClosest(list, value: number?)
	if not list or #list == 0 then
		return nil
	end

	local v5 = value or 1e999
	local v6 = nil

	for _, pVInstance in list do
		if not pVInstance:IsA("PVInstance") then
			continue
		end

		local magnitude = (pVInstance:GetPivot().Position - humanoidRootPart.Position).Magnitude

		if not (magnitude < v5) then
			continue
		end

		v6 = pVInstance
		v5 = magnitude
	end

	return v6
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getHotbarFrame()
	local hotbar = backpack:FindFirstChild("hotbar")
	local hotbarFolder = hotbar and hotbar:FindFirstChild("Folder")
	return hotbarFolder and hotbarFolder:FindFirstChild("Frame")
end

local function updateEnchantReminder()
	local hotbarFrame = getHotbarFrame() -- equivalent call inferred; original call site unknown

	if not hotbarFrame then
		return
	end

	local v5 = playerDataReplicator:TryIndex({ "Spears", parent.Name })
	EnchantReminder.Render({
		Frame = hotbarFrame,
		Prefix = "spear",
		Enchants = spearEnchants.Enchants,
		Entries = {
			{
				Name = v5 and v5.enchant
			},
			{
				Name = v5 and v5.secondaryEnchant,
				Size = UDim2.fromScale(1, 0.27)
			}
		},
		Visible = parent.Parent == character
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearEnchantReminder()
	local hotbarFrame = getHotbarFrame() -- equivalent call inferred; original call site unknown

	if hotbarFrame then
		EnchantReminder.Clear(hotbarFrame, "spear")
	end
end

local function refreshGunStats()
	if not spear then
		return
	end

	local copy = GeneralUtils.copy(spear, true)
	local v5 = playerDataReplicator:TryIndex({ "Spears", parent.Name })

	if v5 then
		spearEnchants:ApplyToStats(copy, { v5.enchant, v5.secondaryEnchant }, localPlayer)
	end

	v = copy
end

local function startMinigame(p, jab, p2)
	if playerGui:FindFirstChild("stab") then
		return false
	end

	local bindableEvent = Instance.new("BindableEvent")
	local clone = replicated.fishing.stab:Clone()

	if p2 == "_geode_" then
		clone.bar.playerbar.icon.ImageTransparency = 1
	end

	maid:Add(clone)
	character:SetAttribute("SpearfishingWalkSpeed", 0)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	maid:Add(function()
		character:SetAttribute("SpearfishingWalkSpeed", nil)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		now = tick()
	end)
	bindableEvent.Event:Once(function()
		bindableEvent:Destroy()
	end)
	local v5 = {
		Ended = bindableEvent.Event,
		Success = nil
	}
	local bar = clone.bar
	local bar2 = bar:WaitForChild("progress"):WaitForChild("bar")
	local playerbar = bar:WaitForChild("playerbar")
	local random = Random.new()
	local flag = false
	local flag2 = false
	local v6 = 0
	local v7 = 20
	local flag3 = false
	local flag4 = false
	local lastTime = tick()

	local function pause()
		local backgroundColor3 = playerbar.BackgroundColor3
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		;(fastTween(playerbar, tweenInfo, {
			BackgroundColor3 = Color3.fromRGB(109, 109, 109)
		})).Completed:Wait()
		flag2 = true
		task.wait(0.5)
		flag2 = false
		;(fastTween(playerbar, tweenInfo, {
			BackgroundColor3 = backgroundColor3
		})).Completed:Wait()
		lastTime = tick()
	end

	local function updateInputUI()
		local preferredInput = UserInputService.PreferredInput

		if preferredInput == Enum.PreferredInput.KeyboardAndMouse then
			bar.pc.Visible = true
			playerbar.xboxcontrol.Visible = false
			bar.mobile.Visible = false
		elseif preferredInput == Enum.PreferredInput.Gamepad then
			bar.pc.Visible = false
			playerbar.xboxcontrol.Visible = true
			bar.mobile.Visible = false
		elseif preferredInput == Enum.PreferredInput.Touch then
			bar.pc.Visible = false
			playerbar.xboxcontrol.Visible = false
			bar.mobile.Visible = true
		end
	end

	local function validateInput(inputObject)
		return inputObject:IsA("InputObject") and (inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.KeyCode == Enum.KeyCode.Space or inputObject.UserInputType == Enum.UserInputType.Touch or inputObject.KeyCode == Enum.KeyCode.ButtonA)
	end

	local function visualizeBadClick()
		local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true)
		fastTween(bar2, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Size = UDim2.fromScale(v7 / 100, bar2.Size.Y.Scale)
		}) -- equivalent call inferred; original call site unknown
		;(fastTween(bar2, tweenInfo, {
			BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		})).Completed:Wait()
	end

	local function visualizePierce()
		local clone2 = fishing.slashes["Default Slash"]:Clone()
		clone2.ImageTransparency = 0
		clone2.Rotation = random:NextInteger(1, 360)
		clone2.Size = UDim2.fromScale(0, 0)
		local color = Color3.fromRGB(150, 0, 0)
		local lerped = color:Lerp(Color3.new(0, 0, 0), 0.5)
		clone2.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, lerped),
			ColorSequenceKeypoint.new(0.2, lerped),
			ColorSequenceKeypoint.new(0.5, color),
			ColorSequenceKeypoint.new(0.8, lerped),
			ColorSequenceKeypoint.new(1, lerped)
		})
		clone2.Parent = playerbar.icon
		local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		fastTween(clone2, tweenInfo, {
			Size = UDim2.fromScale(7, 7)
		}) -- equivalent call inferred; original call site unknown
		task.delay(tweenInfo.Time, function()
			;(fastTween(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Size = UDim2.fromScale(7, 4.75),
				ImageTransparency = 1
			})).Completed:Once(function()
				clone2:Destroy()
			end)
		end)
		local clone3 = fishing2.slashes.stabbystab:Clone()
		clone3.Parent = humanoidRootPart
		clone3.PlaybackSpeed = 1 + random:NextNumber(-0.1, 0.1)
		clone3:Play()
		clone3.Ended:Once(function()
			clone3:Destroy()
		end)
	end

	local v8 = library.fish[p]
	local orderedRarityNames = library.rarities.OrderedRarityNames
	local v9 = (table.find(orderedRarityNames, v8.Rarity) or 2) - 1
	local v10 = 0.05 * v9
	local v11 = 5 + v9
	local spearStats = getSpearStats()
	local handling = spearStats.Handling
	local piercing = spearStats.Piercing
	local power = spearStats.Power
	local v12 = v10 * (handling / 100 - 1)
	maid:Add(UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(updateInputUI))
	updateInputUI()
	task.wait(0.8)
	clone.Parent = playerGui
	updateInputUI()
	maid:Add(RunService.PostSimulation:Connect(function(dt)
		if flag or flag2 then
			return
		end

		bar2.Size = UDim2.fromScale(v7 / 100, bar2.Size.Y.Scale)

		if not flag then
			if v7 <= 0 then
				flag = true
				v5.Success = false
				bindableEvent:Fire()
				return
			elseif v7 >= 100 then
				flag = true
				v5.Success = true
				bindableEvent:Fire()
				return
			end
		end

		v7 = math.max(0, v7 - dt * v11 * ((handling + 100) / 100))
		local v13 = v6
		v6 = math.max(v6, v7)

		if v6 > 25 and v13 <= 25 then
			jab:Play()
		elseif v6 > 50 and v13 <= 50 then
			jab:Play()
		elseif v6 > 75 and v13 <= 75 then
			jab:Play()
		end

		if tick() - lastTime > 2 and not flag3 then
			flag3 = true

			if random:NextNumber(0, 100) <= v12 then
				pause()
			end

			lastTime = tick()
			flag3 = false
		end
	end))
	local position = bar.Position
	local stab = script.Stab
	maid:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed and input.KeyCode ~= Enum.KeyCode.ButtonA or not validateInput(input) or (flag4 or flag) then
			return
		end

		flag4 = true

		if flag2 then
			v7 = math.max(0, v7 - 10)
			visualizeBadClick()
			flag4 = false
		else
			task.delay(0.1, function()
				flag4 = false
			end)

			if random:NextNumber(0, 100) <= piercing then
				v7 = math.min(100, v7 + power * 3)
				visualizePierce()
			else
				v7 = math.min(100, v7 + power)
				local v13 = v7 / 100
				task.spawn(impact, bar, position, v13 / 20, 0.3, 0.01, true)
				playerbar.BackgroundColor3 = Color3.fromRGB(190, 190, 190)
				playerbar.Size = UDim2.fromScale(0.35 - v13 / 10, 1.3)
				fastTween(playerbar, TweenInfo.new(0.3, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
					Size = UDim2.fromScale(0.35, 1.3),
					BackgroundColor3 = Color3.fromRGB(241, 241, 241)
				}) -- equivalent call inferred; original call site unknown
				stab.PlaybackSpeed = v13 + 0.8
				stab:Play()
			end
		end
	end))
	maid:Add(remoteEvent2.OnClientEvent:Connect(function(p3, p4)
		if p4 ~= p2 then
			return
		end

		v7 += p3
		task.spawn(impact, bar, position, p3 / 20, 0.3, 0.01, true)
	end))
	return v5
end

local overlapParams = OverlapParams.new()
overlapParams.IncludeInstances = { workspace.active:WaitForChild("roamingFish") }
parent.Activated:Connect(function()
	if not v2 or v3 or playerGui:FindFirstChild("stab") or playerGui:FindFirstChild("reel") or playerGui:FindFirstChild("harpoonMinigame") or tick() - now < 1 then
		return
	end

	v3 = true
	local charge = tracksByName.charge
	charge.Priority = Enum.AnimationPriority.Action3
	charge.Looped = false
	charge:Play()
	table.insert(v4, charge)
	local jab = tracksByName.jab
	jab.Priority = Enum.AnimationPriority.Action4
	local v5 = pickClosest((CollectionService:GetTagged("SpearfishingZone")))
	local zoneFish = v5 and v5:FindFirstChild("ZoneFish")
	local v6 = zoneFish and pickClosest(zoneFish:GetChildren(), v.Range)

	if not (v6 and v6:GetAttribute("UID")) then
		v6 = nil
	end

	if not v6 then
		local v7 = pickClosest((workspace:GetPartBoundsInRadius(humanoidRootPart.Position, v.Range + 2, overlapParams)))

		if v7 and v7:GetAttribute("UID") then
			v6 = v7
		end
	end

	charge.Stopped:Wait()
	charge:Play()
	charge.TimePosition = charge.Length * 0.9
	charge:AdjustSpeed(0)

	if v6 then
		if not v6:GetAttribute("FishName") then
			local _ = v6.Name
		end

		remoteFunction:InvokeServer(v6:GetAttribute("UID"), nil, v6:HasTag("RoamingFishHitbox"))
	else
		local nearestRoughGeodeBlocker, v7 = SharedTimeFlowPuzzle.Functions.GetNearestRoughGeodeBlocker(localPlayer, 15)
		local completionStateObject = TimeFlowPuzzleController.GetCompletionStateObject("ClearedDebrisUIDs")

		if completionStateObject and nearestRoughGeodeBlocker then
			local v8 = completionStateObject:Get()

			if not table.find(v8, v7) then
				remoteEvent:FireServer(v7)
				hud.Enabled = false
				backpack.Enabled = false
				fastTween(
					workspace.CurrentCamera,
					TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						FieldOfView = 56
					}
				) -- equivalent call inferred; original call site unknown
				local v9 = startMinigame("Motoro Stingray", jab, "_geode_")
				v9.Ended:Wait()
				hud.Enabled = true
				backpack.Enabled = true

				if v9.Success then
					local tween = TweenService:Create(
						workspace.CurrentCamera,
						TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							FieldOfView = 70
						}
					)
					tween.Completed:Once(function()
						tween:Destroy()
					end)
					tween:Play()
				else
					local tween = TweenService:Create(
						workspace.CurrentCamera,
						TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 1),
						{
							FieldOfView = 70
						}
					)
					tween.Completed:Once(function()
						tween:Destroy()
					end)
					tween:Play()
				end

				maid:Destroy()

				if v9 and v9.Success then
					TimeFlowPuzzleController.ClearGeodeBlocker(v7)
				end

				remoteEvent:FireServer(v7, v9.Success)
			end
		end
	end

	charge:AdjustSpeed(1)
	jab:Play()
	table.insert(v4, jab)
	jab.Stopped:Wait()
	v3 = false
end)
parent.Equipped:Connect(function()
	v2 = true
	updateEnchantReminder()
	local idle = tracksByName.idle
	idle.Priority = Enum.AnimationPriority.Idle
	idle.Looped = true
	idle:Play()
	table.insert(v4, idle)
end)
parent.Unequipped:Connect(function()
	v2 = false
	clearEnchantReminder() -- equivalent call inferred; original call site unknown

	if maid then
		maid:Destroy()
	end

	for k, v5 in v4 do
		if v5 and (v5.IsPlaying or v5 == tracksByName.idle) then
			v5:AdjustWeight(0, 0.1)
			v5:Stop()
		end

		table.remove(v4, k)
	end
end)
local v5 = playerDataReplicator:Observe({ "Spears", parent.Name }, function()
	if parent.Parent == character then
		updateEnchantReminder()
	end
end)
DeferredSignalHackaround.Once(script.Destroying, function()
	v5()
	clearEnchantReminder() -- equivalent call inferred; original call site unknown

	if maid then
		maid:Destroy()
	end

	for k, v6 in v4 do
		if v6 and (v6.IsPlaying or v6 == tracksByName.idle) then
			v6:AdjustWeight(0, 0.1)
			v6:Stop()
		end

		table.remove(v4, k)
	end
end)