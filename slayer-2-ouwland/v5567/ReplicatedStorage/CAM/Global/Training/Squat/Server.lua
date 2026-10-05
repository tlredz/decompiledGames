local Squat = {}

function Squat.Do(p, parent, state, _, p2)
	local parent2 = p2.Parent.Parent
	local humanoidRootPart = parent.HumanoidRootPart
	state.Rack = parent2
	state.W = Instance.new("Weld")
	state.W.Part0 = humanoidRootPart
	state.W.Part1 = parent2.Root
	state.W.Parent = parent2.Root
	state.Barbell = parent2.Rack.Barbell
	state.Barbell.Parent = game.Lighting
	state.ActualBarbell = script.Barbell:Clone()
	state.ActualBarbell.Parent = parent
	state.ActualBarbell.Weld.Part0 = parent:FindFirstChild("UpperTorso")
	local child = game.ReplicatedStorage.Player_Service.Values:FindFirstChild(p.Name)

	if not child then
		return true, true
	end

	local toolDisabled = child:FindFirstChild("tooldisabled")

	if toolDisabled == nil then
		toolDisabled = Instance.new("StringValue")
		toolDisabled.Name = "tooldisabled"
		toolDisabled.Parent = child
	end

	toolDisabled.Value = "all"
	state.ToolDisabled = toolDisabled
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "iframe"
	boolValue.Parent = child
	state.IFrame = boolValue
	return true, true
end

function Squat.Destroying(_, _, state, _)
	if state.Barbell then
		state.Barbell.Parent = state.Rack.Rack
	end

	if state.W ~= nil then
		state.W:Destroy()
		state.W = nil
	end

	if state.ActualBarbell then
		state.ActualBarbell:Destroy()
		state.ActualBarbell = nil
	end

	if state.ToolDisabled and state.ToolDisabled.Parent ~= nil then
		state.ToolDisabled:Destroy()
	end

	if state.IFrame and state.IFrame.Parent ~= nil then
		state.IFrame:Destroy()
	end
end

function Squat.Stop(_, _, _, ...)
	return true
end

return Squat