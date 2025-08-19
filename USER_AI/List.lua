local M = {}

function M.new()
  return { first = 0, last = -1 }
end

function M.pushleft(list, value)
  local first = list.first - 1
  list.first = first
  list[first] = value
end

function M.pushright(list, value)
  local last = list.last + 1
  list.last = last
  list[last] = value
end

function M.popleft(list)
  local first = list.first
  if first > list.last then
    return nil
  end
  local value = list[first]
  list[first] = nil -- to allow garbage collection
  list.first = first + 1
  return value
end

function M.popright(list)
  local last = list.last
  if list.first > last then
    return nil
  end
  local value = list[last]
  list[last] = nil
  list.last = last - 1
  return value
end

function M.clear(list)
  for i, _ in ipairs(list) do
    list[i] = nil
  end
  --[[
	if M.size(list) == 0 then
		return
	end
	local first = list.first
	local last  = list.last
	for i=first, last do
		list[i] = nil
	end
--]]
  list.first = 0
  list.last = -1
end

function M.size(list)
  local size = list.last - list.first + 1
  return size
end

return M.new()
