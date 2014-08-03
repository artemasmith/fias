class DbfWrapper
  require 'dbf'

  def table
    @table
  end

  def initialize file_path
    @table = DBF::Table.new(file_path)
  end

  #count = [:first|:all] conditions - hash of search params
  def find_object count, conditions
    result = nil
    if conditions.class == Hash && conditions
      result = @table.find(count, conditions)
    else
      raise "Wrong input params, must be hash of table's search values - #{ conditions }"
    end
    result
  end
end

desc "Import all ADDROBJ district aolevel from ADDROBJ dbf of selected Region(). Use rake import path='Path to the DBF file' region='Digit region code'"
task import: :environment do
  raise "Should specify path to dbf file" if ENV['path'].blank?
  raise "Should specify regioncode" if ENV['region'].blank?

  db = DbfWrapper.new(ENV['path'])
  region = ENV['region']
  puts "start searching of #{ region }"
  parent = db.find_object(:first, { regioncode: region, aolevel: 1 })
  dbp = Location.create(title: "#{ parent.offname } #{ parent.shortname }",
                  translit: "#{ parent.offname } #{ parent.shortname }".parameterize.underscore, location_type: :region)

  db.table.each do |district|
    if district.parentguid == parent.aoguid && district.aolevel == 3
      Location.create(title: "#{ district.offname } #{ district.shortname }",
                      translit: "#{ district.offname } #{ district.shortname }".parameterize.underscore,
                      location_type: :district, location_id: dbp.id)
      puts "location added: #{ district[:offname] }"
    end
  end
end