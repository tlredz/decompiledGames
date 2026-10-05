local UTF8 = {
	__VERSION = "0.0.2",
	__DESCRIPTION = "Library for easily validating UTF-8 strings in pure Lua",
	__URL = "https://github.com/kikito/utf8_validator.lua",
	__LICENSE = [[
    MIT LICENSE

    Copyright (c) 2013 Enrique García Cota

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}
local find = string.find

function UTF8.validate(list)
	local v = #list
	local total = 1

	while total <= v do
		if total == find(list, "[%z\1-\127]", total) then
			total += 1
		elseif total == find(list, "[\194-\223][\128-\191]", total) then
			total += 2
		elseif total == find(list, "\224[\160-\191][\128-\191]", total) or total == find(
			list,
			"[\225-\236][\128-\191][\128-\191]",
			total
		) or total == find(list, "\237[\128-\159][\128-\191]", total) or total == find(
			list,
			"[\238-\239][\128-\191][\128-\191]",
			total
		) then
			total += 3
		elseif total == find(list, "\240[\144-\191][\128-\191][\128-\191]", total) or total == find(
			list,
			"[\241-\243][\128-\191][\128-\191][\128-\191]",
			total
		) or total == find(list, "\244[\128-\143][\128-\191][\128-\191]", total) then
			total += 4
		else
			return false, total
		end
	end

	return true
end

setmetatable(UTF8, {
	__call = function(_, ...)
		return UTF8.validate(...)
	end
})
return UTF8