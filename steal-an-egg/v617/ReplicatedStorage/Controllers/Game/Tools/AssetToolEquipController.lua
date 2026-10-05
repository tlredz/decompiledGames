local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = require(ReplicatedStorage.Data.Assets)
local AssetPlacementHints = require(script.Parent.Parent.Plots.ActiveAssetsController.AssetPlacementHints)
local AssetRoster = require(ReplicatedStorage.Client.AssetRoster)
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local Player = require(ReplicatedStorage.Shared.Player)
local Trove = require(ReplicatedStorage.Packages.Trove)
local color = Color3.fromRGB(85, 255, 85)
local color2 = Color3.fromRGB(255, 70, 70)
local localPlayer = Players.LocalPlayer
local v = Trove.new()
local v2 = Trove.new()
local v3 = nil
local v4 = nil
return {
	Start = function()
		local function isAssetTool(instance)
			return instance:GetAttribute("ItemType") == "Asset"
		end

		local function getAssetToolUid(instance)
			local UID = instance:GetAttribute("UID")

			if typeof(UID) == "string" and UID ~= "" then
				return UID
			end

			return nil
		end

		local function getAssetToolCategory(instance)
			local category = instance:GetAttribute("Category")

			if typeof(category) == "string" and category ~= "" then
				return category
			end

			return nil
		end

		local function isNearPetAreaSurface(penArea, position: Vector3)
			local pointToObjectSpace = penArea.CFrame:PointToObjectSpace(position)
			local v5 = penArea.Size * 0.5
			local vector = Vector3.new(
				math.clamp(pointToObjectSpace.X, -v5.X, v5.X),
				math.clamp(pointToObjectSpace.Y, -v5.Y, v5.Y),
				(math.clamp(pointToObjectSpace.Z, -v5.Z, v5.Z))
			)
			return (position - penArea.CFrame:PointToWorldSpace(vector)).Magnitude <= 20
		end

		local function showGetCloserNotification()
			Toast.Show({
				Text = "Get closer to your Pen to place pets!",
				Color = color2,
				Seconds = 2
			})
		end

		local function showEquipSuccessNotification(instance)
			local category = instance:GetAttribute("Category")

			if typeof(category) ~= "string" or category == "" then
				category = nil
			end

			if category == nil then
				return
			end

			local v5 = Assets.Directory[category]

			if v5.DisplayName ~= "" then
				category = v5.DisplayName
			end

			local v6

			if v5.Rarity then
				v6 = v5.Rarity.Color
			else
				v6 = Color3.new(1, 1, 1)
			end

			Toast.Show({
				Text = `Sucessfully equipped <font color="#{v6:ToHex()}">{category}!</font>`,
				Color = color,
				Seconds = 2
			})
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function showEquipErrorNotification(text: string)
			Toast.Show({
				Text = text,
				Color = color2,
				Seconds = 2
			})
		end

		local function tryEquipToolAsset(instance)
			local UID = instance:GetAttribute("UID")

			if typeof(UID) ~= "string" or UID == "" then
				UID = nil
			end

			if UID == nil or v4 == UID then
				return
			end

			local part = Player.FindRootPart(localPlayer)

			if part ~= nil and not part:IsA("BasePart") then
				return
			end

			local penArea = AssetRoster.FindPenArea(localPlayer)

			if part == nil or penArea == nil then
				return
			end

			if not isNearPetAreaSurface(penArea, part.Position) then
				Toast.Show({
					Text = "Get closer to your Pen to place pets!",
					Color = color2,
					Seconds = 2
				})
				return
			end

			v4 = UID
			AssetPlacementHints.SetFrontPlacement(UID, part.CFrame)
			local wearAsset, text = AssetRoster.WearAsset(UID)

			if v4 == UID then
				v4 = nil
			end

			if not wearAsset then
				AssetPlacementHints.ClearFrontPlacement(UID)

				if text ~= nil then
					showEquipErrorNotification(text) -- equivalent call inferred; original call site unknown
				end
			end

			if wearAsset and v3 == instance then
				showEquipSuccessNotification(instance)
				v2:Clean()
				v3 = nil
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function bindTool(tool)
			v2:Clean()
			v3 = tool
			v2:Connect(tool.Activated, function()
				tryEquipToolAsset(tool)
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refreshCharacter(instance)
			v2:Clean()
			v3 = nil
			local tool = instance:FindFirstChildOfClass("Tool")

			if tool ~= nil and tool:GetAttribute("ItemType") == "Asset" then
				bindTool(tool) -- equivalent call inferred; original call site unknown
			end
		end

		local function bindCharacter(character)
			v:Clean()
			refreshCharacter(character) -- equivalent call inferred; original call site unknown
			v:Connect(character.ChildAdded, function(tool)
				if tool:IsA("Tool") and tool:GetAttribute("ItemType") == "Asset" then
					bindTool(tool) -- equivalent call inferred; original call site unknown
				end
			end)
			v:Connect(character.ChildRemoved, function(p)
				if p == v3 then
					v2:Clean()
					v3 = nil
				end
			end)
		end

		localPlayer.CharacterAdded:Connect(bindCharacter)
		localPlayer.CharacterRemoving:Connect(function()
			v:Clean()
			v2:Clean()
			v3 = nil
			v4 = nil
		end)

		if localPlayer.Character ~= nil then
			bindCharacter(localPlayer.Character)
		end
	end
}