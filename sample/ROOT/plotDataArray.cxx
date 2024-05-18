//
// Simple un-named ROOT script to plot and fit a set of x-data vs. y-data stored
// on standard C/C++ arrays. 
//
// Execute the script at the ROOT command prompt with:
//
//    root[] .x plotDataArray.cxx
//
// Luca Pacher - pacher@to.infn.it
// Spring 2016
//


{
   gROOT->Reset() ;

   //
   // **NOTE
   // As a common practice, ROOT GUI objects are usually allocated on the HEAP with the C++ "new" operator
   // to ensure object persistence outside a program
   // In simple un-named scripts (interactive environment) static objects and dynamically-allocated objects 
   // with pointers are basically equivalent solutions
   //

   //TGraph  gr("/path/to/fileName.dat") ;
   //TGraph  *gr = new TGraph("/path/to/fileName.dat") ;

{

   gROOT->Reset() ;

   int Npts = 5 ;

   TGraph *gr = new TGraph(Npts) ;

   double xData[] = { 283    , 567    , 849    , 1133    , 1415     } ;                  // number of inverting stages in the loop
   double yData[] = { 3.35e6 , 2.11e6 , 1.42e6 , 1.088e6 , 836.8e3  } ;                  // measured toggle frequency

   for(int k=0; k < Npts; ++k) {

      //gr->SetPoint(k,xData[k],yData[k]) ;
      gr->SetPoint(k,1/xData[k],yData[k]) ;
   }

   // set marker size and style
   gr->SetMarkerStyle(21) ;
   gr->SetMarkerSize(0.8) ;
   
   
   // set line width and style
   //gr->SetLineWidth(1) ; 
   //gr->SetLineStyle(1) ; 
   
   // plot title
   gr->SetTitle("plot title") ;
   
   // x-axis setup
   gr->GetXaxis()->SetTitle("x-axis [unit]") ;
   gr->GetXaxis()->CenterTitle() ;
   //gr->GetXaxis()->SetRangeUser(...) ;
   //gr->GetXaxis()->SetNdivisions(...) ;
   //gr->GetXaxis()->SetTickLength(...) ;
   //gr->GetXaxis()->SetLabelOffset(...) ;
   //gr->GetXaxis()->SetLabelSize(...) ;  
   //gr->GetXaxis()->SetLabelFont(...) ; 
   //gr->GetXaxis()->SetTitleOffset(...) ;
   //gr->GetXaxis()->SetTitleSize(...) ;   
   //gr->GetXaxis()->SetTitleFont(...) ; 
   
   // y-axis setup
   gr->GetYaxis()->SetTitle("y-axis [unit]") ;
   gr->GetYaxis()->CenterTitle() ;   
   //gr->GetYaxis()->SetRangeUser(...) ;
   //gr->GetYaxis()->SetNdivisions(...) ;
   //gr->GetYaxis()->SetTickLength(...) ;
   //gr->GetYaxis()->SetLabelOffset(...) ;
   //gr->GetYaxis()->SetLabelSize(...) ;  
   //gr->GetYaxis()->SetLabelFont(...) ; 
   //gr->GetYaxis()->SetTitleOffset(...) ;
   //gr->GetYaxis()->SetTitleSize(...) ;   
   //gr->GetYaxis()->SetTitleFont(...) ; 

   gr->Draw("ALP") ;

}   // end script

