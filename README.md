# CheekiJailbreeki
A 10.2.1 jailbreak for 64-bit devices, for all squatters and communists

*Please note: this is work in progress adopted into a xCode project with the right linker settings so it is easier to compile into an iPhone app for anyone but mainly meant for developers until it's finished. 

# Summary
- Sandbox bypass now works
- Added comments for convenience and capitalist noobs.
- Added music player
- Added Luca Todesco to the credits
- Fixed a vulnerability that Ian Beer left behind in the argv of the debugserver spawn code
- Improved logging
- Fixed an UI issue for the iPhone SE
- Fixed a logic issue
- Added NULL_PTR free checks to the post exploit code
- Added overflow checks to run_poc

# Jailbreakers of all nations unite!
- Add the offsets for kernelpatches for iOS 10.3.1 to speed up the progress
- Add code for setting a nonce on iOS 10.3.1
- Add code for 10.3.1 for gaining tfp0 (convert_task_to_port)
- Add a KPP-race for 10.3.1
- Add your DECOMPRESSED kernelcache of iOS 10.3.1 in a pull request, you can use kdump for it, find it under downloads at:  http://coffeebreakers.space/

# Will support
- iPhone SE (10.2.1)
- iPhone 6S / 6S+ (10.2.1)
- iPhone 6 / 6+ (10.2.1)
- iPhone 5S
- iPad devices (10.2.1 arm64)
- iPod devices (10.2.1 arm64)

# Does not support
- iPhone 8 (iPhone 8 will come with iOS 11)
- iPhone 7
- iPhone 7+
- 10.3.2+

# Might support
- 10.3
- 10.3.1
- 10.3.2 (When CVE-2017-7009 will be uncovered (public) or found.

# Will not support
32-bit devices

# Special thanks to
- Security Researcher Adam Donenfeld [@doadam](http://twitter.com/doadam) for opensourcing his IOSurface and AVEncoder exploits.
- Security Researcher Ian Beer from Google Project Zero for opensourcing his NSXPC exploit (triple_fetch).
- Security Researcher Coolstar [@coolstarorg](http://twitter.com/coolstarorg) for his patch-unpatch idea.
- Luca Todesco, for being a cool guy and previous jailbreaks.
- Karl Marx and Friedrich Engels, for creating the roots of communism.
- Boris Slav, for his great tutorials and videos.
- Vladimir Putin, for being a b0ss.
- Mila432, for adding more offsets to the exploit, thanks [Mila432](http://github.com/mila432/).

# Compilation instructions
- Download the project
- Go into the tripple_fetch folder

cd tripple_fetch_sdk

./build.sh

cp ziva1 ../nsxpc2pc

cp ziva1 ../nsxpc2pc/pocs/

open ../nsxpc2pc.xcodeproj

# To do
- Fix the yalu102 offsets
- Make the output of ziVA log to the debugger
- Make the world communistic
- For some reason my songs don't play random. Fix it and get credited. (:D)

# Extra
- If you have libimobiledevice installed you can run the debug-iphone to get a bit more debug output
- If you have libimobiledevice installed you can run reboot-iphone to restart your iphone when the exploit fails
