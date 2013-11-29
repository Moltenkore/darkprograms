Version = 1.11
x,y = term.getSize()
if not http then
  print("Herp derp, forget to enable http?")
  return exit
end
function getUrlFile(url)
  local mrHttpFile = http.get(url)
  mrHttpFile = mrHttpFile.readAll()
  return mrHttpFile
end
function writeFile(filename, data)
  local file = fs.open(filename, "w")
  file.write(data)
  file.close()
end
function printC(text, line, nextline)
  if term.isColor() then
    term.setBackgroundColor(colors.blue)
    term.setTextColor(colors.yellow)
  end  
  term.setCursorPos((x/2) - (#text/2), line)
  term.write(text)
  if term.isColor() then
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
  end
  if nextline then
    term.setCursorPos(1, nextline)
  end
end
function printLine(text, line, nextline)
  if term.isColor() then
    term.setBackgroundColor(colors.blue)
    text = " "
  end  
  term.setCursorPos(1, line)
  term.write(string.rep(text, x))
  if term.isColor() then
    term.setBackgroundColor(colors.black)
  end
  if nextline then
    term.setCursorPos(1, nextline)
  end
end

x,y = term.getSize()

term.clear()
printLine("-", 1)
printC(" Dark Retriever "..tostring(Version).." ", 1, 3)

write("-> Grabbing file...")
cat = getUrlFile("https://raw.github.com/darkrising/darkprograms/darkprograms/programVersions")
cat = textutils.unserialize(cat)
write(" Done.")

term.setCursorPos(1,5)

programs = {}
pname = {}
for name,data in pairs(cat) do
  table.insert(pname, data.Name .." ".. data.Version)
  table.insert(programs, name)
end
for number,name in pairs(pname) do
  print("["..number.."]".." "..name)
end

print("\nPress a number on the keyboard to download the selected program. Or press 'Q' to exit.")

event, char = os.pullEvent("char")
char = tonumber(char)
if programs[char] then
  print("\nSelected: "..programs[char])
  program = getUrlFile(cat[programs[char]].GitURL)
  writeFile(programs[char], program)
  print("\nDownloaded "..programs[char])
  if cat[programs[char]].Type == "program" then
    print("You can run it by typing: "..programs[char])
  end
  print("Thanks for using Dark Retriever!")
else
  print("\nExiting!")
end