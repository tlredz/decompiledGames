game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local fx = require(ReplicatedStorage2.shared.modules.fx)
local resources = ReplicatedStorage2.resources
local v = Component.new({
	Tag = "ButtonSounds"
})

function v:Construct()
	self.trove = Trove.new()
end

function v.Start(p)
	if not p.Instance:GetAttribute("noClick") then
		p.trove:Add(p.Instance.MouseButton1Click:Connect(function()
			if p.Instance:GetAttribute("buttonType") == "2" then
				fx:PlaySound(resources.sounds.sfx.ui.click2, p.Instance, false)
			else
				fx:PlaySound(resources.sounds.sfx.ui.click1, p.Instance, false)
			end
		end))
	end

	p.trove:Add(p.Instance.MouseEnter:Connect(function()
		fx:PlaySound(resources.sounds.sfx.ui.itemhover, p.Instance, false)
	end))
end

function v.Stop(p)
	p.trove:Destroy()
end

return v