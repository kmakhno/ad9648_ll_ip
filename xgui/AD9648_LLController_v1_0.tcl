# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "AdcRes" -parent ${Page_0}
  ipgui::add_param $IPINST -name "Cpha" -parent ${Page_0}
  ipgui::add_param $IPINST -name "Cpol" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RcvBits" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RxRegWidth" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TxRegWidth" -parent ${Page_0}


}

proc update_PARAM_VALUE.AdcRes { PARAM_VALUE.AdcRes } {
	# Procedure called to update AdcRes when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AdcRes { PARAM_VALUE.AdcRes } {
	# Procedure called to validate AdcRes
	return true
}

proc update_PARAM_VALUE.Cpha { PARAM_VALUE.Cpha } {
	# Procedure called to update Cpha when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.Cpha { PARAM_VALUE.Cpha } {
	# Procedure called to validate Cpha
	return true
}

proc update_PARAM_VALUE.Cpol { PARAM_VALUE.Cpol } {
	# Procedure called to update Cpol when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.Cpol { PARAM_VALUE.Cpol } {
	# Procedure called to validate Cpol
	return true
}

proc update_PARAM_VALUE.RcvBits { PARAM_VALUE.RcvBits } {
	# Procedure called to update RcvBits when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RcvBits { PARAM_VALUE.RcvBits } {
	# Procedure called to validate RcvBits
	return true
}

proc update_PARAM_VALUE.RxRegWidth { PARAM_VALUE.RxRegWidth } {
	# Procedure called to update RxRegWidth when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RxRegWidth { PARAM_VALUE.RxRegWidth } {
	# Procedure called to validate RxRegWidth
	return true
}

proc update_PARAM_VALUE.TxRegWidth { PARAM_VALUE.TxRegWidth } {
	# Procedure called to update TxRegWidth when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TxRegWidth { PARAM_VALUE.TxRegWidth } {
	# Procedure called to validate TxRegWidth
	return true
}


proc update_MODELPARAM_VALUE.AdcRes { MODELPARAM_VALUE.AdcRes PARAM_VALUE.AdcRes } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AdcRes}] ${MODELPARAM_VALUE.AdcRes}
}

proc update_MODELPARAM_VALUE.TxRegWidth { MODELPARAM_VALUE.TxRegWidth PARAM_VALUE.TxRegWidth } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TxRegWidth}] ${MODELPARAM_VALUE.TxRegWidth}
}

proc update_MODELPARAM_VALUE.RxRegWidth { MODELPARAM_VALUE.RxRegWidth PARAM_VALUE.RxRegWidth } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RxRegWidth}] ${MODELPARAM_VALUE.RxRegWidth}
}

proc update_MODELPARAM_VALUE.RcvBits { MODELPARAM_VALUE.RcvBits PARAM_VALUE.RcvBits } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RcvBits}] ${MODELPARAM_VALUE.RcvBits}
}

proc update_MODELPARAM_VALUE.Cpol { MODELPARAM_VALUE.Cpol PARAM_VALUE.Cpol } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.Cpol}] ${MODELPARAM_VALUE.Cpol}
}

proc update_MODELPARAM_VALUE.Cpha { MODELPARAM_VALUE.Cpha PARAM_VALUE.Cpha } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.Cpha}] ${MODELPARAM_VALUE.Cpha}
}

