local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local localPlayer = game.Players.LocalPlayer
local v = Component.new({
	Tag = "ZeusPuzzle_CodeDisplay"
})

function v:Construct()
	self.trove = Trove.new()
end

function v.Start(p)
	local v2 = p.Instance:GetAttribute("CodePart") == 1 and "Zeus_Puzzle_Code1" or "Zeus_Puzzle_Code2"

	if localPlayer:GetAttribute(v2) then
		if p.Instance:GetAttribute("CodePart") == 1 then
			p.Instance.Text = localPlayer:GetAttribute(v2) .. "-XXXX"
		else
			p.Instance.Text = "XXXX-" .. localPlayer:GetAttribute(v2)
		end
	else
		p.Instance.Text = "XXXX-XXXX"
	end

	p.trove:Add(localPlayer:GetAttributeChangedSignal(v2):Connect(function()
		if not localPlayer:GetAttribute(v2) then
			p.Instance.Text = "XXXX-XXXX"
		elseif p.Instance:GetAttribute("CodePart") == 1 then
			p.Instance.Text = localPlayer:GetAttribute(v2) .. "-XXXX"
		else
			p.Instance.Text = "XXXX-" .. localPlayer:GetAttribute(v2)
		end
	end))
end

function v.Stop(p)
	p.trove:Destroy()
end

return v