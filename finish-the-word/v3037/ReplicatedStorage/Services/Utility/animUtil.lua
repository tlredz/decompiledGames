local import = _G.import("mathUtil")
local RunService = game:GetService("RunService")
local AnimUtil = {
	animate = function(p, callback)
		local total = 0

		while total < p do
			total += task.wait(0)
			callback(total / p)
		end

		callback(1)
	end
}

local function run(p, callback, p2, callback2, p3)
	local v = p2 or function(p4)
		return p4
	end
	local v2 = p3 or function()
		return false
	end
	local total = 0
	local connection = nil
	connection = RunService[p]:Connect(function(p4)
		total += p4
		local v3 = v(total)

		if v2(v3) then
			connection:Disconnect()
		else
			callback(callback2(v3), p4, v3)
		end
	end)
	return {
		disconnect = function()
			connection:Disconnect()
			return (math.min(1, callback2(v(total))))
		end
	}
end

local function runAnim(p, p2, p3)
	return (run(p, p3, nil, function(p4)
		return p4 / p2
	end, function(p4)
		return p2 <= p4
	end))
end

function AnimUtil.animHeart(p, p2)
	return (run("Heartbeat", p2, nil, function(p3)
		return p3 / p
	end, function(p3)
		return p <= p3
	end))
end

function AnimUtil.animRender(p, p2)
	return (run("RenderStepped", p2, nil, function(p3)
		return p3 / p
	end, function(p3)
		return p <= p3
	end))
end

function AnimUtil.heart(p, p2, p3, _)
	return (run("Heartbeat", p, p2, p3))
end

function AnimUtil.periodic(p, p2)
	return AnimUtil.heart(p2, function(p3)
		return import.linearPeriodic(p3, 1, p)
	end, function(p3)
		return p3
	end)
end

function AnimUtil:tween(p2, p3, p4)
	local v = self[p2]
	local v2 = import.subNumberSequence(p4, v)
	local total = 0

	while total <= p3 do
		total += task.wait()
		self[p2] = import.addNumberSequence(v, import.mulNumberSequence(v2, total / p3))
	end

	self[p2] = p4
end

function AnimUtil.fadeBeam(p, p2)
	local operateNumberSequence = import.operateNumberSequence(p.Transparency, p.Transparency, function()
		return 1
	end)
	AnimUtil.tween(p, "Transparency", p2, operateNumberSequence)
end

return AnimUtil