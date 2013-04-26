require 'spec_helper'

describe Organization do
  let(:organization) { build :organization }
  subject { organization }

  describe "Respond to" do
    it { should respond_to(:name) }
    it { should respond_to(:parent) }
    it { should respond_to(:children) }
  end

  it "should create a new instance given a valid attributes" do
    expect(build :organization).to be_valid
  end

  describe "#parent" do
    it "should return nil if parent_id is nil" do
      organization.save
      organization.parent.should be_nil
    end
    it "should return parent if parent_id is not nil" do
      organization.save
      parent = organization
      child = create(:organization, parent_id: parent.id)
      child.parent.should == parent
    end
  end

  describe "#children" do
    it "should return children" do
      organization.save
      parent = organization
      organization1 = create :organization, parent: parent 
      organization2 = create :organization, parent: parent 
      parent.child_ids.should == [organization1.id, organization2.id]
    end
  end

  describe "attributes" do
    context "name" do
      describe "is blank" do
        before { organization.name = '' }
        its(:valid?) { should be_false }
      end
    end

    context "parent_id" do
      context "fails" do
      end

      context "successed" do
        describe "is blank" do
          before { organization.parent_id = '' }
          its(:valid?) { should be_true }
        end
        describe "is nil" do
          before { organization.parent_id = nil }
          its(:valid?) { should be_true }
        end
      end

    end
  end
end
