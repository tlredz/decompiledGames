local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HighlightTargets = require(ReplicatedStorage.GameServices:WaitForChild("HighlightTargets"))
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local HatchInteraction = require(script.Parent:WaitForChild("HatchInteraction"))
local highlight = Instance.new("Highlight")
highlight.Name = "ReadyEggHover"
highlight.FillTransparency = 1
highlight.OutlineTransparency = 0
highlight.OutlineColor = Color3.new(1, 1, 1)
highlight.DepthMode = Enum.HighlightDepthMode.Occluded
highlight.Enabled = false
highlight.Parent = workspace
local v = {}
local v2 = nil
local v3 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function Point(input)
	return Vector2.new(input.Position.X, input.Position.Y)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Show(target)
	HighlightTargets.SetAdornee(highlight, target)

	if highlight.Enabled ~= (target ~= nil) then
		highlight.Enabled = target ~= nil
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.Touch then
		v[input] = true

		if v2 then
			v2.Cancelled = true
		end

		local count = 0

		for _ in pairs(v) do
			count += 1
		end

		if gameProcessed or count ~= 1 then
			return
		end

		local v4 = Point(input) -- equivalent call inferred; original call site unknown

		if HatchInteraction.BlockedUI(v4) then
			return
		end

		HatchInteraction.TouchPosition = v4
		v2 = {
			Input = input,
			Start = v4,
			At = os.clock(),
			Egg = HatchInteraction.Target(v4)
		}
	elseif not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 then
		HatchInteraction.Request(HatchInteraction.Target(Point(input)))
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if v2 and v2.Input == input then
		HatchInteraction.TouchPosition = Vector2.new(input.Position.X, input.Position.Y)

		if (Vector2.new(input.Position.X, input.Position.Y) - v2.Start).Magnitude > 16 or HatchInteraction.BlockedUI(Point(input)) then
			v2.Cancelled = true
		end
	end
end)
UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	v[input] = nil

	if not v2 or v2.Input ~= input then
		return
	end

	local v4 = v2
	v2 = nil
	local point = Point(input) -- equivalent call inferred; original call site unknown

	if not gameProcessed and not v4.Cancelled and os.clock() - v4.At <= 0.3 and (point - v4.Start).Magnitude <= 16 and v4.Egg and HatchInteraction.Target(point) == v4.Egg then
		HatchInteraction.Request(v4.Egg)
	end

	HatchInteraction.TouchPosition = nil
	Show(nil) -- equivalent call inferred; original call site unknown
end)
ContextActionService:BindActionAtPriority("DirectEggHatch", function(_, p)
	if p == Enum.UserInputState.Begin then
		local target = HatchInteraction.Target()
		v3 = target ~= nil

		if target then
			HatchInteraction.Request(target)
		end

		return v3 and Enum.ContextActionResult.Sink or Enum.ContextActionResult.Pass
	else
		local v4 = v3

		if p == Enum.UserInputState.End or p == Enum.UserInputState.Cancel then
			v3 = false
		end

		return v4 and Enum.ContextActionResult.Sink or Enum.ContextActionResult.Pass
	end
end, false, Enum.ContextActionPriority.High.Value + 1, Enum.KeyCode.ButtonR2)
local renderSteppedConnection = RunService.RenderStepped:Connect(function()
	if HighlightTargets.IsMuted(highlight) then
		Show(nil) -- equivalent call inferred; original call site unknown
	elseif UserInputService:GetLastInputType() == Enum.UserInputType.Touch and (not v2 or v2.Cancelled) then
		Show(nil) -- equivalent call inferred; original call site unknown
	else
		Show(HatchInteraction.Target()) -- equivalent call inferred; original call site unknown
	end
end)
script.Destroying:Once(function()
	renderSteppedConnection:Disconnect()
	ContextActionService:UnbindAction("DirectEggHatch")
	highlight:Destroy()
end)