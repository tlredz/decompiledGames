local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local clientAction = ReplicatedStorage:WaitForChild("ClientAction", 99999)
local action = nil
local instance = nil
local path = nil

function PerformAction(p)
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
end

clientAction.OnClientEvent:Connect(PerformAction)

function AddMessageToOutput(value, p)
	if #value > 2000 then
		value = value:sub(1, 2000)
	end

	if value:sub(1, 3) ~= "SL_" and value:sub(1, 25) ~= "exception while signaling" and value:sub(1, 19) ~= "Go to Game Settings" and value:sub(
		1,
		29
	) ~= "GuiService:AddSelectionParent" and value:sub(1, 29) ~= "DataStoreService: KeyNotFound" and value:sub(1, 19) ~= "Multiple StyleLinks" and not (value:find(
		"Clamped specified Density value",
		1,
		true
	) or value:find(".Play321.", 1, true) or value:find("SL_Colorize", 1, true) or value:match("PlayerGui.*StarterPlayer") or value:match("PlayerGui.*StarterGui") or value:match("PlayerGui.*StudioGui")) then
		local v = value:match(".*Yueliang%s*:%d*:%s*(.*)$") or value
		local match, v2 = v:match("(.*)%s.-StudioLiteFolder%.SLVM%.LuaVM%.FiOne:%d*:%s(.*)$")

		if match and v2 then
			v = match .. " " .. v2
		end

		local v3 = v:match(".*:%d*: @(.*)$") or v

		if v3:find("Stack Begin", 1, true) or v3:find("Stack End", 1, true) or v3:find("Script '", 1, true) then
			return
		end

		local v4 = v3:find("User is not authorized to access Asset.", 1, true)

		if v4 then
			v3 = v3:sub(1, v4 - 1) .. " Studio Lite can't play it, but it might work in your published game if it's in your inventory."
		end

		if v3:sub(-8) == "near ':'" then
			warn("Studio Lite Play/test mode currently supports the Lua ver 5.1 standard without Type Annotation. Please remove the ': dataType'. But it might work in your published game. L")
		end

		if v3:sub(-37) == "'unpack' (table expected, got string)" then
			warn("Studio Lite Play/test mode currently supports the Lua ver 5.1 standard. Please include the 'in pairs()' notation. But it might work in your published game. L")
		end

		if v3 and #v3 > 300 then
			if p == Enum.MessageType.MessageInfo then
				v3 = v3:match("(.-)%s*%{.*") or v3:sub(1, 300) .. "...too long!"
			else
				v3 = v3:sub(1, 300) .. "...too long!"
			end
		end

		if v3 then
			pcall(function()
				local v5 = (p == Enum.MessageType.MessageError and "<font color='#ff0000'>" or p == Enum.MessageType.MessageWarning and "<font color='#800000'>" or "<font color='#000000'>") .. v3:gsub(
					"<",
					"&lt;"
				) .. "</font>\n"
				local outputFrame = game.Players.LocalPlayer.PlayerGui:WaitForChild("StudioGui", 9):WaitForChild("OutputFrame")
				local errorTextLabel = outputFrame:WaitForChild("ScrollingFrame"):WaitForChild("ErrorTextLabel")
				errorTextLabel.Text ..= v5
				outputFrame.Visible = true
			end)
		end
	end
end

local LogService = game:GetService("LogService")
LogService.MessageOut:Connect(function(p, p2)
	AddMessageToOutput(p, p2)
end)
local ScriptContext = game:GetService("ScriptContext")
ScriptContext.Error:Connect(function(p)
	task.wait()
	AddMessageToOutput(p, Enum.MessageType.MessageError)
end)