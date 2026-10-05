local Players = game:GetService("Players")
game:GetService("UserInputService")
require(game.ReplicatedStorage.Assets.Data.UIData.RandomUITypes)
require(game.ReplicatedStorage.Modules.FeatureFlags)
require(game.ReplicatedStorage.Modules.Server)
local Gamepad = require(game.ReplicatedStorage.Modules.Gamepad)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local neighbors = playerGui:WaitForChild("Neighbors")
return {
	Protection = {
		Icon = "rbxassetid://11322093465",
		MatchingFrame = nil,
		Order = -1,
		EnableGamepadSupport = false
	},
	Outfit = {
		Icon = "rbxassetid://15989991018",
		MatchingFrame = Players.LocalPlayer.PlayerGui:WaitForChild("Catalog").Outfit,
		GamepassRequired = "OutfitSelector",
		Order = 0,
		EnableGamepadSupport = true,
		EnableGamepadCursor = true
	},
	Shop = {
		Icon = "rbxassetid://15609014198",
		MatchingFrame = neighbors.Shop,
		Color = Color3.fromRGB(138, 255, 103),
		Order = -10,
		EnableGamepadSupport = false
	},
	Customize = {
		Icon = "rbxassetid://73924326821820",
		MatchingFrame = Players.LocalPlayer.PlayerGui:WaitForChild("HouseCustomization").Navigation,
		CreateCondition = Players.LocalPlayer:GetAttribute("HouseOwner"),
		Color = Color3.fromRGB(255, 221, 48),
		Callback = function(p)
			local houseCustomization = playerGui:WaitForChild("HouseCustomization")

			local function update()
				p.Visible = (localPlayer:GetAttribute("HouseOwnerPlace") and true or false) and (localPlayer:GetAttribute("HouseEditor") and true or false) and localPlayer:GetAttribute("State") ~= 7

				if not p.Visible then
					houseCustomization.Navigation.Visible = false
				end
			end

			update()
			localPlayer:GetAttributeChangedSignal("HouseOwnerPlace"):Connect(update)
			localPlayer:GetAttributeChangedSignal("HouseEditor"):Connect(update)
			localPlayer:GetAttributeChangedSignal("State"):Connect(update)
		end,
		EnableGamepadSupport = true,
		EnableGamepadCursor = true,
		Order = -5
	},
	Profile = {
		Icon = "rbxassetid://15618650091",
		MatchingFrame = neighbors.Profile,
		IgnoredFrames = { "Party" },
		Order = 2,
		EnableGamepadSupport = false
	},
	Party = {
		Icon = "rbxassetid://15609118393",
		MatchingFrame = neighbors.Party,
		IgnoredFrames = { "Profile" },
		Order = 3,
		EnableGamepadSupport = true,
		EnableGamepadCursor = true
	},
	Settings = {
		Icon = "rbxassetid://15609046570",
		MatchingFrame = neighbors.Settings,
		Order = 4,
		EnableGamepadSupport = true,
		EnableGamepadCursor = true
	},
	Servers = {
		Icon = "rbxassetid://11422925441",
		Color = Color3.fromRGB(107, 208, 255),
		MatchingFrame = playerGui:WaitForChild("Worlds"):WaitForChild("Frame"),
		Order = 999,
		Callback = function(p)
			-- equivalent calls inferred from this helper; original call sites unknown
			local function update()
				p.Visible = Gamepad.GamepadEnabled
			end

			Gamepad.GamepadChanged:Connect(update)
			update() -- equivalent call inferred; original call site unknown
		end,
		EnableGamepadSupport = false
	},
	Exit = {
		Icon = "rbxassetid://109757326745560",
		Color = Color3.fromRGB(255, 64, 64),
		IconScale = 0.8,
		MatchingFrame = nil,
		Order = 999999,
		Callback = function(state)
			-- equivalent calls inferred from this helper; original call sites unknown
			local function update()
				state.Visible = Gamepad.GamepadEnabled
			end

			state.Button.Activated:Connect(function()
				state.Parent.Parent.Visible = false
			end)
			Gamepad.GamepadChanged:Connect(update)
			update() -- equivalent call inferred; original call site unknown
		end,
		EnableGamepadSupport = false
	}
}