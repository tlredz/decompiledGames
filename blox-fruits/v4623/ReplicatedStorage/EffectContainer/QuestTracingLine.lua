local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local billboardGui = script.BillboardGui
local beam = script.Beam
local v = {}

local function Get(p, p2)
	local v2 = v[p]
	return v2 and v2[p2] or nil
end

local function Set(p, p2, p3)
	local v2 = v[p]

	if not v2 then
		v2 = {}
		v[p] = v2
	end

	v2[p2] = p3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Clear(p, p2)
	local v2 = v[p]

	if not v2 then
		return
	end

	v2[p2] = nil

	if next(v2) == nil then
		v[p] = nil
	end
end

local function Destroy(p, p2, state)
	if state.conn then
		state.conn:Disconnect()
		state.conn = nil
	end

	if state.tween then
		state.tween:Cancel()
		state.tween = nil
	end

	if state.beam then
		state.beam:Destroy()
	end

	if state.mark then
		state.mark:Destroy()
	end

	if state.aAtt then
		state.aAtt:Destroy()
	end

	if state.bAtt then
		state.bAtt:Destroy()
	end

	Clear(p, p2) -- equivalent call inferred; original call site unknown
end

local function createTrace(parent, parent2)
	local attachment = Instance.new("Attachment", parent)
	local attachment2 = Instance.new("Attachment", parent2)
	local clone = beam:Clone()
	clone.Attachment0 = attachment2
	clone.Attachment1 = attachment
	clone.Parent = parent
	local clone2 = billboardGui:Clone()
	clone2.Parent = attachment2
	clone2.Enabled = true
	local v2 = {
		aAtt = attachment,
		bAtt = attachment2,
		beam = clone,
		mark = clone2,
		shrunk = false,
		origSize = clone2.Size,
		accum = 0,
		conn = nil,
		tween = nil
	}

	local function tweenTo(udim: UDim2)
		if v2.tween then
			v2.tween:Cancel()
		end

		v2.tween = TweenService:Create(v2.mark, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = udim
		})
		v2.tween:Play()
	end

	v2.conn = RunService.RenderStepped:Connect(function(dt)
		if not (parent.Parent and parent2.Parent and v2.mark.Parent) then
			Destroy(parent, parent2, v2)
			return
		end

		v2.accum += dt

		if v2.accum < 0.1 then
			return
		end

		v2.accum = 0
		local magnitude = (parent.Position - parent2.Position).Magnitude

		if v2.shrunk or not (magnitude <= 12) then
			if v2.shrunk and magnitude > 12 then
				v2.shrunk = false
				tweenTo(v2.origSize)
			end
		else
			v2.shrunk = true
			tweenTo(UDim2.fromScale(0, 0))
		end
	end)
	return v2
end

return function(list)
	local parent = list[1]
	local v3 = list[2]
	local v4 = list[3]
	local v5 = v[parent]
	local v6

	if v5 then
		v6 = v5[v3] or nil
	end

	if v4 == 1 then
		if v6 then
			return
		end

		local trace = createTrace(parent, v3)
		local traces = v[parent]

		if not traces then
			traces = {}
			v[parent] = traces
		end

		traces[v3] = trace
	elseif v4 == 2 then
		if not v6 then
			return
		end

		Destroy(parent, v3, v6)
	end
end