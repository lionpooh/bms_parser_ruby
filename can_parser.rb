module CanParser
  def CanParser.refine_summary(summary)
    # soc 0 / 16
    soc = summary[0..3]
    soc_2 = soc[0..1]
    soc_1 = soc[2..3]
    soc = soc_1 + soc_2
    soc = soc.to_i(16) * 0.1

    # usedCount 2 / 16
    used_count = summary[4..7]
    used_count_2 = used_count[0..1]
    used_count_1 = used_count[2..3]
    used_count = used_count_1 + used_count_2
    used_count = used_count.to_i(16) * 0.1

    # fault, fault, charge finished, charging / 4
    warn_fault_cf_c = summary[8..9]
    warn_fault_cf_c = warn_fault_cf_c.to_i(16).to_s(2).rjust(8, "0")

    # fault 0
    warn = warn_fault_cf_c[0]

    # fault 1..2 (0: normal / 1: fault / 2: fault)
    fault = warn_fault_cf_c[1..2].to_i(2)

    # charge finished 3
    charge_finished = warn_fault_cf_c[3]

    # charging 4
    charging = warn_fault_cf_c[4]

    # puts "#{warn}, #{fault}, #{charge_finished}, #{charging}"

    # Main + Relay, Main - Relay, Precharge Relay, Charge Relay
    mpr_mmr_pr_cr = summary[10..11]
    mpr_mmr_pr_cr = mpr_mmr_pr_cr.to_i(16).to_s(2).rjust(8, "0")

    # Main + Relay 0
    mpr = mpr_mmr_pr_cr[0]

    # Main - Relay 1
    mmr = mpr_mmr_pr_cr[1]

    # Precharge Relay 2
    pr = mpr_mmr_pr_cr[2]

    # Charge Relay 3
    cr = mpr_mmr_pr_cr[3]

    # puts "#{mpr}, #{mmr}, #{pr}, #{cr}"

    # Ignition, Charger Signal
    ig_cs = summary[12..13]
    ig_cs = ig_cs.to_i(16).to_s(2).rjust(8, "0")

    # Ignition
    ig = ig_cs[0]

    # Charger Signal
    cs = ig_cs[1]

    # SubMode, Mode
    sbmod_mod = summary[14..15]
    sbmod_mod = sbmod_mod.to_i(16).to_s(2).rjust(8, "0")

    # SubMode
    sbmod = sbmod_mod[0..3].to_i(2)

    # Mode
    mod = sbmod_mod[4..7].to_i(2)
    
    result_summary = {
      "soc" => soc,
      "used_count" => used_count,
      "warn" => warn,
      "fault" => fault,
      "charge_finished" => charge_finished,
      "charging" => charging,
      "main+relay" => mpr,
      "main-relay" => mmr,
      "precharge_relay" => pr,
      "charge_relay" => cr,
      "ignition" => ig,
      "charger_signal" => cs,
      "sub_mode" => sbmod,
      "mod" => mod
    }

    return result_summary
  end

  def CanParser.refine_value(value)
    # Volt
    volt = value[0..3]
    volt = ParserUtils.reverse_hex_to_i(volt) * 0.1
    
    # Curr
    curr = value[4..7]
    curr = ParserUtils.reverse_hex_to_i(curr)
    curr = curr.to_s(2).rjust(16, "0");
    curr = ParserUtils.two_complement(curr, 0xFFFF) * 0.1
    
    # Dc_LimitCurrent
    dc_limit_current = value[8..11]
    dc_limit_current = ParserUtils.reverse_hex_to_i(dc_limit_current) * 0.1
    
    # C_LimitCurrent
    c_limit_current = value[12..15]
    c_limit_current = ParserUtils.reverse_hex_to_i(c_limit_current) * 0.1

    result_value = {
      "volt" => volt,
      "curr" => curr,
      "dc_limit_current" => dc_limit_current,
      "c_limit_current" => c_limit_current
    }

    return result_value
  end

  # 205
  def CanParser.refine_voltage(voltage)
    # Module max volt
    module_max_volt = voltage[0..3]
    module_max_volt = ParserUtils.reverse_hex_to_i(module_max_volt) * 0.001

    # Module min volt
    module_min_volt = voltage[4..7]
    module_min_volt = ParserUtils.reverse_hex_to_i(module_min_volt) * 0.001

    # Module ave volt
    module_ave_volt = voltage[8..11]
    module_ave_volt = ParserUtils.reverse_hex_to_i(module_ave_volt) * 0.001

    result_voltage = {
      "module_max_volt" => module_max_volt,
      "module_min_volt" => module_min_volt,
      "module_ave_volt" => module_ave_volt
    }

    return result_voltage
  end

  # 207
  def CanParser.refine_temperature(temperature)
    # Module max temp
    module_max_temp = temperature[0..1].to_i(16).to_s(2).rjust(8, "0")
    module_max_temp = ParserUtils.two_complement(module_max_temp, 0xFF)
    
    # Module min temp
    module_min_temp = temperature[2..3].to_i(16).to_s(2).rjust(8, "0")
    module_min_temp = ParserUtils.two_complement(module_min_temp, 0xFF)

    # Module ave temp
    module_ave_temp = temperature[4..5].to_i(16).to_s(2).rjust(8, "0")
    module_ave_temp = ParserUtils.two_complement(module_ave_temp, 0xFF)

    # Temp_0
    temp_0 = temperature[6..7].to_i(16).to_s(2).rjust(8, "0")
    temp_0 = ParserUtils.two_complement(temp_0, 0xFF)

    # Temp_1
    temp_1 = temperature[8..9].to_i(16).to_s(2).rjust(8, "0")
    temp_1 = ParserUtils.two_complement(temp_1, 0xFF)

    result_temperature = {
      "module_max_temp" => module_max_temp,
      "module_min_temp" => module_min_temp,
      "module_ave_temp" => module_ave_temp,
      "temp_0" => temp_0,
      "temp_1" => temp_1
    }

    return result_temperature
  end

  # 209
  def CanParser.refine_position(position)
    # Max Volt Pack Pos
    max_volt_pack_pos = position[0].to_i(16)
    
    # Min Volt Pack Pos
    min_volt_pack_pos = position[1].to_i(16)

    # Max Volt Module Pos
    max_volt_module_pos = position[2..5]
    max_volt_module_pos = ParserUtils.reverse_hex_to_i(max_volt_module_pos)

    # Min Volt Module Pos
    min_volt_module_pos = position[6..9]
    min_volt_module_pos = ParserUtils.reverse_hex_to_i(min_volt_module_pos)
  
    # Max Temp Pack Pos
    max_temp_pack_pos = position[10].to_i(16)
    
    # Min Temp Pack Pos
    min_temp_pack_pos = position[11].to_i(16)
    
    # Max Temp Module Pos
    max_temp_module_pos = position[12..13].to_i(16)

    # Min Temp Module Pos
    min_temp_module_pos = position[14..15].to_i(16)

    result_position = {
      "max_volt_pack_pos" => max_volt_pack_pos,
      "min_volt_pack_pos" => min_volt_pack_pos,
      "max_volt_module_pos" => max_volt_module_pos,
      "min_volt_module_pos" => min_volt_module_pos,
      "max_temp_pack_pos" => max_temp_pack_pos,
      "min_temp_pack_pos" => min_temp_pack_pos,
      "max_temp_module_pos" => max_temp_module_pos,
      "min_temp_module_pos" => min_temp_module_pos
    }
  end

  # 211
  def CanParser.refine_event(event)
    warning_0 = event[0..1].to_i(16).to_s(2).rjust(8, "0")
    warning_module_ovp = warning_0[0].to_i()
    warning_module_uvp = warning_0[1].to_i()
    warning_module_dc_otp = warning_0[2].to_i()
    warning_module_dc_utp = warning_0[3].to_i()
    warning_module_c_otp = warning_0[4].to_i()
    warning_module_c_utp = warning_0[5].to_i()
    warning_module_difference = warning_0[6].to_i()
    warning_ovp = warning_0[7].to_i()

    warning_1 = event[2..3].to_i(16).to_s(2).rjust(8, "0")
    warning_uvp = warning_1[0].to_i()
    warning_otp = warning_1[1].to_i()
    warning_utp = warning_1[2].to_i()
    warning_c_ocp = warning_1[3].to_i()
    warning_dc_ocp = warning_1[4].to_i()
    warning_low_soc = warning_1[5].to_i()
    warning_contctor = warning_1[6].to_i()
    warning_slave_comm = warning_1[7].to_i()

    warning_2 = event[4..5].to_i(16).to_s(2).rjust(8, "0")
    warning_slave_contactor_count = warning_2[0].to_i()
    warning_int_otp = warning_2[1].to_i()
    warning_ic_otp = warning_2[2].to_i()
    warning_switch_otp = warning_2[3].to_i()
    warning_ntc_disconnect = warning_2[4].to_i()

    fault_0 = event[8..9].to_i(16).to_s(2).rjust(8, "0")
    fault_module_ovp = fault_0[0].to_i()
    fault_module_uvp = fault_0[1].to_i()
    fault_module_dc_otp = fault_0[2].to_i()
    fault_module_dc_utp = fault_0[3].to_i()
    fault_module_c_otp = fault_0[4].to_i()
    fault_module_c_utp = fault_0[5].to_i()
    fault_module_difference = fault_0[6].to_i()
    fault_ovp = fault_0[7].to_i()

    fault_1 = event[10..11].to_i(16).to_s(2).rjust(8, "0")
    fault_uvp = fault_1[0].to_i()
    fault_otp = fault_1[1].to_i()
    fault_utp = fault_1[2].to_i()
    fault_c_ocp = fault_1[3].to_i()
    fault_dc_ocp = fault_1[4].to_i()
    fault_low_soc = fault_1[5].to_i()
    fault_contctor = fault_1[6].to_i()
    fault_slave_comm = fault_1[7].to_i()

    fault_2 = event[12..13].to_i(16).to_s(2).rjust(8, "0")
    fault_slave_contactor_count = fault_2[0].to_i()
    fault_int_otp = fault_2[1].to_i()
    fault_ic_otp = fault_2[2].to_i()
    fault_switch_otp = fault_2[3].to_i()
    fault_ntc_disconnect = fault_2[4].to_i()

    result_event = {
      "warning_module_ovp" => warning_module_ovp,
      "warning_module_uvp" => warning_module_uvp,
      "warning_module_dc_otp" => warning_module_dc_otp,
      "warning_module_dc_utp" => warning_module_dc_utp,
      "warning_module_c_otp" => warning_module_c_otp,
      "warning_module_c_utp" => warning_module_c_utp,
      "warning_module_difference" => warning_module_difference,
      "warning_ovp" => warning_ovp,
      "warning_uvp" => warning_uvp,
      "warning_otp" => warning_otp,
      "warning_utp" => warning_utp,
      "warning_c_ocp" => warning_c_ocp,
      "warning_dc_ocp" => warning_dc_ocp,
      "warning_low_soc" => warning_low_soc,
      "warning_contctor" => warning_contctor,
      "warning_slave_comm" => warning_slave_comm,
      "warning_slave_contactor_count" => warning_slave_contactor_count,
      "warning_int_otp" => warning_int_otp,
      "warning_ic_otp" => warning_ic_otp,
      "warning_switch_otp" => warning_switch_otp,
      "warning_ntc_disconnect" => warning_ntc_disconnect,
      "fault_module_ovp" => fault_module_ovp,
      "fault_module_uvp" => fault_module_uvp,
      "fault_module_dc_otp" => fault_module_dc_otp,
      "fault_module_dc_utp" => fault_module_dc_utp,
      "fault_module_c_otp" => fault_module_c_otp,
      "fault_module_c_utp" => fault_module_c_utp,
      "fault_module_difference" => fault_module_difference,
      "fault_ovp" => fault_ovp,
      "fault_uvp" => fault_uvp,
      "fault_otp" => fault_otp,
      "fault_utp" => fault_utp,
      "fault_c_ocp" => fault_c_ocp,
      "fault_dc_ocp" => fault_dc_ocp,
      "fault_low_soc" => fault_low_soc,
      "fault_contctor" => fault_contctor,
      "fault_slave_comm" => fault_slave_comm,
      "fault_slave_contactor_count" => fault_slave_contactor_count,
      "fault_int_otp" => fault_int_otp,
      "fault_ic_otp" => fault_ic_otp,
      "fault_switch_otp" => fault_switch_otp,
      "fault_ntc_disconnect" => fault_ntc_disconnect
    }

    return result_event
  end

  def CanParser.refine_current_adc(current_adc)
    adc_low = current_adc[0..3]
    adc_low = ParserUtils.reverse_hex_to_i(adc_low)
    
    adc_high = current_adc[4..7]
    adc_high = ParserUtils.reverse_hex_to_i(adc_high)
    
    result_current_adc = {
      "adc_low" => adc_low,
      "adc_high" => adc_high
    }

    return result_current_adc
  end

  def CanParser.refine_current(current)
    current_low = current[0..7]
    current_low = ParserUtils.reverse_hex_to_i(current_low)
    current_low = current_low.to_s(2).rjust(32, "0")
    current_low = ParserUtils.two_complement(current_low, 0xFFFFFFFF) * 0.001

    current_high = current[8..15]
    current_high = ParserUtils.reverse_hex_to_i(current_high)
    current_high = current_high.to_s(2).rjust(32, "0")
    current_high = ParserUtils.two_complement(current_high, 0xFFFFFFFF) * 0.001

    result_current = {
      "current_low" => current_low,
      "current_high" => current_high
    }

    return result_current
  end

  def CanParser.refine_balancing(balancing)
    balancing_on_off = balancing[0..1].to_i(16).to_s(2).rjust(8, "0")
    balancing_of_off = balancing_on_off[0].to_i()

    balancing_target = balancing[2..5]
    balancing_target = ParserUtils.reverse_hex_to_i(balancing_target)

    balancing_limit = balancing[6..9]
    balancing_limit = ParserUtils.reverse_hex_to_i(balancing_limit)

    start_gap = balancing[10..11].to_i(16)
    end_gap = balancing[12..13].to_i(16)
    balancing_wait_count = balancing[14..15].to_i(16)
    
    result_balancing = {
      "balancing_on_off" => balancing_on_off,
      "balancing_target" => balancing_target,
      "balancing_limit" => balancing_limit,
      "start_gap" => start_gap,
      "end_gap" => end_gap,
      "balancing_wait_count" => balancing_wait_count
    }

    return result_balancing
  end
  
  def CanParser.refine_etc(etc)
    etc = etc[0..7].to_i(16)
    return etc
  end

  def CanParser.refine_module_voltage(module_voltage)
    module_0 = module_voltage[0..3]
    module_0 = ParserUtils.reverse_hex_to_i(module_0) * 0.001
    
    module_1 = module_voltage[4..7]
    module_1 = ParserUtils.reverse_hex_to_i(module_1) * 0.001

    module_2 = module_voltage[8..11]
    module_2 = ParserUtils.reverse_hex_to_i(module_2) * 0.001

    module_3 = module_voltage[12..15]
    module_3 = ParserUtils.reverse_hex_to_i(module_3) * 0.001
    
    result_module_voltage = {
      "module_0" => module_0,
      "module_1" => module_1,
      "module_2" => module_2,
      "module_3" => module_3
    }
    return result_module_voltage
  end

  def CanParser.refine_module_temperature(module_temperature)
    temp_0 = module_temperature[0..1].to_i(16)
    temp_1 = module_temperature[2..3].to_i(16)
    temp_2 = module_temperature[4..5].to_i(16)
    temp_3 = module_temperature[6..7].to_i(16)
    temp_4 = module_temperature[8..9].to_i(16)
    temp_5 = module_temperature[10..11].to_i(16)
    temp_6 = module_temperature[12..13].to_i(16)
    temp_7 = module_temperature[14..15].to_i(16)
    result_module_temperature = {
      "temp_0" => temp_0,
      "temp_1" => temp_1,
      "temp_2" => temp_2,
      "temp_3" => temp_3,
      "temp_4" => temp_4,
      "temp_5" => temp_5,
      "temp_6" => temp_6,
      "temp_7" => temp_7
    }
    return result_module_temperature
  end
end

module ParserUtils
  def ParserUtils.reverse_hex_to_i(hex)
    return hex.scan(/../).reverse.join("").to_i(16)
  end
  
  def ParserUtils.two_complement(binary, f)
    fb = binary[0]
    target = binary.to_i(2)
    if fb == "1"
      result = ((target ^ f) + 1) * -1
    else 
      result = target
    end
    return result
  end
end