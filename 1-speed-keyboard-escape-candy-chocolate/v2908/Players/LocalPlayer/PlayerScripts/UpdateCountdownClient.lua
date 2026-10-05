local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local updateCountdownData = ReplicatedStorage:WaitForChild("UpdateCountdownData", 15)

if not updateCountdownData then
	warn("[UpdateCountdownClient] UpdateCountdownData introuvable")
	return
end

local value = updateCountdownData:WaitForChild("AA_Time").Value
local value2 = updateCountdownData:WaitForChild("Update_Time").Value
local value3 = updateCountdownData:WaitForChild("ShowThreshold").Value
local value4 = updateCountdownData:WaitForChild("ShowAA").Value
local value5 = updateCountdownData:WaitForChild("ShowUpdate").Value

if value == 0 and value2 == 0 then
	return
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatTime(p)
	if p <= 0 then
		return "00:00:00"
	end

	local v = math.floor(p / 3600)
	local v2 = math.floor(p % 3600 / 60)
	local v3 = p % 60
	return string.format("%02d:%02d:%02d", v, v2, v3)
end

local function updateTagAA(tag)
	local v = value - os.time()

	for _, label in ipairs(CollectionService:GetTagged(tag)) do
		if not label:IsA("TextLabel") then
			continue
		end

		if v > 0 and v <= value3 then
			local v3 = formatTime(v) -- equivalent call inferred; original call site unknown
			label.Text = "ADMIN ABUSE : " .. v3
		else
			label.Text = ""
		end
	end
end

local function updateTagUp(tag)
	local now = os.time()
	local v = value2 - now
	local v2

	if value4 then
		if value <= now then
			v2 = v > 0
		else
			v2 = false
		end
	elseif v > 0 then
		v2 = v <= value3
	else
		v2 = false
	end

	for _, label in ipairs(CollectionService:GetTagged(tag)) do
		if not label:IsA("TextLabel") then
			continue
		end

		if v2 then
			local v4 = formatTime(v) -- equivalent call inferred; original call site unknown
			label.Text = "UPDATE : " .. v4
		elseif not CollectionService:HasTag(label, "MysteryCountdownAAClient") then
			label.Text = ""
		end
	end
end

CollectionService:GetInstanceAddedSignal("MysteryCountdownAAClient"):Connect(function(label)
	if label:IsA("TextLabel") then
		local v = value - os.time()

		if v > 0 and v <= value3 then
			local v3 = formatTime(v) -- equivalent call inferred; original call site unknown
			label.Text = "ADMIN ABUSE : " .. v3
		else
			label.Text = ""
		end
	end
end)
CollectionService:GetInstanceAddedSignal("MysteryCountdownUpClient"):Connect(function(label)
	if label:IsA("TextLabel") then
		local now = os.time()
		local v = value2 - now
		local v2

		if value4 then
			if value <= now then
				v2 = v > 0
			else
				v2 = false
			end
		elseif v > 0 then
			v2 = v <= value3
		else
			v2 = false
		end

		if v2 then
			local v4 = formatTime(v) -- equivalent call inferred; original call site unknown
			label.Text = "UPDATE : " .. v4
		else
			label.Text = ""
		end
	end
end)
local v = math.max(value, value2)

while true do
	if value4 then
		updateTagAA("MysteryCountdownAAClient")
	end

	if value5 then
		updateTagUp("MysteryCountdownUpClient")
	end

	if v <= os.time() then
		if value4 then
			updateTagAA("MysteryCountdownAAClient")
		end

		if not value5 then
			break
		end

		updateTagUp("MysteryCountdownUpClient")
		break
	else
		task.wait(1)
	end
end