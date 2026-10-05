return function(p)
	local Maid = require(game.ReplicatedStorage.Util.Maid)
	local maid = Maid.new()
	task.spawn(function()
		task.wait()
		local React = require(game.ReplicatedStorage.Packages.React)
		local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
		local DialogueWindow = require(script.Parent.Parent.DialogueWindow)
		local OptionsList = require(script.Parent.Parent.OptionsList)
		local parentModule = require(script.Parent)
		local root = ReactRoblox.createRoot(p)
		maid:GiveTask(function()
			root:unmount()
		end)

		local function clicked(p2: string)
			return function()
				print("clicked:", p2)
			end
		end

		local createElement = React.createElement
		local createElement2 = React.createElement
		local v3 = "accept"
		local children = {
			accept = React.createElement(parentModule.AcceptButton, {
				onActivated = function()
					print("clicked:", v3)
				end
			}),
			purchase = 0,
			event = 0,
			chat = 0,
			questRecommended = 0,
			quest = 0,
			questBoss = 0,
			questLocked = 0,
			nevermind = 0
		}
		local v5 = "purchase"
		children.purchase = React.createElement(parentModule.PurchaseButton, {
			text = "Purchase ($2,000)",
			layoutOrder = -99998,
			onActivated = function()
				print("clicked:", v5)
			end
		})
		local v7 = "event"
		children.event = React.createElement(parentModule.EventButton, {
			text = "Magnet Event ⏰",
			effect = "Premium",
			layoutOrder = -99997,
			onActivated = function()
				print("clicked:", v7)
			end
		})
		local v9 = "chat"
		children.chat = React.createElement(parentModule.ChatButton, {
			text = "Who are you?",
			layoutOrder = 1,
			onActivated = function()
				print("clicked:", v9)
			end
		})
		local v11 = "questRecommended"
		children.questRecommended = React.createElement(parentModule.QuestRecommendedButton, {
			text = "Bandits",
			layoutOrder = 2,
			onActivated = function()
				print("clicked:", v11)
			end
		})
		local v13 = "quest"
		children.quest = React.createElement(parentModule.QuestButton, {
			text = "Rocketeers",
			layoutOrder = 3,
			onActivated = function()
				print("clicked:", v13)
			end
		})
		local v15 = "questBoss"
		children.questBoss = React.createElement(parentModule.QuestBossButton, {
			text = "Gorilla King",
			layoutOrder = 4,
			onActivated = function()
				print("clicked:", v15)
			end
		})
		children.questLocked = React.createElement(parentModule.QuestLockedButton, {
			text = "Gorilla King",
			layoutOrder = 5
		})
		local v17 = "nevermind"
		children.nevermind = React.createElement(parentModule.NevermindButton, {
			onActivated = function()
				print("clicked:", v17)
			end
		})
		root:render(createElement(DialogueWindow, {
			text = "Would you like to set your <font color=\"#8c99ff\">Home Point</font> here? You can press the home button from any safe zone to return here!",
			name = "SOMEONES NAME",
			subtitle = "King Red Head"
		}, {
			optionsList = createElement2(OptionsList, {}, children)
		}))
	end)
	return function()
		maid:Destroy()
	end
end