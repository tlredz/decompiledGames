-- equivalent calls inferred from this helper; original call sites unknown
local function handle(instance)
	if not script.Parent.Mic:FindFirstChild("Head") then
		return
	end

	local wire = instance:WaitForChild("Wire")
	wire.SourceInstance = script.Parent.Audio.AudioReverb
end

script.Parent.ChildAdded:Connect(handle)
script.Parent.Mic.ChildAdded:Connect(function(child)
	if child.Name ~= "Head" then
		return
	end

	if script.Parent:FindFirstChild("Speaker1") then
		handle(script.Parent.Speaker1) -- equivalent call inferred; original call site unknown
	end

	if script.Parent:FindFirstChild("Speaker2") then
		handle(script.Parent.Speaker2) -- equivalent call inferred; original call site unknown
	end

	script.Parent.Audio.Wire.SourceInstance = child:WaitForChild("AudioListener", 1)
end)
handle(script.Parent.Speaker1) -- equivalent call inferred; original call site unknown
handle(script.Parent.Speaker2) -- equivalent call inferred; original call site unknown