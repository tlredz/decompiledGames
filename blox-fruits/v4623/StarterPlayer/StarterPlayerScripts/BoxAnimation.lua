local Players = game:GetService("Players")
local Type = require(game.ReplicatedStorage.Packages.Type)
local IndexUtil = require(game.ReplicatedStorage.Packages.IndexUtil)
local Option = require(game.ReplicatedStorage.Packages.Option)
local Notification = require(game.ReplicatedStorage:WaitForChild("Notification"))
local Inventory = require(game.ReplicatedStorage.Controllers.UI.Inventory)
local strictInterface = Type.strictInterface({
	Box = Type.string,
	Main = Type.optional(Type.string),
	Beli = Type.optional(Type.number),
	Fragments = Type.optional(Type.number)
})
IndexUtil.matchPathAsync("game/ReplicatedStorage/Remotes/CommF_", Option.some(15)):await():unwrap()

function readRewardData(instance)
	local v = {
		Box = instance:GetAttribute("Box"),
		Main = instance:GetAttribute("Main"),
		Beli = instance:GetAttribute("Beli"),
		Fragments = instance:GetAttribute("Fragments")
	}
	assert(strictInterface(v))
	return v
end

while not Inventory:GetIfInitialized() do
	task.wait()
end

Players.LocalPlayer.ChildAdded:Connect(function(child)
	if child.Name == "__BoxData" then
		local v = readRewardData(child)
		local Enchant = require(Players.LocalPlayer.PlayerGui.Main.UIController.Enchant)
		Enchant(v.Box)

		if v.Fragments or v.Beli then
			Notification.new("💰 Congratulations! You unboxed... 💰", 7.5):Display()

			if v.Beli then
				Notification.new("<Color=Green>$" .. v.Beli .. "<Color=/>", 7.5):Display()
			end

			if v.Fragments then
				Notification.new("<Color=Purple>ƒ" .. v.Fragments .. "<Color=/>", 7.5):Display()
			end

			if v.Main then
				Notification.new("And... <Color=Yellow><" .. v.Main .. "><Color=/>!", 7.5):Display()
			end
		elseif v.Main then
			Notification.new("Congratulations! You unboxed... <Color=Yellow><" .. v.Main .. "><Color=/>!", 7.5):Display()
		end

		child:Destroy()
	end
end)