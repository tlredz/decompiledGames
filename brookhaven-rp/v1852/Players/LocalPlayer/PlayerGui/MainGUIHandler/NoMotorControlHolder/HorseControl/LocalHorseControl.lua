local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Players")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local child = workspace:WaitForChild(localPlayer.Name)
local humanoid = child:WaitForChild("Humanoid")
local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local game8Settings = playerGui:WaitForChild("Player8Handler"):WaitForChild("Game8Settings")
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local module = require(game8Settings)
local parent = script.Parent
local horseControlButtons = parent:WaitForChild("HorseControlButtons")
local horseColorPicks = parent:WaitForChild("HorseColorPicks")
local hairColorPicks = parent:WaitForChild("HairColorPicks")
local saddleColorPicks = parent:WaitForChild("SaddleColorPicks")
local texturePicks = parent:WaitForChild("TexturePicks")
local speed = parent:WaitForChild("ExitHorse"):WaitForChild("MainOpen"):WaitForChild("Speed")
local passSpeed = speed:WaitForChild("PassSpeed")
local horseRemote = module.HorseRemote
local horseText = parent:WaitForChild("HorseText")
local frame = horseText.HorseText.Picks:WaitForChild("Frame")
local horseName = horseText.HorseText.Picks:WaitForChild("HorseName")
local noResetGUIHandler = playerGui:WaitForChild("NoResetGUIHandler")
local horseSpeedPS5 = playerGui.Player8Handler.HorseSpeedPS5
local jobMenuWorkspace = noResetGUIHandler:WaitForChild("JobMenuWorkspace")
local horseSpeed = localPlayer.PlayersBag:FindFirstChild("HorsePass"):FindFirstChild("HorseSpeed")
local v = false
local v2 = false
local v3 = false
local v4 = false
local v5 = false
local v6 = false
local v7 = false
local v8 = false
local v9 = false
local v10 = false
local v11 = {
	{
		Text = "Walk",
		Value = 10
	},
	{
		Text = "Trot",
		Value = 20
	},
	{
		Text = "Canter",
		Value = 35
	},
	{
		Text = "Gallop",
		Value = 50
	}
}
local v12 = 3

if horseSpeed ~= nil then
	for k, v14 in pairs(v11) do
		if v14.Value ~= horseSpeed.Value then
			continue
		end

		v12 = k
		break
	end
end

local function togglePassSpeed()
	if v8 == false then
		v8 = true
		passSpeed.Visible = not passSpeed.Visible
		updateColor()
		wait(0.3)
		v8 = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function closeHorsePanels()
	PanelController.ToggleGroup("NoMotorControlHolder", false)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function toggleHorsePanel(p: string)
	if PanelController.IsOpen("MainGUIHandler", p) then
		PanelController.Close("MainGUIHandler", p)
		return
	end

	closeHorsePanels() -- equivalent call inferred; original call site unknown
	PanelController.Open("MainGUIHandler", p)
end

speed.MouseButton1Click:connect(togglePassSpeed)

function updateColor()
	if v12 < 3 or UnlockableController.IsFeatureUnlocked(AdFeatures.HORSE_FEATURES.id, Gamepasses.HORSE_UNLOCKED) then
		passSpeed.SB.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	else
		passSpeed.SB.BackgroundColor3 = Color3.fromRGB(133, 255, 80)
	end
end

