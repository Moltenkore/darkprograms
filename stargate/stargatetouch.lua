--Config
dbFName = ".SG_Data"
autoUpdate = true
gateTimeoutPeriod = 30

--Global Vars
Version = 1.204
cpage = 1
--Taken from DarkAPI
function gitUpdate(ProgramName, Filename, ProgramVersion)
  if http then
    local getGit = http.get("https://raw.github.com/darkrising/darkprograms/darkprograms/programVersions")
    local getGit = getGit.readAll()
    NVersion = textutils.unserialize(getGit)
    if NVersion[ProgramName].Version > ProgramVersion then
      getGit = http.get(NVersion[ProgramName].GitURL)
      getGit = getGit.readAll()
      local file = fs.open(Filename, "w")
      file.write(getGit)
      file.close()
      return true
    end
  else
    return false
  end
end

--Database
local function saveDB(filen, tabl)
  local Data = textutils.serialize(tabl)
  local F = fs.open(filen, "w")
  F.write(Data)
  F.close() 
end
local function loadDB(filen)
  local F = fs.open(filen, "r")
  local Data = F.readAll()
  F.close()
  Data = textutils.unserialize(Data)
  return Data
end

--Peripheral
local function genNames() --Generates a table based on sides with peripherals
  local periph = {}
  periph.side = {
    back = {},
    front = {},
    top = {}, 
    bottom = {},
    top = {}, 
    left = {}, 
    right = {},
  }
  periph.names = peripheral.getNames()
  for i,v in pairs(periph.names) do 
    if periph.side[v] then
      current = v
    else
      table.insert(periph.side[current], v) 
    end
  end
  return periph
end
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

