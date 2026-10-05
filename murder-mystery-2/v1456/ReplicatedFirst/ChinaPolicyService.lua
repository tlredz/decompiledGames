local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local bindableEvent = Instance.new("BindableEvent")
local bindableEvent2 = Instance.new("BindableEvent")
local value = false
local v = true
local v2 = false
local flag = false
local ChinaPolicyService = {}

for _, boolValue in pairs(script:GetChildren()) do
	if not boolValue:IsA("BoolValue") then
		continue
	end

	if boolValue.Name == "Forced" then
		value = boolValue.Value
	elseif boolValue.Name == "DisableGroupCheck" then
		v = not boolValue.Value
	end
end

local function retry(p, fn)
	for i = 1, p do
		local success, result = pcall(fn)

		if success then
			return result
		else
			wait(i / 2)
		end
	end
end

local v3 = {}
local v4 = {}

local function getPolicyActive(object)
	if v3[object] ~= nil then
		return v3[object], v4[object]
	end

	local v5

	if value then
		v5 = true
	else
		local v6 = retry(3, function()
			return PolicyService:GetPolicyInfoForPlayerAsync(object).IsSubjectToChinaPolicies
		end)
		v5 = v and not v6 and object.UserId > 0 and retry(3, function()
			return object:IsInGroup(9170755)
		end) and true or v6
	end

	if object.Parent ~= Players then
		return v3[object], v4[object]
	end

	if v5 == nil then
		v3[object] = false
	else
		v3[object] = v5
	end

	v4[object] = v5 == nil
	return v3[object], v4[object]
end

Players.PlayerRemoving:Connect(function(player)
	v3[player] = nil
	v4[player] = nil
end)
local v5

if RunService:IsServer() then
	v5 = value

	if v5 then
		flag = true
	else
		local playerAddedConnection = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function onPlayerAdded(p)
			if not playerAddedConnection then
				return
			end

			playerAddedConnection:Disconnect()
			playerAddedConnection = nil
			v5, v2 = getPolicyActive(p)
			flag = true

			if v5 then
				bindableEvent:Fire(v5, v2)
			end

			bindableEvent2:Fire(v5, v2)
		end

		playerAddedConnection = Players.PlayerAdded:Connect(onPlayerAdded)

		if #Players:GetPlayers() > 0 then
			onPlayerAdded(Players:GetPlayers()[1]) -- equivalent call inferred; original call site unknown
		end
	end
else
	v5, v2 = getPolicyActive(Players.LocalPlayer)
	flag = true
end

function ChinaPolicyService.IsActive(_)
	return v5, v2
end

function ChinaPolicyService.IsReady(_)
	return flag
end

function ChinaPolicyService.WaitForReady(_)
	if flag then
		return v5, v2
	end

	return bindableEvent2.Event:Wait()
end

ChinaPolicyService.Changed = bindableEvent.Event

function ChinaPolicyService.IsActiveForPlayer(_, player)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		error("bad argument #1 to 'IsActiveForPlayer' (Player expected, got " .. typeof(player) .. ")", 2)
	end

	return getPolicyActive(player)
end

return ChinaPolicyService