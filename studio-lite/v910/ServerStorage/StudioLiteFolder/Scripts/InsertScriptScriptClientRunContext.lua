local ReplicatedStorage = game:GetService("ReplicatedStorage")
local luaVM = require(ReplicatedStorage:WaitForChild("StudioLiteFolder"):WaitForChild("SLVM")).LuaVM.new(nil, {
	script = script,
	_VERSION = "SLVM"
})
local parts = script:WaitForChild("SL_CodeTextBox").ContentText:split("\n")
local v = ""
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = nil

for i = 1, #parts do
	local v8 = parts[i]:find("etfenv", 1, true)
	local v9 = parts[i]:find("--", 1, true)

	if v8 and (not v9 or v8 < v9) then
		error("@" .. script:GetFullName() .. ":" .. i .. ": Keywords 'setfenv' and 'getfenv' not available in Play mode. (But it could work in your published game.)")
	else
		local v10 = parts[i]:find("require", 1, true)

		if v10 and (not v9 or v10 < v9) then
			error("@" .. script:GetFullName() .. ":" .. i .. ": Keyword 'require' not available in Play mode. (But it could work in your published game.)")
		end
	end

	if parts[i]:match("[%+%-%*/%.]=") then
		local match, v10 = parts[i]:match("(%s*[%d%a%.%[%]_]+%s*)%+=(.*)")

		if match and v10 then
			parts[i] = match .. "=" .. match .. "+" .. v10
		end

		local match2, v11 = parts[i]:match("(%s*[%d%a%.%[%]_]+%s*)%-=(.*)")

		if match2 and v11 then
			parts[i] = match2 .. "=" .. match2 .. "-" .. v11
		end

		local match3, v12 = parts[i]:match("(%s*[%d%a%.%[%]_]+%s*)%*=(.*)")

		if match3 and v12 then
			parts[i] = match3 .. "=" .. match3 .. "*" .. v12
		end

		local match4, v13 = parts[i]:match("(%s*[%d%a%.%[%]_]+%s*)/=(.*)")

		if match4 and v13 then
			parts[i] = match4 .. "=" .. match4 .. "/" .. v13
		end

		local match5, v14 = parts[i]:match("(%s*[%d%a%.%[%]_]+%s*)%.%.=(.*)")

		if match5 and v14 then
			parts[i] = match5 .. "=" .. match5 .. ".." .. v14
		end
	end

	v ..= "\n" .. parts[i]

	if v2 == nil then
		local v10
		v10, v2 = parts[i]:match("^ *(.-)%.PlayerAdded:Connect(.*)")

		if v10 and v10:find("--", 1, true) then
			v10 = nil
			v2 = nil
		end

		if v10 then
			for i2 = i + 1, #parts do
				if #v2 + #parts[i2] > 2000 then
					break
				else
					v2 ..= "\n" .. parts[i2]
				end
			end

			v2 = v2:match("%b()")

			if v2 == nil or v2 == "" then
				error("Can't find closing parenthesis for 'PlayerAdded:Connect('.  In Studio Lite the PlayerAdded inline function can be at most 2000 characters. Suggest using a named function instead of inline function.")
			end
		end
	end

	if v3 ~= nil then
		continue
	end

	local v10
	v10, v3 = parts[i]:match("^ *(.-)%.CharacterAdded:Connect(.*)")

	if v10 and v10:find("--", 1, true) then
		v10 = nil
		v3 = nil
	end

	if not v10 then
		continue
	end

	for i2 = i + 1, #parts do
		if #v3 + #parts[i2] > 2000 then
			break
		else
			v3 ..= "\n" .. parts[i2]
		end
	end

	v3 = v3:match("%b()")

	if v3 == nil or v3 == "" then
		error("Can't find closing parenthesis for 'CharacterAdded:Connect('.  In Studio Lite the CharacterAdded inline function can be at most 2000 characters. Suggest using a named function instead of inline function.")
	end
end

local v8 = v
local success, result = pcall(function()
	if v2 then
		v4, v5 = v2:match("^%(%s*function%s*(%b())(.-)end%)$")

		if v5 then
			if v4 and #v4 > 2 then
				v4 = v4:sub(2, -2)
			else
				v4 = "player"
			end

			if not v3 then
				v8 ..= [[


]] .. "for _," .. v4 .. " in pairs(game.Players:GetPlayers()) do \n" .. v5 .. [[

 end 
]]
				return
			end

			v6, v7 = v3:match("^%(%s*function%s*(%b())(.-)end%)$")

			if not v7 then
				v8 ..= [[


]] .. "for _," .. v4 .. " in pairs(game.Players:GetPlayers()) do \n" .. v5 .. "\n" .. "   local c = " .. v4 .. ".Character or " .. v4 .. ".CharacterAdded:Wait() \n" .. v3:sub(
					2,
					-2
				) .. [[
(c) 
 end 
]]
				return
			end

			if v6 and #v6 > 2 then
				v6 = v6:sub(2, -2)
			else
				v6 = "char"
			end

			v8 ..= [[


]] .. "for _," .. v4 .. " in pairs(game.Players:GetPlayers()) do \n" .. v5 .. "\n" .. "   local " .. v6 .. " = " .. v4 .. ".Character or " .. v4 .. ".CharacterAdded:Wait() \n" .. v7 .. [[

 end 
]]
		elseif v3 then
			v6, v7 = v3:match("^%(%s*function%s*(%b())(.-)end%)$")

			if not v7 then
				v8 ..= [[


]] .. "for _,p in pairs(game.Players:GetPlayers()) do \n" .. v2:sub(2, -2) .. "(p) \n" .. "   local c = p.Character or p.CharacterAdded:Wait() \n" .. v3:sub(
					2,
					-2
				) .. [[
(c) 
 end 
]]
				return
			end

			if v6 and #v6 > 2 then
				v6 = v6:sub(2, -2)
			else
				v6 = "char"
			end

			v8 ..= [[


]] .. "for _,p in pairs(game.Players:GetPlayers()) do \n" .. v2:sub(2, -2) .. "(p) \n" .. "   local " .. v6 .. " = p.Character or p.CharacterAdded:Wait() \n" .. v7 .. [[

 end 
]]
		else
			v8 ..= [[


]] .. "for _,p in pairs(game.Players:GetPlayers()) do \n" .. v2:sub(2, -2) .. [[
(p) 
 end 
]]
		end
	end
end)

if not success then
	warn("Studio Lite is having trouble with the PlayerAdded or CharacterAdded syntax. Check it for missing parenthsis, or try a different syntax.")
	warn(result)
end

wait(0.5)
local compile, v9 = luaVM:Compile(v8)

if compile then
	compile()
else
	error(v9)
end