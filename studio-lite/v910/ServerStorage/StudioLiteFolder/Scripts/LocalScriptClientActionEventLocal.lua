local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local action = nil
local instance = nil
local path = nil
ReplicatedStorage:WaitForChild("ClientAction", 99999).OnClientEvent:Connect(function(p)
	local success, result = pcall(function()
		action = p.action or ""
		p.action = nil
		instance = p.instance or ""
		p.instance = nil
		path = p.path or ""
		p.path = nil
		local game2 = game

		for k, childName in pairs(path:split(".")) do
			if k == 1 then
				if childName ~= "game" then
					if childName == "player" then
						game2 = game.Players.LocalPlayer
					elseif childName == "ScreenGui" then
						game2 = game.Players.LocalPlayer:WaitForChild("PlayerGui", 9):WaitForChild("ScreenGui", 9)
					elseif childName == "PlayerGui" then
						game2 = game.Players.LocalPlayer:WaitForChild("PlayerGui", 9)
					else
						game2 = game2[childName]
					end
				end
			elseif childName == "LocalPlayer" then
				game2 = game.Players.LocalPlayer
			elseif game2:WaitForChild(childName, 1) then
				game2 = game2[childName]
			else
				error("Problem in " .. script.Name .. ".  " .. childName .. " does not exist in path=\"" .. path .. "\"")
			end
		end

		if action == "update" then
			for k, v in pairs(p) do
				game2[k] = v
			end
		elseif action == "append" then
			for k, v in pairs(p) do
				if k == "Text" then
					game2.Text ..= v
				else
					game2[k] = v
				end
			end
		elseif action == "create" then
			local instance2 = Instance.new(instance)

			for k, v in pairs(p) do
				instance2[k] = v
			end
		elseif action == "delete" then
			Debris:AddItem(game2, 0.01)
		else
			error("Expected action = \"update\", \"create\", or \"delete\"")
		end
	end)

	if not success then
		pcall(function()
			local outputFrame = game.Players.LocalPlayer.PlayerGui:WaitForChild("StudioGui", 9):WaitForChild("OutputFrame")
			local errorTextLabel = outputFrame:WaitForChild("ScrollingFrame"):WaitForChild("ErrorTextLabel")
			errorTextLabel.Text ..= script.Name .. " had trouble with :FireClient action=\"" .. action .. "\", pathString=\"" .. path .. "\".  Error:" .. result:gsub(
				"<",
				"&lt;"
			) .. "\n"
			outputFrame.Visible = true
		end)
	end
end)