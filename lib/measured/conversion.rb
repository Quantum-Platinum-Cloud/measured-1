class Measured::Conversion
  ARBITRARY_CONVERSION_PRECISION = 20

  attr_reader :base_unit, :units

  def initialize(base_unit, units)
    @base_unit = base_unit
    @units = units.dup
    @units << @base_unit
  end

  def unit_names_with_aliases
    @unit_names_with_aliases ||= @units.flat_map(&:names).sort
  end

  def unit_names
    @unit_names ||= @units.map(&:name).sort
  end

  def unit_or_alias?(name)
    !!unit_for(name)
  end

  def unit?(name)
    unit = unit_for(name)
    unit ? unit.name_eql?(name) : false
  end

  def to_unit_name(name)
    unit_for!(name).name
  end

  def convert(value, from:, to:)
    from_unit = unit_for!(from)
    to_unit = unit_for!(to)
    conversion = conversion_table[from][to]

    raise Measured::UnitError, "Cannot find conversion entry from #{from} to #{to}" unless conversion

    BigDecimal(value.to_r * conversion, ARBITRARY_CONVERSION_PRECISION)
  end

  protected

  def conversion_table
    @conversion_table ||= Measured::ConversionTable.build(@units)
  end

  def unit_name_to_unit
    @unit_name_to_unit ||= @units.inject({}) do |hash, unit|
      unit.names.each { |name| hash[name.to_s] = unit }
      hash
    end
  end

  def unit_for(name)
    unit_name_to_unit[name.to_s]
  end

  def unit_for!(name)
    unit = unit_for(name)
    raise Measured::UnitError, "Cannot find unit for #{name}" unless unit
    unit
  end
end
