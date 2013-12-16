require 'spec_helper'

describe Bind do
  let(:bind) { build :bind }
  subject { bind }

  describe 'Association' do
    it { should belong_to(:user) }
  end

  describe 'Validation' do
    before(:each) do
      bind.save
    end
    it 'one baidu_user_id should be refered to one baidu_channel_id' do
      new_bind = Bind.new(baidu_user_id: bind.baidu_user_id, baidu_channel_id: bind.baidu_channel_id)
      new_bind.should have(1).error_on(:baidu_user_id)
    end
  end
end
