require "./can_parser.rb"

module RefineLog
  def RefineLog.refine_bms(bms)
    if !bms.nil? and !bms.empty?
      bms_list = bms.split("/")
      # bms_list = bms.split("|")
      # bms_list = bms_list.drop(1)

      summary = bms_list.shift
      value = bms_list.shift
      voltage = bms_list.shift
      temperature = bms_list.shift
      position = bms_list.shift
      event = bms_list.shift
      current_adc = bms_list.shift
      current = bms_list.shift
      balancing = bms_list.shift
      etc = bms_list.shift
      module_temperature_list = bms_list.shift

      summary = CanParser.refine_summary(summary)
      value = CanParser.refine_value(value)
      voltage = CanParser.refine_voltage(voltage)
      temperature = CanParser.refine_temperature(temperature)
      position = CanParser.refine_position(position)
      event = CanParser.refine_event(event)
      current_adc = CanParser.refine_current_adc(current_adc)
      current = CanParser.refine_current(current)
      balancing = CanParser.refine_balancing(balancing)
      etc = CanParser.refine_etc(etc)

      # 290
      module_temperature_list = CanParser.refine_module_temperature(module_temperature_list)

      # module_voltage_list = []
      # bms_list.each { |bms|
      #   module_voltage = CanParser.refine_module_voltage(bms)
      #   module_voltage_list << module_voltage
      # }

      result_bms = {
        "summary" => summary,
        "value" => value,
        "temperature" => temperature,
        "event" => event,
        "etc" => etc,
        # "module_voltage_list" => module_voltage_list
        "module_temperature_list" => module_temperature_list
      }

      return result_bms
    else
      return ""
    end
  end

  def RefineLog.refine_gps(gps)
    if !gps.nil? and !gps.empty?
    gps = gps[0, gps.length].split("/")
      #  gps = gps[2, gps.length].split("|")
     gps = {"lat" => gps[0], "lon" => gps[1]}
    else
      gps = {"lat" => 0.0, "lon" => 0.0}
    end
    return gps
  end

  def RefineLog.refine_time(now ,time)
    
    if !time.nil? and !time.empty?
      time = time[2, time.length]
      h = time[0..1]
      m = time[2..3]
      s = time[4..5]
      # puts "#{h}:#{m}:#{s}"
      bms_time = Time.new(now.year, now.month, now.day, h.to_i, m.to_i, s.to_i, "+09:00")
      # bms_time = bms_time.strftime("%Y-%m-%d %H:%M:%S +09:00").to_s
      return bms_time
    else
      return now
    end

  end

end
