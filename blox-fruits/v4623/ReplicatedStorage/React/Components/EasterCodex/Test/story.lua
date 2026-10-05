local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local EasterCodex = require(game.ReplicatedStorage.React.Components.EasterCodex)
local createElement = React.createElement

local function fn(p)
	local ref = React.useRef(DateTime.now().UnixTimestamp + 10)
	local ref2 = React.useRef(ref.current + 691200)
	local state, setState = React.useState(true)
	return React.createElement(EasterCodex, {
		IsOpen = state,
		OnFinish = function()
			print("done", state)

			if not state then
				p.cleanup()
			end
		end,
		OnClose = function()
			print("close it")
			setState(false)
		end,
		OnClaim = function(...)
			print("claim", ...)
		end,
		TimeStarts = ref.current,
		TimeEnds = ref2.current,
		Tween = true
	})
end

return function(p)
	local root = ReactRoblox.createRoot(p)

	local function fn2()
		root:unmount()
	end

	task.spawn(function()
		root:render((ReactRoblox.createPortal(createElement(fn, {
			cleanup = fn2
		}), p)))
	end)
	return fn2
end