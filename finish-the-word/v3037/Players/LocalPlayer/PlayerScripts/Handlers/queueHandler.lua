local import = _G.import("romodel")
local import2 = _G.import("event")
local import3 = _G.import("sync")
local import4 = _G.import("viewImports")
local matchmakingQueue = import4:get("matchmakingQueue").MatchmakingQueue
local requeueScreen = import4:get("requeueScreen").RequeueScreen
local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local now = os.time()
local v = nil

local function requeue(playerCount, instance, noButton)
	if v then
		return
	end

	local now2 = os.time()

	if now2 - now < 1 then
		return
	end

	now = now2
	local v2 = noButton and import.make(requeueScreen, {
		PlayerCount = playerCount
	}) or import.make(matchmakingQueue, {
		Position = UDim2.new(0.5, 0, 0.1, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		NoButton = noButton,
		PlayerCount = playerCount
	})
	v = v2
	v2.Instance:GetPropertyChangedSignal("Parent"):Connect(function()
		if v2.Instance.Parent then
			return
		end

		v = nil
	end)

	if noButton then
		import2.fire("hideLoadingScreen")

		if instance then
			instance:Destroy()
		end

		import.mount(v2, playerGui)
	end

	import3.request("joinQueue", function()
		if noButton then
			return
		end

		v2.MatchmakingContainer:open()
	end, function(p3)
		v = nil
		v2:Destroy()
		import2.fire("signal", p3)
	end, function(p3, p4)
		v = nil

		if not noButton then
			if instance then
				instance:Destroy()
			end

			import.mount(v2, playerGui)
		end

		if p3 then
			return
		end

		v2:Destroy()
		import2.fire("signal", p4)
	end)(playerCount)
end

return {
	Priority = 1,
	Run = function()
		import2.connect("requeue", requeue)
		import2.remoteConnect("autoRequeue", function(playerCount)
			requeue(playerCount, nil, true)
		end)
		import2.remoteConnect("cannonExit", function(cFrame)
			local character = localPlayer.Character

			if not character then
				return
			end

			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			humanoidRootPart.CFrame = cFrame
		end)
	end
}