//
// Simple ROOT macro to histogram normally-distributed pseudo-random values generated
// according to the Central Limit Theorem (CLT).
//
// Command line usage:
//
//   % cd /path/to/lab9
//   % root bin/hNormal.cxx
//
// By default the macro assumes to plot work/sim/gaus.txt, but you can also start ROOT
// from another directory and specify a different target ASCII file. As an example:
//
//   % cd /path/to/lab9/work/sim
//   % root
//   root[] .L ../../bin/hNormal.cxx
//   root[] hNormal("gaus.txt")
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//

void hNormal (char *fileName="work/sim/gaus.txt") {

   gROOT -> Reset() ;

   gStyle->SetOptStat("emr") ;   // only show number of entries, mean and RMS in the statistics box
   gStyle->SetOptFit(1) ;        // display also fit results into stats box


   int value ;   // integer pseudo-random value from ASCII file

   // open file handler
   ifstream filePtr ;

   filePtr.open(fileName) ;

   if (!filePtr) {

      std::cout << "\n**ERROR: " << fileName << " Not such file or directory. Force an exit now." << std::endl ;

      // script failure
      exit(1) ;
    }

   int Ntrials = 100000 ;   // number of simulated random values

   int nMin = 0 ;
   int nMax = 8188 ;   // the exact max. number achievable by summing 4x LFSR outputs is 4*(2^11 -1) = 8188 

   int nBins = 90 ;    // approx. sqrt(nMax)

   // histogram for hardware-generated random numbers
   TH1I *hRandom = new TH1I("hRandom","",nBins,nMin,nMax) ;

   hRandom->SetStats(0) ;  // temporary disable stat box

   while (filePtr >> value) {

      //std::cout << value << endl ;

      hRandom->Fill(value) ;

   }

   filePtr.close() ;

   // display histogram
   hRandom->Draw() ;

   // cosmetics
   //hRandom->GetYaxis()->SetRangeUser(0,4000) ;
   gPad->SetGrid() ;


   ////////////////////////////////////////////////////////
   //   gaussian fit on hardware-generated random data   //
   ////////////////////////////////////////////////////////

   hRandom->Fit("gaus") ;

   // cosmectics
   TF1 *fit = hRandom->GetFunction("gaus") ;

   fit->SetLineWidth(2) ;
   fit->SetLineColor(kBlue) ;

   gPad->Modified() ;
   gPad->Update() ;



   ////////////////////////////////////////////
   //   compare with MonteCarlo (optional)   //
   ////////////////////////////////////////////

   //
   // **NOTE
   //
   // From theory, for a uniform (flat) distribution between (a,b) we have:
   //
   // mu    = (a+b)/2
   // sigma = (b-a)/sqrt(12)
   //
   // Assuming to use an 11-bit LFSR we can generate random numbers from 0 to Nmax = 2^11 -1 = 2047
   // with uniform distribution between 0 and 2047, therefore:
   //
   // - the expected MEAN VALUE for each LFSR output code is simply Nmax/2 = 2047/2 = 1023.5
   // - the expected STD DEVIATION for each LFSR output code is Nmax/sqrt(12) = 2047/sqrt(12) = 590.92 
   //
   // Therefore according to CLT we expect a normal distribution with mu = 4x 1023.5 = 4094
   // and sigma = sqrt(4)*590.92 = 2*2047/sqrt(12) = 1182
   //

   //double mu    = hRandom->GetMean() ;
   //double sigma = hRandom->GetRMS() ;

   double muUniform    = (0 + 2047)/2. ;
   double sigmaUniform = (0 + 2047)/sqrt(12) ;

   // expected mu and sigma from CLT
   double mu    = 4*muUniform ;
   double sigma = sqrt(4)*sigmaUniform ;

   // histogram from software-generated random numbers
   TH1I *hNormal = new TH1I("hNormal","",nBins,nMin,nMax) ;

   // cosmetics
   hNormal->SetStats(0) ;
   hNormal->SetFillStyle(3001) ;      // use transparent fill
   hNormal->SetFillColor(kYellow) ;

   for(int i=0; i < Ntrials; ++i) {

      hNormal->Fill(gRandom->Gaus(mu,sigma)) ;
   }

   hNormal->Draw("same") ;

   // cosmetics
   gPad->RedrawAxis() ;

   hRandom->SetStats(1) ; 

   gPad->Modified() ;
   gPad->Update() ;

}
