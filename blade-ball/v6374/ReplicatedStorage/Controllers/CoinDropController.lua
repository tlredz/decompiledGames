local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local TweenService = game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Packages.Observers)
local v3 = require3(ReplicatedStorage2.Packages.Trove)
local v4 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function shouldShowDrops()
	return not (v4:Get("TotalStats.Wins") < 1)
end

return {
	Start = function(_)
		v4 = v.Client:WaitReplion("Data")

		if not v4 then
			return
		end

		v2.observeTag("ActiveCoinDrops", function(folder)
			local maid = v3.new()
			maid:Add(TweenService:Create(
				folder,
				TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{
					Position = folder.Position + createVector(0, 0.5, 0)
				}
			)):Play()

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateVisibility(descendant)
				if descendant:IsA("BillboardGui") or descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
					descendant.Enabled = shouldShowDrops()
				end
			end

			for _, descendant in folder:GetDescendants() do
				updateVisibility(descendant) -- equivalent call inferred; original call site unknown
			end

			maid:Add(folder.DescendantAdded:Connect(updateVisibility))
			return function()
				maid:Destroy()
			end
		end, { workspace })
	end
}