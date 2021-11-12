# frozen_string_literal: true

require 'pp'
require 'set'
require 'rake/testtask'

task default: %i[check_book_file check_references test]

desc 'Run the tests'
Rake::TestTask.new do |task|
  task.pattern = 'test/*_test.rb'
end

desc 'Print histogram of statuses'
task :status_histogram do
  pp status_histogram
end

desc 'Find the next free chapter file (if any)'
task :next_free_chapter do
  next_chapter = (possible_chapters - assigned_chapters).min
  if next_chapter.nil?
    puts 'All chapter files are already assigned.'
  else
    puts "Next Chapter Nr. #{next_chapter}  =>  #{chapter_filename(next_chapter)}  =>  #{formatted_chapter_reference(next_chapter)}"
  end
end

desc 'Check references'
task :check_references do
  if unused_ids.empty?
    puts 'No unused IDs found'
  else
    puts 'Unused IDs:'
    puts unused_ids.to_a
  end

  if missing_ids.empty?
    puts 'No missing IDs found'
  else
    puts 'Missing IDs:'
    puts missing_ids.to_a
  end
end

desc 'check whether all files in Boot.txt exist'
task :check_book_file do
  failed = false
  markup_filenames.each do |fn|
    if fn.match?(/^\s*#/)
      puts "Ignoring #{fn}"
      next
    elsif File.exist?(fn)
      next
    else
      puts "ERROR: Missing file #{fn}"
      failed = true
    end
  end
  if failed
    exit 1
  else
    puts 'Book.txt is looking good'
  end
end

def id_definitions
  id_definition  = /\{\s*id:\s*([-_0-9a-zA-Z]+).*\}/
  id_reference = /\{\s*#([-_0-9a-zA-Z]+)\s*.*\}/
  for_each_markup_file do |fn, id_defs|
    content = File.read(fn)
    id_defs.merge extract_from(content, id_definition)
    id_defs.merge extract_from(content, id_reference)
    id_defs
  end
end

def cross_links
  for_each_markup_file do |fn, id_defs|
    content = File.read(fn)
    id_defs.merge extract_from(content, /\[[^\]]+\]\(#([-_0-9a-zA-Z]+)\)/)
    id_defs
  end
end

def unused_ids
  cross_links - id_definitions
end

def missing_ids
  id_definitions - cross_links
end

def assigned_chapters
  extract_from(File.read('invitees.md'), /\[\]\(manuscript\/chapter-(\d\d)\.md\)/).map(&:to_i)
end

def possible_chapters
  puts Dir.pwd
  existing_chapter_files = Dir['manuscript/chapter-*.md']
  existing_chapter_files.map { |ch_fn|
    if (md = ch_fn.match(/(\d+)/))
      md[1].to_i
    else
      raise "File name error, can't find a number in '#{ch_fn}'"
    end
  }
end

def formatted_chapter_reference(chapter_nr)
  "[](manuscript/#{chapter_filename(chapter_nr)})"
end

def chapter_filename(chapter_nr)
  "chapter-#{'%02d' % chapter_nr}.md"
end

def invitees_table
  File.readlines('invitees.md').map(&:strip)[2..-1].map{ |ln| ln.split(/\s*\|\s*/) }
end

def status_histogram
  invitees_table.map { |ln| ln[7] }.each_with_object(Hash.new(0)) { |status, acc| acc[status.to_s.downcase] += 1 }
end

def markup_filenames(manuscript_folder: 'manuscript')
  book_filename = File.join(manuscript_folder, 'Book.txt')
  chapter_files = File.readlines(book_filename).map(&:strip)
  chapter_files.map { |c_fn| File.join(manuscript_folder, c_fn) }
end

def for_each_markup_file(&block)
  markup_filenames.each_with_object(Set.new, &block)
end

def extract_from(content, id_definition)
  content.scan(id_definition).flatten
end
