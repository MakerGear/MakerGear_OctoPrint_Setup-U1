; Configuration file for Duet Ethernet 
; Rev 15 12/1/2022 GB/JW
; executed by the firmware on start-up
; Rev 15 - Rev.1 updates and reformatted config
; Rev 14 - acceleration adjusment + temp limits
; Rev 13 - more speed adjusments
; Rev 12 - Many differenet changes tweaking settings (probing, temps)
; Rev 11 - changed the M208 Z maximum distance back to 350mm, from testing 50mm.  Changed by JW on KG direction.

; General preferences
M111 S0 							 ; Debugging off
G90                                  ; Send absolute coordinates...
M83                                  ; ...but relative extruder moves

; Set firmware compatibility to look like marlin
M555 P2         

; Network
M550 PU1P3              ; Set machine name
M551 Pftppass           ; Set Duet Web Control Password
M552 S1 P172.16.31.5    ; Set IP address, enable network interface
M553 P255.255.255.0     ; Set Netmask
M554 P172.16.31.4       ; Set Gateway
M586 P0 S1              ; Enable HTTP
M586 P1 S1              ; Enable FTP
M586 P2 S1              ; Enable Telnet

; Stepper Drivers
M569 P0 S1    ; Stepper driver 0 goes forwards (EXT0)
M569 P1 S0    ; Stepper driver 1 goes forwards (X1/defined as "U")
M569 P2 S0    ; Stepper driver 2 goes backwards (X0)
M569 P3 S1    ; Stepper driver 3 goes forwards (Z0)
M569 P4 S1    ; Stepper driver 4 goes forwards (Z1)
M569 P5 S0    ; Stepper driver 5 goes forwards (Y)
M569 P6 S1    ; Stepper driver 6 goes forwards (Y)
M569 P7 S1    ; Stepper driver 7 goes forwards (EXT1)
M569 P8 S1    ; Stepper driver 8 goes forwards (Z)
M569 P9 S1    ; Stepper driver 9 goes forwards (Z)

M584 X2 Y5:6 Z3:4:8:9 U1 E0:7 		 		  ; Apply custom drive mapping
M350 X16 Y16 Z16 U16 E16:16 I1           	  ; Configure microstepping with interpolation
M92 X80.1 Y80.1 U80.1 Z1007.7 E471.5:471.5    ; Set steps per mm
M566 X100 Y100 Z60 U100 E120:120          	  ; Set maximum instantaneous speed changes (mm/min)
M203 X18000 Y18000 Z600 U18000 E1800:1800 	  ; Set maximum speeds (mm/min)
M201 X1000 Y1000 Z10 U1200 E2000:2000 		  ; Set accelerations (mm/s^2)
M204 P2000 T2000							  ; Max travel and priunting acceleration overide
M906 X1450 Y1450 Z1450 U1450 E950:950 		  ; Set motor currents (mA) and motor idle factor in percent
M84 S0 										  ; Disable motor idle current reduction
	
; Axis Limits
M208 X-71.3 Y11 Z0 U0 S1 	   ; Set axis minima
M208 X410 Y340 Z350 U457 S0    ; Set axis maxima

; Endstops
M574 X1 Y2 U2 S1    ; Set active high endstops

; Z-Probe
M574 Z1 S2                        ; Set endstops controlled by probe
M307 H7 A-1 C-1 D-1               ; Disable 7th heater on PWM channel for BLTouch
M307 H3 A-1 C-1 D-1               ; Disable 7th heater on PWM channel for BLTouch
M558 P9 H4 F400 T8000 B1 A2 S1    ; Set Z probe type to bltouch and the dive height + speeds
G31 P25 X21.0 Y0.0 Z0.0 U0.0      ; Set Z probe trigger value, offset and trigger height
M557 X15:390 Y15:340 S75:65       ; Define mesh grid

; Four Corner Z-Motor Points for Auto Leveling
M671 X-131.6482:550.7482:-131.6482:550.7482 Y546.1:546.1:-76.2:-76.2 S4

