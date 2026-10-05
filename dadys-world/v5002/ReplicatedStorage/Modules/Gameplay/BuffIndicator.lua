local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebuffConfig = require(ReplicatedStorage.Modules.Gameplay.DebuffConfig)
local BuffIndicator = {}
local v = {}

function BuffIndicator.raise(parent, name, value)
	if not (parent and parent.Parent) then
		return nil
	end

	if not (DebuffConfig.Get(name) or v[name]) then
		v[name] = true
		warn("[BuffIndicator] no DebuffConfig entry for", name, "- the HUD will not show it")
	end

	if not DebuffConfig.Stacks(name) then
		BuffIndicator.clear(parent, name)
	end

	local stringValue = Instance.new("StringValue")
	stringValue.Name = name
	local stringValue2 = Instance.new("StringValue")
	stringValue2.Name = "DebuffType"
	stringValue2.Value = name
	stringValue2.Parent = stringValue
	local intValue = Instance.new("IntValue")
	intValue.Name = "DebuffStrength"
	intValue.Value = 1
	intValue.Parent = stringValue
	local intValue2 = Instance.new("IntValue")
	intValue2.Name = "Duration"
	intValue2.Value = 99999
	intValue2.Parent = stringValue
	local v2

	if type(value) == "number" then
		v2 = value > 0
	else
		v2 = false
	end

	if v2 then
		local serverTimeNow = workspace:GetServerTimeNow()
		stringValue:SetAttribute("StartedAt", serverTimeNow)
		stringValue:SetAttribute("ExpiresAt", serverTimeNow + value)
		Debris:AddItem(stringValue, value)
	end

	stringValue.Parent = parent
	return stringValue
end

function BuffIndicator.clear(instance, p)
	if not instance then
		return
	end

	for _, stringValue in ipairs(instance:GetChildren()) do
		if stringValue.Name == p and stringValue:IsA("StringValue") then
			stringValue:Destroy()
		end
	end
end

function BuffIndicator.tellPlayer(player, value)
	if not player or not player.Parent or type(value) ~= "string" or value == "" then
		return
	end

	local events = ReplicatedStorage:FindFirstChild("Events")
	local textEvent = events and events:FindFirstChild("TextEvent")

	if textEvent then
		textEvent:FireClient(player, value)
	end
end

function BuffIndicator.tell(character, p)
	BuffIndicator.tellPlayer(character and Players:GetPlayerFromCharacter(character), p)
end

function BuffIndicator.seconds(p)
	if p == 1 then
		return "1 second"
	end

	if p == math.floor(p) then
		return string.format("%d seconds", p)
	end

	return string.format("%.1f seconds", p)
end

return BuffIndicator