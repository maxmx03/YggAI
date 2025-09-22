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

---@param node fun():Status
---@param delay number
function Delay(node, delay)
  local lastExec = 0
  return function()
    local now = GetTick() / 1000
    if now - lastExec >= delay then
      lastExec = now
      return node()
    else
      return STATUS.RUNNING
    end
  end
end

---@param node fun():Status
function Reverse(node)
  return function()
    local status = node()
    if status == STATUS.SUCCESS then
      return STATUS.FAILURE
    elseif status == STATUS.FAILURE then
      return STATUS.SUCCESS
    else
      return status
    end
  end
end

---@param node fun():Status
---@param ... fun():boolean
---@return fun():Status
function Condition(node, ...)
  local conditions = { ... }
  return function()
    local allTrue = true
    for _, condition in ipairs(conditions) do
      if not condition() then
        allTrue = false
        break
      end
    end
    if allTrue then
      return node()
    else
      return STATUS.FAILURE
    end
  end
end

---@param condition fun():boolean
---@return fun():boolean
function Inversion(condition)
  return function()
    if condition() then
      return false
    else
      return true
    end
  end
end

---@param nodes table<integer, fun():Status>
function Random(nodes)
  return function()
    if #nodes == 0 then
      return STATUS.FAILURE
    end
    local index = math.random(1, #nodes)
    local status = nodes[index]()
    if status == STATUS.SUCCESS then
      return STATUS.SUCCESS
    elseif status == STATUS.RUNNING then
      return STATUS.RUNNING
    else
      for i = 1, #nodes do
        if i ~= index then
          local s = nodes[i]()
          if s == STATUS.SUCCESS or s == STATUS.RUNNING then
            return s
          end
        end
      end
      return STATUS.FAILURE
    end
  end
end
