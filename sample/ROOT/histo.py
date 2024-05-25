#
# Minimal PyROOT script to test software installation.
# Command line usage:
#
#   % cd Desktop/lae
#   % python -i sample/ROOT/histo.py
#
#
# Luca Pacher - pacher@to.infn.it
# Spring 2020
#


## load ROOT components into Python 
import ROOT

Ntrials = 10000

histo = ROOT.TH1F("histo","MC example",100,-5,5)

## keep track of Poisson errors on bin entries
histo.Sumw2()

## generate normally-distributed random values
histo.FillRandom("gaus",Ntrials)

## normalize the distribution to unit area
histo.Scale(1.0/histo.GetEntries())

histo.Draw()

histo.Fit("gaus")

## display fit results
ROOT.gStyle.SetOptFit(1)

## save histogram to ROOT file
fout = ROOT.TFile("histo.root","RECREATE")

histo.Write()

fout.Close()
