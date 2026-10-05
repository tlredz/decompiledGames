-- failed to load script (decompiled with syntax error):
-- ptSrqyHUiMwchcUHLKzDehHzb:92: Expected identifier when parsing expression, got ';'

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage2.packages.Net)
local fx = require(ReplicatedStorage.shared.modules:WaitForChild("fx"))
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local localPlayer = Players.LocalPlayer
local location = localPlayer.PlayerGui:WaitForChild("hud").location
local music = localPlayer.PlayerGui:WaitForChild("sounds"):WaitForChild("music")
local Trove = require(game.ReplicatedStorage.packages.Trove)
local character = require(ReplicatedStorage.shared.modules.character)
local ZoneCutsceneManager = require(ReplicatedStorage.client.modules.ZoneCutsceneManager)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local maid = Trove.new()
local ambience = localPlayer.PlayerGui:WaitForChild("sounds"):WaitForChild("ambience")
game.Workspace:GetAttribute("DepthsAbsoluteDarkness")
game.Workspace:GetAttribute("NectarBloom")
local remoteFunction = Net:RemoteFunction("GetZone")
local zonesExplored = localPlayer:WaitForChild("ZonesExplored")
local music2 = ReplicatedStorage.resources.sounds.music
local ambience2 = ReplicatedStorage.resources.sounds.ambience
local locationchange = ReplicatedStorage.resources.sounds.sfx.ui.locationchange
local zone = nil
local humanoidRootPart = nil
local v = nil

while not character.PS(localPlayer) and task.wait(0.1) do

end

local children = {}
local v2 = nil
local v3 = nil

local function CharacterInNoWaterZone()
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = { game.Players.LocalPlayer.Character }
	local flag = false

	for _, v5 in CollectionService:GetTagged("NoWaterEffect") do
		if not (#workspace:GetPartsInPart(v5, overlapParams) > 0) then
			continue
		end

		flag = true
		break
	end

	if flag then
		game.Players.LocalPlayer:SetAttribute("NoWaterZone", true)
	else
		game.Players.LocalPlayer:SetAttribute("NoWaterZone", nil)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function createTween(p, tweenInfo, p2)
	local tween = TweenService:Create(p, tweenInfo, p2)
	tween:Play()
	return tween
end

local v4 = workspace.CurrentCamera:FindFirstChild("KrakenBackgroundSound")

if not v4 then
	v4 = Instance.new("Sound")
	v4.Name = "KrakenBackgroundSound"
	v4.SoundId = "rbxassetid://105317388000013"
	v4.Looped = true
	v4.Volume = 0
	v4.SoundGroup = game.SoundService.music
	v4.Parent = workspace.CurrentCamera
end

local function handleKrakenHuntActivation()
	if not zone then
		return
	end

	local krakenHuntIsActive = workspace:GetAttribute("KrakenHuntIsActive")
	local defaultVolume = music:GetAttribute("DefaultVolume") or 0.5
	local value = zone.Value

	if value and value.Name == "Kraken Lair" and krakenHuntIsActive then
		;(createTween(music, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			Volume = 0
		})).Completed:Wait()
		TweenService:Create(v4, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			Volume = 0.7
		}):Play()
		v4:Play()
		return
	end

	;(createTween(v4, TweenInfo.new(1, Enum.EasingStyle.Linear), {
		Volume = 0
	})).Completed:Wait()
	v4:Stop()
	TweenService:Create(music, TweenInfo.new(1, Enum.EasingStyle.Linear), {
		Volume = defaultVolume
	}):Play()
end

workspace:GetAttributeChangedSignal("KrakenHuntIsActive"):Connect(handleKrakenHuntActivation)
handleKrakenHuntActivation()
local v5 = false

