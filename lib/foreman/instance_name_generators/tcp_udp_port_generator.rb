require 'foreman'

module Foreman::InstanceNameGenerators
  class TCPUDPPortGenerator
    attr_accessor :engine, :base_port, :generator_idx

    # Create a TCP/UDP port number generator
    #
    # @param [Foreman::Engine]  engine        The +Engine+ using this generator
    # @param [Fixnum]           generator_idx The index of all generators of the same class (Counting from 1)
    #
    def initialize(engine, generator_idx)
      @engine        = engine
      @generator_idx = generator_idx.to_int
      @base_port     = (engine.options[:port] || engine.env["PORT"] || ENV["PORT"] || 5000).to_int
    end

    # Get the port for a given instance
    #
    # @param [Fixnum]           instance_idx  The instance index of the process (Counting from 1)
    #
    # @returns [Fixnum]         The port to use for this instance of this process
    #
    def [](instance_idx)
      base_port + (generator_idx * 100) + (instance_idx -1)
    end
  end
end
