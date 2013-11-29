Version = 1.1
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
  term.setCursorPos((x/2) - (#text/2), line)
  term.write(text)
  if nextline then
    term.setCursorPos(1, nextline)
  end
end
function printLine(text, line, nextline)
  term.setCursorPos(1, line)
  term.write(string.rep(text, x))
  if nextline then
    term.setCursorPos(1, nextline)
  end
end

x,y = term.getSize()

term.clear()
printLine("-", 1)
printC(" Dark Retriever "..tostring(Version).." ", 1, 3)

write("-> Grabbing file...")
cat = getUrlFile("https://github.com/darkrising/darkprograms/raw/darkprograms/darksecurity/programVersions")
cat = textutils.unserialize(cat)
write(" Done.")

term.setCursorPos(1,5)

programs = {}
for name,data in pairs(cat) do
  table.insert(programs, name)
end

for number,name in pairs(programs) do
  print("["..number.."]".." "..name)
end

print("\nPress a number on the keyboard to download the selected program.")

event, char = os.pullEvent("char")
char = tonumber(char)
if programs[char] then
  print("\nSelected: "..programs[char])
  program = getUrlFile(cat[programs[char]].GitURL)
  writeFile(programs[char], program)
  print("\nDownloaded "..programs[char])
  print("You can run it by typing chat")
  print("Thanks for using Dark Retriever!")
end
