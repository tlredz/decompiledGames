local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gameServices = ReplicatedStorage:WaitForChild("GameServices")
local Confirmation = require(gameServices:WaitForChild("Confirmation"))
local confirmRequest = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("ConfirmRequest")
assert(confirmRequest:IsA("RemoteEvent"), "Remotes.Game.ConfirmRequest must be a RemoteEvent")
local v = nil
local v2 = false

local function SanitizeOptions(data)
	local v3 = {}

	if type(data) ~= "table" then
		return v3
	end

	local title = data.Title
	local yesText = data.YesText
	local noText = data.NoText
	local timeout = data.Timeout

	if type(title) == "string" then
		v3.Title = title
	end

	if type(yesText) == "string" then
		v3.YesText = yesText
	end

	if type(noText) == "string" then
		v3.NoText = noText
	end

	if type(timeout) == "number" and timeout > 0 and timeout == timeout then
		v3.Timeout = timeout
	end

	return v3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function OnCancelSignal(value: string)
	if value ~= v then
		return
	end

	v2 = true
	Confirmation.Cancel()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function OnRequest(value: string, value2: string, p)
	local sanitizeOptions = SanitizeOptions(p)
	task.spawn(function()
		v = value
		v2 = false
		local ask, v4 = Confirmation.Ask(value2, sanitizeOptions)
		local v5 = v == value
		local v6 = v5 and v2

		if v5 then
			v = nil
			v2 = false
		end

		if not v6 then
			confirmRequest:FireServer(value, ask, v4)
		end
	end)
end

confirmRequest.OnClientEvent:Connect(function(value, value2, p)
	if type(value) ~= "string" then
		return
	end

	if value2 == nil then
		OnCancelSignal(value) -- equivalent call inferred; original call site unknown
	else
		if type(value2) ~= "string" then
			return
		end

		OnRequest(value, value2, p) -- equivalent call inferred; original call site unknown
	end
end)