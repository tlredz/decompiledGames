local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage2:WaitForChild("UserInputService"))

while not workspace:GetAttribute("ClientStarted") do
	workspace:GetAttributeChangedSignal("ClientStarted"):Wait()
end

local clientGameModules = ReplicatedStorage.ClientGameModules
local controllers = ReplicatedStorage.Controllers
local packages = ReplicatedStorage.Packages
local shared = ReplicatedStorage.Shared
local localPlayer = Players.LocalPlayer
local _ = localPlayer.PlayerGui
local parent = script.Parent
local DeviceListener = require(clientGameModules.DeviceListener)
local FastUtils = require(shared.FastUtils)
require(controllers.GamepadIconController)
require(shared.LTM)
local Promise = require(packages.Promise)
local Trove = require(packages.Trove)
local modulesByChild = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function updateIcon(abilityBlockPassive)
	local child = abilityBlockPassive and shared.Abilities:FindFirstChild(abilityBlockPassive)

	if not child then
		return
	end

	local module = modulesByChild[child]

	if not module then
		module = require(child)
		modulesByChild[child] = module
	end

	parent.Vector.Image = module and module.iconId or ""
end

local function updatePassive()
	local abilityBlockPassive = localPlayer.Character:GetAttribute("AbilityBlockPassive")
	parent.Vector.Visible = abilityBlockPassive ~= nil
	parent.ready.Visible = abilityBlockPassive ~= nil

	if not abilityBlockPassive then
		return
	end

	updateIcon(abilityBlockPassive) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateCharges()
	local abilityBlockCharges = localPlayer.Character:GetAttribute("AbilityBlockCharges")
	parent.ready.counts.Text = tostring(abilityBlockCharges or 1)
end

local maid = Trove.new()

local function updateEndTime()
	local abilityBlockEndTime = localPlayer.Character:GetAttribute("AbilityBlockEndTime")
	local serverTimeNow = workspace:GetServerTimeNow()
	local v = (abilityBlockEndTime or serverTimeNow) - serverTimeNow
	maid:Clean()
	local durationOld = parent.DurationOld
	durationOld.Visible = abilityBlockEndTime ~= nil and v > 0

	if v > 0 then
		parent.DurationOld.Background.Bar.BackgroundColor3 = Color3.fromRGB(123, 190, 254)
		parent.DurationOld.Background.Bar.Size = UDim2.fromScale(1, 1)
		maid:Add(FastUtils.fastTween(parent.DurationOld.Background.Bar, TweenInfo.new(v, Enum.EasingStyle.Linear), {
			Size = UDim2.fromScale(0, 1)
		}))
		maid:AddPromise(Promise.delay(v):andThen(function()
			parent.DurationOld.Visible = false
		end))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateVisibility()
	local v = workspace:GetAttribute("CurrentlySelectedMode") == "AbilityBlock"
	local v2 = localPlayer.Character and localPlayer.Character:IsDescendantOf(workspace.Alive)
	parent.Visible = v and v2
	local abilityBlockPassive = localPlayer.Character:GetAttribute("AbilityBlockPassive")
	parent.Vector.Visible = abilityBlockPassive ~= nil
	parent.ready.Visible = abilityBlockPassive ~= nil
	updateIcon(abilityBlockPassive) -- equivalent call inferred; original call site unknown
	updateCharges() -- equivalent call inferred; original call site unknown
	updateEndTime()
end

DeviceListener.OnChange:Connect(function()
	updateVisibility() -- equivalent call inferred; original call site unknown
end)

local function OnCharacterAdded(character)
	if not character then
		return
	end

	updateVisibility() -- equivalent call inferred; original call site unknown
	character.AncestryChanged:Connect(updateVisibility)
	character:GetAttributeChangedSignal("AbilityBlockPassive"):Connect(updatePassive)
	character:GetAttributeChangedSignal("AbilityBlockCharges"):Connect(updateCharges)
	character:GetAttributeChangedSignal("AbilityBlockEndTime"):Connect(updateEndTime)
end

OnCharacterAdded(localPlayer.Character or localPlayer.CharacterAdded:Wait())
localPlayer.CharacterAdded:Connect(OnCharacterAdded)