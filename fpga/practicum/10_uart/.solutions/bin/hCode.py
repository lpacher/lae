##
## Read on-die temperature values from XADC and histogram ADC codes into a refreshing ROOT histogram.
##
## Luca Pacher - pacher@to.infn.it
## Spring 2020
##

import ROOT

import os
import sys
import serial
import time


## ROOT components
try :

   import ROOT

except ImportError :

   print("\n**ERROR: ROOT components are required to run this application!\n")

   if( os.name == 'nt') :
           print("           call %ROOTSYS%\bin\thisroot.bat might solve this problem.\n")
   else :
           print("           source $ROOTSYS/bin/thisroot.(c)sh might solve this problem.\n")

   ## script failure
   raise SystemExit




###############################
##  parse serial port name   ##
###############################

## specify serial port at the command line...
if ( len(sys.argv) > 1) :

   PORT = sys.argv[1]

## assume default port values otherwise
else :

   if( os.name == 'nt') :

      PORT = "COM10"

   else :

      PORT = "/dev/ttyUSB1"



################################
##   open serial connection   ##
################################

s = serial.Serial()

s.port      = PORT                     # target port for connection
s.baudrate  = 9600                     # Baud rate
s.bytesize  = serial.EIGHTBITS         # number of payload bits per byte
s.parity    = serial.PARITY_NONE       # enable/disable parity check
s.stopbits  = serial.STOPBITS_ONE      # number of stop bits
s.timeout   = None                     # timeout in seconds
s.xonoff    = False                    # enable/disable software flow control
s.rtscts    = False                    # enable/disable RTS/CTS hardware flow control
s.dsrdtr    = False                    # enable/disable DSR/DTR hardware flow control

try :

   s.open()

except :

   print "\n**ERROR: Cannot open serial connection to %s!\n" % PORT

   ## script failure
   raise SystemExit


################################
##   histogram of ADC codes   ##
################################

ROOT.gROOT.SetStyle("Plain")

hCode = ROOT.TH1F("hCode","", 4096, -0.5, 4095.5) ;   ## **NOTE: the XADC is a 12-bit ADC

hCode.Draw()

## axis
hCode.GetXaxis().SetTitle("ADC code")
hCode.GetYaxis().SetTitle("entries")
hCode.GetYaxis().CenterTitle()

ROOT.gPad.SetGridx()
ROOT.gPad.SetGridy()
ROOT.gPad.Modified()
ROOT.gPad.Update()


###################################
##  main data acquisition loop   ##
###################################

## loop until a Ctrl-C interrupt is issued at the command line

i = 1

while(1) :

   try :

      ## read 2 bytes each time
      rx_data = s.read(2)

      ## **DEBUG
      #print(rx_data.encode("hex"))
      #print int(rx_data.encode("hex"),16)

      adcCode = int(rx_data.encode("hex"),16)

      ## compute the temperature in Celius degrees (ref. to XADC User Guide)
      temperature = (adcCode*503.975)/4096 -273.15

      ## console output
      print "Measured on-die temperature: %.2f C" % temperature

      ## fill the histogram with ADC code
      hCode.Fill(adcCode)

      ## refresh the ROOT histogram every 10 acquisitions
      if( i%10 == 0) :

         ROOT.gPad.Modified()
         ROOT.gPad.Update()

      i = i+1


   ## catch a Ctrl-C interrupt to safely exit from the while loop
   except KeyboardInterrupt :

      print "\nBye!\n" ; time.sleep(0.5)
      break


## close the serial connection
s.close()

## save the histogram into a ROOT file
f = ROOT.TFile("hCode.root","RECREATE")
hCode.Write()
f.Close()

