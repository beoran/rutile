--
-- Premake 4.x build configuration script
-- 

--
-- Define the project. Put the release configuration first so it will be the
-- default when folks build using the makefile. That way they don't have to 
-- worry about the /scripts argument and all that.
--

	solution "Rutile"
		configurations { "Debug", "Release", "Static" }
	
	project "Rutile"
		targetname  "rutile"
		language    "C"
		kind        "ConsoleApp"
		flags       { "ExtraWarnings"}
		
		includedirs { "include", 
                }

		libdirs     { "/usr/lib/i386-linux-gnu" }
		links       { "m"                       }
		
		files {
			"*.txt", "**.lua", "include/**.h", "src/**.c",
		}

		configuration "Debug"
			targetdir   "bin"
			defines     "CONFIG_DEBUG"
			flags       { "Symbols" }
			
		configuration "Release"
			targetdir   "bin"
			defines     "NDEBUG"
			flags       { "OptimizeSize" }
			
		configuration "Static"
		  flags       { "StaticRuntime" }
		  

--[[	
    configuration "linux"
			defines     { "LUA_USE_POSIX", "LUA_USE_DLOPEN" }
			links       { "m", "dl" } 
			
		configuration "macosx"
			defines     { "LUA_USE_MACOSX" }
			
		configuration { "macosx", "gmake" }
			buildoptions { "-mmacosx-version-min=10.1" }
			linkoptions { "-lstdc++-static", "-mmacosx-version-min=10.1" }

		configuration { "not windows", "not solaris" }
			linkoptions { "-rdynamic" }
			
		configuration { "solaris" }
			linkoptions { "-Wl,--export-dynamic" }
]]


--
-- A more thorough cleanup.
--
	if _ACTION == "clean" then
		os.rmdir("bin")
		os.rmdir("build")
	end
	
