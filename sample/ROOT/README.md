<div align="justify">

# ROOT quick references

## Quick installation (Windows)

Simply download and extract the pre-compiled `.zip` file already prepared for you.
If GNU Win is properly installed you can use `wget` and `unzip` utilities at the command
line as follows:

```
% mkdir -p C:\users\<username>\local
% cd C:\users\<username>\local
% wget http://personalpages.to.infn.it/~pacher/teaching/FPGA/software/windows/ROOT.zip
% unzip ROOT.zip
```

<br />

Then update the `login.bat` initialization file with the following setup:

```
:: ROOT package setup for data analysis
set ROOTSYS=C:\users\<username>\local\ROOT\5.34.32
call %ROOTSYS%\bin\thisroot.bat
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
