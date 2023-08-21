--Title: Dark buttons
Version = 1.231
if not term.isColour() then
	print("Requires an Advanced Computer and an Advanced monitor.")
	return
end
if fs.exists("dark") == false then -- load darkAPI
  print("Missing OSI API")
  print("Attempting to download...")
  if not http then
    error("Enable the HTTP API to download OSI API")
  end
  getGit = http.get("https://raw.githubusercontent.com/rservices/darkprograms/darkprograms/api/dark.lua")
  getGit = getGit.readAll()
  file = fs.open("dark", "w")
  file.write(getGit)
  file.close()  
end
os.loadAPI("dark")

monSids = {} -- stores monitor sides
buttons = {} -- stores buttons data
c = colors.combine() -- Default var for wires
AutoUpdate = true

--General Functions
function Header(text, lText, rText) -- builds a header using functions above from <text>
  local x,y = term.getSize()
  dark.printL("-", 1, nil, "blue", "blue")
  dark.printC(string.rep(" ", x+1), 2, nil, "white", "blue")
  dark.printC(text, 2, nil, "white", "blue")
  dark.printL("-", 3, 5, "blue", "blue")
end
function saveState()
  dark.db.save("state", buttons)
end
function LoadState()
  if fs.exists("state") == true then
    buttons = dark.db.load("state")
  end
  for name, data in pairs(buttons) do
    if data["active"] == true then
      c = colors.combine(c, data.wireCol)
      print(data.wireCol)
      rs.setBundledOutput(options.wireSide, c)
    end
  end
end
function getMonitors()
  monSids = {}
  if peripheral.getNames then
    for i,v in pairs(peripheral.getNames()) do
      if string.sub(v,1,7) == "monitor" then
        table.insert(monSids, v)
      end
    end
  end
  for i,v in pairs(rs.getSides()) do
    if peripheral.isPresent(v) and peripheral.getType(v) == "monitor" then
      table.insert(monSids, v)
    end
  end
end
function clearMonitors()
  for i=1,#monSids do
    monitor = peripheral.wrap(monSids[i])
    monitor.clear()
  end
end
function createStaticbuttons(name,xmin,xmax,ymin,ymax,tCol,bgCol,actCol,bside,wireCol)
  buttons[name] = {}
  buttons[name].active = false 
  buttons[name].xmin = xmin
  buttons[name].ymin = ymin
  buttons[name].xmax = xmax
  buttons[name].ymax = ymax
  buttons[name].side = bside
  buttons[name].wireCol = colors[wireCol] -- bundled cable wire colour
  buttons[name].tCol = colors[tCol] --Text color
  buttons[name].bgCol = colors[bgCol] --Background color (non-active)
  buttons[name].actCol = colors[actCol] --Active color (background active)
end
function drawBox(xmin,xmax,ymin,ymax,bgCol)
  mon.setBackgroundColor(bgCol)
  for i = ymin, ymax do
    for j = xmin, xmax do
      mon.setCursorPos(j, i)
      mon.write(" ")
    end
  end
  mon.setBackgroundColor(colors.black)