local function onZoneChanged()
	if not zone then
		print("no character zone")
		return
	end

	local value = zone.Value

	if value and not humanoidRootPart.Anchored then
		if v2 and v2:FindFirstChild("zonename") and v2.zonename.Value == value.zonename.Value and v5 then
			if music and music.Parent then
				TweenService:Create(music, TweenInfo.new(1, Enum.EasingStyle.Linear), {
					Volume = 1
				}):Play()
				TweenService:Create(ambience, TweenInfo.new(1, Enum.EasingStyle.Linear), {
					Volume = 1
				}):Play()
			end
		else
			if v3 then
				v3.Parent = nil
			end

			if value:FindFirstChild("indoors") and value:FindFirstChild("indoors").Value then
				SoundService.weather.muffle.Enabled = true
			else
				SoundService.weather.muffle.Enabled = ReplicatedStorage.world.weather.Value ~= "Rain"
			end

			if value:FindFirstChild("music") then
				maid:Clean()

				if value.music.Value and value.music.Value ~= music.Name then
					if music then
						music:Destroy()
					end

					local function PlayMusic()
						if value.music.Value and value.music.Value ~= "" then
							if not music2:FindFirstChild(value.music.Value) then
								local _ = music2.Moosewood
							end

							v5 = true
							music = (music2:FindFirstChild(value.music.Value) or music2.Moosewood):Clone()
							music.SoundGroup = SoundService.music
							music.Parent = SoundService.music
							music.Looped = true
							music.Volume = 0
							music:Play()
							TweenService:Create(music, TweenInfo.new(1, Enum.EasingStyle.Linear), {
								Volume = 0.5
							}):Play()
						end
					end

					if value:FindFirstChild("joinmusic") and music2:FindFirstChild(value.joinmusic.Value) and not zonesExplored:FindFirstChild(value.Name) then
						local child = music2:FindFirstChild(value.joinmusic.Value)
						local clone = child:Clone()
						clone.SoundGroup = SoundService.music
						clone.Parent = localPlayer.PlayerGui.sounds
						clone.Volume = 0
						clone:Play()
						game.Debris:AddItem(clone, child.TimeLength / child.PlaybackSpeed)
						TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Linear), {
							Volume = child.Volume
						}):Play()
						maid:Add(task.delay(child.TimeLength / child.PlaybackSpeed - 2, function()
							TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Linear), {
								Volume = 0
							}):Play()
							PlayMusic()
						end))
					else
						PlayMusic()
					end
				end

				if music and music.Parent then
					TweenService:Create(music, TweenInfo.new(1, Enum.EasingStyle.Linear), {
						Volume = 1
					}):Play()
					TweenService:Create(ambience, TweenInfo.new(1, Enum.EasingStyle.Linear), {
						Volume = 1
					}):Play()
				end
			else
				TweenService:Create(music, TweenInfo.new(1, Enum.EasingStyle.Linear), {
					Volume = 0
				}):Play()
			end

			task.spawn(function()
				handleKrakenHuntActivation()
			end)
			local _ = ReplicatedStorage:WaitForChild("world"):WaitForChild("weather").Value == "Tornado"

			if value:FindFirstChild("ambience") and ambience2:FindFirstChild(value.ambience.Value) then
				if value.ambience.Value ~= ambience.Name then
					if ambience then
						TweenService:Create(ambience, TweenInfo.new(1, Enum.EasingStyle.Linear), {
							Volume = 0
						}):Play()
						task.delay(1, ambience.Destroy, ambience)
					end

					local child = ambience2:FindFirstChild(value.ambience.Value)
					ambience = child:Clone()
					ambience.SoundGroup = SoundService.ambience
					ambience.Looped = true
					ambience.Volume = 0
					ambience.Parent = localPlayer.PlayerGui
					ambience:Play()
					TweenService:Create(ambience, TweenInfo.new(1, Enum.EasingStyle.Linear), {
						Volume = child.Volume
					}):Play()
				end
			else
				TweenService:Create(ambience, TweenInfo.new(1, Enum.EasingStyle.Linear), {
					Volume = 0
				}):Play()
			end

			if value:FindFirstChild("discover") and localPlayer then
				local fetched = legacyLocalPlayerData.fetch()
				local value2 = value.discover.Value
				local v6 = value2 .. "Discovered"

				if fetched and not fetched.Stats.tracker_locationsdiscovered:FindFirstChild(v6) then
					ZoneCutsceneManager:PlayCutsceneForDiscovery(value2, value.zonename.Value)
					ReplicatedStorage.events.discoverlocation:FireServer(value2)
				end
			end

			if value.priority.Value <= 3 then
				fx:PlaySound(locationchange, localPlayer.PlayerGui, false)
			end

			if localPlayer.PlayerGui.hud:FindFirstChild("ct") then
				localPlayer.PlayerGui.hud.ct:Destroy()
			end

			local clone = location:Clone()
			clone.Name = "ct"
			clone.title.Text = "• " .. value.zonename.Value .. " •"
			clone.Parent = localPlayer.PlayerGui.hud
			v3 = clone
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
			TweenService:Create(clone.title, tweenInfo, {
				TextTransparency = 0
			}):Play()
			TweenService:Create(clone.title.UIStroke, tweenInfo, {
				Transparency = 0
			}):Play()
			task.wait(4.5)
			TweenService:Create(clone.title, tweenInfo, {
				TextTransparency = 1
			}):Play()
			TweenService:Create(clone.title.UIStroke, tweenInfo, {
				Transparency = 1
			}):Play()
			task.wait(1)
			clone:Destroy()
		end
	else
		TweenService:Create(music, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			Volume = 0
		}):Play()
		TweenService:Create(ambience, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			Volume = 0
		}):Play()
	end
