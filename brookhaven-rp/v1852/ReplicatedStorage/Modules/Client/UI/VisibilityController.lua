local v = {}

local function addTicket(p, direction: string)
	local v2 = v[p]

	if v2 == nil then
		local v3 = direction ~= "show"
		assert(
			p.Visible == v3,
			(`VisibilityController: expected instance.Visible to be {v3} when adding first {direction} ticket, but it was {p.Visible}`)
		)
		v2 = {
			direction = direction,
			ticketCount = 0
		}
		v[p] = v2
	else
		assert(
			v2.direction == direction,
			(`VisibilityController: instance already has {v2.direction} tickets, cannot add {direction} ticket`)
		)
	end

	v2.ticketCount += 1
	local visible = direction == "show"
	p.Visible = visible
	local flag = false
	return function()
		if flag then
			return
		end

		flag = true
		v2.ticketCount -= 1

		if v2.ticketCount == 0 then
			v[p] = nil
			assert(
				p.Visible == visible,
				(`VisibilityController: expected instance.Visible to be {visible} when removing last {direction} ticket, but it was {p.Visible}`)
			)
			p.Visible = not visible
		end
	end
end

local VisibilityController = {}

function VisibilityController.AddHideTicket(p)
	return (addTicket(p, "hide"))
end

function VisibilityController.AddShowTicket(p)
	return (addTicket(p, "show"))
end

return VisibilityController