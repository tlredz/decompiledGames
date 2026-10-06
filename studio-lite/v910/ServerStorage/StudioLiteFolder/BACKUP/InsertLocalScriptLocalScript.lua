local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Loadstring = require(ReplicatedStorage.StudioLiteFolder.Loadstring)
local contentText = script:WaitForChild("SL_CodeTextBox").ContentText
local parts = contentText:split("\n")
local v = nil
local v2 = nil

for i = 1, #parts do
	v, v2 = parts[i]:match("%s*(.-)%.PlayerAdded:Connect(.*)")

	if v and not v:find("--", 1, true) then
		for i2 = i + 1, #parts do
			if parts[i2]:find("etfenv", 1, true) then
				error("'setfenv' and 'getfenv' are not available in Studio Lite.  Line number:" .. i2)
			elseif parts[i2]:find("InsertService", 1, true) or parts[i2]:find("LoadAsset", 1, true) then
				error("Unable to use InsertService. Please use Toolbox or the blue-plus to insert objects.  Line number:" .. i2)
			elseif parts[i2]:find("DataStore", 1, true) then
				error("To protect your data, DataStores are only accessible using Studio Lite's DataStoreScript found in the blue-plus.  Line number:" .. i2)
			elseif parts[i2]:find("require", 1, true) then
				error("Keyword 'require' not supported in Studio Lite.  Line number:" .. i2)
			elseif parts[i2]:find("BadgeService", 1, true) or parts[i2]:find("AwardBadge", 1, true) then
				error("BadgeService not supported in Studio Lite.  Line number:" .. i2)
			elseif parts[i2]:find("GetService", 1, true) then
				if parts[i2]:match("GetService.*GetService") then
					error("Only one GetService is allowed per line.  Line number:" .. i2)
				elseif not parts[i2]:match("GetService%(\"%w*\"%)") then
					error("In Studio Lite, GetService() must contain a one string in double quotes.  Line number:" .. i2)
				end
			end

			v2 ..= "\n" .. parts[i2]

			if #v2 > 2000 then
				break
			end
		end

		v2 = v2:match("%b()")

		if v2 ~= nil and v2 ~= "" then
			break
		end

		error("Can't find closing parenthesis for 'PlayerAdded:Connect('.  In Studio Lite the PlayerAdded inline function can be at most 2000 characters. Suggest using a named function instead of inline function.")
		break
	elseif parts[i]:find("etfenv", 1, true) then
		error("'setfenv' and 'getfenv' are not available in Studio Lite.  Line number:" .. i)
	elseif parts[i]:find("InsertService", 1, true) or parts[i]:find("LoadAsset", 1, true) then
		error("Unable to use InsertService. Please use Toolbox or the blue-plus to insert objects.  Line number:" .. i)
	elseif parts[i]:find("DataStore", 1, true) then
		error("To protect your data, DataStores are only accessible using Studio Lite's DataStoreScript found in the blue-plus.  Line number:" .. i)
	elseif parts[i]:find("require", 1, true) then
		error("Keyword 'require' not supported in Studio Lite.  Line number:" .. i)
	elseif parts[i]:find("BadgeService", 1, true) or parts[i]:find("AwardBadge", 1, true) then
		error("BadgeService not supported in Studio Lite.  Line number:" .. i)
	elseif parts[i]:find("GetService", 1, true) then
		if parts[i]:match("GetService.*GetService") then
			error("Only one GetService is allowed per line.  Line number:" .. i)
		elseif not parts[i]:match("GetService%(\"%w*\"%)") then
			error("In Studio Lite, GetService() must contain a string in double quotes.  Line number:" .. i)
		end
	end
end

if v and not v:find("--", 1, true) then
	local match = v2:match("function(%b())")
	local v3 = not (match and #match > 2) and "player" or match:sub(2, -2)
	local match2, v4 = v2:match("%s*(.-)%.CharacterAdded:Connect(%b())")

	if match2 and not match2:find("--", 1, true) then
		contentText ..= [[


]] .. "for _," .. v3 .. " in pairs(game.Players:GetPlayers()) do \n" .. " local xyz = " .. v2 .. "\n" .. " xyz(" .. v3 .. ") \n" .. " if " .. v3 .. ".Character or " .. v3 .. ".CharacterAdded:Wait() then \n" .. "  local abc = " .. v4 .. "\n" .. "  abc(" .. v3 .. [[
.Character) 
 end 
end 
]]
	else
		contentText ..= [[


]] .. "for _, " .. v3 .. " in pairs(game.Players:GetPlayers()) do \n" .. v2 .. "(" .. v3 .. [[
)  
end 
]]
	end
end

wait(0.5)
local v3, v4 = Loadstring(contentText)

if v4 then
	error(v4)
else
	v3()
end