local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local EclipseTransformation = require(ReplicatedStorage.CharacterModules.EclipseTransformation)
local Eclipse = {}

function Eclipse.Initialize(p, p2)
	print("Eclipse Passive: Initializing Total Eclipse for", p2.Name)
	local info = Workspace:FindFirstChild("Info")

	if not info then
		warn("Eclipse Passive: Info folder not found in workspace")
		return function()
			EclipseTransformation.Cleanup(p)
		end
	end

	local v = {}
	local blackOut = info:FindFirstChild("BlackOut")

	if not blackOut then
		warn("Eclipse Passive: BlackOut value not found in Info")
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function moonUp()
		return blackOut ~= nil and blackOut.Value == true or info:GetAttribute("FullMoon") == true
	end

	local thread = nil

	if moonUp() then
		print("Eclipse Passive: Character spawned during blackout or full moon, applying transformation")
		thread = task.delay(0.1, function()
			thread = nil
			EclipseTransformation.SetBlackout(p, moonUp())
		end)
	end

	local function onMoonChanged()
		local v2 = moonUp() -- equivalent call inferred; original call site unknown
		print("Eclipse Passive: moon " .. (v2 and "up, transforming into werewolf" or "down, reverting to human form"))
		EclipseTransformation.SetBlackout(p, v2)
	end

	if blackOut then
		v.blackoutConnection = blackOut.Changed:Connect(onMoonChanged)
	end

	v.fullMoonConnection = info:GetAttributeChangedSignal("FullMoon"):Connect(onMoonChanged)
	return function()
		print("Eclipse Passive: Cleaning up for", p2.Name)

		if thread then
			task.cancel(thread)
			thread = nil
		end

		for _, connection in pairs(v) do
			if connection then
				connection:Disconnect()
			end
		end

		EclipseTransformation.Cleanup(p)
	end
end

function Eclipse.Activate(_, _, _) end

function Eclipse.Deactivate(_, _) end

function Eclipse.Cleanup(p, p2)
	print("Eclipse Passive: Additional cleanup for", p2.Name)
	EclipseTransformation.Cleanup(p)
end

return Eclipse