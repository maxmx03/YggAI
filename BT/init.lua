---@enum Status
STATUS = {
  RUNNING = 1,
  SUCCESS = 2,
  FAILURE = 3,
}

---@param nodes table<integer, fun():Status>
function Sequence(nodes)
  local index = 1
  return function()
    while index <= #nodes do
      ---@type fun():Status
      local node = nodes[index]
      local status = node()
      if status == STATUS.SUCCESS then
        index = index + 1
      elseif status == STATUS.RUNNING then
        return STATUS.RUNNING
      else
        index = 1
        return STATUS.FAILURE
      end
    end
    index = 1
    return STATUS.SUCCESS
  end
end

---@param nodes table<integer, fun():Status>
function Selector(nodes)
  local index = 1
  return function()
    while index <= #nodes do
      local node = nodes[index]
      local status = node()
      if status == STATUS.SUCCESS then
        index = 1
        return STATUS.SUCCESS
      elseif status == STATUS.RUNNING then
        index = index
        return STATUS.RUNNING
      else
        index = index + 1
      end
    end
    index = 1
    return STATUS.FAILURE
  end
end

---@param nodes table<integer, fun():Status>
function Parallel(nodes)
  return function()
    local allSuccess = true
    local hasRunning = false

    for _, node in ipairs(nodes) do
      local status = node()

      if status == STATUS.FAILURE then
        return STATUS.FAILURE
      elseif status == STATUS.RUNNING then
        hasRunning = true
        allSuccess = false
      elseif status ~= STATUS.SUCCESS then
        allSuccess = false
      end
    end

    if allSuccess then
      return STATUS.SUCCESS
    elseif hasRunning then
      return STATUS.RUNNING
    else
      return STATUS.FAILURE
    end
  end
end