function updateSpeed()
	v12 = math.clamp(v12, 1, 4)

	if v12 == 4 and not UnlockableController.IsFeatureUnlocked(AdFeatures.HORSE_FEATURES.id, Gamepasses.HORSE_UNLOCKED) then
		v12 = 3
		local currentVehicleHorse = VehicleController.GetCurrentVehicleHorse()

		if not currentVehicleHorse then
			return
		end

		local vehicleName = currentVehicleHorse:GetAttribute("vehicleName")
		GamepassController.Show(
			Gamepasses.HORSE_UNLOCKED,
			nil,
			"horse pass",
			togglePassSpeed,
			AdFeatures.HORSE_FEATURES,
			nil,
			"Horse Controls : Speed",
			vehicleName,
			function()
				if VehicleController.GetCurrentVehicleHorse() ~= currentVehicleHorse or humanoid.Parent ~= child then
					return
				end

				v12 = 4
				updateSpeed()
			end
		)
	end

	updateColor()
	passSpeed.Speed.Text = `{v11[v12].Text} - {v11[v12].Value}`
	horseSpeedPS5.Value = v11[v12].Value
	horseSpeed.Value = horseSpeedPS5.Value
	humanoid.WalkSpeed = horseSpeedPS5.Value
	task.defer(function()
		humanoid.WalkSpeed = horseSpeedPS5.Value
	end)
	horseRemote:FireServer("ChangeHorseSpeed", horseSpeedPS5.Value)
end

passSpeed.SB.MouseButton1Click:connect(function()
	if v10 == false then
		v10 = true
		v12 += 1
		updateSpeed()
		wait(0.1)
		v10 = false
	end
end)
passSpeed.SS.MouseButton1Click:connect(function()
	if v9 == false then
		v9 = true
		v12 -= 1
		updateSpeed()
		wait(0.1)
		v9 = false
	end
end)
horseName.FocusLost:connect(function()
	if v7 == false then
		v7 = true
		horseRemote:FireServer("HorseName", horseName.Text)
		wait(0.3)
		v7 = false
	end
end)

for _, child2 in pairs(frame:GetChildren()) do
	if not child2:isA("ImageButton") then
		continue
	end

	local v13 = child2
	child2.MouseButton1Click:connect(function()
		if v6 == false then
			v6 = true

			if v13.Name == "Colors" and v13:FindFirstChild("Color") then
				horseRemote:FireServer("HorseNameColor", v13.Color)
			end

			wait(0.3)
			v6 = false
		end
	end)
end

for _, child2 in pairs(horseColorPicks.ColorPicks.Picks.Frame:GetChildren()) do
	if not child2:isA("ImageButton") then
		continue
	end

	local v13 = child2
	child2.MouseButton1Click:connect(function()
		if v == false then
			v = true

			if v13:FindFirstChild("Color") then
				horseRemote:FireServer("PickingHorseBodyColor", v13.Color)
				wait(0.2)
				v = false
			end
		end
	end)
end

for _, child2 in pairs(hairColorPicks.ColorPicks.Picks.Frame:GetChildren()) do
	if not child2:isA("ImageButton") then
		continue
	end

	local v13 = child2
	child2.MouseButton1Click:connect(function()
		if v2 == false then
			v2 = true

			if v13:FindFirstChild("Color") then
				horseRemote:FireServer("PickingHorseHairColor", v13.Color)
				wait(0.2)
				v2 = false
			end
		end
	end)
end

for _, child2 in pairs(saddleColorPicks.ColorPicks.Picks.Frame:GetChildren()) do
	if not child2:isA("ImageButton") then
		continue
	end

	local v13 = child2
	child2.MouseButton1Click:connect(function()
		if v3 == false then
			v3 = true

			if v13:FindFirstChild("Color") then
				horseRemote:FireServer("PickingSaddleColor", v13.Color)
				wait(0.2)
				v3 = false
			end
		end
	end)
end

for _, child2 in pairs(texturePicks.ColorPicks.Picks.Frame:GetChildren()) do
	if not child2:isA("ImageButton") then
		continue
	end

	local v13 = child2
	child2.MouseButton1Click:connect(function()
		if v4 == false then
			v4 = true

			if v13:FindFirstChild("Color") then
				horseRemote:FireServer("PickingHorseTexture", v13.Color)
				wait(0.2)
				v4 = false
			end
		end
	end)
end

