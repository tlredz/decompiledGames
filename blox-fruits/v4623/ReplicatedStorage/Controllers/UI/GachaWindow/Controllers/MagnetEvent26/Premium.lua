local React = require(game.ReplicatedStorage.Packages.React)
local Premium = require(game.ReplicatedStorage.React.Components.Gacha.Windows.MagnetEvent26.Premium)
local SceneController = require(game.ReplicatedStorage.Controllers.SceneController)
local SceneEffect = require(game.ReplicatedStorage.React.Components.Gacha.SceneEffect)
local Global = require(game.ReplicatedStorage.Global)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local usePolicyService = require(game.ReplicatedStorage.React.Hooks.Player.usePolicyService)

local function fn()
	local state, setState = React.useState(false)
	React.useEffect(function()
		-- equivalent calls inferred from this helper; original call sites unknown
		local function fn2()
			setState(localPlayer:GetAttribute("RobuxPurchasePrompt") ~= nil)
		end

		fn2() -- equivalent call inferred; original call site unknown
		local robuxPurchasePromptChangedConnection = localPlayer:GetAttributeChangedSignal("RobuxPurchasePrompt"):Connect(fn2)
		return function()
			robuxPurchasePromptChangedConnection:Disconnect()
		end
	end, {})
	return state
end

local function fn2()
	local state, setState = React.useState(false)
	React.useEffect(function()
		local connections = {}
		local v = false
		local thread = task.defer(function()
			local Players2 = game:GetService("Players")
			local notifications = Players2.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Notifications"):WaitForChild("Notifications")

			if notifications and notifications:IsA("Frame") and not v then
				local thread2 = nil

				local function update()
					if thread2 then
						task.cancel(thread2)
						thread2 = nil
					end

					thread2 = task.defer(function()
						thread2 = nil
						local count = 0

						for _, label in pairs(notifications:GetChildren()) do
							if not label:IsA("TextLabel") then
								continue
							end

							count += 1
							break
						end

						print("count", count)
						setState(count > 0)
					end)
				end

				if thread2 then
					task.cancel(thread2)
					thread2 = nil
				end

				thread2 = task.defer(function()
					thread2 = nil
					local count = 0

					for _, label in pairs(notifications:GetChildren()) do
						if not label:IsA("TextLabel") then
							continue
						end

						count += 1
						break
					end

					print("count", count)
					setState(count > 0)
				end)
				table.insert(connections, notifications.ChildAdded:Connect(update))
				table.insert(connections, notifications.ChildRemoved:Connect(update))
			end
		end)
		return function()
			v = true
			task.cancel(thread)

			for _, connection in pairs(connections) do
				connection:Disconnect()
			end
		end
	end, {})
	return state
end

return function(props)
	local v = usePolicyService()
	local state, setState = React.useState(nil)
	local v2 = fn2()
	local v3 = fn()
	local visible = props.Visible and v3 == false
	local state2, setState2 = React.useState(nil)
	local state3, setState3 = React.useState(nil)

	local function fn3(itemId, sequenceType, flag: boolean?)
		setState(true)
		local sceneEffect = SceneEffect({
			OnSequenceFinished = function(_, data)
				setState(nil)

				if data then
					data.SequenceHistory(data.Data.PhysicalMoveset).SetSequencePlayedFromLocation(
						"Gacha.Premium",
						"Primary"
					)
					data.Camera.SetCameraType("Inspect")
				end
			end,
			OnSequenceStarted = function(_, p3)
				if p3 and not flag then
					p3.Camera.SetCameraType("CameraSubject")
				end
			end,
			SequenceType = sequenceType,
			ItemId = itemId
		})
		return function()
			setState(nil)
			sceneEffect()
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isPreviewFinished()
		local v5 = SceneController.TryGetCurrentClass()
		return (not v5 or v5.Sequence.GetCurrentSequence().Finished ~= false) and not state
	end

	React.useEffect(function()
		local v5 = SceneController.TryGetCurrentClass()

		if visible and state3 and v5 and v5.TapInWorld and state2 then
			-- equivalent call inferred; original call site unknown
			if isPreviewFinished() then
				return (fn3(state2, v5.TapInWorld, true))
			end
		end

		return function() end
	end, { state3 })
	local selectItem = React.useCallback(function(p)
		if visible then
			-- equivalent call inferred; original call site unknown
			if isPreviewFinished() then
				if p == state2 then
					setState3(os.clock())
				else
					setState2(p)
				end
			end
		end
	end, { visible, state2 })
	React.useEffect(function()
		if not (props.Visible or v3) then
			setState2(nil)
		end
	end, { props.Visible, v3 })
	return React.createElement(Premium, {
		Size = UDim2.fromScale(1, 1),
		HeaderHidden = v2 == true or state == true,
		SelectItem = selectItem,
		Selected = state2,
		PreviewFrameEffect = function(p)
			return (fn3(p, "Primary"))
		end,
		OnPurchase = function(p)
			if v and v.ArePaidRandomItemsRestricted then
				props.SendNotification("This gacha is disabled in your region.")
			else
				Global.hookBuy(p, "Buy")
			end
		end,
		OnClose = props.Close,
		Visible = visible
	})
end