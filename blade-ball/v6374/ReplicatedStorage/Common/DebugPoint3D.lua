game:GetService("RunService")
local point = script.Point
local clonesByText = {}
local DebugPoint3D = {
	HasStarted = false
}

local function startLoop() end

function DebugPoint3D.point(text: string, cframe, value: number?)
	if not DebugPoint3D.HasStarted then
		DebugPoint3D.HasStarted = true
	end

	local clone = clonesByText[text]

	if typeof(cframe) == "Vector3" then
		cframe = CFrame.new(cframe)
	end

	if not clone then
		clone = point:Clone()
		clone.Parent = workspace
		clone.Name = `DEBUGPOINT_{text}`
		clone.Parent = workspace.Debug
		local frame = clone.Gui.Frame
		frame.Circle.BackgroundColor3 = Color3.fromHSV(math.random(), 0.5, 1)
		frame.Label.Text = text
		clonesByText[text] = clone
	end

	clone.Gui.MaxDistance = value or 50
	clone:PivotTo(cframe)
end

return DebugPoint3D