for _, child2 in pairs(horseControlButtons.HorseButtons:GetChildren()) do
	if not child2:isA("ImageButton") then
		continue
	end

	local v13 = child2
	child2.MouseButton1Click:connect(function()
		if v5 == false then
			v5 = true
			jobMenuWorkspace.Visible = false

			if v13.Name == "HouseText" then
				if PanelController.IsOpen("MainGUIHandler", "HorseText") then
					PanelController.Close("MainGUIHandler", "HorseText")
				else
					closeHorsePanels() -- equivalent call inferred; original call site unknown
					PanelController.Open("MainGUIHandler", "HorseText")
				end
			elseif v13.Name == "HorsePass" then
				if GamepassController.IsOwned(Gamepasses.HORSE_UNLOCKED) then
					closeHorsePanels() -- equivalent call inferred; original call site unknown
					horseControlButtons.HorseButtons.HorseSaddleColor.Visible = true
					horseControlButtons.HorseButtons.HorseHairColor.Visible = true
					horseControlButtons.HorseButtons.HorseColor.Visible = true
					horseControlButtons.HorseButtons.HorseTexture.Visible = true
				else
					GamepassController.Show(
						Gamepasses.HORSE_UNLOCKED,
						nil,
						"horse",
						nil,
						nil,
						nil,
						"Horse Controls",
						v13.Name,
						function()
							if v13.Parent == nil or VehicleController.GetCurrentVehicleHorse() == nil or not PanelController.IsOpen(
								"MainGUIHandler",
								"HorseControl"
							) then
								return
							end

							closeHorsePanels() -- equivalent call inferred; original call site unknown
							horseControlButtons.HorseButtons.HorseSaddleColor.Visible = true
							horseControlButtons.HorseButtons.HorseHairColor.Visible = true
							horseControlButtons.HorseButtons.HorseColor.Visible = true
							horseControlButtons.HorseButtons.HorseTexture.Visible = true
						end
					)
				end
			elseif v13.Name == "SecondaryHorse" then
				horseRemote:FireServer("SecondaryHorse")
			elseif v13.Name == "DefaultHorse" then
				horseRemote:FireServer("DefaultHorse")
			end

			wait(0.2)
			v5 = false
		end
	end)
end

for _, child2 in pairs(horseControlButtons.HorsePassButtons:GetChildren()) do
	if not child2:isA("ImageButton") then
		continue
	end

	local v13 = child2
	child2.MouseButton1Click:connect(function()
		local v14

		if v13.Name == "HorseTexture" then
			v14 = "TexturePicks"
		elseif v13.Name == "HorseHairColor" then
			v14 = "HairColorPicks"
		elseif v13.Name == "HorseSaddleColor" then
			v14 = "SaddleColorPicks"
		elseif v13.Name == "HorseColor" then
			v14 = "HorseColorPicks"
		else
			v14 = nil
		end

		if UnlockableController.IsFeatureUnlocked(AdFeatures.HORSE_FEATURES.id, Gamepasses.HORSE_UNLOCKED) then
			if v5 == false then
				v5 = true
				jobMenuWorkspace.Visible = false
				local v15 = v14

				if PanelController.IsOpen("MainGUIHandler", v15) then
					PanelController.Close("MainGUIHandler", v15)
				else
					closeHorsePanels() -- equivalent call inferred; original call site unknown
					PanelController.Open("MainGUIHandler", v15)
				end

				wait(0.2)
				v5 = false
			end
		else
			local currentVehicleHorse = VehicleController.GetCurrentVehicleHorse()

			if not currentVehicleHorse then
				return
			end

			local vehicleName = currentVehicleHorse:GetAttribute("vehicleName")
			GamepassController.Show(
				Gamepasses.HORSE_UNLOCKED,
				nil,
				"horse pass",
				nil,
				AdFeatures.HORSE_FEATURES,
				nil,
				"Horse Controls : " .. v13.Name,
				vehicleName,
				function()
					if v13.Parent == nil or VehicleController.GetCurrentVehicleHorse() ~= currentVehicleHorse or not PanelController.IsOpen(
						"MainGUIHandler",
						"HorseControl"
					) then
						return
					end

					jobMenuWorkspace.Visible = false
					toggleHorsePanel(v14) -- equivalent call inferred; original call site unknown
				end
			)
		end
	end)
end

passSpeed.Visible = false
updateSpeed()
updateColor()