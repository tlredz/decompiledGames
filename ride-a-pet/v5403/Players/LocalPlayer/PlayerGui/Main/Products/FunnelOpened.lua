local parent = script.Parent
local funnelStep = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("FunnelStep")
local v = false

-- equivalent calls inferred from this helper; original call sites unknown
local function Check()
	if parent.Visible and not v then
		v = true
		funnelStep:FireServer("ProductShop", "Opened")
	end
end

parent:GetPropertyChangedSignal("Visible"):Connect(Check)
Check() -- equivalent call inferred; original call site unknown