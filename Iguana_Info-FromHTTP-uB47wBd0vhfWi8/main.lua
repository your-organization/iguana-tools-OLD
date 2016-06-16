-- Use the iguana.info module to return the build information for the 
-- Iguana instance. This includes the operating system, CPU bit size 
-- and Iguana version

-- http://help.interfaceware.com/v6/iguana-info 

require 'iguana.info'

function main(Data)
   
   -- get a table of build info (operating system, CPU bit size -- and Iguana version)
   local Info = iguana.info()
   
   -- concatenate build info into a string "Body"
   local Body = "Iguana version   : "..Info.major.."."..Info.minor.."."..Info.build.."\n"
   Body = Body.."Operating System : "..Info.os.."\n"
   Body = Body.."CPU Type         : "..Info.cpu.."\n"
   trace(Body)
   
   -- display the build info on a webpage which is specified 
   -- in the From HTTP Source properties for the channel 
   net.http.respond{body=Body, entity_type="text/plain"}
end