NOTE: This is an ongoing development and therefore the documentation is not yet finalised.

# Nonlinear flutter rejection filter #

The purpose of this filter is to suppress fast and small-amplitude variations in the estimate of the output; thus, the estimate is smoothed and the motors of the output-device are relieved of oscillating actuations. This improves the stability of the prosthesis control, as the actuation estimates are kept constant for small variations in the estimate of the input to the motors <sup>[1]</sup>.

## Details ##
For details around the filter, see the nonlinear flutter rejection filter in the figure on the [front page](NTNU.md) of the NTNU contribution. The only thing to notice, is that the nonlinearity in the filter is defined by y = |x| tanh(k x).

The code is implemented within the function called _NonlinearFlutterRejectionFilter_, and is located inside the proportional control folder.

# References #
  1. Fougner, Anders. Robust, Coordinated and Proportional Myoelectric Control of Upper-Limb Prostheses. Diss. Norwegian University of Science and Technology, 2013.