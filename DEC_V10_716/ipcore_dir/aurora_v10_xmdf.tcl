# The package naming convention is <core_name>_xmdf
package provide aurora_v10_xmdf 1.0

# This includes some utilities that support common XMDF operations
package require utilities_xmdf

# Define a namespace for this package. The name of the name space
# is <core_name>_xmdf
namespace eval ::aurora_v10_xmdf {
# Use this to define any statics
}

# Function called by client to rebuild the params and port arrays
# Optional when the use context does not require the param or ports
# arrays to be available.
proc ::aurora_v10_xmdf::xmdfInit { instance } {
# Variable containg name of library into which module is compiled
# Recommendation: <module_name>
# Required
utilities_xmdf::xmdfSetData $instance Module Attributes Name aurora_v10
}
# ::aurora_v10_xmdf::xmdfInit

# Function called by client to fill in all the xmdf* data variables
# based on the current settings of the parameters
proc ::aurora_v10_xmdf::xmdfApplyParams { instance } {

set fcount 0
# Array containing libraries that are assumed to exist
# Examples include unisim and xilinxcorelib
# Optional
# In this example, we assume that the unisim library will
# be magically
# available to the simulation and synthesis tool
utilities_xmdf::xmdfSetData $instance FileSet $fcount type logical_library
utilities_xmdf::xmdfSetData $instance FileSet $fcount logical_library unisim
incr fcount





utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path aurora_v10_xmdf.tcl
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

































utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path aurora_v10/ucf/aurora_v10_aurora_sample.ucf
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount


utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path aurora_v10/ucf/aurora_v10_aurora_sample.ucf
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount







































utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path aurora_v10/ucf/aurora_v10.ucf
utilities_xmdf::xmdfSetData $instance FileSet $fcount type ucf
incr fcount




utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path aurora_v10/ucf/aurora_v10.ucf
utilities_xmdf::xmdfSetData $instance FileSet $fcount type ucf
incr fcount

























utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path aurora_v10/implement/config.csh
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount






















































utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path aurora_v10/readme.txt
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

























































utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path aurora_v10/implement/sample_test.do
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount















































utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path aurora_v10/testbench/test_vectors2.vec
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path aurora_v10/testbench/test_vectors.vec
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount
































utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path aurora_v10/testbench/abfm_tx_nfc_frames.dat
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount



utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path aurora_v10/testbench/abfm_tx_ufc_frames.dat
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path aurora_v10/testbench/abfm_tx_pdu_frames.dat
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount






















utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path aurora_v10/implement/sample_wave.do
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount



}

# ::gen_comp_name_xmdf::xmdfApplyParams
