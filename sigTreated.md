[recSession](recSession.md) -> [sigTreated](sigTreated.md) -> [sigFeatures](sigFeatures.md) -> [patRec](patRec.md)

# sigTreated #
  * sF (sampling frequency)
  * sT (sampling time)
  * cT (contraction time)
  * rT (relaxation time)
  * nM (number of movements)
  * nR (number of repetitions)
  * nCh (number of channels)
  * dev (device used for recordings)
  * mov (description of the movements performed)
  * date
  * cmt (comments)
  * cTp (contration time percentage)
  * trData (data extracted using the cTp, initial Samples x Ch x Mov)

  * fFilter (frequency filter)
    * PLH (power line harmonics)
    * BP (predifined band-pass filter)
  * sFilter (spatial filter)
    * DDF (double differential)
    * TDF (triple differential)

  * eCt (effective contraction time)
  * tw (time window)
  * nw (number of window)
  * trSets (training sets, number)
  * vSets (validation sets, number)
  * tSets (testing sets, number)

  * twSegMethod (time window segmentation method)
    * Non Overlapped
    * Overlapped Cons (consecutive)
    * Overlapped Rand (random)

  * trData (Training data (samples x Ch x Mov x time window number)
  * vData (Validation data (samples x Ch x Mov x time window number)
  * tData (Test data (samples x Ch x Mov x time window number)


This structure is comming from [recSession](recSession.md), which has tData instead of trData. tData is the raw recorded data whereas trData is the treated data. This structure is created initially in RemoveTrasient\_cTp which adds cTp and the corresponding data from tData to trData (see [BioPatRec\_Roadmap](BioPatRec_Roadmap.md))

Once the time window segmentation method is defined, trData (samples x channels x movements) is substituted by trData (samples x channels x movements x windows), and the equivalent of validation and test are created (vData and tData)

This structure is send to the GetAllSigFeatures in order to obtaine the signal features which are store in the structure [sigFeatures](sigFeatures.md).