local Players = game:GetService("Players")
require(game.ReplicatedStorage.DialoguesList.Types)
local Util = require(game.ReplicatedStorage.DialoguesList.Util)
local Flags = require(game.ReplicatedStorage.Modules.Flags)
local Net = require(game.ReplicatedStorage.Modules.Net)
local remoteFunction = Net:RemoteFunction("EnchantInvoke")
return {
	Title = "Blacksmith",
	Get = function(_)
		local function gen(label: string)
			return {
				Label = label,
				JumpTo = function()
					local character = Players.LocalPlayer.Character

					if not character then
						return {
							Text = { "..." }
						}
					end

					local tool = character:FindFirstChildOfClass("Tool")

					if not tool or tool.ToolTip ~= label then
						for _, tool2 in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
							if not (tool2:IsA("Tool") and tool2.ToolTip == label) then
								continue
							end

							tool = tool2
							break
						end
					end

					if not tool then
						return {
							Text = { "Where's the item? Please equip a " .. label .. " first." }
						}
					end

					local v

					if Flags.ENCHANT_USES_NEW_SERVICE then
						v = remoteFunction:InvokeServer("CheckUpgrades", tool)
					else
						v = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("UpgradeItem", "Check", tool)
					end

					if not v then
						return {
							Text = { "Where's the item? Please equip a " .. label .. " first." }
						}
					end

					Util.promptCraftAndWaitForGuiToClose(v.Required, v.Result, v.ResultStats)
					return {
						Text = { "..." }
					}
				end
			}
		end

		local v3 = "Sword"
		local v = {
			Text = { "Hi there, I can <Color=Yellow>upgrade<Color=/> your weapons. Let's take a look!" },
			Option1 = {
				Label = "Sword",
				JumpTo = function()
					local character = Players.LocalPlayer.Character

					if not character then
						return {
							Text = { "..." }
						}
					end

					local tool = character:FindFirstChildOfClass("Tool")

					if not tool or tool.ToolTip ~= v3 then
						for _, tool2 in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
							if not (tool2:IsA("Tool") and tool2.ToolTip == v3) then
								continue
							end

							tool = tool2
							break
						end
					end

					if not tool then
						return {
							Text = { "Where's the item? Please equip a " .. v3 .. " first." }
						}
					end

					local v4

					if Flags.ENCHANT_USES_NEW_SERVICE then
						v4 = remoteFunction:InvokeServer("CheckUpgrades", tool)
					else
						v4 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("UpgradeItem", "Check", tool)
					end

					if not v4 then
						return {
							Text = { "Where's the item? Please equip a " .. v3 .. " first." }
						}
					end

					Util.promptCraftAndWaitForGuiToClose(v4.Required, v4.Result, v4.ResultStats)
					return {
						Text = { "..." }
					}
				end
			},
			Option2 = 0
		}
		local v5 = "Gun"
		v.Option2 = {
			Label = "Gun",
			JumpTo = function()
				local character = Players.LocalPlayer.Character

				if not character then
					return {
						Text = { "..." }
					}
				end

				local tool = character:FindFirstChildOfClass("Tool")

				if not tool or tool.ToolTip ~= v5 then
					for _, tool2 in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
						if not (tool2:IsA("Tool") and tool2.ToolTip == v5) then
							continue
						end

						tool = tool2
						break
					end
				end

				if not tool then
					return {
						Text = { "Where's the item? Please equip a " .. v5 .. " first." }
					}
				end

				local v6

				if Flags.ENCHANT_USES_NEW_SERVICE then
					v6 = remoteFunction:InvokeServer("CheckUpgrades", tool)
				else
					v6 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("UpgradeItem", "Check", tool)
				end

				if not v6 then
					return {
						Text = { "Where's the item? Please equip a " .. v5 .. " first." }
					}
				end

				Util.promptCraftAndWaitForGuiToClose(v6.Required, v6.Result, v6.ResultStats)
				return {
					Text = { "..." }
				}
			end
		}
		return v
	end
}