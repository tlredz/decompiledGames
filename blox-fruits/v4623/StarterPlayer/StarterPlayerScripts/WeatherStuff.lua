local createVector = vector.create
game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local v = {}
local folders = {}
local localPlayer = game.Players.LocalPlayer
local topHUDList = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Main", 999):WaitForChild("TopHUDList")
local lightningEventTimer = topHUDList:WaitForChild("LightningEventTimer")
local celestialMeter = topHUDList:WaitForChild("CelestialMeter")
local celestialCountdown = topHUDList:WaitForChild("CelestialCountdown")
local TimeUtil = require(game.ReplicatedStorage.Modules.Util.TimeUtil)
require(game.ReplicatedStorage.Modules.Util.TextUtil)
local getid

getid = function()
	local v2 = math.random(1, 1000000000)

	if v[v2] then
		return getid()
	end

	return v2
end

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = folders
raycastParams.FilterType = Enum.RaycastFilterType.Include

function ChildAdded(folder)
	if folder.Name == "MirageIsland" then
		local clone = script.MirageFog:Clone()
		clone.Parent = game.Lighting.LightingLayers
		local v2 = math.random(1, 1000000000)

		if v[v2] then
			v2 = getid()
		end

		folder:GetPropertyChangedSignal("Parent"):Connect(function()
			if folder.Parent then
				return
			end

			v[v2] = nil
			TweenService:Create(clone.Intensity, TweenInfo.new(2), {
				Value = 0
			}):Play()
			task.wait(3)
			clone:Destroy()
		end)

		v[v2] = function(p)
			if (p - folder.Position * createVector(1, 0, 1)).Magnitude <= 2000 then
				TweenService:Create(clone.Intensity, TweenInfo.new(2), {
					Value = 1
				}):Play()
			else
				TweenService:Create(clone.Intensity, TweenInfo.new(2), {
					Value = 0
				}):Play()
			end
		end
	elseif folder.Name == "RumblingSeas" then
		local v2 = math.random(1, 1000000000)

		if v[v2] then
			v2 = getid()
		end

		folder:GetPropertyChangedSignal("Parent"):Connect(function()
			if folder.Parent then
				return
			end

			v[v2] = nil
			task.wait(5)
			RainEnabled = false
		end)

		v[v2] = function(p)
			local magnitude = (p - folder.Position * createVector(1, 0, 1)).Magnitude
			RainEnabled = RainEnabled or magnitude <= 1000
		end
	elseif folder.Name == "Leviathan" or folder.Name == "Snow" then
		local radius = folder:GetAttribute("Radius")
		local clone = script.LeviathanFog:Clone()

		if folder.Name == "Snow" then
			clone.Color = Color3.new(1, 1, 1)
			clone.Offset = 0.362
		end

		clone.Parent = game.Lighting.LightingLayers
		local v2 = math.random(1, 1000000000)

		if v[v2] then
			v2 = getid()
		end

		folder:GetPropertyChangedSignal("Parent"):Connect(function()
			if folder.Parent then
				return
			end

			v[v2] = nil

			if workspace.Terrain:GetAttribute("SeaTheme") == "Cold" then
				workspace.Terrain:SetAttribute("SeaTheme", "Default")
			end

			workspace.Gravity = 196.2
			TweenService:Create(clone.Intensity, TweenInfo.new(2), {
				Value = 0
			}):Play()
			task.wait(3)
			clone:Destroy()
		end)
		local v3 = false

		v[v2] = function(p)
			local v4 = (p - folder.Position * createVector(1, 0, 1)).Magnitude <= radius

			if v3 ~= v4 then
				if v4 then
					TweenService:Create(clone.Intensity, TweenInfo.new(2), {
						Value = 1
					}):Play()
				else
					TweenService:Create(clone.Intensity, TweenInfo.new(2), {
						Value = 0
					}):Play()
				end

				if v4 then
					if workspace.Terrain:GetAttribute("SeaTheme") ~= "Cold" then
						workspace.Terrain:SetAttribute("SeaTheme", "Cold")
					end
				elseif not v4 and workspace.Terrain:GetAttribute("SeaTheme") == "Cold" then
					workspace.Terrain:SetAttribute("SeaTheme", "Default")
				end
			end

			if v4 and folder.Name == "Leviathan" then
				workspace.Gravity = 278.604
			else
				workspace.Gravity = 196.2
			end

			v3 = v4
		end
	elseif folder.Name == "FunSnow" then
		local radius = folder:GetAttribute("Radius")
		local clone = script.LeviathanFog:Clone()
		clone.Color = Color3.new(0.701961, 0.701961, 0.701961)
		clone.Offset = 0.2
		clone.Density = 0.25
		clone.Haze = 0
		clone.Glare = 1
		clone.Parent = game.Lighting.LightingLayers
		local v2 = math.random(1, 1000000000)

		if v[v2] then
			v2 = getid()
		end

		folder:GetPropertyChangedSignal("Parent"):Connect(function()
			if folder.Parent then
				return
			end

			v[v2] = nil

			if workspace.Terrain:GetAttribute("SeaTheme") == "Cold" then
				workspace.Terrain:SetAttribute("SeaTheme", "Default")
			end

			workspace.Gravity = 196.2
			TweenService:Create(clone.Intensity, TweenInfo.new(10), {
				Value = 0
			}):Play()
			task.wait(15)
			clone:Destroy()
		end)
		local v3 = false

		v[v2] = function(p)
			local v4 = (p - folder.Position * createVector(1, 0, 1)).Magnitude <= radius

			if v3 ~= v4 then
				if v4 then
					TweenService:Create(clone.Intensity, TweenInfo.new(2), {
						Value = 1
					}):Play()
				else
					TweenService:Create(clone.Intensity, TweenInfo.new(2), {
						Value = 0
					}):Play()
				end

				if v4 then
					if workspace.Terrain:GetAttribute("SeaTheme") ~= "Cold" then
						workspace.Terrain:SetAttribute("SeaTheme", "Cold")
					end
				elseif not v4 and workspace.Terrain:GetAttribute("SeaTheme") == "Cold" then
					workspace.Terrain:SetAttribute("SeaTheme", "Default")
				end
			end

			v3 = v4
		end
	else
		for _, part in pairs(folder:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			part.Transparency = 1
			part.CanCollide = false
			part.CanTouch = false
			part.Anchored = true
		end

		if not folder:GetAttribute("Disabled") then
			table.insert(folders, folder)
			raycastParams.FilterDescendantsInstances = folders
		end

		local parentChangedConnection = nil
		local disabledChangedConnection = nil
		parentChangedConnection = folder:GetPropertyChangedSignal("Parent"):Connect(function()
			if not folder.Parent then
				local index = table.find(folders, folder)

				if index then
					table.remove(folders, index)
				end

				parentChangedConnection:Disconnect()
				disabledChangedConnection:Disconnect()
				raycastParams.FilterDescendantsInstances = folders
			end
		end)
		disabledChangedConnection = folder:GetAttributeChangedSignal("Disabled"):Connect(function()
			if folder:GetAttribute("Disabled") then
				local index = table.find(folders, folder)

				if index then
					table.remove(folders, index)
				end
			elseif not table.find(folders, folder) then
				table.insert(folders, folder)
			end

			raycastParams.FilterDescendantsInstances = folders
		end)
	end
end

workspace._WorldOrigin.LightingZones.ChildAdded:Connect(ChildAdded)

for _, child in pairs(workspace._WorldOrigin.LightingZones:GetChildren()) do
	ChildAdded(child)
end

task.spawn(function()
	local GetDangerLevel = require(game.ReplicatedStorage:WaitForChild("Util"):WaitForChild("GetDangerLevel"))
	local SeaTerror = require(script.SeaTerror)
	local clone = script.DarkFog:Clone()
	clone.Parent = game.Lighting.LightingLayers
	local v2 = false

	function v.DarkSea(_)
		local dangerLevel = game.Players.LocalPlayer:GetAttribute("DangerLevel") or 0
		local level = GetDangerLevel(dangerLevel).level
		local _ = GetDangerLevel(dangerLevel).percent
		local leviathanFog = game.Lighting.LightingLayers:FindFirstChild("LeviathanFog")
		local Global = require(game.ReplicatedStorage.Global)
		local v3 = Global.CurrentLocation == "Kitsune Island"
		local Global2 = require(game.ReplicatedStorage.Global)
		local v4 = Global2.CurrentLocation == "Prehistoric Island"
		local v5

		if level >= 7 then
			v5 = not (leviathanFog or v3 or v4)
		else
			v5 = false
		end

		if v2 ~= v5 then
			if v5 then
				TweenService:Create(clone.Intensity, TweenInfo.new(3), {
					Value = 1
				}):Play()
			else
				TweenService:Create(clone.Intensity, TweenInfo.new(3), {
					Value = 0
				}):Play()
			end

			if v5 then
				if workspace.Terrain:GetAttribute("SeaTheme") ~= "Dark" then
					workspace.Terrain:SetAttribute("SeaTheme", "Dark")
				end

				workspace._WorldOrigin.Locations.Sea.Sound:SetAttribute("SoundId", "rbxassetid://15129037402")
				task.spawn(function()
					SeaTerror({
						Value = 1
					})
				end)
			elseif not v5 then
				if workspace.Terrain:GetAttribute("SeaTheme") == "Dark" then
					workspace.Terrain:SetAttribute("SeaTheme", "Default")
				end

				workspace._WorldOrigin.Locations.Sea.Sound:SetAttribute("SoundId", "rbxassetid://2874697725")
				task.spawn(function()
					SeaTerror({
						Value = 0
					})
				end)
			end
		end

		v2 = v5
	end
end)
task.spawn(function()
	local SeaKitsune = require(script.SeaKitsune)
	local clone = script.KitsuneFog:Clone()
	clone.Parent = game.Lighting.LightingLayers
	local v2 = false

	function v.KitsuneSea(_)
		local leviathanFog = game.Lighting.LightingLayers:FindFirstChild("LeviathanFog")
		local Global = require(game.ReplicatedStorage.Global)
		local v3 = Global.CurrentLocation == "Kitsune Island" and not leviathanFog

		if v2 ~= v3 then
			if v3 then
				TweenService:Create(clone.Intensity, TweenInfo.new(3), {
					Value = 1
				}):Play()
			else
				TweenService:Create(clone.Intensity, TweenInfo.new(3), {
					Value = 0
				}):Play()
			end

			if v3 then
				task.spawn(function()
					SeaKitsune({
						Value = 1
					})
				end)
			elseif not v3 then
				task.spawn(function()
					SeaKitsune({
						Value = 0
					})
				end)
			end
		end

		v2 = v3
	end
end)
task.spawn(function()
	local TikiLiberation = require(script.TikiLiberation)
	local clone = script.LiberationFog:Clone()
	clone.Parent = game.Lighting.LightingLayers
	local v2 = false

	function v.TikiLiberation(_)
		local leviathanFog = game.Lighting.LightingLayers:FindFirstChild("LeviathanFog")
		local Global = require(game.ReplicatedStorage.Global)
		local v3 = Global.CurrentLocation == "Liberation of Tiki Outpost" and not leviathanFog

		if v2 ~= v3 then
			if v3 then
				TweenService:Create(clone.Intensity, TweenInfo.new(3), {
					Value = 1
				}):Play()
			else
				TweenService:Create(clone.Intensity, TweenInfo.new(3), {
					Value = 0
				}):Play()
			end

			if v3 then
				task.spawn(function()
					TikiLiberation({
						Value = 1
					})
				end)
			elseif not v3 then
				task.spawn(function()
					TikiLiberation({
						Value = 0
					})
				end)
			end
		end

		v2 = v3
	end
end)
task.spawn(function()
	local PrehistoricAmbient = require(script.PrehistoricAmbient)
	local clone = script.PrehistoricFog:Clone()
	clone.Parent = game.Lighting.LightingLayers
	local v2 = false

	function v.PrehistoricAmbient(_)
		local leviathanFog = game.Lighting.LightingLayers:FindFirstChild("LeviathanFog")
		local Global = require(game.ReplicatedStorage.Global)
		local v3 = Global.CurrentLocation == "Prehistoric Island"
		local prehistoricIsland = workspace.Map:FindFirstChild("PrehistoricIsland")
		local isMinigameActive = prehistoricIsland and prehistoricIsland:GetAttribute("IsMinigameActive")
		local v4 = v3 and isMinigameActive and not leviathanFog

		if v2 ~= v4 then
			if v4 then
				TweenService:Create(clone.Intensity, TweenInfo.new(3), {
					Value = 1
				}):Play()
			else
				TweenService:Create(clone.Intensity, TweenInfo.new(3), {
					Value = 0
				}):Play()
			end

			if v4 then
				task.spawn(function()
					PrehistoricAmbient({
						Value = 1
					})
				end)
			elseif not v4 then
				task.spawn(function()
					PrehistoricAmbient({
						Value = 0
					})
				end)
			end
		end

		v2 = v4
	end
end)
local v2 = {}

while true do
	task.wait(0.2)
	local character = localPlayer.Character

	if not (character and character:FindFirstChild("HumanoidRootPart")) then
		continue
	end

	local currentLocation = localPlayer:GetAttribute("CurrentLocation")

	if currentLocation then
		local lightningEventTimeLeft = workspace:GetAttribute("LightningEventTimeLeft")
		lightningEventTimer.Text = not lightningEventTimeLeft and "" or string.format(
			"Lightning Event: %s",
			TimeUtil.format(lightningEventTimeLeft, "minimal")
		) or ""

		if lightningEventTimeLeft then
			local Global = require(game.ReplicatedStorage.Global)
			lightningEventTimeLeft = Global.TrackingLightningEvent == true
		end

		lightningEventTimer.Visible = string.match(currentLocation, "LightningStrikesRegion") ~= nil or lightningEventTimeLeft
		local corruptedEventTimeLeft = workspace:GetAttribute("CorruptedEventTimeLeft")
		lightningEventTimer.Text = not corruptedEventTimeLeft and "" or string.format(
			"Corrupted Event: %s",
			TimeUtil.format(corruptedEventTimeLeft, "minimal")
		) or ""

		if corruptedEventTimeLeft then
			local Global = require(game.ReplicatedStorage.Global)
			corruptedEventTimeLeft = Global.TrackingCorruptedEvent == true
		end

		lightningEventTimer.Visible = corruptedEventTimeLeft
		local celestialEventCountdown = workspace:GetAttribute("CelestialEventCountdown") or 0
		local formatted = TimeUtil.format(celestialEventCountdown, "minimal")
		local celestialEventActive = workspace:GetAttribute("CelestialEventActive")
		local text

		if workspace:GetAttribute("CelestialEventCountdownActive") then
			text = string.format("Celestial Surge Event starting in <b>%s</b>", formatted)
		else
			text = not celestialEventActive and "" or string.format(
				"Celestial Surge Event ends in <b>%s</b>",
				formatted
			)
		end

		celestialCountdown.TextLabel.Text = text
		celestialCountdown.TextLabel.TextLabel.Text = text
		local v4 = string.match(currentLocation, "Celestial Domain") ~= nil
		celestialCountdown.Visible = v4 and celestialEventCountdown > 0
		celestialMeter.Visible = v4 and celestialEventActive
	end

	local v3 = character.HumanoidRootPart.Position * createVector(1, 0, 1)
	local raycastResult = workspace:Raycast(
		character.HumanoidRootPart.Position - createVector(0, 200, 0),
		createVector(0, 2000, 0),
		raycastParams
	)

	for k, _ in pairs(v2) do
		v2[k] = false
	end

	if raycastResult and raycastResult.Instance then
		local v4 = game.Lighting.LightingLayers:FindFirstChild(raycastResult.Instance.Name) or game.Lighting.LightingLayers:FindFirstChild(raycastResult.Instance.Parent.Name)

		if v4 and v4:FindFirstChild("Intensity") then
			if v4:FindFirstChild("Intensity").Value == 0 then
				TweenService:Create(v4:FindFirstChild("Intensity"), TweenInfo.new(1), {
					Value = 1
				}):Play()
			end

			v2[v4] = true
		end
	end

	for k, v4 in pairs(v2) do
		if v4 or not k:FindFirstChild("Intensity") then
			continue
		end

		TweenService:Create(k:FindFirstChild("Intensity"), TweenInfo.new(1), {
			Value = 0
		}):Play()
		v2[k] = nil
	end

	RainEnabled = false

	for _, v4 in pairs(v) do
		v4(v3)
	end
end