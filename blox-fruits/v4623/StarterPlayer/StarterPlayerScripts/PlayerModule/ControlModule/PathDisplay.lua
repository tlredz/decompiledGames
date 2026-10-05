local createVector = vector.create
local PathDisplay = {
	spacing = 8,
	image = "rbxasset://textures/Cursors/Gamepad/Pointer.png",
	imageSize = Vector2.new(2, 2)
}
local model = Instance.new("Model")
model.Name = "PathDisplayPoints"
local part = Instance.new("Part")
part.Anchored = true
part.CanCollide = false
part.Transparency = 1
part.Name = "PathDisplayAdornee"
part.CFrame = CFrame.new(0, 0, 0)
part.Parent = model
local v = 30
local v2 = {}
local v3 = {}
local v4 = {}

for i = 1, v do
	local imageHandleAdornment = Instance.new("ImageHandleAdornment")
	imageHandleAdornment.Archivable = false
	imageHandleAdornment.Adornee = part
	imageHandleAdornment.Image = PathDisplay.image
	imageHandleAdornment.Size = PathDisplay.imageSize
	v2[i] = imageHandleAdornment
end

local function retrieveFromPool()
	local v5 = v2[1]

	if not v5 then
		return
	end

	local v6 = v2
	local v7 = v
	v2[1] = v2[v]
	v6[v7] = nil
	v -= 1
	return v5
end

-- equivalent calls inferred from this helper; original call sites unknown
local function returnToPool(p)
	v += 1
	v2[v] = p
end

local function renderPoint(p, _)
	if v == 0 then
		return
	end

	local ray = Ray.new(p + createVector(0, 2, 0), createVector(0, -8, 0))
	local part2, v5, v6 = workspace:FindPartOnRayWithIgnoreList(
		ray,
		{ game.Players.LocalPlayer.Character, workspace.CurrentCamera }
	)

	if not part2 then
		return
	end

	local cframe = CFrame.new(v5, v5 + v6)
	local selected = v2[1]

	if selected then
		local v8 = v2
		local v9 = v
		v2[1] = v2[v]
		v8[v9] = nil
		v -= 1
	else
		selected = nil
	end

	selected.CFrame = cframe
	selected.Parent = model
	return selected
end

function PathDisplay.setCurrentPoints(p)
	if typeof(p) == "table" then
		v3 = p
	else
		v3 = {}
	end
end

function PathDisplay.clearRenderedPath()
	for _, v5 in ipairs(v4) do
		v5.Parent = nil
		returnToPool(v5) -- equivalent call inferred; original call site unknown
	end

	v4 = {}
	model.Parent = nil
end

function PathDisplay.renderPath()
	PathDisplay.clearRenderedPath()

	if not v3 or #v3 == 0 then
		return
	end

	local count = #v3
	local v5 = v3[count]
	v4[1] = renderPoint(v5, true)

	if not v4[1] then
		return
	end

	local v6 = 0

	while true do
		local v7 = v3[count]
		local v8 = v3[count - 1]

		if count < 2 then
			break
		end

		local v9 = v8 - v7
		local magnitude = v9.magnitude

		if magnitude < v6 then
			v6 -= magnitude
			count -= 1
		else
			local v11 = renderPoint(v7 + v9.unit * v6, false)

			if v11 then
				v4[#v4 + 1] = v11
			end

			v6 += PathDisplay.spacing
		end
	end

	model.Parent = workspace.CurrentCamera
end

return PathDisplay