local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ButtonActivation = {}
local v = {}

function ButtonActivation.IsGamepadButton(p)
	return p ~= nil and string.match(p.UserInputType.Name, "^Gamepad") ~= nil and string.match(
		p.KeyCode.Name,
		"^Button"
	) ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function key(p)
	return p.UserInputType.Name .. ":" .. p.KeyCode.Name
end

function ButtonActivation.Begin(p)
	if not ButtonActivation.IsGamepadButton(p) then
		return
	end

	local v2 = key(p) -- equivalent call inferred; original call site unknown
	local v3 = v[v2]

	if not (v3 and v3.down) then
		v[v2] = {
			down = true,
			consumed = false
		}
	end
end

function ButtonActivation.End(p)
	if not ButtonActivation.IsGamepadButton(p) then
		return
	end

	local v2 = v[key(p)]

	if v2 and v2.down then
		v2.down = false
		v2.releasedAt = os.clock()
	end
end

function ButtonActivation.Cancel(p)
	if not ButtonActivation.IsGamepadButton(p) then
		return
	end

	local v2 = key(p) -- equivalent call inferred; original call site unknown
	local v3 = v[v2]

	if v3 then
		v3.consumed = true
	else
		v[v2] = {
			down = false,
			consumed = true,
			releasedAt = os.clock()
		}
	end
end

function ButtonActivation.Try(p)
	if not ButtonActivation.IsGamepadButton(p) then
		return true
	end

	local v2 = key(p) -- equivalent call inferred; original call site unknown
	local v3 = v[v2]

	if v3 and v3.consumed and (v3.down or os.clock() - (v3.releasedAt or 0) <= 0.2) then
		return false
	end

	if not (v3 and v3.down) then
		v3 = {
			down = false,
			consumed = false,
			releasedAt = os.clock()
		}
		v[v2] = v3
	end

	v3.consumed = true
	return true
end

if RunService:IsClient() then
	UserInputService.InputBegan:Connect(ButtonActivation.Begin)
	UserInputService.InputEnded:Connect(ButtonActivation.End)
end

return ButtonActivation