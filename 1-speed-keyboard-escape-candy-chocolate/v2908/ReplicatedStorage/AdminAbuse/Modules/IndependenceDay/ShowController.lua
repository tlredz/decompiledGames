local IndependenceDayConfig = require(script.Parent.IndependenceDayConfig)
local ShowController = {}
local thread = nil

local function getSortedBeams(instance)
	local scriptables = instance:FindFirstChild("Scriptables")
	local beams = scriptables and scriptables:FindFirstChild("Beams")

	if not beams then
		warn("[ShowController.getSortedBeams - Scriptables/Beams not found]")
		return {}
	end

	local v = {}

	for _, child in beams:GetChildren() do
		local beam = child:FindFirstChildWhichIsA("Beam", true)

		if beam then
			local order = child:GetAttribute("Order")

			if order == nil then
				warn("[ShowController - missing Order attribute on]", child:GetFullName())
			end

			table.insert(v, {
				beam = beam,
				order = order or 1e999
			})
		else
			warn("[ShowController - no Beam instance found under]", child:GetFullName())
		end
	end

	table.sort(v, function(a, b)
		return a.order < b.order
	end)
	local beams2 = {}

	for _, v2 in v do
		table.insert(beams2, v2.beam)
	end

	return beams2
end

function ShowController.RunSequential(p)
	if not p then
		warn("[ShowController.RunSequential - Missing mapClone arg]")
		return
	end

	ShowController.Stop()
	local sortedBeams = getSortedBeams(p)

	if #sortedBeams == 0 then
		warn("[ShowController.RunSequential - No beams found]")
		return
	end

	for _, sortedBeam in sortedBeams do
		sortedBeam.Enabled = false
	end

	thread = task.spawn(function()
		while true do
			for _, sortedBeam in sortedBeams do
				sortedBeam.Enabled = true
				task.wait(IndependenceDayConfig.BEAM_STEP_INTERVAL)
			end

			task.wait(IndependenceDayConfig.BEAM_HOLD_SEC)

			if IndependenceDayConfig.BEAM_LOOP then
				for i = #sortedBeams, 1, -1 do
					sortedBeams[i].Enabled = false
					task.wait(IndependenceDayConfig.BEAM_STEP_INTERVAL)
				end
			end

			if IndependenceDayConfig.BEAM_LOOP then
				continue
			end

			thread = nil
			break
		end
	end)
end

function ShowController.Stop()
	if thread then
		task.cancel(thread)
		thread = nil
	end
end

return ShowController