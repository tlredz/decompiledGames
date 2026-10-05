local DescendantsCountTracker = require(game.ReplicatedStorage.Util.DescendantsCountTracker)
local RunService = game:GetService("RunService")
RunService:IsStudio()

local function fn(...) end

local function WaitForExpectedDescendants(instance, value, p)
	local v = false
	local v2 = math.random(1, 999999999)

	if not instance:GetAttribute("ExpectedDescendants") then
		return true
	end

	fn(v2, instance:GetFullName())
	local descendantsCountTracker = DescendantsCountTracker(instance)
	local expectedDescendantsNames = instance:GetAttribute("ExpectedDescendantsNames")

	if p and not expectedDescendantsNames then
		local total = 0

		while not instance:GetAttribute("ExpectedDescendantsNames") do
			total += task.wait()

			if (value or 3) < total or not instance:GetAttribute("ExpectedDescendants") then
				fn("so much fail")
				break
			else
				fn(instance:GetAttribute("ExpectedDescendants"))
				fn(instance:GetAttribute("ExpectedDescendantsNames"))
			end
		end

		expectedDescendantsNames = instance:GetAttribute("ExpectedDescendantsNames")
	end

	local v4, expectedDescendantsNamesChangedConnection

	if expectedDescendantsNames then
		local HttpService = game:GetService("HttpService")
		local jSONDecode = HttpService:JSONDecode(expectedDescendantsNames)
		v4 = {}
		assert(v4, "bad serverDictionary")

		for _, v5 in pairs(jSONDecode) do
			v4[v5] = true
		end

		fn(v2, instance:GetFullName(), "Server:", v4)
		expectedDescendantsNamesChangedConnection = instance:GetAttributeChangedSignal("ExpectedDescendantsNames"):Connect(function()
			local expectedDescendantsNames2 = instance:GetAttribute("ExpectedDescendantsNames")

			if not (jSONDecode and expectedDescendantsNames2) then
				v4 = nil
				return
			end

			local HttpService2 = game:GetService("HttpService")
			local jSONDecode2 = HttpService2:JSONDecode(expectedDescendantsNames2)
			v4 = {}

			for _, v5 in pairs(jSONDecode2) do
				v4[v5] = true
			end
		end)
	else
		v4 = {}
	end

	local lastTime = os.clock()
	local flag = false

	while true do
		local expectedDescendants = instance:GetAttribute("ExpectedDescendants")

		if not expectedDescendants then
			break
		end

		local count = descendantsCountTracker.count
		local v5 = true

		if v4 then
			for k in pairs(v4) do
				if descendantsCountTracker.dictionary[k] then
					continue
				end

				v5 = false
				break
			end
		end

		if not flag then
			fn(v2, instance:GetFullName(), "Client:", descendantsCountTracker.dictionary)
		end

		if expectedDescendants <= count and v5 then
			v = true
			break
		end

		if value < os.clock() - lastTime or not instance:IsDescendantOf(game) then
			break
		end

		task.wait()
		flag = true
	end

	if flag then
		local Global = require(game.ReplicatedStorage.Global)

		if Global.TestGame and (instance.Name ~= "Tree" or not (os.clock() - lastTime < 0.1)) then
			warn(
				"Took longer than a step to WaitForExpectedDescendants:",
				instance:GetFullName(),
				"~" .. string.format("%.1f", os.clock() - lastTime) .. "s"
			)
		end
	end

	descendantsCountTracker.Destroy()

	if expectedDescendantsNamesChangedConnection then
		expectedDescendantsNamesChangedConnection:Disconnect()
	end

	instance:SetAttribute("ExpectedDescendantsNames", nil)
	instance:SetAttribute("ExpectedDescendants", nil)
	return v
end

return WaitForExpectedDescendants