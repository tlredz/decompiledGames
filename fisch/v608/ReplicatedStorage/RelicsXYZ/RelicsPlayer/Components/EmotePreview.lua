local parent = script.Parent.Parent
local State = require(parent.State)
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local localPlayer = Players.LocalPlayer
local shared = parent.Parent.Shared
local hooks = parent.Hooks
local components = parent.Components
local View3D = require(components.View3D)
local useClock = require(hooks.useClock)
local useEmotes = require(hooks.useEmotes)
local useSignal = require(hooks.useSignal)
local useAuraSetup = require(hooks.useAuraSetup)
local React = require(shared.React)
local Emotes = require(shared.Emotes)
local UserId = require(shared.UserId)
local Promise = require(shared.Promise)
local RunContext = require(shared.RunContext)
local v = nil
local v2 = false
local nowsByAnimationId = {}
local currents = {}

local function onCharacterAdded(_)
	table.clear(currents)
end

if localPlayer then
	localPlayer.CharacterAdded:Connect(onCharacterAdded)
end

local function promiseDescription()
	local v3 = UserId.Get(localPlayer)
	local character = localPlayer and localPlayer.Character

	if character ~= v2 then
		v = Promise.retry(function()
			return Promise.new(function(callback, callback2)
				local success, result = pcall(function()
					return Players:GetHumanoidDescriptionFromUserId(v3)
				end)

				if success then
					callback(result)
				else
					callback2(result)
				end
			end)
		end, 5, 2)
		v2 = character
	end

	return v
end

local function promiseDummy()
	return Promise.new(function(callback)
		local v3 = table.remove(currents)

		if v3 then
			callback(v3)
			return
		end

		local v4 = UserId.Get(localPlayer)
		local character = localPlayer and localPlayer.Character

		if character ~= v2 then
			v = Promise.retry(function()
				return Promise.new(function(callback2, callback3)
					local success, result = pcall(function()
						return Players:GetHumanoidDescriptionFromUserId(v4)
					end)

					if success then
						callback2(result)
					else
						callback3(result)
					end
				end)
			end, 5, 2)
			v2 = character
		end

		v:andThen(function(p)
			local humanoidModelFromDescriptionAsync = Players:CreateHumanoidModelFromDescriptionAsync(
				p,
				Enum.HumanoidRigType.R15
			)
			local humanoid = humanoidModelFromDescriptionAsync:FindFirstChildWhichIsA("Humanoid")
			local animate = humanoidModelFromDescriptionAsync:FindFirstChild("Animate")

			if animate then
				animate:Destroy()
			end

			if humanoid then
				local rootPart = humanoid.RootPart

				if rootPart then
					rootPart.Anchored = true
				end

				humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			end

			humanoidModelFromDescriptionAsync:PivotTo(CFrame.identity)
			local worldModel = Instance.new("WorldModel")
			humanoidModelFromDescriptionAsync.Parent = worldModel
			callback(worldModel)
		end)
	end)
end

