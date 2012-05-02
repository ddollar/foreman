require 'spec_helper'
require 'foreman/procfile_entry'
require 'pathname'
require 'tmpdir'

describe Foreman::ProcfileEntry do
  subject { described_class.new('alpha', './alpha') }

  it "stringifies as a Procfile line" do
    subject.to_s.should == 'alpha: ./alpha'
  end

end
