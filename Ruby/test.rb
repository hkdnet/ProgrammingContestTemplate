require 'open3'
#
# hogefuga
#
class Hoge
  def initialize
    @current = ".\\#{File.dirname(__FILE__)}"
  end

  def exec
    in_dir, out_dir = inout
    files(in_dir).zip(files(out_dir)).each do |fs|
      p "#{success?(fs[0], fs[1]) ? 'Success' : 'Failed'}: case#{fs[0]}"
    end
  end

  def inout
    ["#{@current}\\in", "#{@current}\\out"]
  end

  def files(dir_path)
    ret = []
    Dir.open(dir_path).each do |f|
      ret << "#{dir_path}\\#{f}" unless /^\./.match(f)
    end
    ret
  end

  def success?(input, output)
    actual = result(input)
    expected?(output, actual)
  end

  def result(input)
    ans = "#{@current}\\ans.rb"
    req = "#{@current}\\stdin_file.rb"
    cmd = "ruby -r#{req} #{ans} #{input}"
    stdout, stderr, status = Open3.capture3(cmd)
    if status.exitstatus != 0
      info = "case #{input}, err: #{stderr} status:#{status}"
      fail "TestFailed - RuntimeError: #{info}"
    end
    stdout
  end

  def expected?(expected_file, actual)
    expected = File.open(expected_file).read
    return true if expected == actual
    if actual.split("\n").size > 20
      puts 'output is too long to show'
    else
      puts 'actual--------------------', actual, 'expected----------------', expected
    end
    false
  end
end

Hoge.new.exec
