# Device Control and Control Algorithms #

In the **control** folder routines for device/[VRE](VRE.md) control following the [Movements\_Protocol](Movements_Protocol.md) are provided, as well as control algorithms to be executed during realtime pattern recognition.

The control algorithms can be selected in the [GUI\_TestPatRec\_Mov2Mov](GUI_TestPatRec_Mov2Mov.md)

## Control algorithms ##

  * Majority vote
  * Buffer output


# How to add a new control algorithm in BioPatRec\_Ett #

To add a control algorithm you have to initialize it in:

  * InitControl

and then add the executing routine in:

  * ApplyControl

These two routines are called in the realtime patrec functions such as:

  * RealtimePatRec
  * MotionTest
  * [TACTest](TACTest.md)


# How to add a new control algorithm from BioPatRec\_TVÅ #

Future releases of BioPatRec will load control algorithms differently from the _BioPatRec ETT_ release. The new loading system will keep the GUI up to date with all available algorithms and also offer a quick way to change algorithm parameters.

The new loading system is managed with a text file, /Control/ValidControlAlgs.txt that contains the name of all available algorithms and a set of default parameters specific for each algorithm.

The control algorithms are loaded with InitControl.m that appends an inputted patRec structure with an associated controlAlg structure. If a patRec has an associated controlAlg structure it can be reached by the command patRec.controlAlg.

## Steps to implement new control algorithms ##

The following steps have to be made in order to be able to use a new control algorithm with BioPatRec.

  * Set up the algorithm and default parameters in ValidControlAlgs.txt
  * Name the routine file same as stated in ValidControlAlgs.txt
  * (Optional) Create an initialization file called Init'YourControlAlg'.m

## Initialization of control algorithms ##

When a control algorithm is initialized, a controlAlg struct is created. This structure contains by default the fields,

  * name
  * fnc

The name of the algorithm is read from ValidControlAlgs.txt and is stored in the name field. From the name, a function handle to the routine store in 'name'.m is created and stored in fnc. If any parameters are set in ValidControlAlgs.txt they are read and stored in an additional field called

  * parameters

The parameters stored in controlAlg.parameters can quickly be altered by
clicking the options-button in GUI\_TestPatRec\_Mov2Mov, the GUI that is used for real-time control.

The initialization process that are executed when a control algorithm is selected in the GUI also sets the field

  * patRec.outBuffer

The output buffer can be used by the control algorithms as they wish, and are by default set to be a matrix with patRec.nOuts columns and bufferSize row. The bufferSize value can either be set as a parameter or an internal property to the algorithm.

  * patRec.controlAlg.parameters.bufferSize
  * patRec.controlAlg.prop.bufferSize

If the bufferSize is a parameter, it should be set with a default value in ValidControlAlgs.txt. If the bufferSize is an internal property, it should be set in an initialization file named Init'YourControlAlg'.m that takes a !patRec struct as input and gives it back as an output. If neither a parameter nor a property named bufferSize exists the output buffer is initialized with only one row.

## Control Algorithms Implemented in Future Releases ##

  * [MajorityVote](MajorityVote.md)
  * [MajorityVoteSimultaneous](MajorityVoteSimultaneous.md)
  * [BayesianFusion](BayesianFusion.md)
  * [Ramp](Ramp.md)
  * [RampModified](RampModified.md)
  * [CombinedControl](CombinedControl.md)

A run down of the concept behind these algorithm is given in [ControlAlgorithmsExample](ControlAlgorithmsExample.md).