--Draw U
local function wCent(text, per, ty) --Text to write, peripheral to write to, optional line to write to
  local x,y = per.getSize()
  if not ty then
    _,ty = per.getCursorPos()
  end
  per.setCursorPos((x / 2) - (#text / 2), ty)
  per.write(text)
end
local function sc(per,tc,bc) -- Set Colors
  if tc then per.setTextColor(colors[tc]) end
  if bc then per.setBackgroundColor(colors[bc]) end  
end
local function cc(per) -- Reset colors to default
  per.setBackgroundColor(colors.black) 
  per.setTextColor(colors.white)
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
local function writeAt(per,text,x,y,tc,bc) -- Write to x/y on screen
  if tc then per.setTextColor(colors[tc]) end
  if bc then per.setBackgroundColor(colors[bc]) end
  per.setCursorPos(x,y)
  per.write(text)
  return per.getCursorPos()
end
local function pwrite(per,text)
  local cx,cy = per.getCursorPos()
  per.write(text)
  per.setCursorPos(1,cy+1)
end

--Draw S
local function header(per,text)
  local x,y = per.getSize()
  per.setBackgroundColor(colors.blue)
  for i = 1, 3 do
    writeAt(per,string.rep(" ",x),1,i)
  end

  writeAt(per,string.rep(" ",x),1,y)
  writeAt(per,"By Darkrising",x-13,y)
  writeAt(per,Version,1,2)
  
  wCent(text, per, 2)
  
  per.setCursorPos(1,5)
  per.setBackgroundColor(colors.black)
end
local function tab_gui(per,tbl,pern)
  cs(per) cc(per)
  local x,y = per.getSize()
  local colDat = {"black"}
  alter = false
  for i = 2, y do
    if alter then col = "black" else col = "gray" end
    alter = not alter
    writeAt(per,string.rep(" ",x),1,i,nil,col)
    table.insert(colDat, col)
  end
  cc(per)
  tabs = x / 3
  writeAt(per,"[Address]", 1, 1, "yellow")
  writeAt(per,"[Name]", tabs, 1, "yellow")
  writeAt(per,"[Owner]", tabs * 2, 1, "yellow")
  cc(per)
  per.setCursorPos(1,3)
  
  pData = {}
  for name,data in pairs(tbl) do
    table.insert(pData, name)
  end
  table.sort(pData)
  
  for i = 1, y - 1 do
    if tbl[pData[mod]] then
      writeAt(per, pData[mod], 1, i+1, nil, colDat[i+1])
      writeAt(per, tbl[pData[mod]].name, tabs, i+1, nil, colDat[i+1])
      _,cy = writeAt(per, tbl[pData[mod]].owner, tabs * 2, i+1, nil, colDat[i+1])
      db.buttons[pData[mod]] = {["monitor"] = pern, ["line"] = cy}
    end
    mod = mod + 1
  end
end
local function tab_popup(per,name)  
  cs(per) cc(per)
  local x,y = per.getSize()
  local valid
  
  if star.getAddress() ~= name then valid = star.isValidAddress(name) else valid = false end
  if valid ~= true then 
    sc(per,"white","red") wCent("Gate Failed to dial address...",per, y/2) cc(per)
  elseif star.isBusy(name) == true then
    sc(per,"white","red") wCent("Gate Dialed is busy.", per, y/2-1) cc(per)
  elseif star.hasFuel() == true then
    star.dial(name)
    sc(per,"white","blue") wCent(" Gate Dialing... ", per, y/2-1) cc(per)
    wCent("Tap to disconnect...", per, y/2 + 2)
    
    if db.gateList[name] then
      wCent(name..", ".. db.gateList[name].name ..", ".. db.gateList[name].owner  ,mon,y/2+1)
    end
    
    os.queueEvent("start_helper")
    
    repeat
      sleep(1)
    until not star.isDialing()
    
    status = star.isConnected()
    if status == true then
      for i = gateTimeoutPeriod, 1, -1 do
        cs(per)
        sc(per,"white","green") wCent(" Gate Connected ",per, y/2-1) cc(per)
        wCent("Time Left : "..i,per,(y/2)+1)
        wCent("Tap to disconnect...", per, y/2 + 2)
        sleep(1)
        if star.isConnected() == false then break end
      end
      cs(per)
      sc(per,"white","red") wCent(" Gate closing... ",per, y/2-1) cc(per)
      star.disconnect()
    else
      sc(per,"white","red") wCent(" Gate interrupted. ",per, y/2-1) cc(per)
    end
  end
  
  os.queueEvent("stop_helper")
  sleep(2)
end

term_gui = {
  ["main"] = {
    draw = function(per)
      header(per,"Gate Addresses")
      pwrite(per," ")
      pwrite(per,"[1] Check")
      pwrite(per,"[2] Add")
      pwrite(per,"[3] Remove")
    end,
    options = {"gate_check","gate_add","gate_remove"},
  },
    ["gate_check"] = {
      draw = function(per)
        header(per,"Gate Addresses - Check")
        pwrite(per,"[1] Gate Addresses")
        pwrite(per," ")
        pwrite(per,"[2] By Serial")
        pwrite(per,"[3] By Name")
      end,
      options = {"main","gate_check_serial","gate_check_name"},
    },
      ["gate_check_serial"] = {
        run = function(per)
          header(per,"Gate Addresses - Check - Serial")
           
          write("Gate Serial: ")
          gser = string.upper(read())
          pwrite(per,"")
       
          if db.gateList[gser] then
            pwrite(per,"Name    : ".. db.gateList[gser].name)
            pwrite(per,"Owner   : ".. db.gateList[gser].owner)
            pwrite(per,"Allowed : ".. tostring(db.gateList[gser].allowed))
          else
            pwrite(per,"Record not found.")
          end
        
          pwrite(per,"")
          write("Press enter to continue...")
          read()
      end,
      },
      ["gate_check_name"] = {
        run = function(per)
          header(per,"Gate Addresses - Check - Name")
             
          write("Gate Name: ")
          gname = string.lower(read())
          
          for i,v in pairs(db.gateList) do
            lowern = string.lower(v.name)
            if string.find(lowern,gname) then
              gser = i
            end
          end
            
          pwrite(per,"")
            
          if db.gateList[gser] then
            pwrite(per,"Name    : ".. db.gateList[gser].name)
            pwrite(per,"Owner   : ".. db.gateList[gser].owner)
            pwrite(per,"Allowed : ".. tostring(db.gateList[gser].allowed))
          else
            pwrite(per,"Record not found.")
          end
        
          pwrite(per,"")
          write("Press enter to continue...")
          read()
        end,
      },
    ["gate_add"] = {
      run = function(per)
        header(per,"Gate Addresses - Add")
        
        repeat
          write("Gate Serial : ")
          gser = string.upper(read())
        until star.isValidAddress(gser) == true
                  
        repeat
          write("Gate Name : ")
          gname = read()
        until gname ~= ""
        
        repeat
          write("Gate Owner : ")
          gowner = read()
        until gowner ~= ""
                
        db.gateList[gser] = {
          name = gname,
          owner = gowner,
          allowed = true,
        }
        
        saveDB(dbFName, db)
        
        pwrite(per,"")
        pwrite(per,"Added!")
        sleep(1.5)
        
      end,
    },
    ["gate_remove"] = {
      draw = function(per)
        header(per,"Gate Addresses - Remove")
        pwrite(per,"[1] Gate Addresses")
        pwrite(per," ")
        pwrite(per,"[2] By Serial")
        pwrite(per,"[3] By Name")
      end,
      options = {"main","gate_remove_serial","gate_remove_name"},
    },
      ["gate_remove_serial"] = {
        run = function(per)
          header(per,"Gate Addresses - Remove - Serial")
          
          write("Gate Serial to remove: ")
          gser = read()
          
          if db.gateList[gser] then
            db.gateList[gser] = nil
            saveDB(dbFName, db)
            pwrite(per,"Removed.")
          else
            pwrite(per,"Gate not found.")
          end
          pwrite(per,"")
          write("Press enter to continue...")
          read()          
        end,
      },
      ["gate_remove_name"] = {
        run = function(per)
          header(per,"Gate Addresses - Remove - Name")
          
          write("Gate Name: ")
          gname = string.lower(read())
          
          for i,v in pairs(db.gateList) do
            lowern = string.lower(v.name)
            if string.find(lowern,gname) then
              gser = i
            end
          end
          
          pwrite(per,"")
          
          if db.gateList[gser] then
            db.gateList[gser] = nil
            saveDB(dbFName, db)
            pwrite(per,"Removed.")
          else
            pwrite(per,"Gate not found.")
          end         
          
          pwrite(per,"")
          write("Press enter to continue...")
          read()          
        end,
      },
}
  
--Loop
local function stopHelper()
  while true do
    e = os.pullEvent("start_helper")
    repeat
      e = os.pullEvent()
    until e == "stop_helper" or e == "monitor_touch"
    if e == "monitor_touch" then
      star.disconnect()
      sleep(5)
    end
  end
end
local function terminal()
  state = "main"
  lstate = "main"
  while true do
    os.queueEvent("refresh")
    cs(term)  
    if term_gui[state].run then
      term_gui[state].run(term)
      state = lstate
    end
    cs(term)
    
    term_gui[state].draw(term)
    eve,par1,par2,par3,par4 = os.pullEvent("char")
    
    if eve == "char" then
      key = par1
      if tonumber(key) then
        key = tonumber(key)
        if key <= #term_gui[state].options and key > 0 then
          lstate = state
          state = term_gui[state].options[key]
        end     
      end
    end
  end
end
local function monitors()
  local mon
  while true do
    mod = 1
    db.buttons = {}
    for i,v in pairs(mons) do
      mon = peripheral.wrap(v)
      cs(mon) cc(mon)
      tab_gui(mon, db.gateList, v)
      cpage = cpage + 1
    end
    
    ep,par1,par2,par3,par4 = os.pullEvent()
    
    if ep == "monitor_touch" then
      ep,tper,xp,yp = ep,par1,par2,par3
      for name,data in pairs(db.buttons) do
        if (data.monitor == tper) and (data.line == yp) then
          for i,v in pairs(mons) do
            mon = peripheral.wrap(v)
            local x,y = mon.getSize()
            cc(mon) cs(mon)
            wCent("[Operation Active]",mon, y/2)
          end
          mon = peripheral.wrap(tper)
          tab_popup(mon, name)
        end
      end
    end
    if ep == "sgIncoming" then
      local gid = par1
      for i,v in pairs(mons) do
        mon = peripheral.wrap(v)
        local x,y = mon.getSize()
        cc(mon) cs(mon)
        sc(mon,"white","red")
        wCent(" Warning - Incoming Wormhole ", mon, y/2 - 1)
        cc(mon)
        if db.gateList[gid] then
          wCent(gid..", ".. db.gateList[gid].name ..", ".. db.gateList[gid].owner  ,mon,y/2+1)
        else
          wCent(gid ,mon,y/2+3)
        end
        
        wCent("Tap to disconnect...",mon,y/2 + 3)
      end
      repeat
        os.startTimer(1)
        theE = os.pullEvent()
      until (star.isConnected() == false and star.isDialing() == false) or theE == "monitor_touch"
      star.disconnect()
    end
    if eq == "refresh" then
      sleep(0.1)
    end
  end
end

do -- A few tests
  cs(term)
  if autoUpdate then -- Check for update
    print("Checking for updates...")
    if gitUpdate("stargatetouch", shell.getRunningProgram(), Version) == true then
      print("Updates found, updating!")
      sleep(1)
      shell.run(shell.getRunningProgram())
    end
    sleep(1)
  end
  stargates = listPer("stargate")
  if #stargates < 1 then
    error("No Stargates found.")
    return
  end
  mons = listPer("monitor")
  if #mons < 1 then
    error("No monitors found.")
    return
  end
  
  if term.isColor() == false then
    print("Terminal and monitors must be coloured.")
    return exit
  end
  for i,v in pairs(mons) do
    mon = peripheral.wrap(v)
    if mon.isColor() == false then
      print("Terminal and monitors must be coloured.")
      return exit
    end
  end
end

if not fs.exists(dbFName) then
  db = {}
  db.gateList = {}
  db.buttons = {}
  saveDB(dbFName, db)
else
  db = loadDB(dbFName)
end

star = peripheral.wrap(stargates[1])
star.disconnect()

parallel.waitForAll(terminal,monitors,stopHelper)

--[[
  db
  -gateList
  --gid - string
  ---name - string
  ---owner - string
  ---allowed - boolean
  -buttons
  --name
  ---monitor - string
  ---line - string
]]--