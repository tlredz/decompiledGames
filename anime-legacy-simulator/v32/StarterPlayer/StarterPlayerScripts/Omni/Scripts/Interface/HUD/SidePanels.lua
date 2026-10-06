local v = {}
local v2 = nil
local v3 = nil
local flag = false
local SidePanels = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function RefreshArrows()
	local v4 = v2 or v3

	for k, v5 in v do
		v5.Arrow.Visible = v4 == nil or v4 == k
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Process()
	if flag then
		return
	end

	flag = true
	task.defer(function()
		while v2 ~= v3 do
			if v2 then
				local v4 = v2
				local v5 = v[v4]

				if v5 then
					v5.Close()
				end

				if v2 == v4 then
					v2 = nil
				end
			else
				local v4 = v3
				local v5 = v[v4]

				if v5 and v5.CanOpen() then
					v2 = v4
					v5.Open()
				else
					v3 = nil
				end
			end

			RefreshArrows() -- equivalent call inferred; original call site unknown
		end

		flag = false
	end)
end

function SidePanels.Register(p: string, p2)
	v[p] = p2
	RefreshArrows() -- equivalent call inferred; original call site unknown
end

function SidePanels.Open(p: string)
	local v4 = v[p]

	if not (v4 and v4.CanOpen()) then
		return
	end

	v3 = p
	RefreshArrows() -- equivalent call inferred; original call site unknown
	Process() -- equivalent call inferred; original call site unknown
end

function SidePanels.Close(p: string)
	if v3 ~= p then
		return
	end

	v3 = nil
	RefreshArrows() -- equivalent call inferred; original call site unknown
	Process() -- equivalent call inferred; original call site unknown
end

function SidePanels.Toggle(p: string)
	if v3 == p then
		SidePanels.Close(p)
	else
		SidePanels.Open(p)
	end
end

function SidePanels.Unregister(p: string)
	v[p] = nil

	if v3 == p then
		v3 = nil
	end

	if v2 == p then
		v2 = nil
	end

	RefreshArrows() -- equivalent call inferred; original call site unknown
	Process() -- equivalent call inferred; original call site unknown
end

return SidePanels