local todo_file = "todo.txt"
local points_file = "points.txt"

local tasks = {}
local input = ""
local points = 0
local font, font_large
local hover_index = nil

local function load_tasks()
  local t = {}
  love.graphics.print("> " .. input, 25, input_y + 5)
  local f = io.open(todo_file, "r")
  if f then
    for line in f:lines() do
      table.insert(t, line)
    end
    f:close()
  end
  return t
end

local function save_tasks()
  local f = io.open(todo_file, "w")
  for _, task in ipairs(tasks) do
    f:write(task .. "\n")
  end
  f:close()
end

local function savePoints()
  local f = io.open(points_file, "w")
  f:write(tostring(points))
  f:close()
end

local function getPoints()
  local pointsFile = io.open(points_file, "r")
  if pointsFile then
    local val = tonumber(pointsFile:read "*a") or 0
    pointsFile:close()
    return val
  end
  return 0
end

function love.load()
  font = love.graphics.newFont(16)
  font_large = love.graphics.newFont(24)
  love.graphics.setFont(font)
  tasks = load_tasks()
  points = getPoints()
end

function love.draw()
  love.graphics.setBackgroundColor(0.12, 0.13, 0.15)
  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(font_large)
  love.graphics.print("TODO LIST", 20, 15)
  love.graphics.setFont(font)
  love.graphics.print("Points: " .. points, 400, 20)

  local startY = 60
  for i, task in ipairs(tasks) do
    local y = startY + (i - 1) * 30
    if i == hover_index then
      love.graphics.setColor(0.2, 0.3, 0.4, 0.5)
      love.graphics.rectangle("fill", 15, y - 2, 500, 26)
    end

    if task:sub(1, 4) == "[x] " then
      love.graphics.setColor(0.3, 0.8, 0.3)
    else
      love.graphics.setColor(1, 1, 1)
    end

    love.graphics.print(task, 20, y)
  end

  local input_y = startY + #tasks * 30 + 15
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", 20, input_y, 460, 30)

  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.print("Enter to add | Right-click to remove | Esc to quit", 20, input_y + 40)
end

function love.textinput(t)
  input = input .. t
end

function love.keypressed(key)
  if key == "backspace" then
    input = input:sub(1, -2)
  elseif key == "return" then
    if #input > 0 then
      table.insert(tasks, "[ ] " .. input)
      input = ""
    end
  elseif key == "escape" then
    save_tasks()
    savePoints()
    love.event.quit()
  end
end

function love.mousepressed(x, y, button)
  local startY = 60
  for i, task in ipairs(tasks) do
    local ty = startY + (i - 1) * 30
    if y >= ty and y <= ty + 24 then
      if button == 1 then
        if task:sub(1, 4) == "[ ] " then
          tasks[i] = "[x] " .. task:sub(5)
          points = points + 10
        elseif task:sub(1, 4) == "[x] " then
          tasks[i] = "[ ] " .. task:sub(5)
          points = math.max(0, points - 10)
        end
      elseif button == 2 then
        table.remove(tasks, i)
      end
      break
    end
  end
end

function love.mousemoved(x, y)
  hover_index = nil
  local startY = 60
  for i = 1, #tasks do
    local ty = startY + (i - 1) * 30
    if y >= ty and y <= ty + 24 then
      hover_index = i
      break
    end
  end
end

function love.quit()
  save_tasks()
  savePoints()
end
