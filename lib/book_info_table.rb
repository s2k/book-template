require 'forwardable'

# Turn Markup file into an Array of Hashes that
# can be easily iterated over & selected form
#
class BookInfoTable

  extend Forwardable

  attr_reader :table

  def_delegators :@table, :size

  def initialize(file_name)
    @lines = File.readlines(file_name, chomp: true)
    headers = split_row(lines.first)
    @table = lines[2..-1].map{|line| Hash[headers.zip split_row(line)]}
  end

  def each_chapter_info
    table.each
  end

  private

  attr_reader :lines

  def split_row(raw_row)
    raw_row.scan(/[^|]+/).map(&:strip)
  end

end
