require "spec_helper"
require "foreman/tmux_engine"

describe "Foreman::TmuxEngine", :fakefs do
  subject { Foreman::TmuxEngine.new("Procfile", {}) }
  let(:session) { Time.now.to_i }

  before do
    any_instance_of(Foreman::TmuxEngine) do |engine|
      stub(engine).proctitle
      stub(engine).termtitle
    end
    Timecop.freeze(Time.now)
  end

  after do
    FileUtils.rm_f("foreman.#{session}.log")
    Timecop.return
  end

  describe "initialize" do
    describe "without an existing Procfile" do
      it "raises an error" do
        lambda { subject }.should raise_error
      end
    end

    describe "with a Procfile" do
      before { write_procfile }

      it "reads the processes" do
        subject.procfile["alpha"].command.should == "./alpha"
        subject.procfile["bravo"].command.should == "./bravo"
      end
    end
  end

  describe "start" do
    before do
      write_procfile
      @pid = fork do
        exec("tmux start-server")
      end
    end

    after do
      Process.waitpid(@pid)
      %x{tmux kill-session -t #{session} &> /dev/null}
    end

    it "creates a tmux session and attaches" do
      %x{tmux has-session -t #{session} &> /dev/null}
      $?.exitstatus.should == 1

      mock(Kernel).exec("tmux attach-session -t #{session}")
      subject.start

      %x{tmux has-session -t #{session}}
      $?.exitstatus.should == 0

      %x{tmux list-windows -t #{session}}.split("\n").map { |window|
        if window =~ /[0-9]+:\s(.+?)\s/
          $1
        end
      }.should == ["alpha.1", "bravo.1", "all"]
      sleep 1
      %x{tmux kill-session -t #{session}}
      output = %x[cat /tmp/foreman.#{session}.log]
      output.should =~ /alpha\.1.+\.\/alpha: No such file or directory/
      output.should =~ /bravo\.1.+\.\/bravo: No such file or directory/
    end
  end
end
