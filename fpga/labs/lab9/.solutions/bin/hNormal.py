##===============================================================================================
## Simple PyROOT script to histogram normally-distributed pseudo-random values generated
## according to the Central Limit Theorem (CLT).
##
## Command line usage:
##
##   % cd /path/to/lab9
##   % python -i bin/hNormal.py
##
## By default the script assumes to process "work/sim/gaus.txt", but you can also start Python
## from another directory and specify a different target ASCII file. As an example:
##
##   % cd /path/to/lab9/work/sim
##   % python -i ../../bin/hNormal.py gaus.txt
##
## Luca Pacher - pacher@to.infn.it
## Spring 2020
##===============================================================================================

## Python standard libraries
import sys
import os
import math

## ROOT components
import ROOT

if ( len(sys.argv) > 1):
   ## specify input at the command line...
   fileName = sys.argv[1]
else:
   ## assume default path otherwise
   fileName = "work/sim/gaus.txt"

## check if file exists
if (os.path.exists(fileName)):
   ## open file handler
   filePtr = open(fileName,"r")
else:
   print "\n**ERROR: %s Not such file or directory. Force an exit now.\n" % fileName
   ## script failure
   sys.exit(1) ;


ROOT.gStyle.SetOptStat("emr") ;   #only show number of entries, mean and RMS in the statistics box
ROOT.gStyle.SetOptFit(1) ;        #display also fit results into stats box


## number of simulated random values
#Ntrials = 100000
Ntrials = 0

nMin = 0
nMax = 8188 ;   #the exact max. number achievable by summing 4x LFSR outputs is 4*(2^11 -1) = 8188 

nBins = 90 ;    #approx. sqrt(nMax)

## histogram for hardware-generated random numbers
hRandom = ROOT.TH1I("hRandom","",nBins,nMin,nMax)

hRandom.SetStats(0) ;  #temporary disable stat box

for line in filePtr:

   value = int(line.split("\n")[0])
   ## **DEBUG
   #print(value)
   Ntrials = Ntrial + 1
   hRandom.Fill(value)


## close file handler
filePtr.close()

## display histogram
hRandom.Draw()

## cosmetics
#hRandom.GetYaxis().SetRangeUser(0,4000)
ROOT.gPad.SetGrid()


########################################################
##   gaussian fit on hardware-generated random data   ##
########################################################

hRandom.Fit("gaus")

## cosmectics
fit = hRandom.GetFunction("gaus")

fit.SetLineWidth(2)
fit.SetLineColor(kBlue)

ROOT.gPad.Modified()
ROOT.gPad.Update()


############################################
##   compare with MonteCarlo (optional)   ##
############################################

##
## **NOTE
##
## From theory, for a uniform (flat) distribution between (a,b) we have:
##
## mu    = (a+b)/2
## sigma = (b-a)/sqrt(12)
##
## Assuming to use an 11-bit LFSR we can generate random numbers from 0 to Nmax = 2^11 -1 = 2047
## with uniform distribution between 0 and 2047, therefore:
##
## - the expected MEAN VALUE for each LFSR output code is simply Nmax/2 = 2047/2 = 1023.5
## - the expected STD DEVIATION for each LFSR output code is Nmax/sqrt(12) = 2047/sqrt(12) = 590.92 
##
## Therefore according to CLT we expect a normal distribution with mu = 4x 1023.5 = 4094
## and sigma = sqrt(4)*590.92 = 2*2047/sqrt(12) = 1182
##

#mu    = hRandom.GetMean()
#sigma = hRandom.GetRMS()

muUniform    = (0 + 2047)/2.
sigmaUniform = (0 + 2047)/math.sqrt(12)

## expected mu and sigma from CLT
mu    = 4*muUniform ;
sigma = sqrt(4)*sigmaUniform ;

## histogram from software-generated random numbers
hNormal = ROOT.TH1I("hNormal","",nBins,nMin,nMax) ;

## cosmetics
hNormal.SetStats(0)
hNormal.SetFillStyle(3001) ;   #use transparent fill
hNormal.SetFillColor(kYellow)

for i in range(Ntrials):
   hNormal.Fill(ROOT.gRandom.Gaus(mu,sigma))


hNormal.Draw("same") ;

## cosmetics
ROOT.gPad.RedrawAxis()

hRandom.SetStats(1)

## optionally, set y-axis log scale for easier HW-data vs. MC-data comparison
#ROOT.gPad.SetLogy()

ROOT.gPad.Modified()
ROOT.gPad.Update()

