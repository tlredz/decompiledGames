local total = 0
local total2 = 0
local total3 = 0
local total4 = 0
local total5 = 0
local total6 = 0
local identity = CFrame.identity
local v = false
local v2 = nil
local Apply = {
	accumulate = function(p, p2, p3, p4, p5, p6)
		total += p
		total2 += p2
		total3 += p3
		total4 += p4
		total5 += p5
		total6 += p6
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function clearState()
	total = 0
	total2 = 0
	total3 = 0
	total4 = 0
	total5 = 0
	total6 = 0
	identity = CFrame.identity
	v = false
	v2 = nil
end

function Apply.applyFrame()
	local v3 = total ~= 0 or total2 ~= 0 or total3 ~= 0 or total4 ~= 0 or total5 ~= 0 or total6 ~= 0

	if not (v or v3) then
		return
	end

	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		if v2 and v2 ~= currentCamera then
			if v and v2.Parent then
				pcall(function()
					v2.CFrame *= identity:Inverse()
				end)
			end

			identity = CFrame.identity
			v = false
		end

		local v4 = CFrame.new(total, total2, total3) * CFrame.fromOrientation(total4, total5, total6)
		currentCamera.CFrame = currentCamera.CFrame * identity:Inverse() * v4
		identity = v4
		v = v3
		v2 = currentCamera
		total = 0
		total2 = 0
		total3 = 0
		total4 = 0
		total5 = 0
		total6 = 0
	else
		clearState() -- equivalent call inferred; original call site unknown
	end
end

function Apply.reset()
	if v and v2 and v2.Parent then
		pcall(function()
			v2.CFrame *= identity:Inverse()
		end)
	end

	clearState() -- equivalent call inferred; original call site unknown
end

return Apply