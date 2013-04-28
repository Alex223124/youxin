module Youxin
  class ExcelPraser
    attr_accessor :file, :file_path, :user_array

    def initialize(file_path)
      raise Youxin::ExcelPraser::InvalidFilePath if file_path.is_a?(String)
      @file_path = file_path
      verify_file_type
      @user_array = []
    end

    def verify_file_type
      begin
        @file = Spreadsheet.open(@file_path.to_s)
      rescue Exception => e
        raise Youxin::ExcelPraser::InvalidFileType
      end
    end

    def process
      sheet = @file.worksheet 0
      sheet.each 1 do |row|
        @user_array << {
          name: row[0],
          email: row[1],
          password: row[2].is_a?(Float) ? row[2].to_i.to_s : row[2]
        }
      end
    end
  end
end

module Exceptions
  class Youxin::ExcelPraser::InvalidFilePath < StandardError

  end
  class Youxin::ExcelPraser::InvalidFileType < StandardError
  end
end
