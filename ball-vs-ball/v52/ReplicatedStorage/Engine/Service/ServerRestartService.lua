local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ServerRestartService = {}
local flag = false

local function messageFrom(p)
	if type(p) ~= "table" or type(p.message) ~= "string" then
		return ""
	end

	local match = p.message:gsub("%c", " "):match("^%s*(.-)%s*$")
	local v = utf8.len(match)

	if not v then
		return ""
	end

	if v > 160 then
		match = match:sub(1, utf8.offset(match, 161) - 1)
	end

	return match
end

function ServerRestartService.schedule(p, p2, p3)
	assert(RunService:IsServer(), "ServerRestartService.schedule is server-only")
	assert(typeof(p) == "DateTime", "Expected the official restart DateTime")
	script:SetAttribute("RestartState", HttpService:JSONEncode({
		deadline = p.UnixTimestampMillis / 1000,
		message = messageFrom(p3),
		source = tostring(p2)
	}))
end

function ServerRestartService.getState()
	local restartState = script:GetAttribute("RestartState")

	if type(restartState) ~= "string" then
		return nil
	end

	local success, result = pcall(HttpService.JSONDecode, HttpService, restartState)

	if success and type(result) == "table" and type(result.deadline) == "number" and result.deadline == result.deadline and math.abs(result.deadline) ~= 1e999 then
		return {
			deadline = result.deadline,
			message = type(result.message) ~= "string" and "" or result.message or ""
		}
	end

	return nil
end

function ServerRestartService.onChanged(callback)
	return script:GetAttributeChangedSignal("RestartState"):Connect(function()
		callback(ServerRestartService.getState())
	end)
end

function ServerRestartService.init()
	assert(RunService:IsServer(), "ServerRestartService.init is server-only")

	if flag then
		return
	end

	flag = true
	game.ServerRestartScheduled:Connect(ServerRestartService.schedule)
end

return ServerRestartService