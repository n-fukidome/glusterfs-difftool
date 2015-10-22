require 'fileutils'
require 'digest'
require 'time'
require 'logger'
require 'find'
require 'json'

require 'bundler'
Bundler.require

require 'active_support/core_ext/hash'

class Lister
  attr_accessor :dryrun

  def initialize(list_files: [], root: nil)
    @list_files = list_files
    @root       = root
    log "set #{@root}"
  end

  def log(msg, level: :info)
    logger.send(level, msg)
  end

  def logger
    @logger ||= ::Logger.new(STDERR)
  end

  def make_list
    t0 = Time.now
    log "START #{__method__}".yellow

    root = @root
    filename = @list_files.first

    File.open(filename, 'w') do |ofile|
      count = 0
      Find.find(root) do |path|
        next if not FileTest.readable? path

        is_dir     = FileTest.directory? path
        is_symlink = FileTest.symlink? path

        stat   = File.stat(path)
        ctime  = stat.ctime
        mtime  = stat.mtime
        size   = stat.size
        mode   = stat.mode
        uid    = stat.uid
        gid    = stat.gid

        entry = {
          size:   size, 
          ctime:  ctime,
          mtime:  mtime,
          path:   path,
          mode:   mode,
          type:   is_symlink ? 'l' : (is_dir ? 'd' : 'f')
        }

        ofile.puts entry.to_json

        count += 1
        log "#{__method__}: DONE #{count}" if (count % 1000) == 0
      end

      t1 = Time.now
      log "FINISH #{__method__} #{t1-t0}".yellow
    end
  end

  def read_lists
    t0 = Time.now
    log "START #{__method__}".yellow

    @lists = {}

    @list_files.each_with_index do |list_file,i|
      list = {}
      File.open(list_file, 'r') do |f|
        count = 0
        f.each_line do |l|
          entry = parse_line(l)

          list[ entry[:path] ] = entry
          count += 1
        end
        fail if count != list.count
      end

      @lists[i] = list
      log "READ #{list_file} list: #{list.count}".blue
    end

    t1 = Time.now
    log "FINISH #{__method__} #{t1-t0}".yellow
  end

  def parse_line(line)
    entry = JSON.parse(line).deep_symbolize_keys
    entry[:mtime] = Time.parse entry[:mtime]
    entry[:ctime] = Time.parse entry[:ctime]

    entry
  end

  def compute_diff(ofile_name)
    t0 = Time.now
    log "START #{__method__}".yellow
    @only0       = {}
    @only1       = {}
    @both01_iden = {}
    @both01_diff = {}

    list0 = @lists[0]
    list1 = @lists[1]

    # CHECK LIST 0 with LIST 1
    list0.each do |path0,meta0|
      meta1 = list1[path0]
      if meta1 # FOUND IN LIST 1
        if same?(meta0, meta1)
          @both01_iden[path0] = [meta0, meta1]
        else
          @both01_diff[path0] = [meta0, meta1]
        end
      else
        @only0[path0] = [meta0]
      end
    end

    # CHECK LIST 1 with LIST 0
    list1.each do |path1,meta1|
      meta0 = list0[path1]
      begin
        if meta0 # FOUND IN LIST 0
          if same?(meta1, meta0)
            fail if not @both01_iden[path1]
          else
            fail if not @both01_diff[path1]
          end
        else
          @only1[path1] = [meta1]
        end
      rescue => e
        puts meta0, meta1
      end
    end

    log "FOUND ONLY #{@list_files[0]} #{@only0.count}".blue
    log "FOUND ONLY #{@list_files[1]} #{@only1.count}".red
    File.open("ONLY_#{ofile_name}", "w") do |f|
      target_lists = @only0.count > @only1.count ? @only1 : @only0
      target_lists.each{|k,v| f.puts('"' + v.first[:path] + '"')}
    end
    log "FOUND BOTH(IDENTICAL) #{@list_files} #{@both01_iden.count}".blue
    log "FOUND BOTH(DIFFERENT) #{@list_files} #{@both01_diff.count}".red

    t1 = Time.now
    log "FINISH #{__method__} #{t1-t0}".yellow
  end

  def same?(meta0, meta1)
    return false unless meta0[:type] == meta1[:type]
    if meta0[:type] == 'd'
      true # meta0[:path] == meta1[:path]
    else
      meta0[:size] == meta1[:size]
    end
  end

  # def output_only0(ofile = STDOUT)
  #   title = "FOUND ONLY #{@list_files[0]}"
  #   ofile.puts "<<< #{title}: #{@only0.count} >>>"
  #   output_result("#{title}", @only0, ofile)
  # end

  # def output_only1(ofile = STDOUT)
  #   title = "FOUND ONLY #{@list_files[1]}"
  #   ofile.puts "<<< #{title}: #{@only1.count} >>>"
  #   output_result("#{title}", @only1, ofile)
  # end

  # def output_both01_iden(ofile = STDOUT)
  #   title = "FOUND BOTH(IDENTICAL) #{@list_files.join(' & ')}"
  #   ofile.puts "<<< #{title}: #{@both01_iden.count} >>>"
  #   # output_result("#{title}", @both01_iden, ofile)
  # end

  # def output_both01_diff(ofile = STDOUT)
  #   title = "FOUND BOTH(DIFFERENT) #{@list_files.join(' & ')}"
  #   ofile.puts "<<< #{title}: #{@both01_diff.count} >>>"
  #   output_result("#{title}", @both01_diff, ofile)
  # end

  # def output_result(tag, result, ofile)
  #   result.each do |k,v|
  #     ofile.puts '"' + v.first[:path] + '"'
  #   end
  # end

  def put_count(enterprise)
    puts "#{enterprise}, #{@both01_iden.count}, #{@both01_diff.count}, #{@only0.count}, #{@only1.count},"
  end
end

start_time = Time.now
puts "#{ARGV} #{start_time}"

action     = ARGV[0] || fail
target_list = ARGV[1] || fail

File.open(target_list, 'r') do |list|
  list.each_line do |line|  
    enterprise = line.gsub(/\n/, '')
    case action
    when 'list'
      list_file  = "lists/#{enterprise}_#{ARGV[2]}" || fail
      root       = ARGV[3] || fail

      lister = Lister.new(list_files: [list_file], root: "#{root}/#{enterprise}")

      lister.make_list
    when 'compare'
      list_file0 = "lists/#{enterprise}_#{ARGV[2]}" || fail
      list_file1 = "lists/#{enterprise}_#{ARGV[3]}" || fail
      # ofile      = "results/#{enterprise}_#{ARGV[4]}" || fail
      ofile_name = "#{ARGV[4]}" || fail

      lister = Lister.new(list_files: [list_file0, list_file1])

      lister.read_lists
      lister.compute_diff ofile_name
      # File.open(ofile, 'w') do |f|
      #   lister.output_only0(f)
      #   lister.output_only1(f)
      #   lister.output_both01_iden(f)
      #   lister.output_both01_diff(f)
      # end
      lister.put_count enterprise
    end
  end
end

end_time = Time.now
puts "END #{end_time - start_time}"