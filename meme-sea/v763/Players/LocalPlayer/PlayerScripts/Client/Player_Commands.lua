local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local connections = {}
local v = {
	"CooldownGui",
	"GameGui",
	"MainGui",
	"Menu",
	"Mobile",
	"Power",
	"Weapon",
	"Backpack",
	"TopbarStandard",
	"FightingStyle"
}
ReplicatedStorage:WaitForChild("OtherEvent"):WaitForChild("MiscEvents"):WaitForChild("Player_Commands").Event:Connect(function(p: string, ...)
	if p == "Run_Command" then
		local v2 = ...

		if string.lower(v2) == "/hideui" then
			if #connections <= 0 then
				for _, child in ipairs(playerGui:GetChildren()) do
					if not (table.find(v, child.Name) and child.Enabled) then
						continue
					end

					child.Enabled = false
					local v3 = child
					connections[#connections + 1] = child:GetPropertyChangedSignal("Enabled"):Connect(function()
						if v3.Enabled == true then
							v3.Enabled = false
						end
					end)
					connections[#connections + 1] = localPlayer.CharacterAdded:Connect(function()
						DisabledUI()
					end)
				end
			end
		elseif string.lower(v2) == "/showui" then
			DisabledUI()
		elseif string.lower(v2) == "/defaultsky" then
			if Lighting:FindFirstChild("Atmosphere") and Lighting:FindFirstChild("Sky") then
				local atmosphere = Lighting:FindFirstChild("Atmosphere")
				local sky = Lighting:FindFirstChild("Sky")

				if atmosphere then
					atmosphere.Parent = script
				end

				if sky then
					sky.Parent = script
				end
			elseif script:FindFirstChild("Atmosphere") and script:FindFirstChild("Sky") then
				local atmosphere = script:FindFirstChild("Atmosphere")
				local sky = script:FindFirstChild("Sky")

				if atmosphere then
					atmosphere.Parent = Lighting
				end

				if sky then
					sky.Parent = Lighting
				end
			end
		elseif string.lower(v2) == "/recd" and not localPlayer:GetAttribute("Reset_Cooldown") then
			localPlayer:SetAttribute("Reset_Cooldown", true)
			task.wait(0.1)
			localPlayer:SetAttribute("Reset_Cooldown", nil)
		end
	end
end)

function DisabledUI()
	for _, connection in ipairs(connections) do
		if connection then
			connection:Disconnect()
		end
	end

	table.clear(connections)

	for _, child in ipairs(playerGui:GetChildren()) do
		if not (table.find(v, child.Name) and child.Enabled == false) then
			continue
		end

		if child.Name == "FightingStyle" then
			local character = localPlayer.Character

			if character and character.Parent then
				local tool = character:FindFirstChildWhichIsA("Tool")

				if tool and tool:HasTag("FightingStyle") then
					child.Enabled = true
				end
			end
		elseif child.Name == "Weapon" then
			local character = localPlayer.Character

			if character and character.Parent then
				local tool = character:FindFirstChildWhichIsA("Tool")

				if tool and tool:HasTag("Weapon") then
					child.Enabled = true
				end
			end
		elseif child.Name == "Power" then
			local character = localPlayer.Character

			if character and character.Parent then
				local tool = character:FindFirstChildWhichIsA("Tool")

				if tool and tool:HasTag("Power") then
					child.Enabled = true
				end
			end
		else
			child.Enabled = true
		end
	end
end