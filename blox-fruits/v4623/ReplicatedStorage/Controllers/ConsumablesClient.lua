local ConsumablesClient = {
	Hunger = 0
}
local Net = require(game.ReplicatedStorage.Modules.Net)
local remoteFunction = Net:RemoteFunction("RequestPlayer")
local PlayerLookupComponent = require(game.ReplicatedStorage.Modules.Create.PlayerLookupComponent)
local CharacterReady = require(game.ReplicatedStorage.Modules.Player.CharacterReady)
local localPlayer = game.Players.LocalPlayer

-- equivalent calls inferred from this helper; original call sites unknown
local function updateHunger()
	ConsumablesClient.Hunger = localPlayer.Character:GetAttribute("Hunger") or 0
end

function ConsumablesClient.OnStart(_)
	CharacterReady(localPlayer, function(player)
		player.Character:GetAttributeChangedSignal("Hunger"):Connect(updateHunger)
		updateHunger() -- equivalent call inferred; original call site unknown
	end)

	remoteFunction.OnClientInvoke = function(data)
		local userId = nil
		local connection = PlayerLookupComponent({
			Filter = function(p, p2)
				local playerByUserId = game.Players:GetPlayerByUserId(p2.UserId)

				if p._Category == "Server" and not playerByUserId or data.Filter == "Friends" and not p2.IsFriend then
					return true
				end

				return table.find(data.Tabs or {}, "Global") == nil and not playerByUserId
			end,
			MouseButton1Click = function(instance, player)
				instance:Debounce({
					Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=150&h=150`,
					Text = `Requesting <{player.DisplayName or player.Name}>`
				})
				instance:Destroy()
				userId = player.UserId
			end
		}):ChangeTitle(data.Title or "Players"):ChangeDescription(data.Description or `Choose a {data.Filter == "Friends" and "friend" or "player"}`):EnableCategory(data.Tabs or {
			"Server",
			"Global"
		}):Connect()

		while userId == nil and not connection._Destroyed do
			task.wait()
		end

		return userId
	end
end

return ConsumablesClient