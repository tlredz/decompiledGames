local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local LegacyGame8Settings = require(ReplicatedStorage.Modules.Client.UI.LegacyGame8Settings)
local rPNameTextRemote = LegacyGame8Settings.RPNameTextRemote
local rPNameColorRemote = LegacyGame8Settings.RPNameColorRemote
local babyFollow = LegacyGame8Settings.BabyFollow
local v = {
	BabyBoy = true,
	BabyGirl = true,
	Minions2026_Ed = true,
	Minions2026_Generic = true,
	Minions2026_Henry = true,
	Minions2026_James = true
}
local v2 = {
	BabyBoy1 = true,
	BabyBoy2 = true,
	BabyBoy3 = true,
	BabyGirl1 = true,
	BabyGirl2 = true,
	BabyGirl3 = true
}
local v3 = Component.new({
	Tag = "CharacterKidMenu"
})

function v3:Construct()
	self._Janitor = Janitor.new()
end

function v3:_SetupFollowControls(instance)
	local frame = instance:WaitForChild("Frame")
	local v4 = false

	for _, button in frame:GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end

		local v5 = button
		self._Janitor:Add(button.MouseButton1Click:Connect(function()
			if v4 == true then
				return
			end

			v4 = true

			if v5.Name == "FollowColor" and v5:FindFirstChild("Color") ~= nil then
				rPNameColorRemote:FireServer("PickingRPFollowColor", v5.Color)
			elseif v5.Name == "DeleteFollow" then
				babyFollow:FireServer("DeleteFollowCharacter")
			end

			task.wait(0.3)
			v4 = false
		end))
	end

	local rPFollowName = frame:WaitForChild("RPFollowName")
	self._Janitor:Add(rPFollowName.FocusLost:Connect(function()
		rPNameTextRemote:FireServer("RolePlayFollow", rPFollowName.Text)
	end))
end

function v3:_SetupBabyButtons(instance, p2)
	local v4 = false

	for _, button in instance:GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end

		local v5 = button
		self._Janitor:Add(button.MouseButton1Click:Connect(function()
			if v4 == true or p2 ~= nil and p2.Sit == true then
				return
			end

			v4 = true
			local name = v5.Name

			if v[name] == true then
				babyFollow:FireServer("SpawnChild", name)
			elseif v2[name] == true then
				if UnlockableController.IsFeatureUnlocked(name, Gamepasses.PREMIUM) then
					babyFollow:FireServer("SpawnChild", name)
				else
					GamepassController.Show(Gamepasses.PREMIUM, v5.Icon.Image, "baby character", nil, {
						id = name
					}, nil, "Kid Inventory", name, function()
						if v5.Parent == nil or p2 == nil or p2.Parent ~= Players.LocalPlayer.Character or p2.Sit == true then
							return
						end

						babyFollow:FireServer("SpawnChild", name)
					end)
				end
			end

			task.wait(0.3)
			v4 = false
		end))
	end
end

function v3:Start()
	local container = self.Instance:WaitForChild("Catalog"):WaitForChild("Container")
	local scrollingFrameKid = container:WaitForChild("ScrollingFrameKid")
	local scrollingFrameKid2 = container:WaitForChild("ScrollingFrameKid2")
	local character = Players.LocalPlayer.Character
	local humanoid

	if character ~= nil then
		humanoid = character:FindFirstChildOfClass("Humanoid")
	end

	self:_SetupFollowControls(scrollingFrameKid2)
	self:_SetupBabyButtons(scrollingFrameKid, humanoid)
end

function v3:Stop()
	self._Janitor:Destroy()
end

return v3