Repository enhances the Calculix ccx (Version 2.23)  *AMPLITUDE functionality through an additional parameter „EQUATION" to enter a mathematical expression for a named amplitude in the ccx input file. Example:

*AMPLITUDE, NAME=CUBIC, EQUATION

T*T*T

+1.5*T*T

would create a polynomial amplitude named CUBIC over time T for use within the ccx inp file.

In case there is interest for this potential enhancement to ccx I would create a Pull Request on Github. As a further prerequisite for a Pull Request we would need some testing feedback from the ccx community to better judge on the achieved development quality and to fix community observed testing issues.
Benefits of equation string based *AMPLITUDE cards in ccx

This proposal to introduce equation string based amplitude definitions (like sin(t*2*pi)+3.*cos(t*4*pi) as an example) as an enhancement to the ccx *AMPLITUDE card is driven by multiple factors:

1) Commercial FEM programs offer additional amplitude card features like periodic amplitude or decaying amplitude types which haven’t been available with ccx in the past. Equation string amplitude definitions bridge this gap while enabling users for even more complex *AMPLITUDE related features.
2) Todays GUI based use of FEM programs through preprocessors would improve user productivity through string input fields for an equation based amplitude definition vs. the traditional time consuming tabular input of time and their corresponding amplitude values.
3) The current ccx tabular input requires the user to understand the needed increment between two amplitude values to ensure the needed amplitude value smoothness during the solution. However the understanding of the needed increment may only come during the analysis of the model, hence multiple and time consuming iterations of the *AMPLITUDE card details may be needed during the project. This productivity loss does not apply for amplitudes which can be expressed through mathematical equation strings.
4) Ccx already offers equation amplitude entry options through its subroutine uamplitude.f . However many FEM users being familiar with GUI based pre- and postprocessors may not have the needed FORTRAN and programming skills to compile and link a subroutine with a FORTRAN based equation amplitude to create their own ccx version with the needed equation amplitudes.
5) The parsing process of the amplitude equation string(s) during the model run needs additional time compared vs. a definition within the uamplitude() subroutine. However this increase of the overall solution time for a model is still insignificant vs. the time spent in any of the ccx solvers. Hence the risk of noticeable performance losses is very low when using equation string based amplitudes.

Compiling and validating the development

The attached code version is based on the official ccx version 2.23. To use the enhanced code for your own testing and validation please

1) Copy the files below the src directory of the attached zip file to a directory with your own ccx code of version 2.23. This will replace some source files, add one header file and 2 new C files.
2) Add the 2 new C files equamplitude.c and tinyexpr.c to your makefile.
3) Compile and link the code according to your standard compilation process to generate a new ccx version with this development.
3) Run some tests. The directory Tests of the attachment includes a subset of the executed tests to validate the new development. The inp files whose name include the substring „_equ" contain the examples with the equation strings. The counterpart files without the substring „_equ" are used to compare the equation string results vs. todays ccx standard *AMPLITUDE functionality. The available test documentation has been summarized in file Test_equ_strings_20260520.pdf

Using equation string based amplitudes within your ccx projects

The supported mathematical functions within the *AMPLITUDE equation are explained by the Github project https://github.com/codeplea/tinyexpr from where the equation parsing code was taken from. The only variable/character to be used in your mathematical expression to indicate the time dependency is „T". „T" is the only independent variable to be used as the ccx *AMPLITUDE card concept only allows the time as independent variable. You can input your equation string in lower or upper caps or as a mix of both. Ccx internally converts your string into upper case while the linked tinyexpr library for the handling and parsing process of the equation converts it again (to lower caps). So during ccx console output you may see the equation string in lower of upper caps depending on where the console output has been created.
Amplitude values of the equation are always of type double, not complex (which would include an imaginary component). Hence the imaginary unit i cannot be used within an amplitude equation. This follows the ccx concept of the *AMPLITUDE card and todays ccx internal data structures (and the capabilities of the used tinyexpr library).
    The handling (including the error handling) of the equation is done by the linked tinyexpr library. Error handling examples when parsing equation strings:
        Divisions by 0 do not produce a job abortion, but return a value -nan (not a number) back to the calling subroutine.
        Jobs with amplitudes being invalid throughout the entire step time (e.g. square root of negative time) may produce a result value 0.
        Only round brackets „(" „)" are allowed in the equation string. Curly brackets „{„ „}" and square brackets „[" „]" are not supported. In such cases an error on the console will be displayed similar to:

        Error in tinyexpr library for amplitude name SINUS                                                                          

        near equation string position 3 for equation string:

        sin{t/pi}    

    The maximum equation string length is 510 which can be distributed across multiple subsequent lines. There is no symbol needed at the end of a line to indicate a continuation of the equation in the next line. The general ccx limitation on the max. number of equation characters within a single line applies as well for the equation string.
    Do not use equation string amplitudes together with the SHIFTX or SHIFTY option. In such cases an error will be displayed on the console. If you need such a shift it is recommended to make the shift(s) part of your equation definition!
    The equation strings can be used in combination with other parameters like TIME RESET or TIME=TOTAL TIME.
    The equation strings are written to and read from the restart files. Therefore the restart file format has been extended to support the equation functionality.
    Ccx ignores all amplitudes within *BUCKLE steps as this procedures does not have a time period. This applies as well for equation string defined amplitudes.
    Equation amplitudes within a *STEADY STATE DYNAMICS steps use as well the variable name t for the frequency to keep the variable name unique across all procedure types.
