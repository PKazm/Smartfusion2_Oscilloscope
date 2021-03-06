# Smartfusion2_Oscilloscope
 An Oscilloscope with as much of the design contained within the FPGA as possible.
 
 Spectrum Analyzer diagram:

![Spectrum Analyzer System](Oscilloscope/EXTRA%20FILES/Block%20Diagrams/Spect_Analyzer_Block_Diagram.png)

* LUT: 2069
* DFF: 934
* uSRAM: 10
* LSRAM: 4
* Math: 3
* Est Freq: 120Mhz (limitation in CoreABC)

## Analog to Digital

[Dev Repo](https://github.com/PKazm/vhdl-experiments/tree/master/Delta_Sigma_ADC)

The ADC for this oscilloscope is a custom Sigma-Delta (Delta-Sigma) design with a simple averaging filter on the output data. Components outside the FPGA can be as little as 1 capacitor and 1 resistor in a low pass filter configuration. More complicated (slightly) analog configurations would allow tunable voltage ranges and perhaps cleaner input data.

The main specifications are the limit to a 50Mhz over sampling frequency. Given a desired 8 bit data width the raw sample rate would be 195Khz. This may be reduced further depending on the digital low pass filter.

## Sample Memory

This oscilloscope will not be so large as to require more memory than is available in the FPGA fabric. To that end, filtered ADC samples will be stored in a LSRAM block. Exactly how much sample memory I need is yet to be determined but both the LCD and FFT will be operating on a sample count that easily fits within a single LSRAM. If I find a use for storing more I may incorporate the SPI flash memory on the dev-kit board or the eNVM RAM in the Microprocessor Sub-System.

## The Fourier Transform

[Dev Repo](https://github.com/PKazm/vhdl-experiments/tree/master/FFT_Core)

The ADC will feed the FFT core continuously. The FFT will be set to begin transforming samples whenever the input memory block is full. The transformed data will be available to be read 2 data sets later. Some manipulation of the FFT core is possible to reduce the latency if needed.

While there is an FFT core available from Microsemi, I do not have access to it. I am also not a Xilinx or Altera(Intel) user and therefore cores written for those platforms are unlikely to implement the hardware in a form compatible with my device. I additionally wanted an excuse to learn how to take a mathematical process relevant to digital signal processing and implement it in hardware. Therefore this FFT is custom made by me.

The transformed data will be in complex number format. I'm expecting the time to complete the transform to be far lower than the time to gather the samples.

## Complex Magnitude

[Dev Repo](https://github.com/PKazm/vhdl-experiments/tree/master/Complex_Magnitude)

The output of the FFT will be fed into this core to determine the magnitude of the complex number; aka the absolute value. I've looked into the following methods used to determine the complex magnitude of the FFT output:
* Pythagorean approach, based on a^2 + b^2 = c^2
* Alpha Max plus Beta Min, based on the approximation Mag ~= Alpha * max(|I|, |Q|) + Beta * min(|I|, |Q|)
* CORDIC, using the concept of zeroing out the phase (Q) and equating the magnitude with the real (I) component (notation is all over the place here).

The Pythagorean approach is straight forward math and would probably be the most accurate. This involves using a single Math block to calculate A*A + B*B and something else to calculate sqrt(C). Given I have more than enough fabric resources for this project I investigated using the CoreLNSQRT IP Core provided by Microsemi. Due to the encrypted nature of the core and my license I am unable to synthesize or simulate this core with VHDL (my HDL of choice). So that's out. Bummer.

Alpha Max plus Beta Min is very simple and works by selecting Alpha and Beta constants before hand and performing the previously mentioned equation. This is very easy and fast with the available hardware. The error is apparently within acceptable ranges for many applications so it would 100% work for mine, but I still have resources for "better" solutions.

CORDIC uses a ping-pong approximation approach in which the input values are manipulated to appear in a specific quadrant of the complex plane and then rotated above and below j=0 by adding and subtracting successively small rotations according to a prescribed algorithm. The results become more accurate with each iteration. The core provided for this function by Microsemi is not encrypted and I am able to use it within my project (yay). Or I would've except while testing to Core to integrate it into my project, I found almost all the outputs to be inaccurate. With the Core set to "Rectangular to Polar" mode, 2 inputs will be "graphed" onto the complex plain and then rotated until j=0. The result would be the phase (or change in phase) and the position along the X axis which directly correlates to the magnitude (with a gain as a result of the algorithm). When entering the values 6 and 6, the result was 18, when entering 7 and 7, the result was 9...

I chose the Alpha Max plus Beta Min approach.

The transformed and absolute valued sample blocks will be sent either to the LCD to view the frequency spectrum, or used by other logic to determine the carrier frequency of the analog signal and scale the displayed data accordingly.

## Edge Trigger

While the FFT results should give proper scaling, they provide no method to lock in a signal and prevent it from walking across the screen. This core will provide that functionality.

This core is not yet written.

## Pixel Bar Creator

This is a simple component that takes an unsigned value of any length and converts it to a line of pixels where the number of "on" pixels is related to the value of the entered number compared to its possible maximum. An example is a single column in a visual equalizer used in audio systems.

E.g.

8 bit value of 127 is exactly half of the maximum 8 bit value of 255, therefore the lower half of the pixel bar will be "on".
value of 63 would correspond with the lower 1/4 of the pixel bar being "on".

## LCD display

[Dev Repo](https://github.com/PKazm/vhdl-experiments/tree/master/Nokia5110_Driver_Block)

I have a Nokia5110 LCD which will display the output of the oscilloscope. Its incredibly slow, maxing out at about 4 FPS and is very low resolution at 84x48 pixels. But I own it and stuff.
