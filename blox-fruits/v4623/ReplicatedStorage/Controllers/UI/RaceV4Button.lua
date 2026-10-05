local TweenService = game:GetService("TweenService")
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
local MobileUIController = require(game.ReplicatedStorage.Controllers.UI.MobileUIController)
local localPlayer = game.Players.LocalPlayer
local v = nil
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Linear)
local v2 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function reflectLocked()
	local character = localPlayer.Character
	local raceEnergy = character:FindFirstChild("RaceEnergy")
	local raceTransformed = character:FindFirstChild("RaceTransformed")
	local visible = not raceEnergy or raceEnergy.Value < 1 or raceTransformed and raceTransformed.Value
	local lockedFrame = v:FindFirstChild("LockedFrame", true)
	lockedFrame.Visible = visible
end

local function raceEnergyMeterFlash()
	local WAIT_INTERVAL = 0.25
	local missing = localPlayer.PlayerGui.Main.RaceEnergy.Missing
	local trans = missing.Trans
	TweenService:Create(missing, tweenInfo, {
		BackgroundTransparency = 0.5
	}):Play()
	TweenService:Create(trans, tweenInfo, {
		BackgroundTransparency = 0.9
	}):Play()
	task.wait(WAIT_INTERVAL)
	TweenService:Create(missing, tweenInfo, {
		BackgroundTransparency = 1
	}):Play()
	TweenService:Create(trans, tweenInfo, {
		BackgroundTransparency = 1
	}):Play()
	task.wait(WAIT_INTERVAL)
	TweenService:Create(missing, tweenInfo, {
		BackgroundTransparency = 0.5
	}):Play()
	TweenService:Create(trans, tweenInfo, {
		BackgroundTransparency = 0.9
	}):Play()
	task.wait(WAIT_INTERVAL)
	TweenService:Create(missing, tweenInfo, {
		BackgroundTransparency = 1
	}):Play()
	TweenService:Create(trans, tweenInfo, {
		BackgroundTransparency = 1
	}):Play()
end

local function handleAction(_, p, p2)
	local v3

	if p == Enum.UserInputState.Begin then
		v3 = p2.UserInputState == Enum.UserInputState.Begin
	else
		v3 = false
	end

	if v3 then
		local character = localPlayer.Character

		if not character then
			return
		end

		local raceTransformed = character:FindFirstChild("RaceTransformed")

		if raceTransformed and raceTransformed.Value then
			return
		end

		local raceEnergy = character:FindFirstChild("RaceEnergy")

		if raceEnergy and raceEnergy.Value >= 1 then
			game.ReplicatedStorage.Events.ActivateRaceV4:Fire()
		elseif not v2 then
			v2 = true
			raceEnergyMeterFlash()
			task.delay(1, function()
				v2 = false
			end)
		end
	end
end

local function scan()
	local backpack = localPlayer:FindFirstChildWhichIsA("Backpack")
	local awakening = backpack and backpack:FindFirstChild("Awakening")

	if not awakening then
		local character = localPlayer.Character
		awakening = character and character:FindFirstChild("Awakening")
	end

	local isMobile = LastInput:IsMobile()

	if awakening and (not isMobile or MobileUIController:IsNewUIEnabled()) then
		local v3 = awakening and awakening:IsA("Tool") and MobileUIController:IsNewUIEnabled() and MobileUIController:CreateContextButton(
			"ActivateRaceV4",
			handleAction,
			Enum.KeyCode.Y
		)

		if v3 then
			local lockedFrame = v3:FindFirstChild("LockedFrame", true)
			lockedFrame.Label.Text = ""
			lockedFrame.Label.Visible = false
			v = v3
			reflectLocked() -- equivalent call inferred; original call site unknown
		end
	else
		MobileUIController:UnbindContextButton("ActivateRaceV4")
		v = nil
	end
end

return {
	OnStart = function(_)
		-- equivalent calls inferred from this helper; original call sites unknown
		local function backpackAdded()
			scan()
			localPlayer.Backpack.ChildAdded:Connect(scan)
			localPlayer.Backpack.ChildRemoved:Connect(scan)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function lookForBackpack()
			if localPlayer:FindFirstChildWhichIsA("Backpack") then
				backpackAdded() -- equivalent call inferred; original call site unknown
			end
		end

		lookForBackpack() -- equivalent call inferred; original call site unknown
		localPlayer.ChildAdded:Connect(lookForBackpack)

		local function charAdded(instance)
			instance.ChildAdded:Connect(function(child)
				child.ChildAdded:Connect(scan)
				child.ChildRemoved:Connect(scan)
			end)
		end

		localPlayer.CharacterAdded:Connect(charAdded)
		game.ReplicatedStorage.Events.MobileUIModeUpdated.Event:Connect(scan)
		task.defer(function()
			while task.wait(1) do
				if not (localPlayer.Character and v and v.Parent) then
					continue
				end

				reflectLocked() -- equivalent call inferred; original call site unknown
			end
		end)
	end
}