; Heaters
; Heated Build Plate = Heater #0
M140 P0 H0		                     ; Heated Build Plate ~ Tie the bed (H0) heater and thermistor to P0 as a bed heater
M305 P0 R4700 T100000 B4138 C0       ; Set thermistor + ADC parameters for heater 0
M143 H0 S120                         ; Set temperature limit for heater 0 to 120C. AC BED SDC

; Extrduer Heater 0 = Heater #1
M305 P1 T100000 B4138 C0 R4700       ; Set thermistor + ADC parameters for heater 1
M143 H1 S310                         ; Set temperature limit for heater 1 to 310C
M307 H1 A340.0 C140.0 D5.5 S1.00 V0.0 B0 ; PID settings


; Extrduer Heater 1 = Heater #2
M305 P2 T100000 B4138 C0 R4700       ; Set thermistor + ADC parameters for heater 2
M143 H2 S310                         ; Set temperature limit for heater 2 to 310C
M307 H2 A340.0 C140.0 D5.5 S1.00 V0.0 B0 ; PID settings

; Heater Fault Detection
M570 H0 S1200
M307 H0 A90.0 C700.0 D10.0 B1

; Fans
M106 P0 S0 I0 F500 H-1 C"T0F0"             			  ; T0 Fan0          Set fan 0 value, PWM signal inversion and frequency. Thermostatic control is turned off
M106 P1 S1.0 I0 F500 H1 T45  C"T0F1"         		  ; T0 Fan1          Set fan 100% value, PWM signal inversion and frequency. Thermostatic control is turned on
M106 P2 S0 I0 F500 H-1  C"ENCLOSURE"          		  ; Enclosure Fan    Set fan 0 value, PWM signal inversion and frequency. Thermostatic control is turned off
M106 P3 S0 I0 F500 H-1  C"T1F0"                       ; T1 Fan0          Set fan 0 value, PWM signal inversion and frequency. Thermostatic control is turned off
M106 P4 S1.0 I0 F500 H2 T45   C"T1F1"                 ; T1 Fan1          Set fan 100% value, PWM signal inversion and frequency. Thermostatic control is turned on
M106 P7 S1.0 I0 F500 H-1   C"ELECTRONICS0"            ; Electronics Fan0    Set fan 100% value, PWM signal inversion and frequency. Thermostatic control is turned off
M106 P8 S1.0 I0 F500 H-1   C"ELECTRONICS1"            ; Electronics Fan1    Set fan 100% value, PWM signal inversion and frequency. Thermostatic control is turned off

; Tools
M563 P0 D0 H1 F0                           ; Define Tool_0
G10 P0 X0.0 Y0.0 Z0.0                      ; Set Tool_0 axis offsets
G10 P0 R0 S0                               ; Set initial Tool_0 active and standby temperatures to 0C
M563 P1 D1 H2 X3 F3                        ; Define Tool_1
G10 P1 U0.0 Y0.0 Z0.00                     ; Set Tool_1 axis offsets 
G10 P1 R0 S0                               ; Set initial Tool_1 active and standby temperatures to 0C

; Duplication Mode
; Tool_2 uses both extruders and hot end heaters, maps X to both X and U, and uses both print cooling fans
M563 P2 D0:1 H1:2 X0:3 F0:3
G10 P2 X0 Y0 U-203.2                        ; Set tool offsets and temperatures for Tool_2
G10 P2 R0 S0                                ; Set initial Tool_2 active and standby temperatures to 0C
M567 P2 E1:1                                ; set mix ratio 100% on both extruders
M568 P2 S1                                  ; turn on mixing for Tool_2

; Z-Motor Stall Detection
M915 Z S3 F0 ; low z value, no filtering - for checking if we bottom out on Z

; Run-out Sensor Triggers
M581 T3 E3 C0 S0 ; Trigger 3, e3 endstop, always trigger/look, rising edge (filament out)
M581 T4 E3 C0 S1 ; Trigger 4, e3 endstop, always trigger/look, falling edge(filament in)
M581 T5 E4 C0 S0 ; Trigger 4, e4 endstop, always trigger/look, rising edge(filament out)
M581 T6 E4 C0 S1 ; Trigger 4, e4 endstop, always trigger/look, falling edge(filament in)

M501             ; Read stored parameters
T0               ; Set active extruder to Tool_0