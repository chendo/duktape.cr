require "../spec_helper"
require "../../src/duktape/runtime"

# This spec is meant to be run with -D preview_mt
# i.e. crystal run -D preview_mt ./spec/duktape/thread_safe_spec.cr
describe Duktape::Runtime do
  ctx = Duktape::Context.new

  context "thread-safety" do
    describe "push_global_proc" do
      it "should not crash when called from multiple threads" do
        ctx.push_global_proc("sleep", 1) do |ptr|
          env = Duktape::Context.new ptr
  
          begin
            num = env.require_number 0
          rescue Duktape::TypeError
            next env.call_failure :type
          end
  
          print "."
          sleep(num)
          env.call_success
        end
  
        100.times do
          spawn do
            rc = ctx.eval!("sleep(0.01);")
          end
        end

        sleep(1)
      end
    end
  end
end