end

local function ToggleIslandPOI(enabled)
	if not SettingsController:GetSettingValue("poiHeaders") then
		enabled = false
	end

	for _, billboardGui in pairs(CollectionService:GetTagged("poi_island")) do
		if billboardGui:IsA("BillboardGui") and billboardGui.Name == "POIHeader" then
			billboardGui.Enabled = enabled
		end
	end
end

workspace:GetAttributeChangedSignal("DepthsAbsoluteDarkness"):Connect(function()
	if not zone then
		return
	end

	local value = zone.Value

	if value and not humanoidRootPart.Anchored and value.Name == "The Depths" and workspace:GetAttribute("DepthsAbsoluteDarkness") == true then
		script.DepthsPing:Play()
	end
end)
workspace:GetAttributeChangedSignal("NectarBloom"):Connect(function()
	if not zone then
		return
	end

	local value = zone.Value

	if value and not humanoidRootPart.Anchored and value.Name == "Nectar Den" and workspace:GetAttribute("NectarBloom") == true then
		script.NectarPing:Play()
	end
end)

remoteFunction.OnClientInvoke = function()
	local value = zone and zone.Value
	local v6

	if value then
		return value.Name
	end

	return v6
end

local function OnCharacterAdded(p)
	v5 = false
	v2 = nil
	v = p
	humanoidRootPart = v:WaitForChild("HumanoidRootPart")
	zone = v:WaitForChild("zone", 30)
	humanoidRootPart:GetPropertyChangedSignal("Anchored"):Connect(onZoneChanged)
	zone.Changed:Connect(onZoneChanged)
	onZoneChanged()
end

if localPlayer.Character then
	task.spawn(OnCharacterAdded, localPlayer.Character)
end

localPlayer.CharacterAdded:Connect(OnCharacterAdded)
workspace:WaitForChild("zones"):WaitForChild("player")

-- equivalent calls inferred from this helper; original call sites unknown
local function getName(ocean)
	if not ocean then
		return nil
	end

	local zonename = ocean:FindFirstChild("zonename")

	if zonename and zonename:IsA("StringValue") then
		return zonename.Value
	end

	return ocean.Name
end

local v6 = nil
local v7 = 0

while true do
	task.wait(0.5)
	pcall(function()
		local spawningAt = not localPlayer:GetAttribute("SpawnFinished") and localPlayer:GetAttribute("SpawningAt") or humanoidRootPart.Position
		table.clear(children)
		local v8 = -1e999
		local ocean = nil

		for _, child in workspace.zones.player:GetChildren() do
			if not ((child:GetClosestPointOnSurface(spawningAt) - spawningAt).Magnitude <= 0.5) then
				continue
			end

			table.insert(children, child)
			local value = child:FindFirstChild("priority").Value

			if not (v8 < value) then
				continue
			end

			ocean = child
			v8 = value
		end

		if #children == 0 then
			ocean = ReplicatedStorage:FindFirstChild("Ocean") or ReplicatedStorage:FindFirstChild("Open Ocean") or ocean
		end

		if ocean and ocean ~= v6 then
			local value = zone.Value

			if value then
				local value2 = zone.Value

				if value2 then
					local zonename = value2:FindFirstChild("zonename")

					if zonename and zonename:IsA("StringValue") then
						value = zonename.Value
					else
						value = value2.Name
					end
				else
					value = nil
				end
			end

			local v9

			if value then
				local name = getName(ocean) -- equivalent call inferred; original call site unknown

				if name == value then
					v6 = ocean
				elseif v7 <= 0 then
					v9 = Net:RemoteFunction("SetZone"):InvokeServer(ocean)
					task.wait()

					if v9 then
						v2 = ocean
						zone.Value = ocean
						v6 = ocean
						v7 = 1.5
					else
						v2 = nil
						v6 = nil
					end
				end
			elseif v7 <= 0 then
				v9 = Net:RemoteFunction("SetZone"):InvokeServer(ocean)
				task.wait()

				if v9 then
					v2 = ocean
					zone.Value = ocean
					v6 = ocean
					v7 = 1.5
				else
					v2 = nil
					v6 = nil
				end
			end
		elseif not ocean then
			v6 = nil
		end

		if v7 > 0 then
			v7 -= 0.5
		end

		local value = zone.Value

		if value then
			if zone.Value.Name == "Ocean" or zone.Value.Name == "Open Ocean" then
				value = v:GetAttribute("SpawnFinished")
			else
				value = false
			end
		end

		ToggleIslandPOI(value)
		CharacterInNoWaterZone()
	end)
end