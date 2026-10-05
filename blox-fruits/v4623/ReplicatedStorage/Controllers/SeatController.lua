local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local TableAttribute = require(game.ReplicatedStorage.Modules.Util.TableAttribute)
local localPlayer = game.Players.LocalPlayer
local maid = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyTrove()
	if maid then
		maid:Destroy()
		maid = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function lockTool(tool)
	if tool:IsA("Tool") then
		TableAttribute:SetKey(tool, "Locks", "SeatLock", true)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function charAdded(character)
	character:WaitForChild("Humanoid").Seated:Connect(function(p, p2)
		if p and p2 then
			destroyTrove() -- equivalent call inferred; original call site unknown
			maid = Trove.new()

			for _, child in localPlayer.Backpack:GetChildren() do
				lockTool(child) -- equivalent call inferred; original call site unknown
			end

			assert(maid, "bad trove")
			maid:Add(localPlayer.Backpack.ChildAdded:Connect(lockTool))
			maid:Add(function()
				for _, tool in localPlayer.Backpack:GetChildren() do
					if tool:IsA("Tool") then
						TableAttribute:SetKey(tool, "Locks", "SeatLock", nil)
					end
				end
			end)
		else
			destroyTrove() -- equivalent call inferred; original call site unknown
		end
	end)
end

return {
	OnStart = function(_)
		if localPlayer.Character then
			charAdded(localPlayer.Character) -- equivalent call inferred; original call site unknown
		end

		localPlayer.CharacterAdded:Connect(charAdded)
	end
}