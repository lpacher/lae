<div align="justify">

# ROOT and PyROOT installation references

## Windows installation

Simply download and extract the pre-compiled `.zip` file already prepared for you.
If GNU Win is properly installed you can use `wget` and `unzip` utilities at the command
line as follows:

```
% cd C:\Users\<username>
% mkdir -p local
% cd local
% wget http://personalpages.to.infn.it/~pacher/teaching/FPGA/software/windows/ROOT.zip
% wget http://personalpages.to.infn.it/~pacher/teaching/FPGA/software/windows/Python.zip
% unzip ROOT.zip
% unzip Python.zip
```

<br />

Then update the `login.bat` initialization file with the following setup:

```
:: Python 2.7 setup
set PATH=C:\users\<username>\local\Python\2.7\x86;%PATH%

:: ROOT/PyROOT setup for data analysis
set ROOTSYS=C:\users\<username>\local\ROOT\5.34.32
call %ROOTSYS%\bin\thisroot.bat
set PYTHONPATH=%ROOTSYS%\bin;%PYTHONPATH%
```

<br />

Save and exit once done. Finally check if the `root.exe` executable is properly found
in the search path:

```
% call login
% where root
```

<br />

Fee free of course to change the target installation directory as usual, e.g. `C:\opt`
or `D:\local` etc. depending on your needs.

</div>
