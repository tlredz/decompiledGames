local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SupportBarView = require(ReplicatedStorage._FRAMEWORK.Features.supportBar.SupportBarView)
local UILabs = require(ReplicatedStorage.Packages["UI-Labs"])
local Vide = require(ReplicatedStorage.Packages.Vide)
local controls2 = {
	visible = UILabs.Boolean(true),
	cruz = UILabs.Slider(148000, 0, 1000000, 1000),
	splink = UILabs.Slider(102000, 0, 1000000, 1000)
}
return UILabs.CreateVideStory({
	name = "Support Bar",
	vide = Vide,
	controls = controls2
}, function(p)
	local controls = p.controls

	-- equivalent calls inferred from this helper; original call sites unknown
	local function total()
		return controls.cruz() + controls.splink()
	end

	return Vide.create("Frame")({
		Name = "SupportBarStory",
		BackgroundColor3 = Color3.fromRGB(38, 38, 46),
		Size = UDim2.fromScale(1, 1),
		SupportBarView.create({
			visible = controls.visible,
			cruz = controls.cruz,
			splink = controls.splink,
			cruzRatio = function()
				local v2 = total() -- equivalent call inferred; original call site unknown

				if v2 > 0 then
					return controls.cruz() / v2
				end

				return 0.5
			end
		})
	})
end)