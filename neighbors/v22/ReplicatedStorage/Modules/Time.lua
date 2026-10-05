local Time = {
	seconds = function(p: number)
		return p
	end,
	minutes = function(p: number)
		return p * 60
	end
}

function Time.hours(p: number)
	return p * Time.minutes(60)
end

function Time.days(p: number)
	return p * Time.hours(24)
end

return Time