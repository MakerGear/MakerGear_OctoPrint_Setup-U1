#!/usr/bin/python

from __future__ import print_function
import RPi.GPIO as GPIO
import subprocess, time, socket
# import serial
# import shutil
# import pwd
# import grp
import os
import datetime
import sys

# eStopWatch - a script to run at boot, to watch a pin for our "E stop not activated" signal, and react once/if it goes away.
# Based on the GPIO polling version of the M3 resetWatch script.


# Change log
# Removed cruft from original version of this file, added " head -n1 | " to the eStopShutdown curl calls, to deal with the (I suspect unlikely) situation of there being multiple lines in config.yaml matching "key"; Josh, 9/7/2021


GPIO.setwarnings(False)

debugMode = False

buttonPin = 3
# buttonPin = 21 #this pin for testing without needing to trigger the physical estop - wire connecting (BCM) 9 to 25 (board 21 to 22), should be able to trigger remotely
# for testing without the reset/estop button - connect that wire, then call this command in terminal (need the "pigpio" GPIO package installed - https://abyz.me.uk/rpi/pigpio/download.html ):
# pi@U1Printer1X049:~ $ sudo pigs w 25 1 && sleep 2 && sudo pigs w 25 0
# pi@U1Printer1X049:~ $ sudo pigs w 25 1 && sleep 5 && sudo pigs w 25 0
# first command sets pin (BCM) 25 to output HIGH, waits 2 seconds, then sets 25 to output LOW; the second command does the same but with a 5 second wait, obvs.  These are set to be below and above the estopShutdownTime value below.

rebootHoldTime = 5     # Duration for button hold (shutdown)
resetPasswordHoldTime = 55     # Duration for button hold (shutdown)
sshHoldTime = 115     # Duration for button hold (shutdown)
tapTime = 0.1  # Debounce time for button taps
active = True # Simple flag that we'll check later - if it's set to False, stop checking for button input - we're already in an estop state and will be shutting down.

estopShutdownTime = 3 #Duration for reset button activation time, before we will start the shutdown process



def eStopShutdown():
	debugPrint("EStop button has been pressed for long enough, shutting down now.")
	globals()['active'] = False
	if not debugMode:
		# pass
		#do whatever shutdown process here
		# curl -XPOST -H "X-Api-Key: $(grep 'key' ~/.octoprint/config.yaml | sed 's/.*key: *//')" -H "Content-type: application/json" -d "{\"command\": \"M117 hello josh\"}" '127.0.0.1/api/printer/command'
		# escaped version courtesy of https://www.pythonescaper.com/
		# subprocess.call("curl -XPOST -H \"X-Api-Key: $(grep \'key\' ~/.octoprint/config.yaml | sed \'s/.*key: *//\')\" -H \"Content-type: application/json\" -d \"{\\\"command\\\": \\\"M117 hello josh\\\"}\" \'127.0.0.1/api/printer/command\'", shell = True)
		subprocess.call("curl -XPOST -H \"X-Api-Key: $(grep \'key\' /home/pi/.octoprint/config.yaml | head -n1 | sed \'s/.*key: *//\')\" -H \"Content-type: application/json\" -d \"{\\\"command\\\": \\\"M112\\\"}\" \'127.0.0.1/api/printer/command\'", shell = True)
		subprocess.call("curl -XPOST -H \"X-Api-Key: $(grep \'key\' /home/pi/.octoprint/config.yaml | head -n1 | sed \'s/.*key: *//\')\" -H \"Content-type: application/json\" -d \"{\\\"command\\\": \\\"cancel\\\"}\" \'127.0.0.1/api/job\'", shell = True)
		subprocess.call("sync")
		subprocess.call(["shutdown", "-h", "now"])


	else:


		debugPrint("Except cancel that, as we're debugging.")

def debugPrint(message):
	if debugMode and message is not None:
		print(str(message))

# Initialization

# Use Broadcom pin numbers (not Raspberry Pi pin numbers) for GPIO
GPIO.setmode(GPIO.BOARD)

# Enable LED and button (w/pull-up on latter)
GPIO.setup(buttonPin, GPIO.IN, pull_up_down=GPIO.PUD_UP)


# Poll initial button state and time
prevButtonState = GPIO.input(buttonPin)
prevTime        = time.time()

elapsed = 0.0



# GPIO wait_for_edge info:
# wait_for_edge(...)
#     Wait for an edge.  Returns the channel number or None on timeout.
#     channel      - either board pin number or BCM number depending on which mode is set.
#     edge         - RISING, FALLING or BOTH
#     [bouncetime] - time allowed between calls to allow for switchbounce
#     [timeout]    - timeout in ms



# Main loop
while(True):
	if active:
		# debugPrint("active")

		triggered = GPIO.wait_for_edge(buttonPin, GPIO.BOTH, timeout=1000)

		# Poll current button state and time
		buttonState = GPIO.input(buttonPin)
		t           = time.time()

		# Alright, so basic plan for new implementation - use wait_for_edge with a 1S timeout; if no trigger before timeout, and button is currently pressed, increment elapsed and record previous time and button state; if not triggered, and button is not pressed...pass?
		# If we're triggered, however - if pressed (falling), reset elapsed/etc. and start counting; if not pressed (rising), check if elapsed is >= our various action times, and perform whatever actions are required:
		# reboot (shutdown...), reset password, etc.


		if triggered is None:
			# debugPrint("triggered is None")
			# not triggered before the 1S timeout - so either button is being held for an action, or not pressed at all
			if buttonState:
				# debugPrint("buttonState")
				# button is being held - update elapsed time
				elapsed += t - prevTime
				prevTime = t
				debugPrint("Button is pressed, but did not trigger this cycle - must be held.  Elapsed time: {}".format(str(elapsed)))
				if elapsed >= estopShutdownTime:

					eStopShutdown()

			else:
				# debugPrint("not buttonState")
				# button is not being held - this is the state 99.999999....9% of the time, so ignore
				pass

		else:
			# debugPrint("triggered is not None")
			# rising or falling edge was detected on the reset button
			if buttonState:
				# debugPrint("buttonState")
				debugPrint("Button pressed, and triggered this cycle - must have been pressed.  Elapsed time: {}".format(str(elapsed)))
				# button is currently pressed, so was a rising edge - reset the elapsed timer so we can start accumulating this press time
				elapsed = 0.0
				prevTime = t
			else:
				# debugPrint("not buttonState")
				elapsed += t - prevTime
				prevTime = t
				# button is currently not pressed, so was a falling edge - check how much time has elapsed since the button was first pressed, and perform whatever action is indicated by that time
				# if elapsed <= tapTime:
				# 	debugPrint("Button released, but elapsed time less than tapTime: {}".format(str(elapsed)))
				# 	# first check if elapsed is less than the tap time - software debounce
				# 	elapsed = 0.0
				# 	pass

				# elif elapsed >= estopShutdownTime:
				# 	eStopShutdown()


				if elapsed <= estopShutdownTime:
					debugPrint("Button released, but elapsed time less than estopShutdownTime: {}; calling this a transient and resetting.".format(str(estopShutdownTime)))
					elapsed = 0.0



				# else:
				# 	debugPrint("Button ")
