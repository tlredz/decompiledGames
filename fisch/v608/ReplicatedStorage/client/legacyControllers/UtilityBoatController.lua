local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
game:GetService("RunService")
game:GetService("MarketplaceService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local shared = ReplicatedStorage.shared
local modules = shared.modules
local hud = localPlayer.PlayerGui:WaitForChild("hud")
local utilityBoat = hud:WaitForChild("safezone").UtilityBoat
local list = utilityBoat.List
local header = utilityBoat.Header
local tabs = header.Tabs
local DataController = require(legacyControllers.DataController)
local GeneralUtils = require(shared.utils.GeneralUtils)
local Net = require(packages.Net)
require(packages.Observers)
local Trove = require(packages.Trove)
local Timer = require(packages.Timer)
local RomanNumerals = require(ReplicatedStorage.shared.utils.RomanNumerals)
require(ReplicatedStorage.client.modules.ViewportModule)
require(legacyControllers.WorldController)
require(modules:WaitForChild("fishing"):WaitForChild("bobbers"))
local vessels = require(ReplicatedStorage.shared.modules.vessels)
require(ReplicatedStorage.shared.modules.library.rods)
local Utilities = require(ReplicatedStorage.shared.modules.Utilities)
local remoteEvent = Net:RemoteEvent("UtilityBoat/PlaceUtility", -1)
local UtilityBoatController = {
	_openTrove = Trove.new()
}

local function getBoatInfo()
	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local seatPart = humanoid and humanoid.SeatPart

	if seatPart and seatPart.Name ~= "owner" then
		return {}
	end

	local parent = seatPart and seatPart.Parent
	return parent and vessels.library[parent.Name] or {}, parent
end

function UtilityBoatController:CreateOpenConnections()
	for _, button in tabs:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local v = button
		button.Activated:Connect(function()
			self:SetUITab(v.Name)
		end)
	end

	local function connect(data)
		data.Locked.Visible = false
		data.Unlocked.Visible = true
		self._openTrove:Connect(data.Unlocked.SelectButton.Activated, function()
			remoteEvent:FireServer(data.Name, self._closestValidPool)

			if Utilities.all[data.Name].InstantCatch then
				utilityBoat.Visible = false
			end
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function disconnect(frame, tierRequired)
		frame.Locked.Visible = true
		frame.Locked.Icon.Label.Text = `Unlock Tier {RomanNumerals:ToRoman(tierRequired)} Boat`
		frame.Unlocked.Visible = false
	end

	local utilityPlaced = Players.LocalPlayer:GetAttribute("UtilityPlaced") or 0
	header.Amount.Text = `{utilityPlaced}/5`
	self._openTrove:Connect(Players.LocalPlayer:GetAttributeChangedSignal("UtilityPlaced"), function()
		utilityPlaced = Players.LocalPlayer:GetAttribute("UtilityPlaced") or 0
		header.Amount.Text = `{utilityPlaced}/5`
	end)
	self._openTrove:Add(DataController.PlayerDataReplicator:Observe({ "Utilities" }, function(p)
		if not p then
			return
		end

		for _, child in list:GetChildren() do
			for _, frame in child:GetChildren() do
				if not frame:IsA("Frame") then
					continue
				end

				local v = not p[frame.Name] and 0 or p[frame.Name].amount or 0
				frame.Unlocked.SelectButton.Amount.Text = "x" .. v
			end
		end
	end))

	for _, child in list:GetChildren() do
		for _, frame in child:GetChildren() do
			if not frame:IsA("Frame") then
				continue
			end

			local v = Utilities.all[frame.Name]
			frame.Flare.Icon.Image = v.Icon

			if (getBoatInfo().UtilityTier or 0) >= v.TierRequired then
				frame.Locked.Visible = false
				frame.Unlocked.Visible = true
				local v2 = frame
				self._openTrove:Connect(frame.Unlocked.SelectButton.Activated, function()
					remoteEvent:FireServer(v2.Name, self._closestValidPool)

					if Utilities.all[v2.Name].InstantCatch then
						utilityBoat.Visible = false
					end
				end)
			else
				disconnect(frame, v.TierRequired) -- equivalent call inferred; original call site unknown
			end
		end
	end
end

function UtilityBoatController:SetUITab(p: string)
	for _, child in list:GetChildren() do
		child.Visible = child.Name == p
	end
end

function UtilityBoatController:PopulateUtilities()
	DataController.PlayerDataReplicator:WaitForLoaded()
	local index = DataController.PlayerDataReplicator:Index({ "Utilities" })

	for _, child in list:GetChildren() do
		local utility = Utilities[child.Name]
		local sample = child:FindFirstChild("Sample")
		sample.Parent = nil

		if not utility then
			continue
		end

		for k, v in utility do
			local v2 = not index[k] and 0 or index[k].amount or 0
			local clone = sample:Clone()
			clone.Label.Text = k
			clone.LayoutOrder = v.TierRequired or 0
			clone.Name = k
			clone.Unlocked.SelectButton.Amount.Text = "x" .. v2
			clone.Parent = child
			clone.Unlocked.Stats.LuckStat.Text = `Luck: {tostring(v.Luck)}%`
			clone.Unlocked.Stats.KGStat.Text = `Max Kg: {tostring(v.Strength)}kg`
		end
	end
end

function UtilityBoatController:Start()
	self:PopulateUtilities()
	self._closestValidPool = nil
	utilityBoat.Close.Activated:Connect(function()
		utilityBoat.Visible = false
	end)
	local InputController = require(legacyControllers.InputController)
	InputController:Get("Gamepad").ButtonDown:Connect(function(p, flag: boolean?)
		if not (flag ~= true and p == Enum.KeyCode.ButtonY) then
			return
		end

		local boatInfo, v = getBoatInfo()

		if not boatInfo.IsUtility then
			return
		end

		self:SetUITab((v:GetAttribute("UtilityType")))
		utilityBoat.Visible = not utilityBoat.Visible
	end)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		local boatInfo, v = getBoatInfo()

		if not boatInfo.IsUtility then
			return
		end

		self:SetUITab((v:GetAttribute("UtilityType")))

		if input.KeyCode == Enum.KeyCode.X then
			utilityBoat.Visible = not utilityBoat.Visible
		end
	end)
	utilityBoat:GetPropertyChangedSignal("Visible"):Connect(function()
		if utilityBoat.Visible then
			GeneralUtils.fastTween(
				workspace.CurrentCamera,
				TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					FieldOfView = 60
				}
			)
			GeneralUtils.fastTween(
				Lighting:WaitForChild("uiblur"),
				TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Size = 10
				}
			)
			GeneralUtils.fastTween(
				Lighting:WaitForChild("uicc"),
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Brightness = -0.07,
					TintColor = Color3.fromRGB(184, 184, 184),
					Saturation = -0.3
				}
			)
			self:CreateOpenConnections()
		else
			self._openTrove:Clean()
			GeneralUtils.fastTween(
				workspace.CurrentCamera,
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					FieldOfView = 70
				}
			)
			GeneralUtils.fastTween(
				Lighting:WaitForChild("uiblur"),
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Size = 0
				}
			)
			GeneralUtils.fastTween(
				Lighting:WaitForChild("uicc"),
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Brightness = 0,
					TintColor = Color3.fromRGB(255, 255, 255),
					Saturation = 0
				}
			)
		end
	end)
	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local v = nil

	local function attachToHumanoid(humanoid2)
		if v then
			v:Destroy()
		end

		v = Trove.new()
		v:AttachToInstance(humanoid2)
		v:Connect(humanoid2.Seated, function()
			hud.viewUtilities.Visible = getBoatInfo().IsUtility
		end)
	end

	if humanoid then
		attachToHumanoid(humanoid)
	end

	Players.LocalPlayer.CharacterAdded:Connect(function(character2)
		attachToHumanoid(character2:WaitForChild("Humanoid"))
	end)
	Timer.Simple(0.5, function()
		local v2 = 100
		local closestValidPool = nil

		for _, v4 in CollectionService:GetTagged("UtilityPool") do
			local distanceFromCharacter = Players.LocalPlayer:DistanceFromCharacter(v4.Position)
			local isUtility = getBoatInfo().IsUtility or false
			v4.radar.Enabled = isUtility
			v4.utilityInfo.Enabled = isUtility

			if not (distanceFromCharacter < v2) then
				continue
			end

			closestValidPool = v4
			v2 = distanceFromCharacter
		end

		self._closestValidPool = closestValidPool
	end)
end

return UtilityBoatController