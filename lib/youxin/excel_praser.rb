module Youxin
  class ExcelPraser
    attr_accessor :file, :user_array, :worksheets

    def initialize(file)
      @file = file
      verify_file_type
      @user_array = []
    end

    def verify_file_type
      begin
        @worksheets = Spreadsheet.open(@file)
      rescue Exception => e
        raise Youxin::ExcelPraser::InvalidFileType
      end
    end

    def process
      # TODO: need test
      sheet = @worksheets.worksheet 0
      sheet.each 1 do |row|
        @user_array << {
          name: row[0],
          phone: row[1].is_a?(Float) ? row[1].to_i.to_s : row[1],
          email: row[2]
        }
      end
      self
    end
  end
end

module Exceptions
  class Youxin::ExcelPraser::InvalidFileType < StandardError
  end
end
