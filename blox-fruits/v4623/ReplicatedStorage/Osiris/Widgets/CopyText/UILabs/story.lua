local Iris = require(game.ReplicatedStorage.Packages.Iris)
local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local parentModule = require(script.Parent)
return (UILabs.CreateIrisStory({
	name = "CopyText",
	summary = "A read-only text field whose contents can be selected and copied but never edited.",
	controls = {
		Text = "/level 700",
		Label = "command",
		Wrapped = false
	},
	iris = Iris
}, function(p)
	local controls = p.controls
	local connection = Osiris:Connect(function()
		Osiris.Widget.Window({
			Arguments = {
				Title = "CopyText"
			}
		}, function()
			if parentModule({
				Arguments = {
					Text = controls.Text:get(),
					Label = controls.Label:get(),
					Wrapped = controls.Wrapped:get() == true
				}
			}).focused() then
				print("focused, text is selected and ready to copy")
			end

			parentModule({
				Arguments = {
					Text = "/i2 12345"
				}
			})
		end)
	end)
	return function()
		connection()
	end
end))