end
function boxText(text,xmin,xmax,ymin,ymax,tCol,bgCol)
  thex = (((xmax - xmin) / 2) + xmin) - (#text / 2)
  they = (ymin + ymax) / 2
  mon.setCursorPos(thex , they)
  mon.setTextColor(tCol)
  mon.setBackgroundColor(bgCol)
  mon.write(text)
  mon.setTextColor(colors.white)
  mon.setBackgroundColor(colors.black)
end
function textBox(text,xmin,xmax,ymin,ymax,tCol,bgCol)
  drawBox(xmin,xmax,ymin,ymax,bgCol)
  boxText(text,xmin,xmax,ymin,ymax,tCol,bgCol)
end
function draw()
  getMonitors()
  for i,v in pairs(monSids) do
    mon = peripheral.wrap(v)
    mon.clear()
  end
  for name, data in pairs(buttons) do
    if peripheral.wrap(data.side) then
      mon = peripheral.wrap(data.side)
      x,y = mon.getSize()
      if data.active == true then
        textBox(name,data.xmin,data.xmax,data.ymin,data.ymax,data.tCol,data.actCol)
      else
        textBox(name,data.xmin,data.xmax,data.ymin,data.ymax,data.tCol,data.bgCol)
      end
    end
  end
end
function checkerboard()
  getMonitors()
  for i,v in pairs(monSids) do
    mon = peripheral.wrap(v)
    local mx, my = mon.getSize()
    if mon.isColor() then mon.setTextColor(colors.gray) end
    for i = 1, my do
      mon.setCursorPos(1,i)
      mon.write(string.rep("X", mx))
    end
    if mon.isColor() then mon.setTextColor(colors.white) end
  end
  for name, data in pairs(buttons) do
    mon = peripheral.wrap(data.side)
    x,y = mon.getSize()
    if data.active == true then
      textBox(name,data.xmin,data.xmax,data.ymin,data.ymax,data.tCol,data.actCol)
    else
      textBox(name,data.xmin,data.xmax,data.ymin,data.ymax,data.tCol,data.bgCol)
    end
  end
end
function check(hx,hy,Side)
  for name, data in pairs(buttons) do
    if Side == data.side then
      if hy>=data.ymin and hy<=data.ymax then
        if hx>=data.xmin and hx<=data.xmax then
          data.active = not data.active
          if data.active == true then
            c = colors.combine(c, data.wireCol)
          else
            c = colors.subtract(c, data.wireCol)
          end
          rs.setBundledOutput(options.wireSide, c)
          return true
        end
      end
    end
  end
  return false
end
--looping functions
function terminalMenu()
  while true do
    term.clear()
    term.setCursorPos(1,1)
    Header("Running DarkButtons V"..Version)
    print("Please press a key to select an option.")
    print("\n[1] Add a button")
    print("[2] Remove a button")
    _,char = os.pullEvent()
    if char == "1" then
      os.queueEvent("stop")
      wizard("add")
      os.queueEvent("start")
    elseif char == "2" then
      os.queueEvent("stop")
      wizard("remove")
      os.queueEvent("start")
    end
  end
end
function stealthUpdate()
  if AutoUpdate == true then 
    if ((dark.gitUpdate("darkbuttons", shell.getRunningProgram(), Version) == true) or (dark.gitUpdate("dark", "dark", dark.DARKversion) == true)) then
      os.reboot()
    end
  end
  return
end
function breakListen()
  while true do
    os.pullEvent("monitor_resize")
    draw()
  end
end
function hitListen()
  while true do
    draw()
    Event,Side,hx,hy = os.pullEvent()
    if Event == "monitor_touch" then
      getMonitors()
      check(hx,hy,Side)
      draw()
      saveState()
    elseif Event == "stop" then
      os.pullEvent("start")
    end
  end
end
--Wizard
function wizard(mode)
  function monWrite(text,mx,my)
    mon.setCursorPos(mx,my)
    mon.write(text)
  end
  function rButton(side,txd,tyd,txu,tyu)
    -- reverse incase they hit bottom first
    if txd > txu then
      temp = txd
      txd = txu
      txu = temp
    end
    if tyd > tyu then
      temp = tyd
      tyd = tyu
      tyu = temp
    end
    textBox("?",txd,txu,tyd,tyu,colors.white,colors.red)
  end  
  function checkTemp(hx,hy,xmin,xmax,ymin,ymax)
    if hy>=ymin and hy<=ymax then
      if hx>=xmin and hx<=xmax then
        return true
      end      
    end
  end
  function drawX(mx,my)
    mon.setCursorPos(mx,my)
    mon.setTextColor(colors.lime)
    mon.write("X")
    mon.setTextColor(colors.white)
  end
  function rainbow(line)
    local order = {}
    local function drawPixyel(pxy,py,color)
      term.setCursorPos(xy,py)
      term.setBackgroundColor(colors[color])
      term.write(" ")
      term.setBackgroundColor(colors.black)
    end
    xy = 1
    for name,v in pairs(colors) do
      if name == "subtract" or name == "combine" or name == "test" then
      else
        drawPixyel(xy, line, name)
        table.insert(order,name)
        xy = xy + 1
      end
    end
    return order
  end
  function addButton_terminalPart()
    function waitForClick(bOrder)
      repeat
        _,_,lx,ly = os.pullEvent("mouse_click")
      until lx>0 and lx<17 and ly==1
      return bOrder[lx] 
    end
    function waitForExitClick()
      _,_,lx,ly = os.pullEvent("mouse_click")
      if ly == y-1 then
        return true
      else
        return false
      end
    end
    function boxesColors()
      dark.cs()
      color2 = "white"
      bOrder = rainbow(1)
      print(" <- Click one to select!")
        
      term.setCursorPos(1,3)
      print("Inactive button background colour.     ")
      color = waitForClick(bOrder)
  
      term.setCursorPos(1,3)
      print("Text colour.                              ")
      color2 = waitForClick(bOrder)
        
      term.setCursorPos(1,5)
      print("Inactive button")
      textBox("Test Box",1,x,6,8,colors[color2],colors[color])
      
      term.setCursorPos(1,3)
      print("Button activate background colour.      ")
      color3 = waitForClick(bOrder)
      
      term.setCursorPos(1,10)
      print("Active button")
      textBox("Test Box",1,x,11,13,colors[color2],colors[color3])
      
      term.setCursorPos(1,3)
      print("                                            ")
      
      term.setCursorPos(1,y-1)
      write("Click ")
      term.setTextColor(colors.yellow)
      write("here ")
      term.setTextColor(colors.white)
      write("to confirm colours")
      term.setCursorPos(1,y)
      write("Else click here to choose again")
    end
    mon = term
    x,y = term.getSize()
    repeat   
      boxesColors()
      happy = waitForExitClick()
    until happy == true
    dark.cs()
    happy = false
    print("Text on the button: ")
    print("\nNote: This is the text that appears on the button, type it in and then press enter.")
    term.setCursorPos(20,1)
    bText = read()
    repeat
      dark.cs()
      bOrder = rainbow(1)
      term.setCursorPos(1,2)
      write("Wire color for this button: ")
      wireCol = waitForClick(bOrder)
      
      term.setCursorPos(28,2)
      term.setTextColor(colors[wireCol])
      write(wireCol)
      term.setTextColor(colors.white)
      
      term.setCursorPos(1,y-1)
      write("Click ")
      term.setTextColor(colors.yellow)
      write("here ")
      term.setTextColor(colors.white)
      write("to confirm colours")
      term.setCursorPos(1,y)
      write("Else click here to choose again")  
      happy = waitForExitClick()
    until happy == true
    happy = false    
    return color2,color,color3,bText,wireCol
  end
  function addButton()
    repeat --Button wizard
      clearMonitors()
      checkerboard()
      mon = peripheral.wrap(selectedMon)
      monWrite("Tap position 1 for your button",1,y)
      _,side,txd,tyd = os.pullEvent("monitor_touch")
      drawX(txd,tyd)
      monWrite("Tap position 2 for your button",1,y)
      _,_,txu,tyu = os.pullEvent("monitor_touch")
      rButton(side,txd,tyd,txu,tyu)
      monWrite("If you are happy Tap the button",1,y-1)
      monWrite("Else, Tap any black space        ",1,y)
      _,Side,hx,hy = os.pullEvent("monitor_touch")
      do --Reverse if hit from bottom first
      if txd > txu then
        temp = txd
        txd = txu
        txu = temp
      end
      if tyd > tyu then
        temp = tyd
        tyd = tyu
        tyu = temp
      end
    end
      happyness = checkTemp(hx,hy,txd,txu,tyd,tyu)
      if happyness ~= true then
        textBox(":'(",txd,txu,tyd,tyu,colors.white,colors.blue)
      else
        textBox(":)",txd,txu,tyd,tyu,colors.white,colors.blue)
      end
      sleep(1)
    until happyness == true
    clearMonitors()
    text = "Right click on the"
    monWrite(text, x/2 - #text/2, y/2 - 1)
    text = "terminal to continue."
    monWrite(text, x/2 - #text/2, y/2)
    return txd,txu,tyd,tyu
  end
  function removeButton()
    while true do
      clearMonitors()
      draw()
      mon = peripheral.wrap(selectedMon)
      monWrite("Tap a button to remove it.",1,y-1)
      monWrite("Tap ",1,y)
      mon.setTextColor(colors.yellow)
      mon.write("here")
      mon.setTextColor(colors.white)
      mon.write(" when you're finished.")
      _,Side,hx,hy = os.pullEvent("monitor_touch")
      if hy == y then 
        break 
      end
      for name, data in pairs(buttons) do
        if Side == data.side then
          if checkTemp(hx,hy,data.xmin,data.xmax,data.ymin,data.ymax) == true then
            c = colors.subtract(c, buttons[name].wireCol) -- if the button is on, we turn it off
            rs.setBundledOutput(options.wireSide, c)
            buttons[name] = nil
            break
          end
        end
      end
    end
  end
  function selectMonitor()
    print("Select a monitor by right clicking on it.")
    for i=1,#monSids do
      mon = peripheral.wrap(monSids[i])
      x,y = mon.getSize()
      mon.setCursorPos(x/2,y/2)
      mon.write(tostring(i)) 
    end
    _,Side,hx,hy = os.pullEvent("monitor_touch")
    mon = peripheral.wrap(Side)
    selectedMon = Side
    x,y = mon.getSize()
    mon.setCursorPos(x/2 - 9/2,y/2)
    mon.write("Selected!")
    sleep(1)
    return selectedMon
  end
  getMonitors()
  clearMonitors()
  term.clear()
  term.setCursorPos(1,1)
  selectedMon = selectMonitor()
  
  if mode == "add" then
    xmin,xmax,ymin,ymax = addButton()
    tCol,bgCol,actCol,name,wireCol = addButton_terminalPart()   
    dark.cs()
    createStaticbuttons(name,xmin,xmax,ymin,ymax,tCol,bgCol,actCol,selectedMon,wireCol)
  elseif mode == "remove" then
    dark.cs()
    removeButton()
  end
  clearMonitors()
  saveState()
end

options = {}
options.wireSide = "bottom"
LoadState()
getMonitors()
parallel.waitForAll(hitListen, breakListen, terminalMenu, stealthUpdate)
