local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local UIQuality = {}
local v = false

local function fn() end

local v2 = false
local success, result = pcall(function()
	return UserSettings():GetService("UserGameSettings")
end)

if success and result then
	local function read()
		local success2, result2 = pcall(function()
			return result.SavedQualityLevel
		end)

		if success2 then
			if result2 == Enum.SavedQualitySetting.Automatic then
				success2 = false
			else
				success2 = result2.Value <= 3
			end
		end

		v2 = success2
		fn()
	end

	local success2, result2 = pcall(function()
		return result.SavedQualityLevel
	end)

	if success2 then
		if result2 == Enum.SavedQualitySetting.Automatic then
			success2 = false
		else
			success2 = result2.Value <= 3
		end
	end

	v2 = success2
	fn()
	pcall(function()
		result:GetPropertyChangedSignal("SavedQualityLevel"):Connect(read)
	end)
end

local function lowGraphics()
	return v2
end

local v3 = UserInputService.TouchEnabled and not (UserInputService.KeyboardEnabled or UserInputService.MouseEnabled)
task.spawn(function()
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end

	task.wait(3)
	local dts = table.create(60)
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		dts[#dts + 1] = dt

		if #dts >= 60 then
			heartbeatConnection:Disconnect()
			table.sort(dts)
			v = dts[30] > 0.02
			fn()
		end
	end)
end)

function UIQuality.low()
	local forceLow = script:GetAttribute("ForceLow")

	if forceLow == nil then
		return v3 or v or v2
	end

	return forceLow == true
end

local v4 = {}

function UIQuality.onChanged(p)
	table.insert(v4, p)
	return function()
		local index = table.find(v4, p)

		if index then
			table.remove(v4, index)
		end
	end
end

local low = UIQuality.low()

fn = function()
	local low2 = UIQuality.low()

	if low2 == low then
		return
	end

	low = low2

	for _, callback in ipairs(table.clone(v4)) do
		task.spawn(callback, low2)
	end
end

script:GetAttributeChangedSignal("ForceLow"):Connect(function()
	fn()
end)

function UIQuality.reason()
	return ("touchOnly=%s slowFrames=%s lowGraphics=%s forced=%s"):format(
		tostring(v3),
		tostring(v),
		tostring(v2),
		(tostring(script:GetAttribute("ForceLow")))
	)
end

return UIQuality