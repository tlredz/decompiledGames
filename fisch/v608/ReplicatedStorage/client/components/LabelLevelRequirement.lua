local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage.packages
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local _ = ReplicatedStorage:WaitForChild("shared").modules
local _ = Players.LocalPlayer
local v = Component.new({
	Tag = "LabelLevelRequirement"
})

function v:Construct()
	self.trove = Trove.new()
end

function v.Start(p)
	local level = p.Instance:GetAttribute("Level")

	if not level then
		return
	end

	local fetched = legacyLocalPlayerData.fetch()

	if not fetched then
		return
	end

	local stats = fetched:FindFirstChild("Stats")

	if not stats then
		return
	end

	local level2 = stats:FindFirstChild("level")

	if not level2 then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		if level2.Value < level then
			p.Instance.Text = `Require min level {level} to unlock!`
			p.Instance.Visible = true
		else
			p.Instance.Visible = false
		end
	end

	update() -- equivalent call inferred; original call site unknown
	p.trove:Add(level2.Changed:Connect(update))
end

function v.Stop(p)
	p.trove:Destroy()
end

return v