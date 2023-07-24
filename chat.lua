os.pullEvent = os.pullEventRaw
--A Small SMS program.
--functions and variables
msg = ""
MHN = 1
MH = {}
MH[0] = "Loaded Wireless One Chat"
term.write("Name: ")
name = read()
clear = function()
term.clear()
x,y = term.getSize()
term.setCursorPos(1,y)
end
clear()
function drawScreen(Msg)
clear()
i = 18
while i >= 0 do
if MH[i] ~= nil then
print(MH[i])
end
i = i - 1
end
term.write(Msg)
end
function send(MSg)
rednet.broadcast(name..": "..MSg)
end
function runTime()
drawScreen("Enter A message")
while 1 do
event, a, b, c = os.pullEvent()
if event == "char" then
msg = msg..a
drawScreen(msg)
end
if event == "key" then
if a == keys.backspace then
msg = ""
drawScreen(msg)
elseif a == keys.enter then
send(msg)
x = MH[0]
MH[0] = msg
y = MH[1]
MH[1] = x
x = MH[2]
MH[2] = y
y = MH[3]
MH[3] = x
x = MH[4]
MH[4] = y
y = MH[5]
MH[5] = x
x = MH[6]
MH[6] = y
y = MH[7]
MH[7] = x
x = MH[8]
MH[8] = y
y = MH[9]
MH[9] = x
x = MH[10]
MH[10] = y
y = MH[11]
MH[11] = x
x = MH[12]
MH[12] = y
y = MH[13]
MH[13] = x
x = MH[14]
MH[14] = y
y = MH[15]
MH[15] = x
x = MH[16]
MH[16] = y
y = MH[17]
MH[17] = x
MH[18] = y
msg = ""
drawScreen(msg)
end
elseif event == "rednet_message" then
x = MH[0]
y = MH[1]
MH[0] = b
MH[1] = x
x = MH[2]
MH[2] = y
y = MH[3]
MH[3] = x
x = MH[4]
MH[4] = y
y = MH[5]
MH[5] = x
x = MH[6]
MH[6] = y
y = MH[7]
MH[7] = x
x = MH[8]
MH[8] = y
y = MH[9]
MH[9] = x
x = MH[10]
MH[10] = y
y = MH[11]
MH[11] = x
x = MH[12]
MH[12] = y
y = MH[13]
MH[13] = x
x = MH[14]
MH[14] = y
y = MH[15]
MH[15] = x
x = MH[16]
MH[16] = y
y = MH[17]
MH[17] = x
MH[18] = y
drawScreen(msg)
end
end
end
--main
runTime()
