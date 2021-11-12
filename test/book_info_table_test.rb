require 'minitest/autorun'
require_relative '../lib/book_info_table'


class TestBookInfoTable < Minitest::Test
  def setup
    @bit = BookInfoTable.new(File.join(File.dirname(__FILE__), '..', 'book_info.md'))
  end

  def test_info_file_has_correct_number_of_entries
    assert @bit.size == 4
  end

  def test_all_info_rows_have_all_headers
    @bit.each_chapter_info do |ci|
      p ci
    end
  end
end
