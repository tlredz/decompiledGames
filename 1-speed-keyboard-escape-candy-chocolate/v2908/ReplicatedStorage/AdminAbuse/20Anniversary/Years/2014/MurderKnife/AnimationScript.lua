local function WaitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do
		parent.ChildAdded:wait()
	end

	return parent[childName]
end

local parent = script.Parent
local track = nil
local track2 = nil
local track3 = nil
local track4 = nil
local humanoid = nil
local v = {}

local function PlayAnimation(track5, p, p2)
	if p and p.Value and humanoid then
		track5:Play()

		if v[track5] then
			v[track5] += 1
		end

		if p2 then
			wait(p2)

			if v[track5] then
				v[track5] -= 1

				if v[track5] == 0 then
					track5:Stop()
				end
			end
		end
	end
end

function OnEquipped()
	humanoid = parent.Parent:FindFirstChild("Humanoid")
	track = humanoid:LoadAnimation((WaitForChild(parent, "DownStab")))
	v[track] = 0
	track2 = humanoid:LoadAnimation((WaitForChild(parent, "StabPunch")))
	v[track2] = 0
	track3 = humanoid:LoadAnimation((WaitForChild(parent, "Throw")))
	v[track3] = 0
	track4 = humanoid:LoadAnimation((WaitForChild(parent, "ThrowCharge")))
	v[track4] = 0
	local waitForChild = WaitForChild(parent, "PlayStabPunch")
	local waitForChild2 = WaitForChild(parent, "PlayDownStab")
	local waitForChild3 = WaitForChild(parent, "PlayThrow")
	local waitForChild4 = WaitForChild(parent, "PlayThrowCharge")
	waitForChild.Changed:connect(function()
		PlayAnimation(track2, waitForChild, 1)
	end)
	waitForChild2.Changed:connect(function()
		PlayAnimation(track, waitForChild2, 1)
	end)
	waitForChild3.Changed:connect(function()
		PlayAnimation(track3, waitForChild3, 1.5)
	end)
	waitForChild4.Changed:connect(function(p)
		if p then
			PlayAnimation(track4, waitForChild4, 1)
		else
			track4:Stop()
		end
	end)
end

function OnUnequipped()
	if track then
		track:Stop()
		track = nil
	end

	if track2 then
		track2:Stop()
		track2 = nil
	end

	if track3 then
		track3:Stop()
		track3 = nil
	end

	if track4 then
		track4:Stop()
		track4 = nil
	end

	v = {}
end

parent.Equipped:connect(OnEquipped)
parent.Unequipped:connect(OnUnequipped)