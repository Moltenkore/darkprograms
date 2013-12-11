local function listPer(pname) --Returns list of peripherals matching pname
  local pers = peripheral.getNames()
  local perList = {}
  for i,v in pairs(pers) do
    if string.find(v, pname) then
      table.insert(perList, v)
    end
  end
  return perList
end
--Draw
local function wCent(text, per, ty) --Text to write, peripheral to write to, optional line to write to
  local x,y = per.getSize()
  if not ty then
    _,ty = per.getCursorPos()
  end
  per.setCursorPos((x / 2) - (#text / 2), ty)
  per.write(text)
end
local function sc(per,tc,bc) -- Set Colours
  if tc and per.isColor() then per.setTextColor(colors[tc]) end
  if bc and per.isColor() then per.setBackgroundColor(colors[bc]) end  
end
local function cc(per) -- Reset colours to default
  if per.isColor() then
    per.setBackgroundColor(colors.black) 
    per.setTextColor(colors.white)
  end
end
local function cs(per) -- clear screen of passed per
  local x,y = per.getSize()
  cc(per)
  for i=1,y do
    per.setCursorPos(1,i)
    per.write(string.rep(" ",x))
  end
  per.clear()
  per.setCursorPos(1,1)
end
local function writeAt(per,text,x,y,tc,bc) -- Write to x/y on screen with optional text and background colours
  if tc then per.setTextColor(colors[tc]) end
  if bc then per.setBackgroundColor(colors[bc]) end
  per.setCursorPos(x,y)
  per.write(text)
  return per.getCursorPos()
end
local function pwrite(per,text) --Same as print
  local cx,cy = per.getCursorPos()
  per.write(text)
  per.setCursorPos(1,cy+1)
end

local function header(per,text,botbar,nl) --Draw header with optional new line, default 5.
  local x,y = per.getSize()
  per.setBackgroundColor(colors.blue)
  for i = 1, 3 do writeAt(per,string.rep(" ",x),1,i) end
  if botbar then writeAt(per,string.rep(" ",x),1,y) end
  if state == "main" then
    writeAt(per,"By Darkrising",x-13,y)
    writeAt(per,Version,1,2)
  end  
  wCent(text, per, 2)
  per.setCursorPos(1,5)
  if nl then per.setCursorPos(1,nl) end
  per.setBackgroundColor(colors.black)
end

local function pwritem(per,text,link) --Generates menu options
  local sx,sy = per.getCursorPos()
  pwrite(per," "..text)
  local ex,_ = per.getCursorPos()
  local coption = {
    text = text,
    link = link,
    sx = sx,
    sy = sy,
    ex = ex,
  }
  table.insert(menu[state].options, coption)
end

x,y = term.getSize()

menu = {
  ["main"] = {
    draw = function(per)
      header(per, "Test", true)
      pwritem(per, "Test option 1","test1")
      pwritem(per, "Test option 2","test2")
      per.setCursorPos(1,8)
      pwritem(per, "Test Run 1","testrun1")
    end,
  },
  ["test1"] = {
    draw = function(per)
      header(per, "Test Option 1", true)
      pwritem(per, "Main Menu", "main")
    end,
  },
  ["test2"] = {
    draw = function(per)
      header(per, "Test Option 2", true)
      pwritem(per, "Main Menu", "main")
    end,
  },
  ["testrun1"] = {
    run = function(per)
      header(per, "Test Run 1", true)
      pwrite(per, "Whats your name?")
      per.write(": ")
      local name = read()
      pwrite(per,"")
      pwrite(per,"Hello "..name..".")
      sleep(2)
    end,
  },
}

ind = 3

state = "main"
csel = 1
page = 0
ava = y - ind
per = term -- peripheral is computer terminal

local function procKeys(key)
  if key == keys.up then
    csel = csel - 1
  end
  if key == keys.down then
    csel = csel + 1
  end
  if csel < 1 then
    csel = #menu[state].options
  end
  if csel > #menu[state].options then
    csel = 1
  end
  if key == keys.enter then
    state = menu[state].options[csel].link
    csel = 1
  end
end
local function genSel(per,copt)
  per.setCursorPos(copt.sx, copt.sy)
  sc(per,"yellow") per.write("[")
  sc(per,"white") per.write(copt.text)
  sc(per,"yellow") per.write("]")
  cc(per)
end
local function runMenu() -- Rep loop
  while true do
    if not pause then
    cs(per) cc(per)
    if menu[state] and menu[state].draw then
      lastState = state
      menu[state].options = {}
      menu[state].draw(per)
      genSel(per, menu[state].options[csel])
      e,key = os.pullEvent("key")
      
      procKeys(key)
    elseif menu[state] and menu[state].run then
      menu[state].run(per)
      state = lastState
    else
      wCent("Invalid option / Menu type.",per,y/2)
      state = lastState
      sleep(1)
    end
    else
      os.pullEvent("start")
    end
  end
end

bla = {}
for i = 1, 100 do
  bla["Option "..i] = "thing"..i
end

runMenu()