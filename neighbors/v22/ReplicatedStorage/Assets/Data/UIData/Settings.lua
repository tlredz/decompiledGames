local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local Players = game:GetService("Players")
local Server = require(ReplicatedStorage.Modules.Server)
require(ReplicatedStorage.Modules.Language)
local CountryData = require(game.ReplicatedStorage.Assets.Data.CountryData)
local localPlayer = Players.LocalPlayer
return {
	{
		SettingName = "Country",
		Category = "Gameplay",
		Display = "Country",
		Type = "Button",
		ValueClassName = "StringValue",
		DefaultValue = "",
		Updated = function(instance, _: string)
			local button = instance:FindFirstChild("Button")
			local country = localPlayer:GetAttribute("Country") or ""
			local countryInfo = CountryData.GetCountryInfo(country)
			local flagEmoji = CountryData.GetFlagEmoji(country)
			button.Text = not countryInfo and "Unknown Country" or `{flagEmoji} {countryInfo.BigTitle}`
		end,
		Clicked = function(_)
			localPlayer.PlayerGui.Prompts.CountrySetting.Visible = true
		end
	},
	{
		SettingName = "ShowServerOwnerInName",
		Display = "Show Server Owner Crown",
		Type = "Toggle",
		Category = "Gameplay",
		Callback = function(p)
			-- equivalent calls inferred from this helper; original call sites unknown
			local function update()
				local customServerOwner = localPlayer:GetAttribute("CustomServerOwner")
				local isCustomServer = workspace:GetAttribute("IsCustomServer")
				p.Visible = customServerOwner and isCustomServer
			end

			localPlayer:GetAttributeChangedSignal("CustomServerOwner"):Connect(update)
			update() -- equivalent call inferred; original call site unknown
		end
	},
	{
		SettingName = "HidePurchasables",
		Display = "Hide Item Purchasables",
		Type = "Toggle",
		Category = "Gameplay"
	},
	{
		SettingName = "HideCountry",
		Display = "Hide Country",
		Type = "Toggle",
		Category = "Privacy"
	},
	{
		SettingName = "HideVerifiedBadge",
		Display = "Hide Verified Badge",
		Type = "Toggle",
		Category = "Privacy"
	},
	{
		SettingName = "SecretMode",
		Display = "Go Secret Mode",
		Type = "Toggle",
		Category = "Privacy",
		MinimumRank = 35
	},
	{
		SettingName = "MuteMusic",
		Display = "Mute Music",
		Type = "Toggle",
		Category = "Audio"
	},
	{
		SettingName = "MuteEventSounds",
		Display = "Mute Event Related Sounds",
		Type = "Toggle",
		Category = "Audio"
	},
	{
		SettingName = "DisableCars",
		Display = "Mute Cars",
		Type = "Toggle",
		Category = "Audio",
		ExcludedServers = { Server.Servers.Neighborhood, Server.Servers.Night }
	},
	{
		SettingName = "MuteWeather",
		Display = "Mute Weather",
		Type = "Toggle",
		Category = "Audio"
	},
	{
		SettingName = "MuteToolSounds",
		Display = "Mute Item Sound Effects",
		Type = "Toggle",
		Category = "Audio"
	},
	{
		SettingName = "DisablePartyInvites",
		Display = "Disable Party Invites",
		Type = "Toggle",
		Category = "Gameplay"
	},
	{
		SettingName = "DisableMatchRequests",
		Display = "Disable Match Request Invites",
		Type = "Toggle",
		Category = "Gameplay"
	},
	{
		SettingName = "DisableVRRagdoll",
		Display = "Disable Ragdoll in VR",
		Type = "Toggle",
		Category = "Gameplay"
	},
	{
		SettingName = "HideGraffiti",
		Display = "Hide Other Players Spray Paint",
		Type = "Toggle",
		Category = "Gameplay",
		ExcludedServers = { Server.Servers.Neighborhood, Server.Servers.Night }
	},
	{
		SettingName = "HideHours",
		Display = "Hide Time Played",
		Type = "Toggle",
		Category = "Privacy",
		Cooldown = 1
	},
	{
		SettingName = "HideReputation",
		Display = "Hide Reputation",
		Type = "Toggle",
		Category = "Privacy"
	},
	{
		SettingName = "ShowOwnTag",
		Display = "Hide My Nametag/Title",
		Type = "Toggle",
		Category = "Gameplay"
	},
	{
		SettingName = "UseMasculineTitles",
		Display = "Use Masculine Titles",
		Type = "Toggle",
		Category = "Gameplay"
	},
	{
		SettingName = "ShowProfileOnSpawn",
		Display = "Display Profile On Entrance",
		Type = "Toggle",
		Category = "Gameplay"
	},
	{
		SettingName = "DisableComments",
		Display = "Block Comments",
		Type = "Toggle",
		Category = "Privacy"
	},
	{
		SettingName = "DisableCommentOnProfile",
		Display = "Hide Random Comment on Profile",
		Type = "Toggle",
		Category = "Privacy"
	},
	{
		SettingName = "HideStreak",
		Display = "Hide Streak",
		Type = "Toggle",
		Category = "Gameplay"
	},
	{
		SettingName = "StreamerMode",
		Display = "Streamer Mode",
		Type = "Toggle",
		Category = "Privacy"
	},
	{
		SettingName = "HideBadServers",
		Display = "Hide Incompatible Servers",
		Type = "Toggle",
		Category = "Gameplay"
	},
	{
		SettingName = "EnableFakeInteriors",
		Display = "Enable Fake Interiors",
		Type = "Toggle",
		Category = "Performance"
	},
	{
		SettingName = "DisableShadows",
		Display = "Disable Shadows",
		Type = "Toggle",
		Category = "Performance"
	},
	{
		SettingName = "DisableMemOpti",
		Display = "Disable Memory Optimization",
		Type = "Toggle",
		Category = "Performance"
	},
	{
		SettingName = "MusicSelection",
		Display = "Theme Song",
		Category = "Audio",
		Type = {
			{
				Name = "Synced",
				Icon = "rbxassetid://15813326642"
			},
			{
				Name = "Regular",
				Icon = "rbxassetid://114902830462126"
			},
			{
				Name = "Night time",
				Icon = "rbxassetid://114902830462126"
			},
			{
				Name = "Old 18+ Theme",
				Icon = "rbxassetid://114902830462126"
			},
			{
				Name = "Halloween",
				Icon = "rbxassetid://114902830462126"
			},
			{
				Name = "Christmas",
				Icon = "rbxassetid://114902830462126"
			},
			{
				Name = "Valentines",
				Icon = "rbxassetid://114902830462126"
			}
		}
	},
	{
		SettingName = "WeatherChoice",
		Display = "Weather",
		Category = "Gameplay",
		Type = {
			{
				Name = "Synced",
				Icon = "rbxassetid://15813326642"
			},
			{
				Name = "Clear",
				Icon = "rbxassetid://15706999377"
			},
			{
				Name = "Rain",
				Icon = "rbxassetid://15706999731"
			},
			{
				Name = "Thunderstorm",
				Icon = "rbxassetid://15706999553"
			}
		}
	},
	{
		SettingName = "TimeOfDay",
		Display = "Time of Day",
		Category = "Gameplay",
		Type = {
			{
				Name = "Synced",
				Icon = "rbxassetid://15813326642"
			},
			{
				Name = "Real Time",
				Icon = "rbxassetid://15813326642"
			},
			{
				Name = "Dawn",
				Icon = "rbxassetid://15706999377"
			},
			{
				Name = "Sunrise",
				Icon = "rbxassetid://15706999377"
			},
			{
				Name = "Day",
				Icon = "rbxassetid://15706999377"
			},
			{
				Name = "Sunset",
				Icon = "rbxassetid://15706999079"
			},
			{
				Name = "Dusk",
				Icon = "rbxassetid://15706999079"
			},
			{
				Name = "Night",
				Icon = "rbxassetid://15706999079"
			}
		}
	}
}