local function EmotePreview(props)
	local v3 = useEmotes()
	local v4 = React.useContext(State.Context)
	local v5 = React.useMemo(function()
		local result = {}

		for _, v6 in pairs(v3) do
			table.insert(result, v6)
		end

		return result
	end, { v3 })
	local state, setState = React.useState(localPlayer.Character)
	useSignal(localPlayer.CharacterAdded, setState)
	local state2, setState2 = React.useState()
	local ref = React.useRef(state2)
	local state3, setState3 = React.useState(nil)
	local state4, setState4 = React.useState(nil)
	local renderInWorld

	if props.RenderInWorld == nil or not props.RenderEffect then
		renderInWorld = false
	else
		renderInWorld = props.RenderInWorld
	end

	local v6 = renderInWorld and 0.05 or 1
	React.useEffect(function()
		local flag = false
		local v7 = Promise.new(function(callback)
			local v8 = table.remove(currents)

			if v8 then
				callback(v8)
				return
			end

			local v9 = UserId.Get(localPlayer)
			local character = localPlayer and localPlayer.Character

			if character ~= v2 then
				v = Promise.retry(function()
					return Promise.new(function(callback2, callback3)
						local success, result = pcall(function()
							return Players:GetHumanoidDescriptionFromUserId(v9)
						end)

						if success then
							callback2(result)
						else
							callback3(result)
						end
					end)
				end, 5, 2)
				v2 = character
			end

			v:andThen(function(p)
				local humanoidModelFromDescriptionAsync = Players:CreateHumanoidModelFromDescriptionAsync(
					p,
					Enum.HumanoidRigType.R15
				)
				local humanoid = humanoidModelFromDescriptionAsync:FindFirstChildWhichIsA("Humanoid")
				local animate = humanoidModelFromDescriptionAsync:FindFirstChild("Animate")

				if animate then
					animate:Destroy()
				end

				if humanoid then
					local rootPart = humanoid.RootPart

					if rootPart then
						rootPart.Anchored = true
					end

					humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
				end

				humanoidModelFromDescriptionAsync:PivotTo(CFrame.identity)
				local worldModel = Instance.new("WorldModel")
				humanoidModelFromDescriptionAsync.Parent = worldModel
				callback(worldModel)
			end)
		end):andThen(function(current)
			if flag then
				table.insert(currents, current)
				return
			end

			local model = current:FindFirstChildOfClass("Model")
			current:ScaleTo(v6)
			local humanoid = model and model:FindFirstChildWhichIsA("Humanoid")
			ref.current = current

			if humanoid then
				task.delay(0.1, function()
					humanoid:BuildRigFromAttachments()
				end)
			end

			setState3(model)
			setState2(current)
		end)
		return function()
			flag = true
			v7:cancel()
		end
	end, { state, renderInWorld })
	React.useLayoutEffect(function()
		return function()
			local current = ref.current

			if current then
				local animator = current:FindFirstChildWhichIsA("Animator", true)

				if animator then
					for _, v7 in animator:GetPlayingAnimationTracks() do
						v7:Stop(0)
					end
				end

				current.Parent = script
				table.insert(currents, current)
			end
		end
	end, {})
	local v7 = React.useMemo(function()
		local emote = props.Emote

		if emote then
			return Emotes.GetEmoteByAnimation(emote)
		end

		if #v5 == 0 then
			return nil
		end

		return v5[math.random(1, #v5)]
	end, { props.Emote, v5 })
	React.useEffect(function()
		if not v7 then
			setState4(nil)
			return
		end

		local animation = v7.Animation

		-- equivalent calls inferred from this helper; original call sites unknown
		local function onChildAdded(child)
			if child.Name == "Effect" then
				setState4(child)
			end
		end

		local childAddedConnection = animation.ChildAdded:Connect(onChildAdded)

		for _, child in animation:GetChildren() do
			onChildAdded(child) -- equivalent call inferred; original call site unknown
		end

		return function()
			childAddedConnection:Disconnect()
		end
	end, { v7 })
	React.useEffect(function()
		if not (v7 and renderInWorld) then
			return nil
		end

		local songId = v7.SongId
		local songTitle = v7.SongTitle
		local songArtist = v7.SongArtist

		if not songId then
			return nil
		end

		local addSongOverride = v4.AddSongOverride
		local v9 = {
			Song = `rbxassetid://{songId}`,
			Artist = songArtist,
			Title = 0,
			Priority = 3000,
			SuppressRemote = true
		}
		local title

		if songTitle then
			title = `{songTitle} (Dance)`
		end

		v9.Title = title
		addSongOverride("EmoteSongPreview", v9)
		return function()
			v4.RemoveSongOverride("EmoteSongPreview")
		end
	end, { v7, renderInWorld })
	React.useEffect(function()
		if not state2 then
			return
		end

		local animator = state2:FindFirstChildWhichIsA("Animator", true)

		if not animator then
			return
		end

		for _, v8 in animator:GetPlayingAnimationTracks() do
			v8:Stop(0)
		end

		local animation = v7 and v7.Animation or props.Emote

		if not animation then
			return
		end

		local v8 = false
		local thread = task.spawn(function()
			ContentProvider:PreloadAsync({ animation })

			if v8 or not state2.Parent then
				return
			end

			local animator2 = state2:FindFirstChildWhichIsA("Animator", true)

			if not animator2 then
				return
			end

			local animationId = animation.AnimationId

			for _ = 1, 2 do
				local success, result = pcall(function()
					return animator2:LoadAnimation(animation)
				end)

				if success and result then
					result.Priority = Enum.AnimationPriority.Action
					result.Looped = true

					if nowsByAnimationId[animationId] and result.Length > 0 then
						result.TimePosition = nowsByAnimationId[animationId] % result.Length
					else
						nowsByAnimationId[animationId] = os.clock()
					end

					result:Play(0, 1, 1)
					break
				else
					task.wait(0.2)
				end
			end
		end)
		return function()
			v8 = true
			task.cancel(thread)
		end
	end, { v7, state2 })
	local ref2 = React.useRef(nil)

	if state2 == nil or not (props.RenderEffect and state4) then
		state4 = nil
	end

	useAuraSetup(state4, state3, ref2, v6)

	if RunContext.IsEdit then
		useClock(60, function(p)
			local animator = state2 and state2:FindFirstChildWhichIsA("Animator", true)

			if animator then
				animator:StepAnimations(p)
			end
		end)
	end

	return React.createElement("Frame", {
		Size = props.Size or UDim2.fromScale(1, 1),
		Position = props.Position or UDim2.fromScale(0.5, 0.5),
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ZIndex = props.ZIndex or 1
	}, {
		Emote = React.createElement(View3D, {
			Model = state2,
			FieldOfView = 1,
			ZoomScale = renderInWorld and 1.3 or 1.1,
			RenderInWorld = renderInWorld,
			UseSkybox = true,
			SkyboxImg = props.SkyboxImg,
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ZIndex = props.ZIndex or 1,
			EdgeColor = props.BackgroundColor or Color3.fromHex("#401c3d"),
			BackgroundTransparency = props.BackgroundTransparency,
			ViewportRef = ref2
		})
	})
end

return EmotePreview