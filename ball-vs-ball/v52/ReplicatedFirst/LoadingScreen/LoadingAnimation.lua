local RunService = game:GetService("RunService")
local LoadingAnimation = {}
local v = nil
local v2 = nil
local v3 = nil
local v4 = 0
local total = 0
local v5 = 0
local heartbeatConnection = nil
local v6 = false

local function updateProgressBar(value)
	local v7 = math.clamp(value, 0, 1)

	if v7 <= 0 then
		v3.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 1) })
	elseif v7 >= 1 then
		v3.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0) })
	else
		v3.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(v7, 0),
			NumberSequenceKeypoint.new(math.min(v7 + 0.001, 1), 1),
			NumberSequenceKeypoint.new(1, 1)
		})
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateProgressText(value)
	local v7 = math.floor(math.clamp(value, 0, 1) * 100 + 0.5)
	v2.Text = v7 .. "%"
end

local v7 = "Loading"
local v8 = 0
local v9 = 1

function LoadingAnimation.stop()
	v6 = false

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	v = nil
	v2 = nil
	v3 = nil
end

function LoadingAnimation.setStage(p)
	v7 = not p and "Loading" or "Loading " .. p

	if v then
		v.Text = v7 .. string.rep(".", v9)
	end
end

function LoadingAnimation.start(p, p2, p3)
	LoadingAnimation.stop()
	v = p
	v2 = p2
	v3 = p3
	v4 = 0
	total = 0
	v5 = 0
	v8 = 0
	v9 = 1
	v6 = true
	LoadingAnimation.setStage(nil)
	v3.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 1) })
	v2.Text = 0 .. "%"
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		local v10 = v4 - total
		total += math.sign(v10) * math.min(0.3333333333333333 * dt, (math.abs(v10)))
		updateProgressBar(total)
		updateProgressText(total) -- equivalent call inferred; original call site unknown
		v8 += dt

		if v8 >= 0.4 then
			v9 = (v9 - 1 + math.floor(v8 / 0.4)) % 3 + 1
			v8 %= 0.4
			v.Text = v7 .. string.rep(".", v9)
		end
	end)
end

function LoadingAnimation.update(p, p2)
	if not v6 then
		return
	end

	v5 = p2
	v4 = not (p2 > 0) and 1 or math.clamp(p / p2, 0, 1)
end

function LoadingAnimation.completeImmediately()
	if not v6 then
		return
	end

	v4 = 1
	total = 1
	v3.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0) })
	v2.Text = 100 .. "%"
	v.Text = v7 .. "..."
	LoadingAnimation.stop()
end

function LoadingAnimation.finish()
	while v6 and total < 0.999 do
		task.wait()
	end

	LoadingAnimation.completeImmediately()
end

return LoadingAnimation