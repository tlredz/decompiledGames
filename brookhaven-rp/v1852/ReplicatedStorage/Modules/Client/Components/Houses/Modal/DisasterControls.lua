local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "DisasterControls"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local LegacyGame8Settings = require(ReplicatedStorage.Modules.Client.UI.LegacyGame8Settings)
	local flying = LegacyGame8Settings.Flying
	local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
	local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
	local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	local playerSee = self.Instance.White:WaitForChild("PlayerSee")
	local v2 = false

	for _, child in self.Instance.Frame:GetChildren(), nil, nil do
		if not child:isA("ImageButton") then
			continue
		end

		local v3 = child
		self._Janitor:Add(child.MouseButton1Click:Connect(function()
			if UnlockableController.IsFeatureUnlocked("Feature_DISASTER_PASS", Gamepasses.DISASTER_PASS) then
				if v2 == false then
					v2 = true

					if v3 ~= nil then
						flying:FireServer("DisasterClientRequsting", v3.Name)
					end

					task.wait(0.5)
					v2 = false
				end
			else
				GamepassController.Show(Gamepasses.DISASTER_PASS, nil, "house panel", nil, {
					id = "Feature_DISASTER_PASS"
				}, nil, "improved-housed-controls", "Feature_DISASTER_PASS", function()
					if self.Instance.Parent == nil or v3.Parent == nil then
						return
					end

					PanelController.ToggleGroup("HouseModal", false)
					PanelController.Open("MainGUIHandler", "ModalDisasterControls")
					flying:FireServer("DisasterClientRequsting", v3.Name)
				end)
				PanelController.Close("MainGUIHandler", "ModalDisasterControls")
			end
		end))
	end

	self._Janitor:Add(flying.OnClientEvent:Connect(function(p2, p3)
		if p2 == "DisasterControlMessage" then
			if p3 == "Zombie Loading" then
				playerSee.Text = "Zombie Loading"
				playerSee.BackgroundTransparency = 0.35
				self.Instance.Frame.Zombie.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			elseif p3 == "Zombie Loaded" then
				playerSee.Text = "Disaster Controls"
				playerSee.BackgroundTransparency = 1
			elseif p3 == "Removing Zombie" then
				playerSee.Text = "Removing Zombie"
				playerSee.BackgroundTransparency = 0.35
			elseif p3 == "Zombie Deleted" then
				playerSee.Text = "Disaster Controls"
				playerSee.BackgroundTransparency = 1
				self.Instance.Frame.Zombie.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			elseif p3 == "Wind Loading" then
				playerSee.Text = "Wind Loading"
				playerSee.BackgroundTransparency = 0.35
				self.Instance.Frame.Wind.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			elseif p3 == "Wind Loaded" then
				playerSee.Text = "Disaster Controls"
				playerSee.BackgroundTransparency = 1
			elseif p3 == "Removing Wind" then
				playerSee.Text = "Removing Wind"
				playerSee.BackgroundTransparency = 0.35
			elseif p3 == "Wind Deleted" then
				playerSee.Text = "Disaster Controls"
				playerSee.BackgroundTransparency = 1
				self.Instance.Frame.Wind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			elseif p3 == "Fire Loading" then
				playerSee.Text = "Fire Loading"
				playerSee.BackgroundTransparency = 0.35
				self.Instance.Frame.Fire.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			elseif p3 == "Fire Loaded" then
				playerSee.Text = "Disaster Controls"
				playerSee.BackgroundTransparency = 1
			elseif p3 == "Removing Fire" then
				playerSee.Text = "Removing Fire"
				playerSee.BackgroundTransparency = 0.35
			elseif p3 == "Fire Deleted" then
				playerSee.Text = "Disaster Controls"
				playerSee.BackgroundTransparency = 1
				self.Instance.Frame.Fire.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			elseif p3 == "Lights turning off" or p3 == "Lights Loading" then
				playerSee.Text = "Lights turning off"
				playerSee.BackgroundTransparency = 0.35
				self.Instance.Frame.Lights.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			elseif p3 == "Lights off" or p3 == "Lights Loaded" then
				playerSee.Text = "Disaster Controls"
				playerSee.BackgroundTransparency = 1
			elseif p3 == "Lights turning on" or p3 == "Removing Lights" then
				playerSee.Text = "Lights turning on"
				playerSee.BackgroundTransparency = 0.35
			elseif p3 == "Lights on" or p3 == "Lights Deleted" then
				playerSee.Text = "Disaster Controls"
				playerSee.BackgroundTransparency = 1
				self.Instance.Frame.Lights.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			elseif p3 == "Lightning Loading" then
				playerSee.Text = "Lightning Loading"
				playerSee.BackgroundTransparency = 0.35
				self.Instance.Frame.Lightning.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			elseif p3 == "Lightning Loaded" then
				playerSee.Text = "Disaster Controls"
				playerSee.BackgroundTransparency = 1
			elseif p3 == "Removing Lightning" then
				playerSee.Text = "Removing Lightning"
				playerSee.BackgroundTransparency = 0.35
			elseif p3 == "Lightning Deleted" then
				playerSee.Text = "Disaster Controls"
				playerSee.BackgroundTransparency = 1
				self.Instance.Frame.Lightning.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			elseif p3 == "Flood Loading" then
				playerSee.Text = "Flood Loading"
				playerSee.BackgroundTransparency = 0.35
				self.Instance.Frame.Flood.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			elseif p3 == "Flood Loaded" then
				playerSee.Text = "Disaster Controls"
				playerSee.BackgroundTransparency = 1
			elseif p3 == "Removing Flood" then
				playerSee.Text = "Removing Flood"
				playerSee.BackgroundTransparency = 0.35
			elseif p3 == "Flood Deleted" then
				playerSee.Text = "Disaster Controls"
				playerSee.BackgroundTransparency = 1
				self.Instance.Frame.Flood.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			elseif p3 == "Quake Loading" then
				playerSee.Text = "Quake Loading"
				playerSee.BackgroundTransparency = 0.35
				self.Instance.Frame.Quake.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			elseif p3 == "Quake Loaded" then
				playerSee.Text = "Disaster Controls"
				playerSee.BackgroundTransparency = 1
			elseif p3 == "Removing Quake" then
				playerSee.Text = "Removing Quake"
				playerSee.BackgroundTransparency = 0.35
			elseif p3 == "Quake Deleted" then
				playerSee.Text = "Disaster Controls"
				playerSee.BackgroundTransparency = 1
				self.Instance.Frame.Quake.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			elseif p3 == "Invasion Loading" then
				playerSee.Text = "Invasion Loading"
				playerSee.BackgroundTransparency = 0.35
				self.Instance.Frame.Explosives.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			elseif p3 == "Invasion Loaded" then
				playerSee.Text = "Disaster Controls"
				playerSee.BackgroundTransparency = 1
			elseif p3 == "Removing Invasion" then
				playerSee.Text = "Removing Invasion"
				playerSee.BackgroundTransparency = 0.35
			elseif p3 == "Invasion Deleted" then
				playerSee.Text = "Disaster Controls"
				playerSee.BackgroundTransparency = 1
				self.Instance.Frame.Explosives.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			elseif p3 == "Ghost Loading" then
				playerSee.Text = "Ghost Loading"
				playerSee.BackgroundTransparency = 0.35
				self.Instance.Frame.Ghost.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			elseif p3 == "Ghost Loaded" then
				playerSee.Text = "Disaster Controls"
				playerSee.BackgroundTransparency = 1
			elseif p3 == "Removing Ghost" then
				playerSee.Text = "Removing Ghost"
				playerSee.BackgroundTransparency = 0.35
			elseif p3 == "Ghost Deleted" then
				playerSee.Text = "Disaster Controls"
				playerSee.BackgroundTransparency = 1
				self.Instance.Frame.Ghost.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			elseif p3 == "Alien Loading" then
				playerSee.Text = "Alien Loading"
				playerSee.BackgroundTransparency = 0.35
				self.Instance.Frame.Alien.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			elseif p3 == "Alien Loaded" then
				playerSee.Text = "Disaster Controls"
				playerSee.BackgroundTransparency = 1
			elseif p3 == "Removing Alien" then
				playerSee.Text = "Removing Alien"
				playerSee.BackgroundTransparency = 0.35
			elseif p3 == "Alien Deleted" then
				playerSee.Text = "Disaster Controls"
				playerSee.BackgroundTransparency = 1
				self.Instance.Frame.Alien.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			elseif p3 == "Bugs Loading" then
				playerSee.Text = "Bugs Loading"
				playerSee.BackgroundTransparency = 0.35
				self.Instance.Frame.Bugs.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			elseif p3 == "Bugs Loaded" then
				playerSee.Text = "Disaster Controls"
				playerSee.BackgroundTransparency = 1
			elseif p3 == "Removing Bugs" then
				playerSee.Text = "Removing Bugs"
				playerSee.BackgroundTransparency = 0.35
			elseif p3 == "Bugs Deleted" then
				playerSee.Text = "Disaster Controls"
				playerSee.BackgroundTransparency = 1
				self.Instance.Frame.Bugs.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			elseif p3 == "Solar Flare Loading" then
				playerSee.Text = "Solar Flare Loading"
				playerSee.BackgroundTransparency = 0.35
				self.Instance.Frame.Solar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			elseif p3 == "Solar Flare Loaded" then
				playerSee.Text = "Disaster Controls"
				playerSee.BackgroundTransparency = 1
			elseif p3 == "Removing Solar Flare" then
				playerSee.Text = "Removing Solar Flare"
				playerSee.BackgroundTransparency = 0.35
			elseif p3 == "Solar Flare Deleted" then
				playerSee.Text = "Disaster Controls"
				playerSee.BackgroundTransparency = 1
				self.Instance.Frame.Solar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			elseif p3 == "Gas Loading" then
				playerSee.Text = "Gas Leak Loading"
				playerSee.BackgroundTransparency = 0.35
				self.Instance.Frame.Gas.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			elseif p3 == "Gas Loaded" then
				playerSee.Text = "Disaster Controls"
				playerSee.BackgroundTransparency = 1
			elseif p3 == "Removing Gas" then
				playerSee.Text = "Removing Gas Leak"
				playerSee.BackgroundTransparency = 0.35
			elseif p3 == "Gas Deleted" then
				playerSee.Text = "Disaster Controls"
				playerSee.BackgroundTransparency = 1
				self.Instance.Frame.Gas.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			end
		end
	end))
end

function v.Reset(p)
	local playerSee = p.Instance.White:WaitForChild("PlayerSee")
	playerSee.Text = "Disaster Controls"
	playerSee.BackgroundTransparency = 1
	p.Instance.Frame.Zombie.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	p.Instance.Frame.Wind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	p.Instance.Frame.Fire.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	p.Instance.Frame.Lights.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	p.Instance.Frame.Lightning.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	p.Instance.Frame.Flood.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	p.Instance.Frame.Quake.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	p.Instance.Frame.Explosives.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	p.Instance.Frame.Ghost.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	p.Instance.Frame.Alien.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	p.Instance.Frame.Bugs.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	p.Instance.Frame.Solar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	p.Instance.Frame.Gas.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v