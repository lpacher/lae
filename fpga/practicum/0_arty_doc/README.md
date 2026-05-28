
<div align="justify">

# Practicum 1
[[**Home**](https://github.com/lpacher/lae)] [[**Back**](https://github.com/lpacher/lae/tree/master/fpga/practicum)]

<br />

>
> **IMPORTANT NOTE**
>
> README files of this course are **better displayed** and **more readable** in the Web Browser
> if a **light theme** is adopted. Very likely by default you are using a "dark" appearance instead,
> however it is highly recommended to switch to "light" the theme of your browser for reading.
>
> As an example, in _Google Chrome_ you can change this with _Customize Chrome > Appearance > Light Mode_.
>

<br />

## Contents

* [**Introduction**](#introduction)
* [**Practicum aims**](#practicum-aims)
* [**Reference documentation**](#reference-documentation)
* [**Navigate to the practicum directory**](#navigate-to-the-practicum-directory)

<br />
<!--------------------------------------------------------------------->


## Introduction
[**[Contents]**](#contents)

<br />
<!--------------------------------------------------------------------->


## Practicum aims
[**[Contents]**](#contents)

This introductory practicum should exercise the following concepts:

* locate Digilent Arty A7 development board reference documentation

</div>


## Reference documentation
[**[Contents]**](#contents)

All reference documents are open and freely available on Digilent website:


* _Arty Reference Manual_ <br />
  <https://reference.digilentinc.com/reference/programmable-logic/arty/reference-manual> <br />
  <https://reference.digilentinc.com/reference/programmable-logic/arty-a7/reference-manual>

* _Arty Programming Guide_ <br />
   <https://reference.digilentinc.com/learn/programmable-logic/tutorials/arty-programming-guide/start>

* _Board Schematics_ <br />
  <https://reference.digilentinc.com/_media/reference/programmable-logic/arty/arty_sch.pdf> <br />
  <https://reference.digilentinc.com/_media/reference/programmable-logic/arty-a7/arty_a7_sch.pdf>

<br />

PDF copies of all above documents are also part of this practicum and are available in the `doc/arty/` directory.
For faster access to PDF documents from the command line it would be recommended to include in the search path
of your operating system also the executable of your preferred PDF viewer application.

Very likely Windows users have **Adobe Acrobat Reader** program already installed on their machines and
can update the `PATH` environment variable in the `login.bat` script in order to include the `Acrobat.exe`
(or `Acrord32.exe`) executable in the search path as follows:

```
:: add Adobe Acrobat Reader executable to search path
set PATH="C:\Program Files\Adobe\Acrobat DC\Acrobat";%PATH%       :: check the proper installation directory
```

<br />

Do not forget to save and re-load the script once done:

```
% call login.bat
```

<br />

Once the executable is in the search path you can easily open a PDF document from the Windows _Command Prompt_ with:


```
% acrobat doc/arty/arty_board_reference_manual.pdf
```

<br />


```
% which evince
/usr/bin/evince

% evince doc/arty/arty_board_reference_manual.pdf &
```

<br />

The Evince PDF viewer is also available for Windows systems and can be installed from the [official website](https://evince.en.uptodown.com/windows).
If you prefer a non-administrator installation a `.zip` of the software is also available at:

_<https://www.to.infn.it/~pacher/teaching/FPGA/software/windows/Evince.zip>_

<br />

>
> **NOTE**
>
> You can quickly download and extract the provided zip file from the Command Prompt using `wget` and `unzip` utilities as follows:
>
> ```
> % cd C:\Users\<username>
> % mkdir -p local
> % cd local
> % wget --no-check-certificate https://www.to.infn.it/~pacher/teaching/FPGA/software/windows/Evince.zip
> % unzip Evince.zip
> % rm Evince.zip
> ```
>
> <br />
>
> After this, update your `login.bat` setup script in order to add the `evince.exe` executable to the search path:
>
> ```
> :: add Evince executable to search path
> set PATH=C:\Users\<username>\local\Evince\bin;%PATH%
>
> :: redirect garbage 'No display font' errors to NUL (but DosKey ignores the usual > redirection character, needs the $G special character for this)
> doskey evince=evince.exe $* $G nul
> ```
>
> <br />
>
> Do not forget to save and re-load the script once done:
>
> ```
> % call login.bat
> ```
