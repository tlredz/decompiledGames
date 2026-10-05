local Net = require(game.ReplicatedStorage.packages.Net)
local Trove = require(game.ReplicatedStorage.packages.Trove)
local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local v = playerGui:WaitForChild("Return")
local button = v:WaitForChild("Button")

if localPlayer:GetAttribute("ABReturnIsland") == nil then
	localPlayer:GetAttributeChangedSignal("ABReturnIsland"):Wait()
end

local ReturnToIslandController = {}

function containsWord(value, p)
	return string.find(string.lower(value), "%f[%a]" .. p .. "%f[%A]") ~= nil
end

function ReturnToIslandController.Start(_)
	local function CharacterAdded(character2)
		local zone = character2:WaitForChild("zone")

		local function CheckZone()
			if zone.Value then
				if (zone.Value.Name == "Ocean" or containsWord(zone.Value.Name, "Ocean")) and localPlayer:GetAttribute("ABReturnIsland") then
					if localPlayer:GetAttribute("LastIsland") then
						button.Text = "Return To " .. localPlayer:GetAttribute("LastIsland")
						v.Enabled = true
					end
				else
					v.Enabled = false
				end
			end
		end

		if not character2:IsDescendantOf(game) then
			character2.AncestryChanged:Wait()
		end

		local maid = Trove.new()
		maid:AttachToInstance(character2)
		CheckZone()
		maid:Add(zone.Changed:Connect(function()
			CheckZone()
		end))
	end

	CharacterAdded(character)
	localPlayer.CharacterAdded:Connect(CharacterAdded)
	button.Activated:Connect(function()
		if localPlayer.Character or localPlayer.CharacterAdded:Wait() then
			Net:RemoteEvent("ReturnToLastIsland"):FireServer()
		end
	end)
end

return ReturnToIslandController