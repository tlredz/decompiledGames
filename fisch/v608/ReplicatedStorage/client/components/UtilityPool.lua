local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local Timer = require(packages:WaitForChild("Timer"))
local legacyControllers = ReplicatedStorage.client.legacyControllers
require(legacyControllers:WaitForChild("NotificationController"))
local DataController = require(legacyControllers:WaitForChild("DataController"))
local fish = require(ReplicatedStorage.shared.modules.library.fish)
local vessels = require(ReplicatedStorage.shared.modules.vessels)
local _ = Players.LocalPlayer
local v = Component.new({
	Tag = "UtilityPool"
})
local v2 = {
	lobster = "rbxassetid://108155697782475",
	school = "rbxassetid://87360061442737"
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

function v:Construct()
	self.trove = Trove.new()
	local clone = script.FirstTimeDistance:Clone()
	clone.Enabled = false
	clone.Parent = self.Instance
	self.firstTimeDistance = clone
end

function v.Start(data)
	local abundance = data.Instance:FindFirstChild("Abundance")

	if abundance.Value then
		data.Instance.utilityInfo.abundanceName.Text = "[" .. abundance.Value .. "]"
		local v3 = fish[abundance.Value]

		if v3 then
			data.firstTimeDistance.Frame.Icon.Image = v2[v3.UtilityType]
		end
	end

	data.trove:Connect(abundance:GetPropertyChangedSignal("Value"), function(p)
		data.Instance.utilityInfo.abundanceName.Text = "[" .. p .. "]"
		local v3 = fish[p]

		if v3 then
			data.firstTimeDistance.Frame.Icon.Image = v2[v3.UtilityType]
		end
	end)

	if UserInputService.TouchEnabled then
		data.Instance.utilityInfo.title.Visible = false
	end

	data.trove:Connect(UserInputService.LastInputTypeChanged, function(p)
		data.Instance.utilityInfo.title.Visible = p ~= Enum.UserInputType.Touch

		if p == Enum.UserInputType.Gamepad1 then
			data.Instance.utilityInfo.title.Text = "Press [Y] for Traps"
		elseif p == Enum.UserInputType.Touch then
			data.Instance.utilityInfo.title.Text = ""
		else
			data.Instance.utilityInfo.title.Text = "Press [X] for Traps"
		end
	end)
	DataController.PlayerDataReplicator:WaitForLoaded()
	local v3 = DataController.PlayerDataReplicator:TryIndex({ "ReplicatedBooleans", "HasPlacedCage" })
	data.trove:Add(DataController.PlayerDataReplicator:Observe({ "ReplicatedBooleans", "HasPlacedCage" }, function(p)
		v3 = p
	end))
	data.trove:Add(Timer.Simple(0.25, function()
		if not Players.LocalPlayer.Character then
			return
		end

		local v4 = fish[abundance.Value]

		if not v4 then
			data.firstTimeDistance.Enabled = false
			return
		end

		if not getBoatInfo().IsUtility then
			data.firstTimeDistance.Enabled = false
			return
		end

		local distanceFromCharacter = Players.LocalPlayer:DistanceFromCharacter(data.Instance.Position)

		if distanceFromCharacter < 80 then
			data.firstTimeDistance.Enabled = false
			return
		end

		if distanceFromCharacter > 3000 and not v3 then
			data.firstTimeDistance.Enabled = false
			return
		end

		if v4.UtilityTier > 1 and not v3 then
			data.firstTimeDistance.Enabled = false
			return
		end

		local flag = false

		for _, child in data.Instance:GetChildren() do
			if not (child:HasTag("ActiveUtility") and child:GetAttribute("Owner") == Players.LocalPlayer.UserId) then
				continue
			end

			flag = true
		end

		local icon = data.firstTimeDistance.Frame.Icon
		local imageColor

		if flag then
			imageColor = Color3.new(1, 0, 0)
		else
			imageColor = Color3.new(1, 1, 1)
		end

		icon.ImageColor3 = imageColor
		local title = data.firstTimeDistance.Frame.title
		local textColor

		if flag then
			textColor = Color3.new(1, 0, 0)
		else
			textColor = Color3.new(1, 1, 1)
		end

		title.TextColor3 = textColor
		data.firstTimeDistance.Enabled = true
		data.firstTimeDistance.Frame.title.Text = math.ceil(distanceFromCharacter) .. " Studs"
	end), "Disconnect")
end

function v.Stop(p)
	p.trove:Destroy()
end

return v