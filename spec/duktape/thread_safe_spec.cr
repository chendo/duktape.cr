require "../spec_helper"
require "../../src/duktape/runtime"

# This spec is meant to be run with -D preview_mt
# i.e. crystal run -D preview_mt ./spec/duktape/thread_safe_spec.cr
describe Duktape::Runtime do
  ctx = Duktape::Context.new

  context "thread-safety" do
    describe "push_global_proc" do
      it "should not crash when called from multiple threads" do
        ctx.push_global_proc("add_one", 1) do |ptr|
          env = Duktape::Context.new ptr
  
          begin
            num = env.require_number 0
          rescue Duktape::TypeError
            next env.call_failure :type
          end
  
          env << num + 1
          env.call_success
        end
  
        100.times do
          spawn do
            rc = ctx.eval!("add_one(42);")
  
            rc.should eq(0)
            ctx.is_error(-1).should be_false
            ctx.get_number(-1).should eq(43)
          end
        end
        sleep(1)
      end
    end
  end
end
