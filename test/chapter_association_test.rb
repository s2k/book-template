require 'minitest/autorun'

BOOK_FILE    = 'manuscript/Book.txt'
PREVIEW_FILE = 'manuscript/Subset.txt'

def chapter_files(book_files)
  book_files.grep(/\Achapter-\d+.md$/).map(&:strip)
end

def book_info_table_from(book_info_file)
  book_info_file.lines[2..-1].map { |ln| ln.split(/\s*\|\s*/)[1..-1] }
end

def read(fn)
  File.readlines(fn, chomp: true)
end

class TestHelperMethods < Minitest::Test
  def test_book_chapter_filenames_follow_naming_convention
    assert chapter_files(read(BOOK_FILE)).all? { |chapter_fn| chapter_fn.match?(/\Achapter-\d+\.md\Z/) }
  end

end

class TestChapterAssociationTest < MiniTest::Test
  def setup
    @invitees_file = File.read('book_info.md')
    @assigned_chapters = @invitees_file.scan(/\[\]\(manuscript\/chapter-(\d\d)\.md\)/).flatten
  end

  def test_no_duplicate_chapters
    assert_equal @assigned_chapters, @assigned_chapters.uniq
  end

  def test_invitations_and_preview_contain_same_chapters
    preview_chapters = File.readlines(PREVIEW_FILE).map(&:strip).sort
    assert_path_exists 'manuscript/frontmatter.md'
    assert_includes preview_chapters, 'frontmatter.md'
    assert_equal chapter_files(preview_chapters), @assigned_chapters.map { |ch| "chapter-#{ch}.md" }.sort
  end

  def test_book_file_contains_only_published_chapters
    book_chapters = read(BOOK_FILE).sort
    assert_equal 'frontmatter.md', book_chapters.delete('frontmatter.md')
    publish_info = @invitees_file.lines.map { |ln| ln.split(/\s*\|\s*/)}.map{ |entries| [ entries[1], entries[-2], entries[-1]] }
    publish_ready_chapters = publish_info.select { |_,_, s| 'Publish' == s }.map {|_,c,_| c[/chapter-\d+\.md/] }.sort
    assert_equal book_chapters, publish_ready_chapters
  end

  def test_book_file_chapter_order_is_same_as_invitees_file_order
    book_chapters = chapter_files(File.readlines(BOOK_FILE, chomp: true))
    published_chapter_order = book_info_table_from(@invitees_file).select { |entry| entry[3] == 'Publish'}.flat_map { |e| e[2].scan(/chapter-\d+\.md/) }
    assert_equal book_chapters, published_chapter_order, "The Chapters in the book should have the same order as in the book info table, but don't."
  end
end
