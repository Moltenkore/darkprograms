os.pullEvent = os.pullEventRaw

local isPocket = false
if pocket then
    isPocket = true
end

local msg = ""
local MH = {}
local historyFilePath = "/.chat_history"
local nameFilePath = "/.chat_username"
local modemSide = nil

-- Load chat history from file if available
if fs.exists(historyFilePath) then
    local file = fs.open(historyFilePath, "r")
    local line = file.readLine()
    while line do
        table.insert(MH, 1, line) -- Insert at the beginning for newest messages at the bottom
        line = file.readLine()
    end
    file.close()
end

-- Check if the name is saved in a file, otherwise ask the user to enter it
if fs.exists(nameFilePath) then
    local file = fs.open(nameFilePath, "r")
    name = file.readLine()
    file.close()
else
    term.write("Name: ")
    name = read()
    local file = fs.open(nameFilePath, "w")
    file.writeLine(name)
    file.close()
end

-- Detect modem side
for _, side in ipairs(rs.getSides()) do
    if peripheral.getType(side) == "modem" then
        modemSide = side
        break
    end
end

if not modemSide then
    error("No modem detected. Please attach a modem.")
end

local function clear()
    term.clear()
    local _, y = term.getSize()
    term.setCursorPos(1, y)
end

local function saveHistory()
    local file = fs.open(historyFilePath, "w")
    for _, line in ipairs(MH) do
        file.writeLine(line)
    end
    file.close()
end

local function send(MSg)
    rednet.broadcast(name .. ": " .. MSg)
end
local function drawScreen(Msg)
    clear()
    local i = 18
    while i >= 0 do
        if MH[i] ~= nil then
            print(MH[i])
        end
        i = i - 1
    end
    print(Msg)
end

local function clearOldMessages()
    local currentTime = os.time()
    local maxAge = 2 * 24 * 60 * 60 -- 2 days in seconds

    local newMH = {}
    for _, line in ipairs(MH) do
        local timestamp = tonumber(line:match("^%[(%d+)%]"))
        if not timestamp or currentTime - timestamp <= maxAge then
            table.insert(newMH, line)
        end
    end

    MH = newMH
    saveHistory()
end

local function deleteHistory()
    MH = {}
    saveHistory()
end

local function runTime()
    rednet.open(modemSide)

    local historyStart = 1
    local linesToShow = isPocket and 5 or 18
    local screenLines = term.getSize()

    while true do
        clear()

        term.setCursorPos(1, 1)
        term.write("Wireless One Chat")

        local historyCount = #MH
        local historyEnd = historyCount
        local historyBegin = math.max(1, historyCount - linesToShow + 1)

        for i = historyBegin + historyStart - 1, historyEnd + historyStart - 1 do
            term.setCursorPos(1, screenLines - (i - historyStart + 1))
            term.write(MH[i])
        end

        drawScreen("Enter a message: " .. msg)

        local event, a, b, c = os.pullEvent()

        if event == "char" then
            msg = msg .. a
            drawScreen("Enter a message: " .. msg)
        elseif event == "key" then
            if a == keys.backspace then
                msg = msg:sub(1, #msg - 1)
                drawScreen("Enter a message: " .. msg)
            elseif a == keys.enter then
                if msg ~= "" then
                    send(msg)
                    table.insert(MH, 1, name .. ": " .. msg)
                    saveHistory()
                    msg = ""
                    drawScreen("Enter a message: " .. msg)
                end
            elseif a == keys.up then
                historyStart = math.max(1, historyStart - 1)
            elseif a == keys.down then
                historyStart = math.min(historyCount - linesToShow + 1, historyStart + 1)
            elseif a == keys.d and c == true then
                term.clear()
                term.setCursorPos(1, 1)
                term.setTextColor(colors.red)
                term.write("Delete chat history? (Y/N): ")
                local confirmation = read():lower()
                if confirmation == "y" then
                    deleteHistory()
                end
            end
        elseif event == "rednet_message" then
            table.insert(MH, 1, "[" .. os.time() .. "] " .. b)
            saveHistory()
        end

        clearOldMessages() -- Check and clear old messages
    end
end

runTime()
