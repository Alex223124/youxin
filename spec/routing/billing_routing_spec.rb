require 'spec_helper'

describe BillingController do
  it "to #sms" do
    get('/billing/sms').should route_to('billing#sms')
  end
  it "to #call" do
    get('/billing/call').should route_to('billing#call')
  end
  it "to #bill_summary" do
    get('/billing/bill_summary').should route_to('billing#bill_summary')
  end
end
