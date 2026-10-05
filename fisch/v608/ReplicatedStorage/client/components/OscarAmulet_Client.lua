local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local legacyLocalPlayerData = require(game.ReplicatedStorage.client.modules.legacyLocalPlayerData)
local cache = legacyLocalPlayerData.fetch():WaitForChild("Cache")
local v = Component.new({
	Tag = "OscarAmulet"
})

function v:Construct()
	self.trove = Trove.new()
end

function v.Start(p)
	local v2 = nil
	local CheckVisibility

	CheckVisibility = function()
		if cache:FindFirstChild("DeadMansTale1") and not v2 then
			v2 = true
			p.trove:Add(cache.DeadMansTale1.Changed:Connect(CheckVisibility))
		end

		if cache:FindFirstChild("DeadMansTale1") and cache.DeadMansTale1.Value == false then
			for _, descendant in p.Instance:GetDescendants() do
				if descendant:IsA("BasePart") then
					descendant.Transparency = 0
				elseif descendant:IsA("Highlight") or descendant:IsA("ProximityPrompt") then
					descendant.Enabled = true
				end
			end
		else
			for _, descendant in p.Instance:GetDescendants() do
				if descendant:IsA("BasePart") then
					descendant.Transparency = 1
				elseif descendant:IsA("Highlight") or descendant:IsA("ProximityPrompt") then
					descendant.Enabled = false
				end
			end
		end
	end

	CheckVisibility()
	p.trove:Add(cache.ChildAdded:Connect(CheckVisibility))
	p.trove:Add(cache.ChildRemoved:Connect(CheckVisibility))
end

function v.Stop(p)
	p.trove:Destroy()
end

return v